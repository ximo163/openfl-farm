package;

import haxe.io.Bytes;
import tools.MotionEnergy;
import tools.RenderHash;
import tools.RenderTypes.ShotImage;
import tools.SceneShotDiff;
import tools.SceneShotPlan;
import tools.SceneShotTypes.ShotSpec;

/**
 * T1b 场景视觉对拍——游戏进程内的视觉引导模块（issue #59，implement）。
 * 由 nodeboot --visual 在**游戏 bundle 之前**执行（tools/scenario.mjs 编译出
 * export/scenario-gate/visual-boot.js），把整个游戏进程改造成「可截图、可
 * 确定性连拍」的采集环境，API 挂 globalThis.__openflFarmVisual 供驱动侧
 * （scenario.mjs 的 drive）调用。
 *
 * 通道（复用 #57 的结论，不重新探路）：
 * - 截图 = SoftCanvas.installNode() + DecodingImage.install()：openfl 的
 *   CanvasRenderer 落到自研软画布，stage.__renderer.context 就是
 *   SoftCanvasContext，readPixelsStraight() 直读全画布真像素（PNG 真解码；
 *   JPEG format 无解码器 → 真实宽高 + 黑像素兜底，计数进 stats）。RenderProbe
 *   同款钩子，差别只在挂进的是整场游戏而不是单个符号实例。
 * - Math.random 换定种子 mulberry32（RenderProbe 同款 0x57）：原版帧脚本里
 *   的随机行为照常执行、每次取同值，自回归两侧才可比。
 *
 * 确定性虚拟钟（本模块的核心，为什么必须从 bundle 加载前就接管）：
 * - 游戏画面里到处是 ENTER_FRAME 驱动的动画（收获金币、作物摆动），真实
 *   墙钟下「两次运行在同一时刻拍了不同帧」——截图基线永远对不上。方案：
 *   游戏可见时间冻结，只在驱动显式 pump() 泵帧时前进（每帧
 *   1000/stage.frameRate 毫秒）。真实耗时（本地 HTTP 往返、php 渲染）发生在
 *   驱动的 await 里，游戏全程无感——应答处理跑在冻结的游戏时刻上，两次运行
 *   落在同一虚拟时刻。
 * - performance.now 必须在 bundle 静态初始化**前**打补丁：bundle 把
 *   `HxOverrides.now = performance.now.bind(performance)` 写在闭包里（外部
 *   够不到 HxOverrides 本体），绑定捕获的是「当时的函数」。晚了补丁就永远
 *   够不到它——Timer.stamp→As3.getTimer→GameTime 全线真钟。
 * - Date.now / new Date() 一并虚拟（fade、上报取时间的地方）；node 内部
 *   （HTTP 应答头）用的不是全局 Date，不受影响。
 * - setTimeout/setInterval 全量进虚拟队列（haxe.Timer 走 untyped setInterval、
 *   openfl Timer 走 window.setInterval、lime 帧循环走 nodeboot 的
 *   rAF→setTimeout(16)——js 的闭包变量在调用点解析到全局，包一层全收进来）。
 *   等待真实网络交付时驱动不泵帧 → 定时器不走 → 游戏状态冻结在应答前的样子。
 * - 泵帧语义（钉死，两侧同构）：每轮 virtualElapsed += 1 帧时长；然后按
 *   (due, 入队序) 依次触发到期定时器（rAF 的 16ms 定时器天然每轮触发一次 →
 *   lime 每泵恰渲染一帧、ENTER_FRAME 恰广播一次）。0 延迟同轮补发（重扫），
 *   interval 重排按「当前时刻 + 周期」（错过的不补——浏览器语义）。
 *
 * nodeboot 自身的看门狗/轮询/sleep 在 visual 模式下钉在真实计时引用上
 * （nodeboot.mjs 顶部捕获），不进虚拟域。
 *
 * API（globalThis.__openflFarmVisual，全是纯函数 + 状态查询）：
 * - bindStage(stage)：绑舞台句柄，按 stage.frameRate 校正帧时长（未绑时缺省
 *   1000/24——Project.xml fps=24；stage 句柄在 Main 首帧才出现，首帧只能用
 *   缺省值，帧率不是 24 时早引导帧的步长会偏差，stats 里带出实际值可查）。
 * - pump(n)/settle(n)：泵 n 帧（游戏时间 +n 帧）。
 * - shot()：截全舞台 → ShotImage 形状 {width, height, pixels}（RGBA 直色）。
 * - hash(img)：RenderHash.imageHash（#57 基线指纹同款）。
 * - burst(count, framesPerInterval)：连拍——首拍后每间隔泵 framesPerInterval
 *   帧再拍；返回 {frames, curve}（curve = MotionEnergy.curve）。
 * - frozenBurst(count)：冻住注入用——不泵帧连拍 count 张（同一画布连读，
 *   帧帧全同 → 能量全零），供 --self-check 证明门禁有牙。
 * - compareBurst(a, b)：SceneShotDiff.compareBurst（两级判定，供自检断言）。
 * - recordMatches(spec, frameCount, curveLength)：SceneShotDiff.recordMatches
 *   （连拍记录与声明的对齐门，驱动按步判红用——离线复验同语义）。
 * - specOf(checkpoint)：SceneShotPlan.specOfCheckpoint（视觉拍法解析，声明
 *   错直接抛——驱动按步失败处理）。
 * - framesForMs(ms)：intervalMs → 泵帧数（四舍五入）。
 * - stats()：泵帧/定时器触发数、帧时长、解码覆盖计数（盲区如实报告）。
 */
typedef VTimer = {
	id:Int,
	/** "timeout" | "interval" */
	kind:String,
	fn:Dynamic,
	/** 到期时刻（虚拟毫秒，相对冻结点）。 */
	due:Float,
	/** interval 周期（timeout 不用）。 */
	interval:Float,
	/** 全局入队序（同 due 先进先出的并列序）。 */
	seq:Int,
	/** 清除标记（触发中/排队中被 clear 都置真，interval 不再重排）。 */
	dead:Bool,
};

class ScenarioVisual {
	/** 游戏可见毫秒（performance.now 域）= 冻结锚点 + 泵过的帧时长累计。 */
	static var virtualElapsed:Float = 0;
	static var virtualBasePerf:Float = 0;
	static var virtualBaseDate:Float = 0;

	/** 舞台句柄（bindStage 绑定；截图与帧率都从它来）。 */
	static var stage:Dynamic = null;
	/** 泵帧步长（毫秒）。缺省 1000/24（Project.xml fps=24），bindStage 校正。 */
	static var frameStepMs:Float = 1000.0 / 24.0;
	static var pumpedFrames:Int = 0;
	static var timersFired:Int = 0;

	static var vtimers:Array<VTimer> = [];
	static var idMap:Map<Int, VTimer> = new Map();
	static var timerSeq:Int = 0;

	static function main():Void {
		// 渲染通道（#57 结论：node 里唯一的本地图通道）
		SoftCanvas.installNode();
		DecodingImage.install();
		DecodingImage.resetCounters();
		installDeterministicRandom();
		// 时钟/定时器接管（顺序：必须在游戏 bundle 之前，见类头）
		freezeClockAndWrapTimers();
		js.Syntax.code("globalThis.__openflFarmVisual = {0}", {
			bindStage: bindStage,
			pump: pump,
			settle: pump,
			shot: shot,
			hash: hash,
			burst: burst,
			frozenBurst: frozenBurst,
			compareBurst: compareBurst,
			recordMatches: recordMatches,
			specOf: specOf,
			framesForMs: framesForMs,
			stats: stats,
		});
	}

	// ---------------------------------------------------------------- 时钟

	static function virtualNowMs():Float {
		return virtualBasePerf + virtualElapsed;
	}

	static function virtualDateMs():Float {
		// Date.now 语义是整数毫秒；帧时长 1000/24 非整——floor 钉死跨跑一致
		return Math.floor(virtualBaseDate + virtualElapsed);
	}

	static function freezeClockAndWrapTimers():Void {
		// 留真实引用（驱动侧走 nodeboot 传的 realDateNow；本模块自身不计时）
		js.Syntax.code("(function(){
			globalThis.__svReal = {
				perfNow: globalThis.performance.now.bind(globalThis.performance),
				dateNow: Date.now.bind(Date),
				dateCtor: Date,
			};
		})()");
		var realPerfNow:Void->Float = js.Syntax.code("globalThis.__svReal.perfNow");
		var realDateNow:Void->Float = js.Syntax.code("globalThis.__svReal.dateNow");
		virtualBasePerf = realPerfNow();
		virtualBaseDate = realDateNow();
		js.Syntax.code("(function(){
			var virtualNow = {0};
			var virtualDateMs = {1};
			// performance.now：bundle 静态初始化之前打——HxOverrides.now 绑定
			// 捕获的是「当时的函数」（见类头「确定性虚拟钟」节）
			Object.defineProperty(globalThis.performance, 'now', {
				value: virtualNow, writable: true, configurable: true});
			Date.now = virtualDateMs;
			// new Date()（haxe Date.now 走零参构造）：取虚拟钟；带参构造/静态
			// parse/UTC 透传原实现
			var RealDate = globalThis.__svReal.dateCtor;
			class VDate extends RealDate {
				constructor(...args) {
					if (args.length === 0) super(virtualDateMs());
					else super(...args);
				}
			}
			VDate.now = virtualDateMs;
			VDate.parse = RealDate.parse;
			VDate.UTC = RealDate.UTC;
			globalThis.Date = VDate;
			// 定时器全量虚拟：游戏侧（haxe.Timer/openfl Timer/lime 帧循环）与
			// nodeboot 的 rAF 都在调用点解析全局，包一层全收进虚拟队列
			globalThis.setTimeout = {2};
			globalThis.setInterval = {3};
			globalThis.clearTimeout = {4};
			globalThis.clearInterval = {4};
		})()", virtualNowMs, virtualDateMs, wrappedSetTimeout, wrappedSetInterval, wrappedClearTimer);
	}

	// ---------------------------------------------------------------- 虚拟定时器

	static function numOr(v:Dynamic, dflt:Float):Float {
		if (v == null || Std.isOfType(v, Bool) || Std.isOfType(v, String)) return dflt;
		var f:Float = cast v;
		return Math.isNaN(f) ? dflt : f;
	}

	static function wrappedSetTimeout(fn:Dynamic, ms:Dynamic):Int {
		return scheduleVirtual("timeout", fn, clampDelay(ms));
	}

	static function wrappedSetInterval(fn:Dynamic, ms:Dynamic):Int {
		// interval 夹到 ≥1ms（node 同款）：0 间隔自旋会在单帧内烧穿泵
		var d = clampDelay(ms);
		if (d < 1) d = 1;
		return scheduleVirtual("interval", fn, d);
	}

	static function clampDelay(ms:Dynamic):Float {
		var d = numOr(ms, 0);
		return d < 0 ? 0 : d;
	}

	static function scheduleVirtual(kind:String, fn:Dynamic, delay:Float):Int {
		timerSeq++;
		var t:VTimer = {
			id: timerSeq, kind: kind, fn: fn,
			due: virtualElapsed + delay, interval: delay, seq: timerSeq, dead: false
		};
		vtimers.push(t);
		idMap.set(t.id, t);
		return timerSeq;
	}

	static function wrappedClearTimer(id:Dynamic):Void {
		// 非数字 id（node 的 Timeout 对象等）不在虚拟域——交给真实实现清不
		// 了也无妨：那类 id 只会来自 virtual 接管之前调度的真实定时器
		var f = numOr(id, Math.NaN);
		if (Math.isNaN(f)) return;
		var t = idMap.get(Std.int(f));
		if (t != null) {
			t.dead = true;
			vtimers.remove(t);
		}
	}

	// ---------------------------------------------------------------- 泵帧

	/** 泵 n 帧（settle 同义别名）：每帧推进一个帧时长并触发到期定时器。 */
	static function pump(rounds:Dynamic):Int {
		var n = Std.int(numOr(rounds, 1));
		for (r in 0...n) {
			virtualElapsed += frameStepMs;
			pumpedFrames++;
			fireDueTimers();
		}
		return pumpedFrames;
	}

	static function fireDueTimers():Void {
		var guard = 0;
		while (true) {
			// 到期里最早的（同 due 按入队序）：rAF(16ms) 每轮先于长周期定时器
			var best:VTimer = null;
			for (t in vtimers) {
				if (t.due <= virtualElapsed
					&& (best == null || t.due < best.due || (t.due == best.due && t.seq < best.seq))) {
					best = t;
				}
			}
			if (best == null) return;
			vtimers.remove(best);
			timersFired++;
			best.fn();
			if (best.kind == "interval") {
				if (best.dead) {
					idMap.remove(best.id); // 触发中被 clear：到此为止
				} else {
					// 重排按当前时刻 + 周期（错过不补——浏览器 interval 语义）
					best.due = virtualElapsed + best.interval;
					vtimers.push(best);
				}
			} else {
				idMap.remove(best.id);
			}
			if (++guard > 100000) {
				throw new haxe.Exception('虚拟定时器单帧内触发超 10 万次（疑似 0 延迟自旋），虚拟泵在第 ${pumpedFrames} 帧中止');
			}
		}
	}

	// ---------------------------------------------------------------- 截图

	static function bindStage(st:Dynamic):Bool {
		if (stage != null) return false;
		stage = st;
		var getFr = Reflect.field(st, "get_frameRate");
		if (getFr != null) {
			var fr = numOr(Reflect.callMethod(st, getFr, []), 0);
			if (fr > 0) frameStepMs = 1000.0 / fr;
		}
		return true;
	}

	static function stageContext():SoftCanvasContext {
		if (stage == null) {
			throw new haxe.Exception("视觉通道未绑定 stage（驱动须先 bindStage）");
		}
		var renderer:Dynamic = Reflect.field(stage, "__renderer");
		var ctx:Dynamic = renderer == null ? null : Reflect.field(renderer, "context");
		if (ctx == null) {
			throw new haxe.Exception("stage.__renderer.context 不可达（渲染器未建或不是 CanvasRenderer——视觉通道只在 2d 软画布模式可用）");
		}
		return cast ctx;
	}

	/** 截全舞台（含未泵渲染时的旧画布内容——正是「画面此刻长这样」的语义）。 */
	static function shot():Dynamic {
		var ctx = stageContext();
		var b:Bytes = ctx.readPixelsStraight();
		var pixels:Array<Int> = [for (i in 0...b.length) b.get(i)];
		return {width: ctx.width, height: ctx.height, pixels: pixels};
	}

	static function hash(img:Dynamic):String {
		var image:ShotImage = {width: img.width, height: img.height, pixels: img.pixels};
		return RenderHash.imageHash(image);
	}

	// ---------------------------------------------------------------- 连拍

	/** 连拍：首拍后每间隔泵 framesPerInterval 帧（framesForMs 换算）再拍。 */
	static function burst(count:Dynamic, framesPerInterval:Dynamic):Dynamic {
		var n = Std.int(numOr(count, 2));
		var per = Std.int(numOr(framesPerInterval, 1));
		if (per < 1) per = 1;
		var frames:Array<ShotImage> = [shot()];
		for (i in 1...n) {
			pump(per);
			frames.push(shot());
		}
		return {frames: frames, curve: MotionEnergy.curve(frames)};
	}

	/** 冻住注入（--self-check 用）：不泵帧连拍——帧帧全同、能量全零。 */
	static function frozenBurst(count:Dynamic):Dynamic {
		var n = Std.int(numOr(count, 2));
		var frames:Array<ShotImage> = [for (i in 0...n) shot()];
		return {frames: frames, curve: MotionEnergy.curve(frames)};
	}

	/** 两级判定（SceneShotDiff.compareBurst）——驱动侧自检断言用。 */
	static function compareBurst(a:Dynamic, b:Dynamic):Dynamic {
		return SceneShotDiff.compareBurst(toFrames(a), toFrames(b));
	}

	/** 连拍记录与声明的对齐门（SceneShotDiff.recordMatches）——驱动按步判红用。 */
	static function recordMatches(spec:Dynamic, frameCount:Dynamic, curveLength:Dynamic):Bool {
		var s:ShotSpec = {kind: spec.kind, intervalMs: spec.intervalMs, count: spec.count};
		return SceneShotDiff.recordMatches(s, Std.int(numOr(frameCount, 0)), Std.int(numOr(curveLength, 0)));
	}

	static function toFrames(v:Dynamic):Array<ShotImage> {
		if (v == null) return [];
		if (Std.isOfType(v, Array)) return cast v;
		var arr:Dynamic = Reflect.field(v, "frames");
		return arr == null ? [] : cast arr;
	}

	// ---------------------------------------------------------------- 拍法与换算

	/** checkpoint 的视觉声明 → 拍法（声明错原样上抛，驱动按步失败处理）。 */
	static function specOf(checkpoint:Dynamic):Dynamic {
		return SceneShotPlan.specOfCheckpoint(checkpoint);
	}

	/** intervalMs → 泵帧数（四舍五入；帧率换算，两侧同构地取整）。 */
	static function framesForMs(ms:Dynamic):Int {
		var m = numOr(ms, 0);
		if (m <= 0 || frameStepMs <= 0) return 1;
		return Math.round(m / frameStepMs);
	}

	static function stats():Dynamic {
		return {
			pumpedFrames: pumpedFrames,
			timersFired: timersFired,
			frameStepMs: frameStepMs,
			virtualElapsedMs: virtualElapsed,
			png: DecodingImage.decodedPng,
			jpg: DecodingImage.decodedJpeg,
			decodeFail: DecodingImage.decodeFailures.slice(0, 8),
			fillTextCalls: SoftCanvasContext.fillTextCalls,
			fallbackImageSources: SoftCanvasContext.fallbackImageSources,
		};
	}

	// ---------------------------------------------------------------- 杂项

	/** 把 Math.random 换成定种子 mulberry32（RenderProbe 同款，种子 0x57）：
	 * 原版帧脚本里的随机行为照常执行，只是每次运行取同一序列。 */
	static function installDeterministicRandom():Void {
		js.Syntax.code("(function() {
			var a = 0x57;
			Math.random = function() {
				a |= 0; a = a + 0x6D2B79F5 | 0;
				var t = Math.imul(a ^ a >>> 15, 1 | a);
				t = t + Math.imul(t ^ t >>> 7, 61 | t) ^ t;
				return ((t ^ t >>> 14) >>> 0) / 4294967296;
			};
		})()");
	}
}
