package com.qzone.qfa.events;

import openfl.events.Event;

// DebugEvent.as 逐句对应。PORT-NOTE: AS3 允许字段赋值先于 super()，Haxe 要求
// super() 在前——log 在 Event 构造过程中不会被读，行为等价。
class DebugEvent extends Event {
	// DebugEvent.as:7
	public static final LOG_UPDATED:String = "DEBUG_LOG_UPDATED";

	// DebugEvent.as:9
	public var log:String;

	// DebugEvent.as:11-15
	public function new(param1:String, param2:String = "") {
		super(param1, false, false);
		this.log = param2;
	}
}
