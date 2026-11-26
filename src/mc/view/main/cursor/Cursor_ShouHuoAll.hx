package mc.view.main.cursor;

import common.MaterialLib;
import openfl.display.MovieClip;

/**
 * mc.view.main.cursor.Cursor_ShouHuoAll —— Cursor_ShouHuoAll.as 逐句对应
 * （issue #87「光标」片真身）。一键收获光标：ctor 取 "CursorShouHuoAll"
 * 素材挂树，down 时 _cursor.gotoAndStop(3)、up 回 gotoAndStop(1)。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/cursor/Cursor_ShouHuoAll.as。
 */
@:keep
class Cursor_ShouHuoAll extends BaseCursor {
	// Cursor_ShouHuoAll.as:9
	private var _cursor:MovieClip;

	// Cursor_ShouHuoAll.as:11-18
	public function new() {
		super();
		this._cursor = cast MaterialLib.getInstance().getMaterial("CursorShouHuoAll");
		this._cursor.cacheAsBitmap = true;
		addChild(this._cursor);
		this.cacheAsBitmap = true;
	}

	// Cursor_ShouHuoAll.as:20-23
	override public function down():Void {
		this._cursor.gotoAndStop(3);
	}

	// Cursor_ShouHuoAll.as:25-28
	override public function up():Void {
		this._cursor.gotoAndStop(1);
	}
}
