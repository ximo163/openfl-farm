package com.qzone.qfa.managers.events;

import openfl.events.Event;

/**
 * com.qzone.qfa.managers.events.RequestEvent —— write-tests stub（issue #7）：
 * 常量与字段签名照抄
 * legacy/decompiled/main3_v_221/scripts/com/qzone/qfa/managers/events/RequestEvent.as
 * （FAULT/RESULT :8/:10、_data :12、构造 :14-22），构造体在翻译阶段实现。
 */
class RequestEvent extends Event {
	// RequestEvent.as:8
	public static final FAULT:String = "RequestFault";

	// RequestEvent.as:10
	public static final RESULT:String = "RequestResult";

	// RequestEvent.as:12
	private var _data:Dynamic;

	public function new(param1:String, param2:Dynamic = null, param3:Bool = false, param4:Bool = false) {
		super(param1, param3, param4);
		throw new openfl.errors.Error("not implemented");
	}

	// RequestEvent.as:21-28（get/set data）
	public var data(get, set):Dynamic;

	private function get_data():Dynamic {
		throw new openfl.errors.Error("not implemented");
	}

	private function set_data(param1:Dynamic):Dynamic {
		throw new openfl.errors.Error("not implemented");
	}
}
