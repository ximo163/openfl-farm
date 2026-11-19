package com.qzone.qfa.managers.operation;

import openfl.events.EventDispatcher;

// com.qzone.qfa.managers.operation.Operation —— Operation.as 逐句对应。
class Operation extends EventDispatcher implements IOperation {
	// Operation.as:8
	private var _url:String;

	public function new() {
		super();
	}

	// Operation.as:10-18
	public var url(get, set):String;

	private function get_url():String {
		return _url;
	}

	// Operation.as:20-22
	public function send(param1:Dynamic = null):Void {}

	// Operation.as:24-26
	private function set_url(param1:String):String {
		_url = param1;
		return param1;
	}

	// Operation.as:27-29
	public function close():Void {}
}
