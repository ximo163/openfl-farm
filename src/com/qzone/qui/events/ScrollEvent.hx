package com.qzone.qui.events;

import openfl.events.Event;

// com.qzone.qui.events.ScrollEvent —— ScrollEvent.as 逐句对应。滚动条位置
// 变化事件（HScrollBar/VScrollBar → ScrollBase._MOUSE_WHEEL/scrollBarChange）。
// 注意 ctor 形参顺序是 (type, detail, position, direction, delta, ...)——
// param2 是 detail、param4 是 direction，照抄。
class ScrollEvent extends Event {
	// ScrollEvent.as:8
	public static final SCROLL:String = "scroll";

	// ScrollEvent.as:10-16
	private var _direction:String;
	private var _position:Float;
	private var _detail:String;
	private var _delta:Float;

	// ScrollEvent.as:18-25。PORT-NOTE: AS3 的 `Number = NaN` 默认参——Haxe 默认
	// 参要求字面量常量（Math.NaN 不是），缺位语义改 Null<Float> = null、ctor
	// 里归一回 NaN；调用点实传 Float 时行为与原文一致
	public function new(param1:String, param2:String = null, param3:Null<Float> = null, param4:String = null,
			param5:Null<Float> = null, param6:Bool = false, param7:Bool = false) {
		this._position = param3 == null ? Math.NaN : (param3 : Float);
		this._direction = param4;
		this._detail = param2;
		this._delta = param5 == null ? Math.NaN : (param5 : Float);
		super(param1, param6, param7);
	}

	// ScrollEvent.as:27-30
	public var position(get, never):Float;

	private function get_position():Float {
		return this._position;
	}

	// ScrollEvent.as:32-35（AS3 的 super.type 等成员在同实例上取，Haxe 侧
	// 直接读 openfl Event 同名属性）
	override public function toString():String {
		return "[ScrollEvent type=\"" + this.type + "\" position=" + this._position + " direction=\"" + this._direction
			+ "\" bubbles=" + this.bubbles + " cancelable=" + this.cancelable + " eventPhase=" + this.eventPhase + "]";
	}

	// ScrollEvent.as:37-40
	public var detail(get, never):String;

	private function get_detail():String {
		return this._detail;
	}

	// ScrollEvent.as:42-45
	public var delta(get, never):Float;

	private function get_delta():Float {
		return this._delta;
	}

	// ScrollEvent.as:47-50
	public var direction(get, never):String;

	private function get_direction():String {
		return this._direction;
	}
}
