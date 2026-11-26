package mc.view.main.cursor;

import openfl.display.MovieClip;
import openfl.errors.Error;

/**
 * mc.view.main.cursor.CursorArrow —— CursorArrow.as 的签名面 stub（原类
 * 29 loc，issue #87「光标」片充真身）。箭头光标：ctor 取 "CursorArrow"
 * 素材挂树，down 时 _cursor.gotoAndPlay(2)、up 回 gotoAndPlay(1)。成员
 * 签名逐字取自反编译原文，方法体随 implement 充真身。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/cursor/CursorArrow.as。
 */
@:keep
class CursorArrow extends BaseCursor {
	// CursorArrow.as:9
	private var _cursor:MovieClip;

	// CursorArrow.as:11-17（ctor 读 MaterialLib 素材——有依赖副作用，入 stub 掷）
	public function new() {
		super();
		throw new Error("not implemented");
	}

	// CursorArrow.as:19-22
	override public function down():Void {
		throw new Error("not implemented");
	}

	// CursorArrow.as:24-27
	override public function up():Void {
		throw new Error("not implemented");
	}
}
