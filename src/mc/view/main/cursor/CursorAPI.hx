package mc.view.main.cursor;

import common.MaterialLib;
import openfl.display.MovieClip;

/**
 * mc.view.main.cursor.CursorAPI —— CursorAPI.as 逐句对应（issue #87「光标」
 * 片真身）。API 素材光标：ctor 按 materialName 取 MaterialLib 素材当光标皮
 * （cacheAsBitmap），click 时 _cursor.gotoAndPlay(2)，cursorArgument setter
 * 仅转 super。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/cursor/CursorAPI.as。
 */
@:keep
class CursorAPI extends BaseCursor {
	// CursorAPI.as:9
	private var _cursor:MovieClip;

	// CursorAPI.as:11-17（`as MovieClip` 失配得 null 时下行 cacheAsBitmap 即
	// 抛——原版同；cast 直取与仓内 MsgIcon/MouseTip 等同族先例一致）
	public function new(param1:String = null) {
		super();
		this._cursor = cast MaterialLib.getInstance().getMaterial(param1);
		this._cursor.cacheAsBitmap = true;
		addChild(this._cursor);
	}

	// CursorAPI.as:19-22
	override public function click():Void {
		this._cursor.gotoAndPlay(2);
	}

	// CursorAPI.as:24-27（原文仅 super.cursorArgument = param1——Haxe 属性
	// 覆写只能覆 accessor 函数，super.set_cursorArgument 直调等价 super 属性写）
	override private function set_cursorArgument(param1:Dynamic):Dynamic {
		super.set_cursorArgument(param1);
		return param1;
	}
}
