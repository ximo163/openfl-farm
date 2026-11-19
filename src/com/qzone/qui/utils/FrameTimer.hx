package com.qzone.qui.utils;

import openfl.events.EventDispatcher;

/**
 * com.qzone.qui.utils.FrameTimer —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * qui 帧定时器（FrameTimer.as 192 loc，ENTER_FRAME 驱动的 setTimeout/
 * setInterval 替代品）；Main.setup 只调 init(this)，定时语义随 qui 片翻译。
 */
@:keep
class FrameTimer extends EventDispatcher {
	public function new(param1:Float, param2:Int = 0) {
		super();
	}

	// FrameTimer.as:42-（帧驱动的 setTimeout，qui 片翻译）
	public static function setTimeout(param1:Dynamic, param2:Float, param3:Array<Dynamic> = null):UInt {
		return 0;
	}

	// FrameTimer.as:53-（帧驱动的 setInterval，qui 片翻译）
	public static function setInterval(param1:Dynamic, param2:Float, param3:Array<Dynamic> = null):UInt {
		return 0;
	}

	// FrameTimer.as:63-
	public static function clear(param1:UInt):Void {}

	// FrameTimer.as:76-（init：挂显示对象收 ENTER_FRAME，qui 片翻译）
	public static function init(param1:Dynamic):Void {}

	// FrameTimer.as:85-
	public static function clearInterval(param1:UInt):Void {}

	// FrameTimer.as:103-
	public static function clearTimeout(param1:UInt):Void {}
}
