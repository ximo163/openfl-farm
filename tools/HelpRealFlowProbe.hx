package;

import haxe.Json;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Loader;
import openfl.display.MovieClip;
import openfl.display.SimpleButton;
import openfl.events.Event;
import openfl.net.URLRequest;
import openfl.text.TextField;
import shim.LocalSwfLoader;
import swf.exporters.animate.AnimateLibrary;

/**
 * #77 验收 4 第一条的 node 真实流探针：走 **LocalSwfLoader 真实加载流**装
 * help 库（load() → Assets.loadLibrary("help") → COMPLETE 派发 →
 * attachContent → HelpGuideWiring.attach——与 WelcomeView.showNewGuide 在
 * 真机上的加载链同一通道），再按真机帧相位做**真帧推进**（openfl Stage
 * __onLimeRender 次序逐字复制：broadcastEvent(ENTER_FRAME/FRAME_
 * CONSTRUCTED/EXIT_FRAME) 三广播 + __enterFrame 时间轴推进——手动凑事件
 * dispatch 不算数，广播注册表驱动的一次性重放只有这个次序能覆盖）。之后：
 *
 * - 在树上收出全部 DefineEditText 实例（页直挂 + SimpleButton up/over/
 *   down/hitTest 四态子树里的——对应 41 个字段定义，实例多于 41 因为按钮
 *   11/30 各放 4 页、每态一份）；
 * - 逐实例触发真实布局收尾（numLines——真机渲染侧的 textWidth/渲染管线
 *   同走 __updateLayout，告警只在布局循环里发出。「不许再用探针手工触发
 *   textWidth 代替真实流」针对的是把手工触发当修复验证替身；这里布局收尾
 *   是对真机渲染的等价复读，加载流本身已经走完）；
 * - 断言每实例末 range end == text.length、console.warn 对
 *   "You found a bug in OpenFL's text code!" 0 命中。
 *
 * 关键实证（2026-11-25 探针闭合，手写进 lessons #77 条）：
 * - 真机 41 条告警的首次布局发生点是 openfl Loader_onComplete 为补
 *   contentLoaderInfo.width/height 读 content.width/height（递归量测整树）
 *   ——在 attach 回调**之前**。本探针重现：修复前置前 real-flow 告警 41
 *   条（与真机账一致），修复前置后 0 条。
 * - 编译必须带 html5 构建的 define 集：裸 `haxe -js` 没有 `-D tools`，
 *   lime Assets.loadLibrary 的工具分支编译掉、返回永不完成的空 Future，
 *   LocalSwfLoader 在 node 根本走不通——这正是 #75 用「手工 textWidth
 *   探针」代替真实流的隐形原因。按 export/html5/haxe/release.hxml 的
 *   define 集编译后全链可跑。
 *
 * 对照组（--probe-only）：跳过 LocalSwfLoader/HelpGuideWiring，直接
 * lib.getMovieClip 实例化后同帧推进同布局收尾——洞必须原形毕露（告警
 * 全发出、末 range 不达文末），证明探针的告警通道有牙（#75 假信心的
 * 教训：验证链本身必须先证明自己有牙）。
 *
 * 单行 JSON 出结果（TimelineProbe 同款 stdout 契约；库侧 console 全拦进
 * 缓冲随 JSON 出）。退出码 0 通过 / 1 红 / 2 基建错误。
 *
 * 用法：
 *   haxe -cp tools -cp src -lib format -lib swf -lib openfl -lib lime \
 *        -D tools -D html5 -D web -D openfl-html5 -D lime-html5 -D lime-canvas \
 *        -D lime-dom -D lime-webgl -D lime-howlerjs -D howlerjs \
 *        -js export/help-flow-probe/help-flow-probe.js -main HelpRealFlowProbe
 *   node tools/run-openfl-node.js <绝对路径>/help-flow-probe.js \
 *        <绝对路径>/export/html5/bin/lib/help.zip [--probe-only]
 */
class HelpRealFlowProbe {
	/** 库侧 console 输出缓冲（lime.utils.Log 直连 console.*，告警从这里数）。 */
	private static var consoleLog:Array<String> = js.Syntax.code(
		"typeof globalThis.__hfConsoleLog != 'undefined' ? globalThis.__hfConsoleLog : (globalThis.__hfConsoleLog = [])");

	static function main() {
		// 单行 JSON stdout 契约：haxe trace 与 console.* 全拦进缓冲（TimelineProbe
		// 同款，why 见其头注）；探针自己的 println 走 process.stdout.write
		haxe.Log.trace = function(v:Dynamic, ?infos:haxe.PosInfos):Void {
			if (consoleLog.length < 400) {
				var s = Std.string(v);
				consoleLog.push("trace: " + (s.length > 300 ? s.substr(0, 300) + "…" : s));
			}
		};
		captureConsole();
		var out:Dynamic = {};
		var code = 2;
		try {
			var a = args();
			if (a.length < 1) {
				println("用法: help-flow-probe.js <lib.zip> [--probe-only]");
				exitNow(2);
				return;
			}
			var zip = a[0];
			var probeOnly = false;
			for (i in 1...a.length) {
				if (a[i] == "--probe-only") {
					probeOnly = true;
				} else {
					println("未知参数: " + a[i] + "（只支持 --probe-only）");
					exitNow(2);
					return;
				}
			}
			out.mode = probeOnly ? "probe-only" : "real-flow";
			code = run(zip, probeOnly, out);
		} catch (e:Dynamic) {
			out.error = "异常: " + e + "\n" + haxe.CallStack.toString(haxe.CallStack.exceptionStack());
			code = 2;
		}
		if (consoleLog.length > 0) out.consoleLog = consoleLog;
		println(Json.stringify(out));
		exitNow(code);
	}

	// ---- 探针本体 ----

	static function run(zip:String, probeOnly:Bool, out:Dynamic):Int {
		// 装库：AnimateLibrary.loadFromBytes 后用注册表接管 "help" 名——
		// Assets.loadLibrary("help")（LocalSwfLoader 内部唯一通道）在 lime
		// 侧 libraries.get(name) 命中注册实例，不走文件/网络（node 垫片
		// 没有资产清单）。先补 instances 防御（StepAnimate 同款）
		if (@:privateAccess AnimateLibrary.instances == null) {
			@:privateAccess AnimateLibrary.instances = new Map();
		}
		var lib:AnimateLibrary = null;
		var loadError:String = null;
		AnimateLibrary.loadFromBytes(cast getBytes(zip)).onComplete(function(l) {
			lib = cast l;
		}).onError(function(e) {
			loadError = Std.string(e);
		});
		if (lib == null) throw "AnimateLibrary 加载失败: " + loadError;
		lime.utils.Assets.registerLibrary("help", lib);

		var loader:Loader = null;
		var content:MovieClip = null;
		var completed = false;
		var completeError:String = null;

		if (probeOnly) {
			// 对照组：跳过 LocalSwfLoader（HelpGuideWiring 不会执行），其余
			// 步骤一字不差——洞必须原形毕露，证明探针的告警通道有牙
			content = lib.getMovieClip("");
		} else {
			// 真实流（issue 验收原文「走 LocalSwfLoader 加载 help 库」）：
			// WelcomeView.showNewGuide 的同款调用面——new LocalSwfLoader +
			// contentLoaderInfo COMPLETE 监听 + load(URLRequest)
			loader = new LocalSwfLoader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(_) {
				completed = true;
			});
			loader.load(new URLRequest("module/ui/main/outswf/help.swf"));
			if (!completed) {
				// Assets.loadLibrary 的工具分支（lime）对注册库同步
				// complete——本探针按 html5 define 集编译后该链是同步的。
				// 落 null 说明编译缺 -D tools（见头注：那是 #75 假探针的
				// 隐形原因），直接基建错
				throw "LocalSwfLoader 未同步完成——编译缺 html5 define 集（-D tools 等，见头注用法段）；"
					+ "错误面: " + completeError;
			}
			if (loader.numChildren == 0) throw "Loader 完成但 content 未挂载";
			content = cast loader.getChildAt(0);
			if (!Std.isOfType(content, MovieClip)) throw "content 不是 MovieClip";
		}
		out.completed = true;

		// 帧推进前查实：修复的一次性重放监听已登记进 ENTER_FRAME 广播
		// 注册表（attach 挂的）——登记缺失本身就是真实流断链（真机上
		// 重放永不到达）。probe-only 无此登记，跳过
		var registeredBefore = probeOnly ? false : isInBroadcastRegistry(content, Event.ENTER_FRAME);

		// 真帧推进（issue 验收原文「真帧推进」）：openfl 9.5.2 Stage
		// __onLimeRender（Stage.hx:2433-2439）的相位逐字复制——
		// broadcastEvent(ENTER_FRAME) → broadcastEvent(FRAME_CONSTRUCTED) →
		// broadcastEvent(EXIT_FRAME) → __enterFrame(deltaTime)。
		// __broadcastEvent 的派发条件是 dispatcher.stage == stage ||
		// stage == null，node 侧无窗口没有真 Stage，content 未上舞台
		// stage==null 恰命中第二支——「未上舞台也广播」在此场景不是偏差
		// 而是真实相位本身；修复的一次性重放挂在 ENTER_FRAME 广播注册表上，
		// 只有这条相位链驱动它才算「真帧推进」
		advanceFramePhase(content, 16);

		// 帧推进后查实：一次性重放已自摘（广播确实到达并驱动了它——
		// 「登记过且帧后消失」证明 ENTER_FRAME 广播链真实走过，不是
		// 摆样子的相位调用）
		var registeredAfter = probeOnly ? false : isInBroadcastRegistry(content, Event.ENTER_FRAME);
		if (!probeOnly) {
			out.replayRegisteredBeforeFrame = registeredBefore;
			out.replaySelfRemovedAfterFrame = registeredBefore && !registeredAfter;
		}

		// 布局触发（真机渲染的等价收尾）：树上全部 DefineEditText 实例——
		// 页直挂经容器递归，SimpleButton 四态子树特判遍历（盲区一的同款
		// 账面；hitTest 真资产是纯 shape 无文字，遍历防同族）。getLineMetrics
		// 内部 __updateLayout（TextField.hx:961/1058 一族）——真机渲染管线
		// 每帧对文本字段做的就是这套；告警只在布局循环发出
		var fields = collectTextFields(content);
		out.instanceCount = fields.length;
		var uncoveredBeforeMeasure = 0;
		var uncoveredAfter = 0;
		var linesZero = 0;
		var perInstance:Array<Dynamic> = [];
		for (i in 0...fields.length) {
			var tf = fields[i];
			var endBefore = lastRangeEnd(tf);
			var len = textLength(tf);
			var hole = endBefore < len;
			if (hole) uncoveredBeforeMeasure++;
			// 真实布局：首行 metrics（触发完整布局循环；行数为 0 意味着
			// 布局循环中断——告警 break 的可观察后果）
			var numLines = -1;
			try {
				numLines = tf.numLines;
			} catch (e:Dynamic) {
				numLines = -1;
			}
			if (numLines == 0) linesZero++;
			var endAfter = lastRangeEnd(tf);
			if (endAfter < len) uncoveredAfter++;
			perInstance.push({
				i: i,
				len: len,
				endBefore: endBefore,
				endAfter: endAfter,
				numLines: numLines
			});
		}
		out.instances = perInstance;
		out.uncoveredBeforeMeasure = uncoveredBeforeMeasure;
		out.uncoveredAfterMeasure = uncoveredAfter;

		// 告警命中数（console.warn 拦截缓冲逐条扫）
		var warnHits = 0;
		for (line in consoleLog) {
			if (line.indexOf("You found a bug in OpenFL") != -1) warnHits++;
		}
		out.textBugWarnHits = warnHits;

		if (probeOnly) {
			// 对照组判定：洞里字段的告警必须有命中、末 range 必须有未补
			// （help 41 字段全是双段 HTML，洞在真实布局链上字字命中）
			out.pass = warnHits > 0 && uncoveredAfter > 0;
			out.verdict = out.pass ? "对照组成立：洞在真实布局链上发出告警，探针通道有牙"
				: "对照组失牙：probe-only 流里洞未现形（告警通道/布局链断）";
		} else {
			// 主组判定（issue 验收原文两条）：全部实例末 range end ==
			// text.length；console.warn 对 text bug 0 命中。外加帧相位真实性
			// 钉板：一次性重放监听帧前在注册表、帧后自摘——证明真帧推进
			// 走到了 ENTER_FRAME 广播驱动重放，不是摆样子的相位调用
			out.pass = warnHits == 0 && uncoveredAfter == 0 && fields.length > 0
				&& registeredBefore == true && registeredAfter == false;
			out.verdict = out.pass ? "真实流通过：41 字段定义的全部实例覆盖齐、告警 0 命中、ENTER_FRAME 广播驱动重放到达"
				: "真实流红：修复未覆盖真实加载流";
		}
		return out.pass ? 0 : 1;
	}

	/** content 是否在指定广播事件的注册表里（一次性重放监听的登记凭证）。 */
	static function isInBroadcastRegistry(content:MovieClip, type:String):Bool {
		var registry:Map<String, Array<DisplayObject>> = @:privateAccess DisplayObject.__broadcastEvents;
		if (!registry.exists(type)) return false;
		return registry.get(type).indexOf(content) != -1;
	}

	/** openfl 9.5.2 Stage.__onLimeRender 帧相位（Stage.hx:2433-2439）的
	 * 逐字复制：三广播 + __enterFrame。广播走 DisplayObject.__broadcastEvents
	 * 注册表（addEventListener(ENTER_FRAME) 时登记），不能手工对单对象
	 * dispatchEvent——那绕过了注册表语义，且一次性重放的监听挂在 content
	 * 上、靠广播到达。 */
	static function advanceFramePhase(content:MovieClip, deltaMs:Int):Void {
		broadcastEvent(new Event(Event.ENTER_FRAME));
		broadcastEvent(new Event(Event.FRAME_CONSTRUCTED));
		broadcastEvent(new Event(Event.EXIT_FRAME));
		@:privateAccess content.__enterFrame(deltaMs);
	}

	/** Stage.__broadcastEvent（Stage.hx:1337-1365）的同款：遍历注册表，
	 * dispatcher.stage == null 命中（node 无窗口无真 Stage，见 run 注）。 */
	static function broadcastEvent(event:Event):Void {
		var registry:Map<String, Array<DisplayObject>> = @:privateAccess DisplayObject.__broadcastEvents;
		if (!registry.exists(event.type)) return;
		var dispatchers = registry.get(event.type);
		// 拷贝一份再派：一次性重放的第一件事就是自摘（改注册表），
		// 边遍历边改数组在 js 上会跳项
		var snapshot = dispatchers.copy();
		for (dispatcher in snapshot) {
			if (dispatcher.stage == null) {
				@:privateAccess dispatcher.__dispatch(event);
			}
		}
	}

	/** 树上全部 TextField：容器递归 + SimpleButton 四态子树特判（盲区一
	 * 账面的同款遍历，why 见 HelpGuideWiring 头注 #77-1）。 */
	static function collectTextFields(root:DisplayObject):Array<TextField> {
		var out:Array<TextField> = [];
		collectInto(root, out);
		return out;
	}

	static function collectInto(obj:DisplayObject, out:Array<TextField>):Void {
		if (obj == null) return;
		if (Std.isOfType(obj, TextField)) {
			out.push(cast obj);
			return;
		}
		if (Std.isOfType(obj, SimpleButton)) {
			var btn:SimpleButton = cast obj;
			collectInto(btn.upState, out);
			collectInto(btn.overState, out);
			collectInto(btn.downState, out);
			collectInto(btn.hitTestState, out);
			return;
		}
		if (Std.isOfType(obj, DisplayObjectContainer)) {
			var c:DisplayObjectContainer = cast obj;
			for (i in 0...c.numChildren) {
				collectInto(c.getChildAt(i), out);
			}
		}
	}

	@:access(openfl.text.TextField)
	static function lastRangeEnd(tf:TextField):Int {
		var ranges = tf.__textEngine.textFormatRanges;
		if (ranges == null || ranges.length == 0) return -1;
		return ranges[ranges.length - 1].end;
	}

	@:access(openfl.text.TextField)
	static function textLength(tf:TextField):Int {
		var text = tf.__textEngine.text;
		return text == null ? 0 : text.length;
	}

	/** 拦 console.log/info/warn/error 进全局缓冲（TimelineProbe 同款，
	 * 截断 400 条）。 */
	static function captureConsole():Void {
		#if js
		js.Syntax.code("(function() {
			var buf = globalThis.__hfConsoleLog;
			['log', 'info', 'warn', 'error'].forEach(function(m) {
				console[m] = function() {
					if (buf.length >= 400) {
						if (!buf.capped) { buf.capped = true; buf.push('…（库日志超 400 条，截断）'); }
						return;
					}
					var parts = [];
					for (var i = 0; i < arguments.length; i++) {
						var s = String(arguments[i]);
						parts.push(s.length > 300 ? s.slice(0, 300) + '…' : s);
					}
					buf.push(parts.join(' '));
				};
			});
		})()");
		#end
	}

	// ---- 跨目标 IO 适配（TimelineProbe 同款，仅本工具用） ----

	static function getBytes(path:String):haxe.io.Bytes {
		#if sys
		return sys.io.File.getBytes(path);
		#elseif js
		var fs:Dynamic = js.Syntax.code("require('fs')");
		return haxe.io.Bytes.ofData(fs.readFileSync(path));
		#else
		throw "unsupported target";
		#end
	}

	static function args():Array<String> {
		#if sys
		return Sys.args();
		#elseif js
		var a:Array<String> = js.Syntax.code("typeof process !== 'undefined' ? process.argv.slice(2) : []");
		return a;
		#else
		return [];
		#end
	}

	static function println(s:String):Void {
		#if sys
		Sys.println(s);
		#elseif js
		// 不走 console.log：captureConsole 把 console.* 全拦了
		js.Syntax.code("process.stdout.write({0})", s + "\n");
		#end
	}

	static function exitNow(code:Int):Void {
		#if sys
		Sys.exit(code);
		#elseif js
		js.Syntax.code("process.exit({0})", code);
		#end
	}
}
