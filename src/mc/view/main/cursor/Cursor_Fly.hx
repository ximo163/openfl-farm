package mc.view.main.cursor;

import common.MaterialLib;
import openfl.display.MovieClip;

/**
 * mc.view.main.cursor.Cursor_Fly —— Cursor_Fly.as 逐句对应（issue #87「光标」
 * 片真身）。苍蝇光标：ctor 取 "CursorFly" 素材挂树，click 时
 * _cursor.gotoAndPlay(2)。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/cursor/Cursor_Fly.as。
 */
@:keep
class Cursor_Fly extends BaseCursor {
	// Cursor_Fly.as:9
	private var _cursor:MovieClip;

	// Cursor_Fly.as:11-18
	public function new() {
		super();
		this._cursor = cast MaterialLib.getInstance().getMaterial("CursorFly");
		this._cursor.cacheAsBitmap = true;
		addChild(this._cursor);
		this.cacheAsBitmap = true;
	}

	// Cursor_Fly.as:20-23
	override public function click():Void {
		this._cursor.gotoAndPlay(2);
	}
}
