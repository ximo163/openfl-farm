package mc.view.main.cursor;

import openfl.display.MovieClip;
import openfl.errors.Error;

/**
 * mc.view.main.cursor.CursorAPI —— CursorAPI.as 的签名面 stub（原类 29 loc，
 * issue #87「光标」片充真身）。API 素材光标：ctor 按 materialName 取
 * MaterialLib 素材当光标皮（cacheAsBitmap），click 时 _cursor.gotoAndPlay(2)，
 * cursorArgument setter 仅转 super。成员签名逐字取自反编译原文，方法体
 * 随 implement 充真身。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/cursor/CursorAPI.as。
 */
@:keep
class CursorAPI extends BaseCursor {
	// CursorAPI.as:9
	private var _cursor:MovieClip;

	// CursorAPI.as:11-17（ctor 读 MaterialLib 素材并挂树——有依赖副作用，入 stub 掷）
	public function new(param1:String = null) {
		super();
		throw new Error("not implemented");
	}

	// CursorAPI.as:19-22
	override public function click():Void {
		throw new Error("not implemented");
	}

	// CursorAPI.as:24-27（原文仅 super.cursorArgument = param1——转发逻辑归
	// implement，入 stub 掷）
	override private function set_cursorArgument(param1:Dynamic):Dynamic {
		throw new Error("not implemented");
	}
}
