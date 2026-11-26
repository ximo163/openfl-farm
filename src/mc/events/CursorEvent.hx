package mc.events;

import openfl.events.Event;

/**
 * mc.events.CursorEvent —— CursorEvent.as 逐句对应（issue #86 牧场库底座，
 * 事件片）。光标切换事件：cursorName/materialName/cursorArgument 三载荷 +
 * disabled 公共位。
 * legacy/decompiled/Master2_v_142/scripts/mc/events/CursorEvent.as。
 */
@:keep
class CursorEvent extends Event {
	// CursorEvent.as:8-12
	public static final CURSOR:String = "setCursor";
	public static final USE_TYPE:String = "useType";
	public static final API:String = "api";

	// :14
	private var _cursorName:String = "";

	// :16
	private var _materialName:String = "";

	// :18
	private var _cursorArgument:Dynamic;

	// :20
	public var disabled:Bool = false;

	// :22-25
	public function new(param1:String, param2:Bool = false, param3:Bool = false) {
		super(param1, param2, param3);
	}

	// :27-30/:32-35
	public var cursorName(get, set):String;

	private function get_cursorName():String {
		return this._cursorName;
	}

	private function set_cursorName(param1:String):String {
		this._cursorName = param1;
		return param1;
	}

	// :37-40/:47-50
	public var materialName(get, set):String;

	private function get_materialName():String {
		return this._materialName;
	}

	private function set_materialName(param1:String):String {
		this._materialName = param1;
		return param1;
	}

	// :42-45/:52-55
	public var cursorArgument(get, set):Dynamic;

	private function get_cursorArgument():Dynamic {
		return this._cursorArgument;
	}

	private function set_cursorArgument(param1:Dynamic):Dynamic {
		this._cursorArgument = param1;
		return param1;
	}
}
