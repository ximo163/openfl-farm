package com.minutes.ui.core;

import openfl.events.Event;

/**
 * com.minutes.ui.core.UIEvent —— UIEvent.as 逐句对应（issue #19 Master2
 * 闭包顺手译）。
 */
@:keep
class UIEvent extends Event {
	// UIEvent.as:8-14
	public static final RESIZE:String = "resize";
	public static final SCROLL_CONTENT_CHANGE:String = "scrollContentChange";
	public static final TEXT_CHANGE:String = "textChange";
	public static final CLOSE:String = "close";

	private var _data:Dynamic;

	public function new(param1:String, param2:Bool = false, param3:Bool = false) {
		super(param1, param2, param3);
	}

	// UIEvent.as:23-31
	public var data(get, set):Dynamic;

	private function get_data():Dynamic {
		return this._data;
	}

	private function set_data(param1:Dynamic):Dynamic {
		this._data = param1;
		return param1;
	}
}
