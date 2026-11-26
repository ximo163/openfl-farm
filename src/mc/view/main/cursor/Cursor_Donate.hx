package mc.view.main.cursor;

import openfl.display.MovieClip;
import openfl.errors.Error;

/**
 * mc.view.main.cursor.Cursor_Donate —— Cursor_Donate.as 的签名面 stub
 * （原类 27 loc，issue #87「光标」片充真身）。捐赠光标：ctor 取
 * "CursorDonate" 素材挂树，down/up 原文即空体重写（入 stub 不掷）。成员
 * 签名逐字取自反编译原文，方法体随 implement 充真身。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/cursor/Cursor_Donate.as。
 */
@:keep
class Cursor_Donate extends BaseCursor {
	// Cursor_Donate.as:9
	private var _cursor:MovieClip;

	// Cursor_Donate.as:11-18（ctor 读 MaterialLib 素材——有依赖副作用，入 stub 掷）
	public function new() {
		super();
		throw new Error("not implemented");
	}

	// Cursor_Donate.as:20-23（空体重写——原文即空体，入 stub 不掷）
	override public function down():Void {}

	// Cursor_Donate.as:25-28（空体重写——原文即空体，入 stub 不掷）
	override public function up():Void {}
}
