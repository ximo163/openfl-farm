package mc.view.main.cursor;

import common.MaterialLib;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import shim.As3;

/**
 * mc.view.main.cursor.CursorTool —— CursorTool.as 逐句对应（issue #87「光标」
 * 片真身）。工具光标：cursorArgument.type!=9 取素材
 * "CursorTool_"+type+"_"+tId（cacheAsBitmap），type==9 拼
 * "Animal_"+id+"_1"（id 取 cId 优先、tId 兜底）摘其第一子件进新
 * MovieClip；click 播第 2 帧。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/cursor/CursorTool.as。
 */
@:keep
class CursorTool extends BaseCursor {
	// CursorTool.as:9
	private var _cursor:MovieClip;

	// CursorTool.as:11-15
	public function new() {
		super();
		this.cacheAsBitmap = true;
	}

	// CursorTool.as:17-20
	override public function click():Void {
		this._cursor.gotoAndPlay(2);
	}

	// CursorTool.as:22-49（PORT-NOTE：`param1["type"] != 9` 是 Dynamic 松比——
	// AS3 数值/字符串双形态下 "9"!=9 为假，走 As3.floatOf 归一（lessons #35 条）；
	// `Number(param1["cId"])` 是 AS3 Number() 强转，同走 floatOf——素材名拼接
	// 时整数 Float 在 eval/js 的 toString 不带小数点，与 AS3 一致，probe 实证）
	override private function set_cursorArgument(param1:Dynamic):Dynamic {
		var _loc2_:String = null;
		var _loc3_:Float = Math.NaN;
		var _loc4_:Sprite = null;
		super.set_cursorArgument(param1);
		if (As3.floatOf(Reflect.field(param1, "type")) != 9) {
			_loc2_ = "CursorTool_" + Reflect.field(param1, "type") + "_" + Reflect.field(param1, "tId");
			this._cursor = cast MaterialLib.getInstance().getMaterial(_loc2_);
			this._cursor.cacheAsBitmap = true;
		} else {
			this._cursor = new MovieClip();
			if (As3.hasProp(param1, "cId")) {
				_loc3_ = As3.floatOf(Reflect.field(param1, "cId"));
			} else if (As3.hasProp(param1, "tId")) {
				_loc3_ = As3.floatOf(Reflect.field(param1, "tId"));
			}
			_loc4_ = cast MaterialLib.getInstance().getMaterial("Animal_" + _loc3_ + "_1");
			this._cursor.addChild(_loc4_.getChildAt(0));
		}
		addChild(this._cursor);
		return param1;
	}
}
