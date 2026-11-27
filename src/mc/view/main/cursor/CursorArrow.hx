package mc.view.main.cursor;

import common.MaterialLib;
import openfl.display.MovieClip;

/**
 * mc.view.main.cursor.CursorArrow —— CursorArrow.as 逐句对应（issue #87
 * 「光标」片真身）。箭头光标：ctor 取 "CursorArrow" 素材挂树，down 时
 * _cursor.gotoAndPlay(2)、up 回 gotoAndPlay(1)。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/cursor/CursorArrow.as。
 */
@:keep
class CursorArrow extends BaseCursor {
	// CursorArrow.as:9
	private var _cursor:MovieClip;

	// CursorArrow.as:11-17
	public function new() {
		super();
		this._cursor = cast MaterialLib.getInstance().getMaterial("CursorArrow");
		addChild(this._cursor);
		this.cacheAsBitmap = true;
	}

	// CursorArrow.as:19-22
	override public function down():Void {
		this._cursor.gotoAndPlay(2);
	}

	// CursorArrow.as:24-27
	override public function up():Void {
		this._cursor.gotoAndPlay(1);
	}
}
