package com.qzone.qfa.events;

import openfl.events.Event;

// CommandEvent.as 逐句对应。
class CommandEvent extends Event {
	// CommandEvent.as:12
	public static final REQUEST:String = "RequestCommand";

	// CommandEvent.as:14
	public static final COMPLETE:String = "CommandComplete";

	// CommandEvent.as:16
	public static final ERROR:String = "CommandError";

	// CommandEvent.as:18-30（AS3 Function/Class → Haxe Dynamic/Class<Dynamic>）
	public var body:Dynamic;

	public var dataBindCall:Dynamic;

	public var command:Class<Dynamic>;

	public var completeHandler:Dynamic;

	public var dataBindStr:String;

	public var errorHandler:Dynamic;

	public var result:Dynamic;

	// CommandEvent.as:32-41。字段赋值全部在 super() 之前（原版如此，照抄）
	public function new(param1:String, param2:Class<Dynamic> = null, param3:Dynamic = null, param4:String = "",
			param5:Dynamic = null, param6:Dynamic = null, param7:Dynamic = null, param8:Bool = false, param9:Bool = false) {
		this.command = param2;
		this.body = param3;
		this.dataBindStr = param4;
		this.dataBindCall = param5;
		this.completeHandler = param6;
		this.errorHandler = param7;
		super(param1, param8, param9);
	}
}
