package com.qzone.qfa.debug;

import openfl.events.EventDispatcher;

// Debugger.as 逐句对应。
class Debugger extends EventDispatcher {
	public function new() {
		super();
	}

	// Debugger.as:13-16
	public static function log(param1:Dynamic):Void {
		QFAConsole.log(param1);
	}

	// Debugger.as:18-21
	public static function clear():Void {
		QFAConsole.clear();
	}
}
