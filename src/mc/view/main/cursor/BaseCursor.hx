package mc.view.main.cursor;

import openfl.display.Sprite;
import openfl.errors.Error;

/**
 * mc.view.main.cursor.BaseCursor —— BaseCursor.as 的签名面 stub（原类 53 loc，
 * issue #87「光标」片充真身）。光标基类：cursorArgument 存取、click/down/up
 * 空钩子、setCursorFilter 套 GlowFilter(13434624,1,10,10)+1.1 亮度矩阵、
 * cancelCursorFilter 清空。成员签名逐字取自反编译原文。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/cursor/BaseCursor.as。
 */
@:keep
class BaseCursor extends Sprite implements IBaseCursor {
	// BaseCursor.as:10
	private var _cursorArgument:Dynamic;

	// BaseCursor.as:12-15
	public function new() {
		super();
	}

	// BaseCursor.as:17-19（空钩子——原文即空体，入 stub 不掷）
	public function down():Void {}

	// BaseCursor.as:21-24/:49-52（cursorArgument 存取——原文即完整，入 stub）
	public var cursorArgument(get, set):Dynamic;

	private function set_cursorArgument(param1:Dynamic):Dynamic {
		this._cursorArgument = param1;
		return param1;
	}

	private function get_cursorArgument():Dynamic {
		return this._cursorArgument;
	}

	// BaseCursor.as:26-28（空钩子）
	public function click():Void {}

	// BaseCursor.as:30-32（空钩子）
	public function up():Void {}

	// BaseCursor.as:34-42
	public function setCursorFilter():Void {
		throw new Error("not implemented");
	}

	// BaseCursor.as:44-47
	public function cancelCursorFilter():Void {
		throw new Error("not implemented");
	}
}
