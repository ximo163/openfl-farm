package com.qzone.qfa.events;

import openfl.events.Event;

// QFAEvent.as 逐句对应。
class QFAEvent extends Event {
	// QFAEvent.as:15
	public static final READY:String = "qfa_ready";

	// QFAEvent.as:17
	public static final UNLOAD:String = "qfa_unload";

	// QFAEvent.as:19
	public static final ERROR:String = "qfa_error";

	// QFAEvent.as:21
	public static final PROGRESS:String = "qfa_progress";

	// QFAEvent.as:23
	public static final REQUEST:String = "qfa_request";

	// QFAEvent.as:25
	public static final COMPLETE:String = "qfa_complete";

	// QFAEvent.as:27
	public static final START:String = "qfa_start";

	// QFAEvent.as:29
	public var data:Dynamic;

	// QFAEvent.as:31-35。原版在 super() 之前按 param2 赋 data，照抄（Haxe 允许
	// 先写本类字段再调 super）
	public function new(param1:String, param2:Dynamic = null, param3:Bool = false, param4:Bool = false) {
		if (param2 != null) {
			this.data = param2;
		}
		super(param1, param3, param4);
	}

	// QFAEvent.as:37-40
	override public function clone():Event {
		return new QFAEvent(type, this.data, bubbles, cancelable);
	}
}
