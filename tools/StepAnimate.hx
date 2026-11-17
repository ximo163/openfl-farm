package;

import haxe.Json;
import openfl.display.DisplayObjectContainer;
import openfl.display.MovieClip;
import swf.exporters.animate.AnimateLibrary;

/**
 * V1 探路工具（issue #1）：在与 html5 页面**同一套运行时代码**（AnimateLibrary +
 * openfl Timeline/MovieClip）上装库、实例化、固定步长推进，把 currentFrame 序列
 * （含回绕）打成 JSON。src/Main.hx 的 advance()/stepTree() 与这里的步进语义相同
 * （每步对树上每个 MovieClip gotoAndStop(cur % total + 1)），两者输出应一致；
 * 本工具的输出附进 PR 说明。
 *
 * 浏览器之外跑 openfl 显示树有目标差异，所以 IO 走小适配层：
 *   haxe -cp tools -lib lime -lib swf -lib openfl -js step.js -main StepAnimate
 *   node step.js <lib.zip> <符号|空串=根> <步数> [...]
 * zip 用 html5 构建产物（export/html5/bin/lib/），保证和页面加载的同一份。
 */
class StepAnimate {
	static function main() {
		var a = args();
		if (a.length < 3 || a.length > 4) {
			println("用法: step.js <lib.zip> <符号名|空串=根> <步数> [模式=step|play]");
			#if sys
			Sys.exit(2);
			#end
		}
		var steps = Std.parseInt(a[2]);
		run(a[0], a[1], steps == null ? 0 : steps);
	}

	static function run(zip:String, sym:String, steps:Int):Void {
		var mode = args().length >= 4 ? args()[3] : "step";		var out:Dynamic = {zip: zip, symbol: sym, mode: mode};
		try {
			// 评估态上 AnimateLibrary 的 static 初始化不会跑（构造时 instances 仍为
			// null → Null Access），先补上；浏览器/node 无此问题，保留防御
			if (@:privateAccess AnimateLibrary.instances == null) {
				@:privateAccess AnimateLibrary.instances = new Map();
			}
			var lib:AnimateLibrary = null;
			// 评估态没有事件循环，Future 全同步；onComplete 里取值
			AnimateLibrary.loadFromBytes(cast getBytes(zip)).onComplete(function(l) {
				lib = cast l;
			}).onError(function(e) {
				out.error = "加载失败: " + e;
			});
			if (lib == null) {
				println(Json.stringify(out));
				return;
			}
			out.frameRate = @:privateAccess lib.frameRate;
			var clip = lib.getMovieClip(sym);
			if (clip == null) {
				out.error = "getMovieClip null";
				println(Json.stringify(out));
				return;
			}
			if (mode == "play") {
				// 自然播放路径：不 stop，模拟宿主 24fps 的固定 tick（deltaTime=1000/24）
				// 直接喂 __enterFrame——与 Stage 每帧对显示树的做法一致。
				// 用于量测库自己的帧率驱动（12fps 作物 vs 24fps 宿主的分歧证据）。
				out.totalFrames = clip.totalFrames;
				var ticks:Array<Dynamic> = [];
				for (t in 0...steps) {
					@:privateAccess clip.__enterFrame(Std.int(1000 / 24));
					var nested:Array<String> = [];
					playTree(clip, "", nested);
					ticks.push({f: clip.currentFrame, n: nested});
				}
				out.ticks = ticks;
			} else {
				// 与页面一致：整树冻结在第 1 帧
				stopTree(clip);
				out.totalFrames = clip.totalFrames;
				out.numChildren = clip.numChildren;
				var recorded:Array<Dynamic> = [];
				for (s in 0...steps) {
					if (clip.totalFrames > 1) clip.gotoAndStop((clip.currentFrame % clip.totalFrames) + 1);
					var nested:Array<String> = [];
					stepTree(clip, "", nested);
					recorded.push({f: clip.currentFrame, n: nested});
				}
				out.steps = recorded;
			}
		} catch (e:Dynamic) {
			out.error = "异常: " + e + "\n" + haxe.CallStack.toString(haxe.CallStack.exceptionStack());
		}
		println(Json.stringify(out));
	}

	/** play 模式只读状态：第一个多帧 MovieClip 的 currentFrame（不动播放头）。 */
	static function playTree(obj:DisplayObjectContainer, path:String, out:Array<String>):Void {
		for (i in 0...obj.numChildren) {
			var child = obj.getChildAt(i);
			var p = path == "" ? Std.string(i) : path + "." + i;
			if (Std.isOfType(child, MovieClip)) {
				var mc:MovieClip = cast child;
				if (mc.totalFrames > 1) out.push(p + "=" + mc.currentFrame + "/" + mc.totalFrames);
			}
			if (Std.isOfType(child, DisplayObjectContainer)) {
				playTree(cast(child, DisplayObjectContainer), p, out);
			}
		}
	}

	static function stopTree(obj:DisplayObjectContainer):Void {
		if (Std.isOfType(obj, MovieClip)) cast(obj, MovieClip).stop();
		for (i in 0...obj.numChildren) {
			var child = obj.getChildAt(i);
			if (Std.isOfType(child, DisplayObjectContainer)) stopTree(cast(child, DisplayObjectContainer));
		}
	}

	// 语义与 src/Main.hx stepTree 一致：每步每个 MovieClip 前进 1 帧并各自回绕
	static function stepTree(obj:DisplayObjectContainer, path:String, out:Array<String>):Void {
		for (i in 0...obj.numChildren) {
			var child = obj.getChildAt(i);
			var p = path == "" ? Std.string(i) : path + "." + i;
			if (Std.isOfType(child, MovieClip)) {
				var mc:MovieClip = cast child;
				if (mc.totalFrames > 1) mc.gotoAndStop((mc.currentFrame % mc.totalFrames) + 1);
				out.push(p + "=" + mc.currentFrame + "/" + mc.totalFrames);
			}
			if (Std.isOfType(child, DisplayObjectContainer)) {
				stepTree(cast(child, DisplayObjectContainer), p, out);
			}
		}
	}

	// ---- 跨目标 IO 适配（浏览器外跑 openfl 的最小胶水，仅本工具用） ----

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
		js.Syntax.code("console.log({0})", s);
		#end
	}
}
