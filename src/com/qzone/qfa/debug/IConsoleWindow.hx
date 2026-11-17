package com.qzone.qfa.debug;

import openfl.events.IEventDispatcher;

// IConsoleWindow.as 逐句对应（getter/setter 落成 Haxe 属性声明）。
interface IConsoleWindow extends IEventDispatcher {
	function hide():Void;

	var isHidden(get, never):Bool;

	var dataProvider(never, set):Array<Dynamic>;

	var logType(get, set):Int;
}
