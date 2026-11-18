package com.qzone.qfa.managers.errors;

import openfl.errors.Error;

/**
 * com.qzone.qfa.managers.errors.ConnectionError —— write-tests stub（issue #7）：
 * 常量照抄
 * legacy/decompiled/main3_v_221/scripts/com/qzone/qfa/managers/errors/ConnectionError.as
 * （:6-18），构造体在翻译阶段实现。
 */
class ConnectionError extends Error {
	// ConnectionError.as:6-18
	public static final ERR_IO:String = "io_err";
	public static final ERR_SECURITY:String = "security_err";
	public static final ERR_TIMEOUT:String = "timeout_err";
	public static final ERR_FETAL:String = "fetal_err";
	public static final ERR_TIMEOUT_CONNECT:String = "timeout_connect";
	public static final ERR_TIMEOUT_SEND:String = "timeout_send";
	public static final ERR_TIMEOUT_RECEIVE:String = "timeout_receive";

	public function new(param1:Dynamic = "", param2:Int = 0) {
		super(param1, param2);
		throw new openfl.errors.Error("not implemented");
	}
}
