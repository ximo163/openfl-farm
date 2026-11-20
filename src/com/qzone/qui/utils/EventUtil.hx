package com.qzone.qui.utils;

import openfl.events.Event;

// com.qzone.qui.utils.EventUtil —— EventUtil.as 逐句对应。AS3 `final class`
// 无本仓 Haxe 对应写法，事件拦截静态工具（ScrollBase._MOUSE_WHEEL 用
// stopAll 合并拦截）。
class EventUtil {
	// EventUtil.as:13-15
	public static function preventDefault(param1:Event):Void {
		param1.preventDefault();
	}

	// EventUtil.as:17-19
	public static function stopPropagation(param1:Event):Void {
		param1.stopPropagation();
	}

	// EventUtil.as:21-23
	public static function stopImmediatePropagation(param1:Event):Void {
		param1.stopImmediatePropagation();
	}

	// EventUtil.as:25-32
	public static function stopAll(param1:Event):Void {
		param1.stopPropagation();
		param1.stopImmediatePropagation();
		param1.preventDefault();
	}

	// EventUtil.as:8-11
	public function new() {}
}
