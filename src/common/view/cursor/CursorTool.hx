package common.view.cursor;

import common.Consts;
import common.misc.Utils;
import openfl.display.MovieClip;
import shim.As3;

/**
 * common.view.cursor.CursorTool —— CursorTool.as 逐句对应（issue #9）。
 * 道具光标：cursorArgument "类型,id" → CursorTool2<id>/有机肥 3<id-30>/
 * 鱼食 Cursor_FishFood_<id> 素材；gotoAndPlay/gotoAndStop 代理给内层素材。
 * AS3 是 dynamic class（运行期可挂属性），原版无调用点往实例挂属性，
 * Haxe 按 普通 class 翻。
 */
@:keep
class CursorTool extends MovieClip {
	// CursorTool.as:10
	private var m_cursor:MovieClip;

	// CursorTool.as:12-16
	public function new() {
		super();
		this.m_cursor = null;
	}

	// CursorTool.as:18-24
	override public function gotoAndPlay(param1:Any, param2:String = null):Void {
		if (this.m_cursor != null) {
			this.m_cursor.gotoAndPlay(param1);
		}
	}

	// CursorTool.as:26-32
	override public function gotoAndStop(param1:Any, param2:String = null):Void {
		if (this.m_cursor != null) {
			this.m_cursor.gotoAndStop(param1);
		}
	}

	// CursorTool.as:34-61（"类型,id" → 素材名；`_loc2_[1] >= ORGANIC_FERTILIZER_ID`
	// 与 `-_loc2_[1] - 常量` 的字符串操作数按 AS3 Number 语义经 As3.floatOf）
	public var cursorArgument(never, set):String;

	private function set_cursorArgument(param1:String):String {
		if (param1 == null || param1 == "") {
			return param1;
		}
		var _loc2_:Array<Dynamic> = param1.split(",");
		if (_loc2_.length != 2) {
			return param1;
		}
		var _loc3_:String = "CursorTool2" + Std.string(_loc2_[1]);
		if (As3.floatOf(_loc2_[1]) >= Consts.ORGANIC_FERTILIZER_ID) {
			_loc3_ = "CursorTool3" + Std.string(As3.floatOf(_loc2_[1]) - Consts.ORGANIC_FERTILIZER_ID);
		}
		if (_loc2_[0] == Consts.ITEM_TYPE_FISHFEED) {
			_loc3_ = "Cursor_FishFood_" + Std.string(_loc2_[1]);
		}
		this.m_cursor = cast Utils.getMaterial(_loc3_);
		if (this.m_cursor == null) {
			return param1;
		}
		this.m_cursor.cacheAsBitmap = true;
		addChild(this.m_cursor);
		return param1;
	}
}
