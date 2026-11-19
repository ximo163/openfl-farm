package events;

import openfl.events.Event;

// events.CommonEvent —— CommonEvent.as 逐句对应。
class CommonEvent extends Event {
	// CommonEvent.as:8/:10
	private var _data:Dynamic;
	private var _result:Dynamic;

	// CommonEvent.as:12-17（param2 必填，无默认值）
	public function new(param1:String, param2:Dynamic, param3:Dynamic = null, param4:Bool = false, param5:Bool = false) {
		super(param1, param4, param5);
		this._data = param2;
		this._result = param3;
	}

	// CommonEvent.as:19-37（result set / data set+get）
	public var data(get, set):Dynamic;
	public var result(get, set):Dynamic;

	private function get_data():Dynamic {
		return this._data;
	}

	private function set_data(param1:Dynamic):Dynamic {
		this._data = param1;
		return param1;
	}

	private function get_result():Dynamic {
		return this._result;
	}

	private function set_result(param1:Dynamic):Dynamic {
		this._result = param1;
		return param1;
	}
}
