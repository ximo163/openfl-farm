package com.qzone.qfa.events;

import openfl.events.Event;

/**
 * write-tests 阶段的最小 stub（issue #3）：签名按
 * legacy/decompiled/happyfarm3_v_149/scripts/com/qzone/qfa/events/LoaderEvent.as，
 * 常量照抄；实例字段（percentQueue/item/queueCount 等）由实现阶段按原版补齐。
 */
class LoaderEvent extends Event {
	// LoaderEvent.as:24
	public static final STATUS_CHANGED:String = "STATUS_CHANGED";

	// LoaderEvent.as:26
	public static final ERROR:String = "ERROR";

	// LoaderEvent.as:28
	public static final START:String = "START";

	// LoaderEvent.as:30
	public static final PROGRESS:String = "PROGRESS";

	// LoaderEvent.as:32
	public static final COMPLETE:String = "COMPLETE";

	// LoaderEvent.as:34
	public static final QUEUE_CHANGED:String = "QUEUE_CHANGED";

	// LoaderEvent.as:36
	public static final QUEUE_START:String = "QUEUE_START";

	// LoaderEvent.as:38
	public static final QUEUE_PROGRESS:String = "QUEUE_PROGRESS";

	// LoaderEvent.as:40
	public static final QUEUE_COMPLETE:String = "QUEUE_COMPLETE";

	// LoaderEvent.as:49-52
	public function new(param1:String, param2:Bool = false, param3:Bool = false) {
		super(param1, param2, param3);
		throw new haxe.Exception("not implemented");
	}
}
