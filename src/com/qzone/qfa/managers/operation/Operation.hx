package com.qzone.qfa.managers.operation;

import openfl.events.EventDispatcher;

/**
 * com.qzone.qfa.managers.operation.Operation —— write-tests stub（issue #7）：
 * 签名与 legacy/decompiled/main3_v_221/scripts/com/qzone/qfa/managers/operation/Operation.as
 * 一致，方法体 `throw new Error("not implemented")`，实现在翻译阶段完成
 * （url get/set :13-25、send :20-22、close :27-29）。
 */
class Operation extends EventDispatcher implements IOperation {
	// Operation.as:10
	private var _url:String;

	public function new() {
		super();
	}

	// Operation.as:13-18
	public var url(get, set):String;

	private function get_url():String {
		throw new openfl.errors.Error("not implemented");
	}

	// Operation.as:20-22
	public function send(param1:Dynamic = null):Void {
		throw new openfl.errors.Error("not implemented");
	}

	// Operation.as:24-26
	private function set_url(param1:String):String {
		throw new openfl.errors.Error("not implemented");
	}

	// Operation.as:27-29
	public function close():Void {
		throw new openfl.errors.Error("not implemented");
	}
}
