package com.qzone.qfa.events;

import com.qzone.qfa.data.Resource;
import com.qzone.qfa.managers.LoadManager;
import openfl.events.Event;
import openfl.media.ID3Info;

// LoaderEvent.as 逐句对应。
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

	// LoaderEvent.as:49
	public var msg:String = "";

	// LoaderEvent.as:51
	public var id3Info:ID3Info;

	// LoaderEvent.as:53
	public var percentQueue:Float;

	// LoaderEvent.as:55
	public var bytesLoaded:Float;

	// LoaderEvent.as:57
	public var failCount:Int;

	// LoaderEvent.as:59
	public var loadTime:Int;

	// LoaderEvent.as:61
	public var queueLength:Int;

	// LoaderEvent.as:63
	public var bytesTotal:Float;

	// LoaderEvent.as:65
	public var loader:LoadManager;

	// LoaderEvent.as:67
	public var item:Resource;

	// LoaderEvent.as:69
	public var percentItem:Float;

	// LoaderEvent.as:71
	public var queueCount:Int;

	// LoaderEvent.as:75-78
	public function new(param1:String, param2:Bool = false, param3:Bool = false) {
		super(param1, param2, param3);
	}

	// LoaderEvent.as:80-83
	override public function toString():String {
		return formatToString("LoaderEvent", "type", "percentQueue", "percentItem", "item", "queueCount", "failCount",
			"queueLength", "loader", "loadTime");
	}
}
