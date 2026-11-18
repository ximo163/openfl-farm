package com.qzone.qfa.model;

import shim.As3;

// DebugLog.as 逐句对应。
class DebugLog {
	// DebugLog.as:11
	public static final LOG:Int = 0;

	// DebugLog.as:13
	public static final WARNING:Int = 1;

	// DebugLog.as:15
	public static final ERROR:Int = 2;

	// DebugLog.as:17
	public static final TRAFFIC:Int = 3;

	// DebugLog.as:19
	public var msg:String;

	// DebugLog.as:21
	public var type:Int;

	// DebugLog.as:23
	public var time:String;

	// DebugLog.as:25-37
	public function new(param1:String, param2:Int = 0, param3:String = "") {
		var _loc4_:Date = null;
		this.type = param2;
		this.msg = param1;
		if (!As3.truthy(this.time)) {
			_loc4_ = Date.now();
			// PORT-NOTE: Haxe Date 没有 getMilliseconds（毫秒分量），
			// Std.int(getTime() % 1000) 与 AS3 同值
			this.time = _loc4_.getHours() + ":" + _loc4_.getMinutes() + ":" + _loc4_.getSeconds() + ":"
				+ Std.int(_loc4_.getTime() % 1000);
		}
	}

	// DebugLog.as:39-42
	public function toStringWithoutFormat():String {
		return this.time + " : \n" + this.msg;
	}

	// DebugLog.as:44-47。AS3 的 /\</g 是全局替换，Haxe 的 StringTools.replace
	// 即全局替换，语义一致
	public function toString():String {
		return "<p class=\'t\'>" + this.time + ":</p><p class=\'m\'>"
			+ StringTools.replace(StringTools.replace(this.msg, "<", "&lt;"), ">", "&gt;") + "</p>";
	}
}
