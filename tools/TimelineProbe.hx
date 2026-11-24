package;

import haxe.Json;
import openfl.display.DisplayObjectContainer;
import openfl.display.FrameLabel;
import openfl.display.MovieClip;
import openfl.display.Timeline;
import swf.exporters.animate.AnimateLibrary;
import swf.exporters.animate.AnimateSpriteSymbol;
import swf.exporters.animate.AnimateSymbol;
import t3.TimelineDiff;
import tools.TimelineExtract;
import t3.TimelineSpec;
import tools.TimelineTypes.ActualClip;
import tools.TimelineTypes.AssetSpec;
import tools.TimelineTypes.StepFrame;
import tools.TimelineTypes.StepName;

/**
 * T3 时间轴行为对拍——实跑侧探针 CLI（issue #56）：在 html5 构建产物同一套
 * 运行时（AnimateLibrary + openfl Timeline/MovieClip）上装库、实例化、固定
 * 步长推进，录序列项四件（每步 currentFrame / 帧标签命中 / 循环与终点 /
 * 帧事件），再用 t3.TimelineDiff 对拍期望侧（tools.TimelineExtract 从 swf
 * 结构静态提取），单行 JSON 出结果。期望侧提取与本 CLI 同进程（省一次 node
 * 启动）；Spec/Diff 实现在 test/t3/（stub 类路径被 append-only 的
 * test/tools/*.hx 占死，见 test/tools/import.hx），显式 import t3.* 经
 * -cp test 进链。
 *
 * 用法（node 垫片同 StepAnimate）：
 *   haxe -cp tools -cp test -lib format -lib swf -lib openfl -lib lime \
 *        -js timeline-probe.js -main TimelineProbe
 *   node tools/run-openfl-node.js timeline-probe.js <swf> <lib.zip> [--inject skip-frame]
 * 退出码：0 通过 / 1 红 / 2 错误（lib 缺失、实例化异常等）。
 *
 * 推进语义与 tools/StepAnimate.hx 一字不差：stopTree（:107-113）整树先冻结
 * 第 1 帧；每步根 gotoAndStop((currentFrame % totalFrames) + 1)（:79）、
 * stepTree（:116-129）递归对每个多帧子件同式推进（:122 的 totalFrames>1 门），
 * 步后记录。单帧剪辑不记录（不是比对单元——比对侧 clipExtra 用例钉死此点）。
 *
 * 记录目标 = 库里每个多帧 sprite 符号单独实例化（导出名 = symbolsByClassName
 * 键，无导出名 = "#<charId>"），外加主时间轴（键 ""，多帧才记录）：fish_01 的
 * 8 个符号根本没放进主轴（根 1 帧空树），逐个实例化是全覆盖的唯一办法；主轴
 * 符号本体跳过不单独实例化（避免同一符号以文档类名再记一条 → clipExtra）。
 * 每个目标独立走完 steps 步（steps 取期望侧 stepsFor——两侧步数不一致本身就是
 * 资产级红项），事件归属当前推进的树根。
 *
 * 帧事件（序列项四）：包装每个 MovieClip 的 Timeline.__frameScripts 回调
 * （@:privateAccess），触发时记 {step, frame}——帧脚本改播放头（gotoAndPlay 族）
 * 属实跑行为照录；openfl 侧没有原版 AS3 可执行的（scriptSource 空串被丢一族）
 * 记不到事件，期望侧 scriptFrames 非空的剪辑在比对里降级标注（不判红不假绿）。
 *
 * --inject skip-frame：注入式自检（完成标准 2）——第一个记录目标第 2 步多跳
 * 1 帧gotoAndStop((cur % total) + 2)，门禁必须红在第 2 步 currentFrame。
 */
class TimelineProbe {
	/** 当前步号（1 基；0 = 未开始推进，实例化期触发的事件不计）。 */
	private static var curStep:Int = 0;
	/** 当前记录目标的事件数组（null = 不归属任何目标）。 */
	private static var curEvents:Array<StepFrame> = null;
	/** 库侧 trace 缓冲（帧脚本求值错/缺字体等，都被库吞掉不抛）。 */
	private static var scriptLog:Array<String> = [];
	/** 库侧 console 输出缓冲（lime.utils.Log 直连 console.info/warn/error，
	 * 绕过 haxe.Log.trace；由 captureConsole 填）。 */
	private static var consoleLog:Array<String> = js.Syntax.code(
		"typeof globalThis.__tlConsoleLog != 'undefined' ? globalThis.__tlConsoleLog : (globalThis.__tlConsoleLog = [])");

	static function main() {
		// swf/openfl 库在 js 上报错两条路都不抛只打日志：haxe trace（缺字体
		// 警告一类）和 lime.utils.Log → console.info/error（AnimateTimeline 帧
		// 脚本求值错，AnimateTimeline.hx:569）。都会冲掉「单行 JSON」stdout
		// 契约——分别改道进缓冲随 JSON 出，openfl 侧证据留在报告里；探针自
		// 己的 println 走 process.stdout.write，不经 console 不被拦。
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
			if (a.length < 2) {
				println("用法: timeline-probe.js <swf> <lib.zip> [--inject skip-frame]");
				exitNow(2);
				return;
			}
			var swf = a[0];
			var zip = a[1];
			// 注入标记两种形态都收：--inject skip-frame（两 token）或合写单 token
			var inject = false;
			var i = 2;
			while (i < a.length) {
				var f = a[i];
				if (f == "--inject" && i + 1 < a.length && a[i + 1] == "skip-frame") {
					inject = true;
					i += 2;
				} else if (f == "--inject" || f == "--inject skip-frame" || f == "skip-frame") {
					inject = true;
					i += 1;
				} else {
					println("未知参数: " + f + "（只支持 --inject skip-frame）");
					exitNow(2);
					return;
				}
			}
			out.inject = inject ? "skip-frame" : null;

			// ---- 期望侧：swf 结构静态提取 ----
			var structure = TimelineExtract.extractStructure(assetOf(swf), getBytes(swf));
			out.via = structure.via;
			var spec:AssetSpec = TimelineSpec.parseAssetStructure(structure.json);
			var steps = TimelineSpec.stepsFor(spec);
			out.asset = spec.asset;
			out.steps = steps;

			// ---- 实跑侧：装库、实例化、固定步长推进 ----
			var record:Dynamic = probeRecord(zip, spec, steps, inject);
			out.record = record;
			out.recordedClips = record.clips.length;

			// ---- 比对 + 报告 ----
			var report = TimelineDiff.compare(spec, Json.stringify(record));
			out.pass = report.pass;
			out.downgraded = report.downgraded;
			out.render = TimelineDiff.render(report);
			code = report.pass ? 0 : 1;
		} catch (e:Dynamic) {
			out.error = "异常: " + e + "\n" + haxe.CallStack.toString(haxe.CallStack.exceptionStack());
			code = 2;
		}
		var all = scriptLog.concat(consoleLog);
		if (all.length > 0) out.scriptLog = all; // JSON 转义换行，仍是单行
		println(Json.stringify(out));
		exitNow(code);
	}

	// ---- 探针本体 ----

	static function probeRecord(zip:String, spec:AssetSpec, steps:Int, inject:Bool):Dynamic {
		// 评估态上 AnimateLibrary 的 static 初始化不会跑（构造时 instances 仍为
		// null → Null Access），先补上（StepAnimate 同款防御）
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

		// 记录目标：主时间轴（多帧才记）+ 每个多帧 sprite 符号（跳过主轴符号本体）
		var targets:Array<{key:String, clip:MovieClip}> = [];
		var rootClip:MovieClip = lib.getMovieClip("");
		if (rootClip != null && rootClip.totalFrames > 1) {
			targets.push({key: "", clip: rootClip});
		}
		var rootSym:AnimateSymbol = @:privateAccess lib.root;
		for (sym in @:privateAccess lib.symbols) {
			if (sym == rootSym) continue;
			if (!Std.isOfType(sym, AnimateSpriteSymbol)) continue;
			var spriteSym:AnimateSpriteSymbol = cast sym;
			if (spriteSym.frames.length < 2) continue; // 单帧不是比对单元
			var key = sym.className != null ? sym.className : "#" + sym.id;
			var instance = @:privateAccess spriteSym.__createObject(lib);
			if (instance == null || !Std.isOfType(instance, MovieClip)) {
				// 自定义基类不是 MovieClip（无时间轴）：不记录 → 比对侧 clipMissing 红，
				// 诚实暴露「探针无法实例化」而不是静默放过
				continue;
			}
			targets.push({key: key, clip: cast instance});
		}

		var injectDone = false;
		var injectKey:String = null;
		var clips:Array<Dynamic> = [];
		for (t in targets) {
			// 注入只打第一个记录目标（「人为改坏一处」，完成标准 2）
			var doInject = inject && !injectDone;
			if (doInject) {
				injectDone = true;
				injectKey = t.key;
			}
			clips.push(advanceAndRecord(t.key, t.clip, steps, doInject));
		}
		return {
			asset: spec.asset,
			steps: steps,
			clips: clips,
			injectKey: injectKey
		};
	}

	/** 单个目标：整树冻结 → steps 步推进 → 序列项四件。 */
	static function advanceAndRecord(key:String, clip:MovieClip, steps:Int, doInject:Bool):ActualClip {
		var frames:Array<Int> = [];
		var labels:Array<StepName> = [];
		var events:Array<StepFrame> = [];
		var loops = 0;

		stopTree(clip);
		curEvents = events;
		curStep = 0;
		wrapScripts(clip);

		for (s in 1...steps + 1) {
			curStep = s;
			if (clip.totalFrames > 1) {
				// 注入：第 2 步多跳一帧（正常 +1）——门禁须红在第 2 步 currentFrame
				var advance = doInject && s == 2 ? 2 : 1;
				clip.gotoAndStop((clip.currentFrame % clip.totalFrames) + advance);
			}
			stepTree(clip);
			frames.push(clip.currentFrame);
			if (clip.currentFrame == 1) loops++;
			for (fl in clip.currentLabels) {
				if (fl.frame == clip.currentFrame) labels.push({step: s, name: fl.name});
			}
		}

		curEvents = null;
		curStep = 0;
		return {
			key: key,
			frames: frames,
			labels: labels,
			loops: loops,
			endFrame: frames.length > 0 ? frames[frames.length - 1] : 1,
			frameEvents: events
		};
	}

	/** 与 StepAnimate.stopTree（:107-113）一致：整树冻结在第 1 帧。 */
	static function stopTree(obj:DisplayObjectContainer):Void {
		if (Std.isOfType(obj, MovieClip)) cast(obj, MovieClip).stop();
		for (i in 0...obj.numChildren) {
			var child = obj.getChildAt(i);
			if (Std.isOfType(child, DisplayObjectContainer)) stopTree(cast(child, DisplayObjectContainer));
		}
	}

	/** 与 StepAnimate.stepTree（:116-129）一致：每步每个多帧子件 +1 带回绕；
	 * 差异仅在 goto 前先包该子件的帧脚本（新出现在本步的子件也要能记事件）。 */
	static function stepTree(obj:DisplayObjectContainer):Void {
		for (i in 0...obj.numChildren) {
			var child = obj.getChildAt(i);
			if (Std.isOfType(child, MovieClip)) {
				var mc:MovieClip = cast child;
				if (mc.totalFrames > 1) {
					wrapScripts(mc);
					mc.gotoAndStop((mc.currentFrame % mc.totalFrames) + 1);
				}
			}
			if (Std.isOfType(child, DisplayObjectContainer)) {
				stepTree(cast(child, DisplayObjectContainer));
			}
		}
	}

	/** 包装树内 MovieClip 的 __frameScripts 回调：触发记 {step, frame} 后调原函数。
	 * 同帧多脚本只包一次（wrapper 上打 __tlWrapped 标记）。 */
	static function wrapScripts(mc:MovieClip):Void {
		var timeline:Timeline = @:privateAccess mc.__timeline;
		if (timeline == null) return;
		var frameScripts:Map<Int, MovieClip->Void> = @:privateAccess timeline.__frameScripts;
		if (frameScripts == null) return;
		for (frame in frameScripts.keys()) {
			var fn:MovieClip->Void = frameScripts.get(frame);
			if (fn == null) continue;
			if (Reflect.field(fn, "__tlWrapped") == true) continue;
			var frameNum = frame;
			var original = fn;
			var wrapper:MovieClip->Void = function(scope:MovieClip):Void {
				if (curEvents != null && curStep >= 1) {
					curEvents.push({step: curStep, frame: frameNum});
				}
				original(scope);
			};
			Reflect.setField(wrapper, "__tlWrapped", true);
			frameScripts.set(frame, wrapper);
		}
	}

	/** swf 路径 → 结构 JSON 的 asset 字段（assets/legacy-assets.txt 的相对路径
	 * 形态）。gate 侧传绝对路径，取最后一个 assets/legacy/ 之后的部分；剥不
	 * 掉就原样（比对两侧 asset 字段一致即可）。 */
	static function assetOf(swfPath:String):String {
		var marker = "assets/legacy/";
		var idx = swfPath.lastIndexOf(marker);
		if (idx >= 0) return swfPath.substr(idx + marker.length);
		return swfPath;
	}

	/** 拦 console.log/info/warn/error 进全局缓冲（只本探针进程内；截断 400 条，
	 * 每条 300 字符）。frameScript 求值错每圈都来一条，不设限 JSON 会爆炸。 */
	static function captureConsole():Void {
		#if js
		js.Syntax.code("(function() {
			var buf = globalThis.__tlConsoleLog;
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

	// ---- 跨目标 IO 适配（StepAnimate 同款，仅本工具用） ----

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
