package mc.view.main.cursor;

import common.MaterialLib;
import openfl.display.MovieClip;

/**
 * mc.view.main.cursor.Cursor_ClearBB —— Cursor_ClearBB.as 逐句对应（issue #87
 * 「光标」片真身）。清杂草光标：ctor 取 "CursorClearBB" 素材挂树，click 时
 * _cursor.gotoAndPlay(2)。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/cursor/Cursor_ClearBB.as。
 */
@:keep
class Cursor_ClearBB extends BaseCursor {
	// Cursor_ClearBB.as:9
	private var _cursor:MovieClip;

	// Cursor_ClearBB.as:11-18
	public function new() {
		super();
		this._cursor = cast MaterialLib.getInstance().getMaterial("CursorClearBB");
		this._cursor.cacheAsBitmap = true;
		addChild(this._cursor);
		this.cacheAsBitmap = true;
	}

	// Cursor_ClearBB.as:20-23
	override public function click():Void {
		this._cursor.gotoAndPlay(2);
	}
}
