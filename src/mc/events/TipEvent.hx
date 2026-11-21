package mc.events;

import openfl.events.Event;

/**
 * mc.events.TipEvent —— TipEvent.as 逐句对应（issue #19 Master2 闭包顺手译）。
 */
@:keep
class TipEvent extends Event {
	// TipEvent.as:10-12
	public static final TIP_SHOW:String = "tipShow";
	public static final TIP_HIDE:String = "tipHide";

	// TipEvent.as:14
	private var _tX:Float = 0;

	// TipEvent.as:16
	private var _tY:Float = 0;

	// TipEvent.as:18
	private var _tipType:String = "";

	// TipEvent.as:20
	private var _tipArgument:Dynamic;

	public function new(param1:String, param2:Bool = false, param3:Bool = false) {
		super(param1, param2, param3);
	}

	// TipEvent.as:29-32（AS3 public get/set tX/tY/tipArgument/tipType 对）
	public var tX(get, set):Float;

	private function get_tX():Float {
		return this._tX;
	}

	private function set_tX(param1:Float):Float {
		this._tX = param1;
		return param1;
	}

	public var tY(get, set):Float;

	private function get_tY():Float {
		return this._tY;
	}

	private function set_tY(param1:Float):Float {
		this._tY = param1;
		return param1;
	}

	public var tipArgument(get, set):Dynamic;

	private function get_tipArgument():Dynamic {
		return this._tipArgument;
	}

	private function set_tipArgument(param1:Dynamic):Dynamic {
		this._tipArgument = param1;
		return param1;
	}

	public var tipType(get, set):String;

	private function get_tipType():String {
		return this._tipType;
	}

	private function set_tipType(param1:String):String {
		this._tipType = param1;
		return param1;
	}
}
