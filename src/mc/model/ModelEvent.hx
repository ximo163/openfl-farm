package mc.model;

import openfl.events.Event;

/**
 * mc.model.ModelEvent —— ModelEvent.as 逐句对应（issue #19 Master2 闭包顺手译）。
 */
@:keep
class ModelEvent extends Event {
	// ModelEvent.as:10
	private var _data:Dynamic;

	public function new(param1:String, param2:Bool = false, param3:Bool = false) {
		super(param1, param2, param3);
	}

	// ModelEvent.as:19-25（AS3 public get/set data 对）
	public var data(get, set):Dynamic;

	private function get_data():Dynamic {
		return this._data;
	}

	private function set_data(param1:Dynamic):Dynamic {
		this._data = param1;
		return param1;
	}
}
