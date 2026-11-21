package com.qzone.qui.events;

import openfl.events.Event;

/**
 * com.qzone.qui.events.ResizeEvent —— ResizeEvent.as 逐句对应（issue #18
 * qui 收尾：事件片）。携带旧宽高的 resize 事件。
 * PORT-NOTE: AS3 `param2:Number = NaN` —— Haxe 默认参必须是常量、Math.NaN
 * 不可作默认值，落成 Null<Float> = null 构造归一（null → NaN），调用点
 * 形参个数与语义不变。
 */
class ResizeEvent extends Event {
	// ResizeEvent.as:6
	public static final RESIZE:String = "resize";

	// :8-11
	public var oldHeight:Float;

	public var oldWidth:Float;

	// :13-18
	public function new(param1:String, param2:Null<Float> = null, param3:Null<Float> = null, param4:Bool = false,
			param5:Bool = false) {
		this.oldHeight = param3 == null ? Math.NaN : param3;
		this.oldWidth = param2 == null ? Math.NaN : param2;
		super(param1, param4, param5);
	}

	// :20-24
	override public function toString():String {
		return "[ResizeEvent type=\"" + super.type + "\" oldWidth=" + this.oldWidth + " oldHeight=" + this.oldHeight
			+ " bubbles=" + super.bubbles + " cancelable=" + super.cancelable + " eventPhase=" + super.eventPhase + "]";
	}
}
