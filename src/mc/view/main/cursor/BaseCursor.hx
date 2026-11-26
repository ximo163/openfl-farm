package mc.view.main.cursor;

import openfl.display.Sprite;
import openfl.filters.ColorMatrixFilter;
import openfl.filters.GlowFilter;

/**
 * mc.view.main.cursor.BaseCursor —— BaseCursor.as 逐句对应（issue #87「光标」
 * 片真身）。光标基类：cursorArgument 存取、click/down/up 空钩子、
 * setCursorFilter 套 GlowFilter(13434624,1,10,10)+1.1 亮度矩阵、
 * cancelCursorFilter 清空滤镜。
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

	// BaseCursor.as:17-19（空钩子——原文即空体）
	public function down():Void {}

	// BaseCursor.as:21-24/:49-52（cursorArgument 存取）
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

	// BaseCursor.as:34-42（concat 逐段拼出 4×5 亮度矩阵，视觉参数逐字照抄）
	public function setCursorFilter():Void {
		var _loc1_:Array<Dynamic> = new Array<Dynamic>();
		_loc1_ = _loc1_.concat([1.1, 0, 0, 0, 0]);
		_loc1_ = _loc1_.concat([0, 1.1, 0, 0, 0]);
		_loc1_ = _loc1_.concat([0, 0, 1.1, 0, 0]);
		_loc1_ = _loc1_.concat([0, 0, 0, 1, 0]);
		this.filters = [new GlowFilter(13434624, 1, 10, 10), new ColorMatrixFilter(cast _loc1_)];
	}

	// BaseCursor.as:44-47
	public function cancelCursorFilter():Void {
		this.filters = null;
	}
}
