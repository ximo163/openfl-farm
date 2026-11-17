package;

import haxe.Json;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.utils.Assets;

/**
 * V1 资产通道探针（issue #1）：四类样本各占一格（2x2），验证 openfl/swf 库
 * 能否原样消费原版资产。这是脚手架不是翻译类——V2/V3 垂直切片会把本文件换成
 * 预加载器的翻译版；替换时保留下面的 window.__openflFarm* 接口约定
 * （harness/smoke.mjs 等 __openflFarmReady 出现）。
 *
 * 实例化走 SymbolClass 导出符号名（游戏原行为：mcloader 的 MaterialLib 按
 * 导出类 getDefinition 后 new，见 legacy/decompiled/mcloader_v_53/scripts/
 * common/MaterialLib.as 的 getClass/getMaterial），不用根时间轴——
 * a6291_1 / FDog100_v_1 的根与导出符号帧数不同（900/695 帧的根是作者舞台，
 * 游戏真正实例化的是 Animal_6291_x / FDog100）。
 *
 * 时间轴语义：构造即整树 stop（首帧确定，web-smoke 首截图=各样本第 1 帧），
 * 推进只经 window.__openflFarmAdvance(n) 固定步长：每步对树上每个 MovieClip
 * gotoAndStop(currentFrame % totalFrames + 1)。这等价于 Flash「宿主帧率驱动
 * 一切时间轴、各自在 totalFrames 处回绕」的逐帧行为，且不依赖真实时间，
 * 推进 N 帧后截图可复现。页面运行期间 rAF 照常打进来，但全树已 stop，
 * 自然播放不会推进帧。
 */
/** 一格样本：库 id + 导出符号名 + 实例化结果 */
typedef Cell = {
	lib:String,
	symbol:String,
	clip:MovieClip,
	error:String
}

class Main extends Sprite {
	// Project.xml 窗口 860x500；2x2 网格（探针专用布局，不进翻译类）
	private static inline var CELL_W:Int = 430;
	private static inline var CELL_H:Int = 250;
	private static inline var LABEL_H:Int = 16;

	private var cells:Array<Cell> = [];

	public function new() {
		super();

		var defs:Array<{lib:String, sym:String, label:String}> = [
			{lib: "Crop_1056_3", sym: "Crop_1056_3", label: "1 Crop_1056_3（静态 矢量+位图）"},
			{lib: "a6291_1", sym: "Animal_6291_3", label: "2 a6291_1:Animal_6291_3（嵌套动画）"},
			{lib: "shop_v_7", sym: "", label: "3 shop_v_7 根时间轴（界面+音效）"},
			{lib: "FDog100_v_1", sym: "FDog100", label: "4 FDog100_v_1:FDog100（主轴动画）"},
		];
		for (i in 0...defs.length) {
			addCell(defs[i].lib, defs[i].sym, defs[i].label, (i % 2) * CELL_W, Std.int(i / 2) * CELL_H);
		}

		expose();
	}

	private function addCell(lib:String, symbol:String, label:String, cellX:Int, cellY:Int):Void {
		var cell:Sprite = new Sprite();
		cell.x = cellX;
		cell.y = cellY;
		cell.graphics.lineStyle(1, 0x999999);
		cell.graphics.drawRect(0, 0, CELL_W, CELL_H);
		addChild(cell);

		var tf = new TextField();
		tf.defaultTextFormat = new TextFormat(null, 11, 0x333333);
		tf.text = label;
		tf.width = CELL_W;
		tf.height = LABEL_H;
		cell.addChild(tf);

		var entry:Cell = {lib: lib, symbol: symbol, clip: null, error: null};
		try {
			// preload="true" 的库在启动期已装好；符号名取 SymbolClass 导出名，
			// 空串=整个根时间轴（swf 库 README 写法）
			var clip = Assets.getMovieClip(lib + ":" + symbol);
			if (clip == null) {
				entry.error = "getMovieClip 返回 null";
			} else {
				entry.clip = clip;
				cell.addChild(clip);
				fitCell(cell, clip);
				stopTree(clip);
			}
		} catch (e:Dynamic) {
			entry.error = "实例化抛异常: " + e;
		}
		if (entry.error != null) {
			var err = new TextField();
			err.defaultTextFormat = new TextFormat(null, 12, 0xcc0000);
			err.text = entry.error;
			err.width = CELL_W - 8;
			err.wordWrap = true;
			err.y = LABEL_H + 4;
			cell.addChild(err);
		}
		cells.push(entry);
	}

	/** 等比缩放并居中到格子内容区（探针可视用，非原版布局参数）。 */
	private function fitCell(cell:Sprite, clip:MovieClip):Void {
		var w = clip.width, h = clip.height;
		if (w <= 0 || h <= 0) return; // 空时间轴（如纯 ABC 的 shop_v_7），原样放
		var s = Math.min((CELL_W - 12) / w, (CELL_H - LABEL_H - 8) / h);
		clip.scaleX = clip.scaleY = s;
		var b = clip.getBounds(cell);
		clip.x += (CELL_W - b.width) / 2 - b.x;
		clip.y += LABEL_H + (CELL_H - LABEL_H - b.height) / 2 - b.y;
	}

	/** 整树冻结在第 1 帧（含尚未挂上显示列表的池内实例不受影响：宿主 tick 到不了它们）。 */
	private function stopTree(obj:DisplayObjectContainer):Void {
		if (Std.isOfType(obj, MovieClip)) {
			cast(obj, MovieClip).stop();
		}
		for (i in 0...obj.numChildren) {
			var child = obj.getChildAt(i);
			if (Std.isOfType(child, DisplayObjectContainer)) stopTree(cast(child, DisplayObjectContainer));
		}
	}

	/**
	 * 固定步长推进一步：树上每个 MovieClip 前进 1 帧并在各自 totalFrames 回绕。
	 * 先 gotoAndStop 父层再遍历子层——父层换帧新挂上的实例在同一同步步里被停住并推进，
	 * rAF 无法插进来，推进后全树仍然冻结，截图可复现。
	 * 返回每步的状态（root 帧号 + 各嵌套剪辑 path=currentFrame/totalFrames）。
	 */
	private function stepTree(obj:DisplayObjectContainer, path:String, out:Array<String>):Void {
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

	private function advance(n:Int):String {
		if (n < 0) n = 0;
		if (n > 120) n = 120; // 探针够用（10/50 帧截图），防误传巨值拖垮页面
		var record:Array<Array<Dynamic>> = [];
		for (step in 0...n) {
			var row:Array<Dynamic> = [];
			for (cell in cells) {
				if (cell.clip == null) {
					row.push({error: cell.error});
					continue;
				}
				if (cell.clip.totalFrames > 1) {
					cell.clip.gotoAndStop((cell.clip.currentFrame % cell.clip.totalFrames) + 1);
				}
				var nested:Array<String> = [];
				stepTree(cell.clip, "", nested);
				row.push({f: cell.clip.currentFrame, t: cell.clip.totalFrames, n: nested});
			}
			record.push(row);
		}
		return Json.stringify(record);
	}

	private function stateJson():String {
		var out:Array<Dynamic> = [];
		for (cell in cells) {
			var entry:Dynamic = {lib: cell.lib, symbol: cell.symbol};
			if (cell.clip == null) {
				entry.error = cell.error;
			} else {
				entry.currentFrame = cell.clip.currentFrame;
				entry.totalFrames = cell.clip.totalFrames;
				entry.numChildren = cell.clip.numChildren;
				entry.width = cell.clip.width;
				entry.height = cell.clip.height;
				entry.movieClips = countClips(cell.clip);
			}
			out.push(entry);
		}
		return Json.stringify(out);
	}

	private function countClips(obj:DisplayObjectContainer):Int {
		var n = Std.isOfType(obj, MovieClip) ? 1 : 0;
		for (i in 0...obj.numChildren) {
			var child = obj.getChildAt(i);
			if (Std.isOfType(child, DisplayObjectContainer)) n += countClips(cast(child, DisplayObjectContainer));
		}
		return n;
	}

	/** JS 接口：__openflFarmReady（冒烟标记）、__openflFarmAdvance(n)、__openflFarmState()。 */
	private function expose():Void {
		#if js
		var w:Dynamic = js.Browser.window;
		w.__openflFarmReady = true;
		w.__openflFarmAdvance = advance;
		w.__openflFarmState = stateJson;
		#end
	}
}
