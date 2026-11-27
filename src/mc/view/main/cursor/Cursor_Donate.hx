package mc.view.main.cursor;

import common.MaterialLib;
import openfl.display.MovieClip;

/**
 * mc.view.main.cursor.Cursor_Donate —— Cursor_Donate.as 逐句对应（issue #87
 * 「光标」片真身）。捐赠光标：ctor 取 "CursorDonate" 素材挂树，down/up
 * 原文即空体重写（屏蔽基类钩子的任何将来实现）。原文 `final class` 照写。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/cursor/Cursor_Donate.as。
 */
@:keep
final class Cursor_Donate extends BaseCursor {
	// Cursor_Donate.as:9
	private var _cursor:MovieClip;

	// Cursor_Donate.as:11-18
	public function new() {
		super();
		this._cursor = cast MaterialLib.getInstance().getMaterial("CursorDonate");
		this._cursor.cacheAsBitmap = true;
		addChild(this._cursor);
		this.cacheAsBitmap = true;
	}

	// Cursor_Donate.as:20-23（空体重写——原文即空体）
	override public function down():Void {}

	// Cursor_Donate.as:25-28（空体重写——原文即空体）
	override public function up():Void {}
}
