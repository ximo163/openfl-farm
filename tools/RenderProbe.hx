package;

import haxe.Json;
import openfl.display.BitmapData;
import openfl.display.DisplayObjectContainer;
import openfl.display.MovieClip;
import openfl.geom.Matrix;
import swf.exporters.animate.AnimateBitmapSymbol;
import swf.exporters.animate.AnimateButtonSymbol;
import swf.exporters.animate.AnimateDynamicTextSymbol;
import swf.exporters.animate.AnimateFontSymbol;
import swf.exporters.animate.AnimateLibrary;
import swf.exporters.animate.AnimateShapeSymbol;
import swf.exporters.animate.AnimateSpriteSymbol;
import swf.exporters.animate.AnimateStaticTextSymbol;
import swf.exporters.animate.AnimateSymbol;
import t3.TimelineSpec;
import tools.BaselineFile;
import tools.RenderDiff;
import tools.RenderHash;
import tools.RenderPlan;
import tools.RenderTypes.BaselineDoc;
import tools.RenderTypes.BaselineEntry;
import tools.RenderTypes.CurrentShot;
import tools.RenderTypes.ShotImage;
import tools.RenderTypes.ShotPlan;
import tools.TimelineExtract;
import tools.TimelineTypes.AssetSpec;

/**
 * T2 资产渲染对拍——实拍侧探针 CLI（issue #57）：在 html5 构建产物同一套运行时
 * （AnimateLibrary + openfl Timeline/MovieClip + BitmapData.draw）上装库、逐
 * 符号 gotoAndStop 关键帧/固定步长推进，逐拍点软光栅化截图（SoftCanvas 把
 * openfl 的 CanvasRenderer 调用落到自研软画布——无头 node 里唯一的本地图
 * 通道，探路结论见类头「通道」节），出单行 JSON：比对模式（--baseline）对
 * 自回归基线逐拍点哈希对拍，更新模式（--update）吐本资产的基线条目。
 *
 * 通道（issue #57 探路结论，2026-11-24 容器内实测）：
 * - web-smoke 浏览器截图通道 CI-only（容器无浏览器），本地不可用；
 * - node 侧唯一可行 = 软光栅化：SoftCanvas.installNode() 把 document.createElement
 *   的 canvas 换成软画布元素 + 注册 Path2D/DOMMatrix/HTMLCanvasElement 全局，
 *   BitmapData.draw(clip) → CanvasRenderer → 软画布 context 的既有着色路径
 *   全部落到自研栅格化器（fish_01/farmui1 全符号渲染实测通过、双跑确定）。
 *   位图经 DecodingImage 顶替 globalThis.Image 同步解码（PNG 真像素；JPEG
 *   format 无解码器 → 真实宽高 + 黑像素兜底，计数进报告）。
 *
 * 确定性：69 个 bundle 的 scriptSource 全量扫描只有 farmui1 一处非确定源——
 * a_151 第 1 帧脚本 this.gotoAndPlay(Math.floor(Math.random() * 100))（原版
 * AS3 本意就是随机相位；T3 步进从第 2 帧起恰不进第 1 帧而躲过）。探针在装
 * 库前把 Math.random 换成定种子的 mulberry32：脚本照原样执行（行为语义不
 * 动），每次取同值——自回归基线才可比。属探针环境胶水，不碰翻译侧。
 *
 * 拍点（RenderPlan 契约，ClipSpec 侧）：
 * - 静态：起点帧 + 各标签帧（gotoAndStop 语义；单帧符号也拍——「逐符号」）；
 * - 播放：0 基步号 {0 起点、中间、回绕、k 网格}，推进语义与 T3 一字不差
 *   （root gotoAndStop((cur%total)+1) + stepTree 子件同式 +1）。
 *
 * 记录目标 = 主时间轴（键 ""，含单帧）+ 每个 sprite 符号实例化（含单帧——
 * T2 与 T3 的差别：截图覆盖单帧符号）+ 非 MovieClip 的 DisplayObject 容器
 * 符号（自定义基类 Sprite 族：仅静态拍点）。主轴符号本体跳过（T3 同款），
 * 位图/形状/文本/按钮符号不单独实例化——都是叶子，由引用它们的 sprite/主轴
 * 截图间接覆盖（覆盖数进 census 报告）。
 *
 * 用法（node 垫片与 StepAnimate/TimelineProbe 同款）：
 *   haxe -cp tools -cp test -lib format -lib swf -lib openfl -lib lime \
 *        -js render-probe.js -main RenderProbe
 *   node tools/run-openfl-node.js render-probe.js <swf> <lib.zip> \
 *        [--baseline <file>] [--update] [--k 10] [--inject scale]
 * 退出码：0 通过/更新完成 / 1 比对红 / 2 错误（lib 缺失、基线文件坏等）。
 *
 * --inject scale：注入式自检（issue #57 完成标准 2）——第一个记录目标
 * scaleX=2 再拍，画面尺寸/像素全变，门禁必须红在该目标的拍点键上。
 */
typedef ParsedArgs = {
	swf:String,
	zip:String,
	baseline:String,
	update:Bool,
	inject:Bool,
	k:Int,
};

class RenderProbe {
	/** 库侧 trace 缓冲（缺字体警告一类被库吞掉不抛，改道进报告）。 */
	private static var scriptLog:Array<String> = [];
	/** 实例化即失败的符号（如实计数：坏数据符号没有可拍的渲染面）。 */
	private static var instantiateFails:Array<String> = [];
	private static var instantiateFailCount:Int = 0;
	/** 库侧 console 输出缓冲（lime.utils.Log 直连 console.*，绕开 haxe trace）。 */
	private static var consoleLog:Array<String> = js.Syntax.code(
		"typeof globalThis.__rpConsoleLog != 'undefined' ? globalThis.__rpConsoleLog : (globalThis.__rpConsoleLog = [])");

	static function main() {
		// swf/openfl 库在 js 上报错两条路都不抛只打日志（haxe trace 与
		// lime.utils.Log → console.*）——都改道进缓冲随 JSON 出，保住「单行
		// JSON」stdout 契约；探针自己的 println 走 process.stdout.write。
		haxe.Log.trace = function(v:Dynamic, ?infos:haxe.PosInfos):Void {
			if (scriptLog.length < 200) {
				var s = Std.string(v);
				scriptLog.push(s.length > 300 ? s.substr(0, 300) + "…" : s);
			}
		};
		captureConsole();
		var a = args();
		var out:Dynamic = {};
		var code = 2;
		try {
			var parsed = parseArgs(a);
			if (parsed == null) {
				println("用法: render-probe.js <swf> <lib.zip> [--baseline <file>] [--update] [--k 10] [--inject scale]");
				exitNow(2);
				return;
			}

			// 渲染通道安装（顺序在最前：库装载期的位图解码就走软画布/解码钩子）
			SoftCanvas.installNode();
			DecodingImage.install();
			DecodingImage.resetCounters();
			// 定种子随机（顺序同最前：farmui1 a_151 的帧脚本在实例化/入帧时
			// 就调 Math.random，装库晚于本行没关系但越早越稳）
			installDeterministicRandom();

			// ---- 结构侧：资产级步数（T3 stepsFor 同式）----
			var structure = TimelineExtract.extractStructure(assetOf(parsed.swf), getBytes(parsed.swf));
			var spec:AssetSpec = TimelineSpec.parseAssetStructure(structure.json);
			var steps = TimelineSpec.stepsFor(spec);
			out.asset = spec.asset;
			out.steps = steps;
			out.k = parsed.k;

			// ---- 实拍 ----
			var lib = loadLib(parsed.zip);
			out.census = census(lib);
			var targets = enumTargets(lib);
			out.targets = targets.length;
			var shots:Array<CurrentShot> = [];
			var injectKey = null;
			var injectDone = false;
			for (t in targets) {
				// 注入只打第一个「有可见画面」的记录目标（「人为改坏一处」，
				// 完成标准 2）。空渲染目标不行：如 Crop_1056_3 主轴拍点 0×0，
				// scaleX=2 后仍是空拍点，注入不红 → 自检假阴。全空资产选不出
				// 目标时 inject 报 null，gate 侧按自检失败报出来。
				var bounds = t.clip.getBounds(t.clip);
				var doInject = parsed.inject && !injectDone && bounds.width > 0 && bounds.height > 0;
				if (doInject) {
					injectDone = true;
					injectKey = t.key;
					t.clip.scaleX = 2;
				}
				shootTarget(t, spec.asset, steps, parsed.k, shots);
			}
			out.inject = parsed.inject ? injectKey : null;
			out.shots = shots.length;

			// ---- 覆盖数（盲区如实计数，见 DecodingImage/SoftCanvasContext 类头）----
			out.coverage = {
				png: DecodingImage.decodedPng,
				jpg: DecodingImage.decodedJpeg,
				decodeFail: DecodingImage.decodeFailures.slice(0, 8),
				fillTextCalls: SoftCanvasContext.fillTextCalls,
				fallbackImageSources: SoftCanvasContext.fallbackImageSources,
				instantiateFailCount: instantiateFailCount,
				instantiateFails: instantiateFails.slice(0, 16)
			};

			if (parsed.update) {
				// 更新模式：吐本资产条目（gate 合并进全局基线文件），不比对
				var entries:Array<BaselineEntry> = [];
				for (shot in shots) {
					entries.push({
						hash: RenderHash.imageHash(shot.image),
						width: shot.image.width,
						height: shot.image.height
					});
				}
				// 条目与拍点一一对应：shot.key 在 entries 同下标（gate 侧 zip 合并）
				var entryKeys = [for (s in shots) s.key];
				out.mode = "update";
				out.entries = entries;
				out.entryKeys = entryKeys;
				out.pass = true;
				code = 0;
			} else {
				// 比对模式：本资产条目子集比对（基线文件是全资产共库的）
				if (parsed.baseline == null) {
					println("比对模式须给 --baseline <file>（或用 --update 生成基线）");
					exitNow(2);
					return;
				}
				var baselineJson = getString(parsed.baseline);
				var doc:BaselineDoc = BaselineFile.parse(baselineJson);
				var filtered = filterAsset(doc, spec.asset);
				var report = RenderDiff.compareShots(shots, filtered);
				out.mode = "compare";
				out.pass = report.pass;
				out.failed = report.failed;
				out.missing = report.missing;
				out.extra = report.extra;
				out.render = RenderDiff.render(report);
				code = report.pass ? 0 : 1;
			}
		} catch (e:Dynamic) {
			out.error = "异常: " + e + "\n" + haxe.CallStack.toString(haxe.CallStack.exceptionStack());
			code = 2;
		}
		var all = scriptLog.concat(consoleLog);
		if (all.length > 0) out.scriptLog = all; // JSON 转义换行，仍是单行
		println(Json.stringify(out));
		exitNow(code);
	}

	// ---- 参数 ----

	static function parseArgs(a:Array<String>):ParsedArgs {
		if (a.length < 2) return null;
		var baseline:String = null;
		var update = false;
		var inject = false;
		var k = 10;
		var i = 2;
		while (i < a.length) {
			var f = a[i];
			if (f == "--baseline" && i + 1 < a.length) {
				baseline = a[i + 1];
				i += 2;
			} else if (f == "--update") {
				update = true;
				i += 1;
			} else if (f == "--inject" && i + 1 < a.length && a[i + 1] == "scale") {
				inject = true;
				i += 2;
			} else if (f == "--k" && i + 1 < a.length) {
				k = Std.parseInt(a[i + 1]);
				if (k == null) return null;
				i += 2;
			} else {
				return null;
			}
		}
		return {swf: a[0], zip: a[1], baseline: baseline, update: update, inject: inject, k: k};
	}

	// ---- 库装载与目标枚举 ----

	static function loadLib(zip:String):AnimateLibrary {
		// 评估态上 AnimateLibrary 的 static 初始化不会跑（StepAnimate 同款防御）
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
		return lib;
	}

	/** 记录目标（语义见类头）：主轴 "" + 每个 sprite 符号（含单帧、含非
	 * MovieClip 容器——后者仅静态拍点），主轴符号本体跳过。 */
	static function enumTargets(lib:AnimateLibrary):Array<{key:String, clip:DisplayObjectContainer}> {
		var targets:Array<{key:String, clip:DisplayObjectContainer}> = [];
		var rootClip:MovieClip = lib.getMovieClip("");
		if (rootClip != null) {
			targets.push({key: "", clip: rootClip});
		}
		var rootSym:AnimateSymbol = @:privateAccess lib.root;
		for (sym in @:privateAccess lib.symbols) {
			if (sym == rootSym) continue;
			if (!Std.isOfType(sym, AnimateSpriteSymbol)) continue;
			var spriteSym:AnimateSpriteSymbol = cast sym;
			var key = sym.className != null ? sym.className : "#" + sym.id;
			var instance:Dynamic = null;
			try {
				instance = @:privateAccess spriteSym.__createObject(lib);
			} catch (e:Dynamic) {
				// 实例化即炸的符号（levelUpUI_v_1 有一个 frames 空数组的 sprite：
				// AnimateTimeline.init 读 frames[0].objects 抛 TypeError）——真实
				// html5 运行时同样炸，没有可拍的渲染面：如实计数进报告，不让
				// 一个坏符号毁掉整资产其余符号的比对（T3 单帧门天然跳过它，
				// T2 含单帧才踩到）。
				if (instantiateFails.length < 16) {
					instantiateFails.push(key + ": " + Std.string(e).split("\n")[0]);
				}
				instantiateFailCount++;
				continue;
			}
			if (instance == null || !Std.isOfType(instance, DisplayObjectContainer)) {
				continue; // 非容器符号：census 里留计数，不虚造拍点
			}
			targets.push({key: key, clip: cast instance});
		}
		return targets;
	}

	/** 符号类型普查（覆盖数进报告：没进 targets 的类型是叶子，被父级间接覆盖）。 */
	static function census(lib:AnimateLibrary):Dynamic {
		var counts = {
			sprite: 0,
			bitmap: 0,
			shape: 0,
			staticText: 0,
			dynamicText: 0,
			button: 0,
			font: 0,
			other: 0
		};
		for (sym in @:privateAccess lib.symbols) {
			if (Std.isOfType(sym, AnimateSpriteSymbol)) {
				counts.sprite++;
			} else if (Std.isOfType(sym, AnimateBitmapSymbol)) {
				counts.bitmap++;
			} else if (Std.isOfType(sym, AnimateShapeSymbol)) {
				counts.shape++;
			} else if (Std.isOfType(sym, AnimateStaticTextSymbol)) {
				counts.staticText++;
			} else if (Std.isOfType(sym, AnimateDynamicTextSymbol)) {
				counts.dynamicText++;
			} else if (Std.isOfType(sym, AnimateButtonSymbol)) {
				counts.button++;
			} else if (Std.isOfType(sym, AnimateFontSymbol)) {
				counts.font++;
			} else {
				counts.other++;
			}
		}
		return counts;
	}

	// ---- 拍点执行 ----

	/** 单目标：静态拍点（gotoAndStop 关键帧）→ 播放拍点（固定步长推进）。 */
	static function shootTarget(t:{key:String, clip:DisplayObjectContainer}, asset:String, steps:Int, k:Int,
			shots:Array<CurrentShot>):Void {
		var clipSpec = runtimeSpec(t.key, t.clip);
		// 静态拍点：先冻结整树（fresh 实例子件本在第 1 帧，双保险），逐关键帧
		// gotoAndStop 后截——子件停在自己第 1 帧（goto 重建的子件从其第 1 帧起）
		stopTree(t.clip);
		for (sp in RenderPlan.staticShots(clipSpec)) {
			if (Std.isOfType(t.clip, MovieClip)) {
				cast(t.clip, MovieClip).gotoAndStop(sp.index);
			}
			shots.push({key: BaselineFile.shotKey(asset, t.key, sp.id), image: shoot(t.clip)});
		}
		// 播放拍点：整树回第 1 帧重启，0 基步号推进（T3 步进式同款）
		var plays = RenderPlan.playbackShots(clipSpec, steps, k);
		if (plays.length > 0) {
			resetTree(t.clip);
			var wanted = new Map<Int, Bool>();
			for (p in plays) wanted.set(p.index, true);
			if (wanted.exists(0)) {
				shots.push({key: BaselineFile.shotKey(asset, t.key, "s0"), image: shoot(t.clip)});
			}
			var maxStep = plays[plays.length - 1].index;
			for (s in 1...maxStep + 1) {
				stepOnce(t.clip);
				if (wanted.exists(s)) {
					shots.push({key: BaselineFile.shotKey(asset, t.key, "s" + s), image: shoot(t.clip)});
				}
			}
		}
	}

	/** 运行时 ClipSpec：帧数/标签表取实跑实例（gotoAndStop/stepTree 推的就是
	 * 它，拍点推导与推进同一来源，结构与实跑永远不打架；steps 仍取结构侧
	 * stepsFor——资产级最大帧数，T3 语义）。 */
	static function runtimeSpec(key:String, clip:DisplayObjectContainer):tools.TimelineTypes.ClipSpec {
		var frames = 1;
		var labels:Array<{frame:Int, name:String}> = [];
		if (Std.isOfType(clip, MovieClip)) {
			var mc:MovieClip = cast clip;
			frames = mc.totalFrames < 1 ? 1 : mc.totalFrames;
			for (fl in mc.currentLabels) {
				labels.push({frame: fl.frame, name: fl.name});
			}
		}
		return {key: key, isMain: key == "", frames: frames, labels: labels, scriptFrames: []};
	}

	/** 与 TimelineProbe.stopTree（:238-244）一致：整树冻结在当前帧。 */
	static function stopTree(obj:DisplayObjectContainer):Void {
		if (Std.isOfType(obj, MovieClip)) cast(obj, MovieClip).stop();
		for (i in 0...obj.numChildren) {
			var child = obj.getChildAt(i);
			if (Std.isOfType(child, DisplayObjectContainer)) stopTree(cast(child, DisplayObjectContainer));
		}
	}

	/** 播放拍点前重置：根回第 1 帧（子件随之重建在第 1 帧）+ 冻结。 */
	static function resetTree(obj:DisplayObjectContainer):Void {
		if (Std.isOfType(obj, MovieClip)) {
			var mc:MovieClip = cast obj;
			mc.gotoAndStop(1);
		}
		stopTree(obj);
	}

	/** 与 TimelineProbe 的推进式一致（:210-223 去掉事件记录）：根 +1 带回绕，
	 * stepTree 递归子件同式 +1（totalFrames>1 门）。 */
	static function stepOnce(obj:DisplayObjectContainer):Void {
		if (Std.isOfType(obj, MovieClip)) {
			var mc:MovieClip = cast obj;
			if (mc.totalFrames > 1) {
				mc.gotoAndStop((mc.currentFrame % mc.totalFrames) + 1);
			}
		}
		stepTree(obj);
	}

	/** 与 TimelineProbe.stepTree（:248-262）一致（无事件包装）。 */
	static function stepTree(obj:DisplayObjectContainer):Void {
		for (i in 0...obj.numChildren) {
			var child = obj.getChildAt(i);
			if (Std.isOfType(child, MovieClip)) {
				var mc:MovieClip = cast child;
				if (mc.totalFrames > 1) {
					mc.gotoAndStop((mc.currentFrame % mc.totalFrames) + 1);
				}
			}
			if (Std.isOfType(child, DisplayObjectContainer)) {
				stepTree(cast(child, DisplayObjectContainer));
			}
		}
	}

	// ---- 截图（软画布通道核心）----

	/** 紧裁剪截图：getBounds 矩形 → BitmapData → draw 平移 → 软画布像素直读。
	 * 空边界（0 尺寸）出 {0,0,[]}（RenderHash 对 0x0 合法且确定）。 */
	static function shoot(clip:DisplayObjectContainer):ShotImage {
		var b = clip.getBounds(clip);
		var w = Math.ceil(b.width);
		var h = Math.ceil(b.height);
		if (w < 0) w = 0;
		if (h < 0) h = 0;
		if (w <= 0 || h <= 0) {
			return {width: 0, height: 0, pixels: []};
		}
		var bd = new BitmapData(w, h, true, 0);
		var m = new Matrix();
		m.translate(-Math.floor(b.x), -Math.floor(b.y));
		bd.draw(clip, m);
		// draw 后像素在软画布帧缓冲（__srcContext 即 SoftCanvasContext）；
		// 直读必须静态类型化：js 上 Bytes.get 被内联进 .b[]，动态接收者找不到
		var ctx:Dynamic = @:privateAccess bd.image.buffer.__srcContext;
		var px:haxe.io.Bytes = ctx.readPixelsStraight();
		var n = w * h * 4;
		var pixels = new Array<Int>();
		for (i in 0...n) {
			pixels.push(px.get(i));
		}
		return {width: w, height: h, pixels: pixels};
	}

	// ---- 基线子集 ----

	/** 全局基线 → 本资产条目子集（其余资产的条目不是本探针的比对对象；
	 * extra 语义只在资产内成立）。 */
	static function filterAsset(doc:BaselineDoc, asset:String):BaselineDoc {
		var prefix = asset + "|";
		var entries = new Map<String, BaselineEntry>();
		for (key in doc.entries.keys()) {
			if (StringTools.startsWith(key, prefix)) {
				entries.set(key, doc.entries.get(key));
			}
		}
		return {source: doc.source, entries: entries};
	}

	// ---- 杂项（TimelineProbe 同款）----

	/** swf 路径 → asset 字段（assets/legacy-assets.txt 清单原样路径形态）。 */
	static function assetOf(swfPath:String):String {
		var marker = "assets/legacy/";
		var idx = swfPath.lastIndexOf(marker);
		if (idx >= 0) return swfPath.substr(idx + marker.length);
		return swfPath;
	}

	/** 拦 console.log/info/warn/error 进全局缓冲（截断 400 条，每条 300 字符）。 */
	static function captureConsole():Void {
		#if js
		js.Syntax.code("(function() {
			var buf = globalThis.__rpConsoleLog;
			['log', 'info', 'warn', 'error'].forEach(function(m) {
				console[m] = function() {
					if (buf.length >= 60) {
						if (!buf.capped) { buf.capped = true; buf.push('…（库日志超 60 条，截断）'); }
						return;
					}
					var parts = [];
					for (var i = 0; i < arguments.length; i++) {
						var s = String(arguments[i]);
						parts.push(s.length > 250 ? s.slice(0, 250) + '…' : s);
					}
					buf.push(parts.join(' '));
				};
			});
		})()");
		#end
	}

	// ---- 跨目标 IO 适配（仅本工具用）----

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

	static function getString(path:String):String {
		#if sys
		return sys.io.File.getContent(path);
		#elseif js
		var fs:Dynamic = js.Syntax.code("require('fs')");
		return fs.readFileSync(path, "utf8");
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
		// 不走 console.log（captureConsole 全拦）也不走 process.stdout.write：
		// 管道上它是异步的，紧随其后的 process.exit 会截掉大 JSON 的尾巴
		// （farmui2 的 280KB 输出实测丢 60KB）。fs.writeSync(1) 同步落盘。
		var fs:Dynamic = js.Syntax.code("require('fs')");
		js.Syntax.code("{0}.writeSync(1, {1})", fs, s + "\n");
		#end
	}

	static function exitNow(code:Int):Void {
		#if sys
		Sys.exit(code);
		#elseif js
		js.Syntax.code("process.exit({0})", code);
		#end
	}

	/** 把 Math.random 换成定种子 mulberry32（探针环境胶水，理由见类头「确定性」
	 * 节）：原版帧脚本里的随机行为照常执行，只是每次运行取同一序列，自回归
	 * 基线两侧才可比。整数运算全在 32 位（Math.imul），跨 node 版本逐位稳定。 */
	static function installDeterministicRandom():Void {
		#if js
		js.Syntax.code("(function() {
			var a = 0x57; // 种子取 issue 号：无语义偏好，只要每次一样
			Math.random = function() {
				a |= 0; a = a + 0x6D2B79F5 | 0;
				var t = Math.imul(a ^ a >>> 15, 1 | a);
				t = t + Math.imul(t ^ t >>> 7, 61 | t) ^ t;
				return ((t ^ t >>> 14) >>> 0) / 4294967296;
			};
		})()");
		#end
	}
}
