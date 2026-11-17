package com.qzone.qfa.config;

import openfl.errors.Error;
import openfl.utils.Dictionary;
import shim.As3;

// QFAError.as 逐句对应。
class QFAError extends Error {
	// QFAError.as:11
	public static final ERR_IO:Int = -100001;

	// QFAError.as:13
	public static final ERR_SECURITY:Int = -100002;

	// QFAError.as:15
	public static final ERR_TIMEOUT:Int = -100003;

	// QFAError.as:17
	public static final ERR_HTTP_STATUS:Int = -100004;

	// QFAError.as:19
	public static final ERR_INVALID_ARGUMENTS:Int = -100010;

	// QFAError.as:21
	public static final ERR_FETAL:Int = -100011;

	// QFAError.as:23
	public static final ERR_TIMEOUT_CONNECT:Int = -100012;

	// QFAError.as:25
	public static final ERR_TIMEOUT_SEND:Int = -100013;

	// QFAError.as:27
	public static final ERR_TIMEOUT_RECEIVE:Int = -100014;

	// QFAError.as:29。键只有 int 错误码和 importConfig 的 String 键，落到
	// StringMap 语义即可（对象键不会出现）
	private static var _err_map:Dictionary<Dynamic, Dynamic> = new Dictionary<Dynamic, Dynamic>();

	// QFAError.as:31-38
	public function new(param1:Dynamic = 0) {
		var _loc2_:String = "";
		if (As3.truthy(_err_map.get(param1))) {
			_loc2_ = _err_map.get(param1);
		}
		super(_loc2_, param1);
	}

	// QFAError.as:40-46
	public function importConfig(param1:Dynamic):Void {
		var _loc2_:String = null;
		for (_loc2_ in Reflect.fields(param1)) {
			_err_map.set(_loc2_, Reflect.field(param1, _loc2_));
		}
	}
}
