package mc.view.main.cursor;

import common.MaterialLib;
import openfl.display.MovieClip;

/**
 * mc.view.main.cursor.Cursor_ShengChan —— Cursor_ShengChan.as 逐句对应
 * （issue #87「光标」片真身）。生产光标：ctor 取 "CursorPesticide" 素材挂树
 * （原文素材名就是 Pesticide，名字与「生产」错位但逐字照抄），click 时
 * _cursor.gotoAndPlay(2)。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/cursor/Cursor_ShengChan.as。
 */
@:keep
class Cursor_ShengChan extends BaseCursor {
	// Cursor_ShengChan.as:9
	private var _cursor:MovieClip;

	// Cursor_ShengChan.as:11-18
	public function new() {
		super();
		this._cursor = cast MaterialLib.getInstance().getMaterial("CursorPesticide");
		this._cursor.cacheAsBitmap = true;
		addChild(this._cursor);
		this.cacheAsBitmap = true;
	}

	// Cursor_ShengChan.as:20-23
	override public function click():Void {
		this._cursor.gotoAndPlay(2);
	}
}
