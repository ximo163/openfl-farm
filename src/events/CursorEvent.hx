package events;

import openfl.events.Event;

// events.CursorEvent —— CursorEvent.as 逐句对应。
class CursorEvent extends Event {
	// CursorEvent.as:9/:11
	public static final SET_CURSOR:String = "SetCursor";
	public static final SWITCH_CURSOR:String = "SwitchCursor";

	// CursorEvent.as:13-15
	private var _cursorName:String = "";
	private var _cursorArgument:String = "";

	// CursorEvent.as:17-20
	public function new(param1:String, param2:Bool = false, param3:Bool = false) {
		super(param1, param2, param3);
	}

	// CursorEvent.as:22-39
	public var cursorName(get, set):String;
	public var cursorArgument(get, set):String;

	private function get_cursorName():String {
		return this._cursorName;
	}

	private function set_cursorName(param1:String):String {
		this._cursorName = param1;
		return param1;
	}

	private function get_cursorArgument():String {
		return this._cursorArgument;
	}

	private function set_cursorArgument(param1:String):String {
		this._cursorArgument = param1;
		return param1;
	}
}
