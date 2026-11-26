package mc.events;

import openfl.events.Event;

/**
 * mc.events.CommonEvent —— CommonEvent.as 逐句对应（issue #86 牧场库底座，
 * 事件片）。通用数据载荷事件（`*` 形 data）。
 * legacy/decompiled/Master2_v_142/scripts/mc/events/CommonEvent.as。
 */
@:keep
class CommonEvent extends Event {
	// CommonEvent.as:8
	private var _data:Dynamic;

	// :10-13
	public function new(param1:String, param2:Bool = false, param3:Bool = false) {
		super(param1, param2, param3);
	}

	// :15-22（AS3 `*` → Dynamic）
	public var data(get, set):Dynamic;

	private function get_data():Dynamic {
		return this._data;
	}

	private function set_data(param1:Dynamic):Dynamic {
		this._data = param1;
		return param1;
	}
}
