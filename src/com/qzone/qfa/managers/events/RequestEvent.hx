package com.qzone.qfa.managers.events;

import openfl.events.Event;

// com.qzone.qfa.managers.events.RequestEvent —— RequestEvent.as 逐句对应。
// PORT-NOTE: AS3 构造器里 _data 在 super() 之前赋值，Haxe 要求 super 先行，
// 赋值语句顺序对观察者不可见，等价。
class RequestEvent extends Event {
	// RequestEvent.as:8
	public static final FAULT:String = "RequestFault";

	// RequestEvent.as:10
	public static final RESULT:String = "RequestResult";

	// RequestEvent.as:12
	private var _data:Dynamic;

	public function new(param1:String, param2:Dynamic = null, param3:Bool = false, param4:Bool = false) {
		super(param1, param3, param4);
		_data = param2;
	}

	// RequestEvent.as:21-25
	public var data(get, set):Dynamic;

	private function get_data():Dynamic {
		return _data;
	}

	// RequestEvent.as:27-31
	private function set_data(param1:Dynamic):Dynamic {
		_data = param1;
		return param1;
	}
}
