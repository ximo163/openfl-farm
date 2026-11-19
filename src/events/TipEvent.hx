package events;

import openfl.events.Event;

// events.TipEvent —— TipEvent.as 逐句对应。
class TipEvent extends Event {
	// TipEvent.as:9-11
	public static final TIP_HIDE:String = "tipHide";
	public static final TIP_SHOW:String = "tipShow";
	public static final TIP_UPDATE:String = "update";

	// TipEvent.as:13-20
	private var _tX:Float = 0;
	private var _tY:Float = 0;
	private var _tipType:String = "";
	private var _tipArgument:Dynamic;

	// TipEvent.as:22-25
	public function new(param1:String, param2:Bool = false, param3:Bool = false) {
		super(param1, param2, param3);
	}

	// TipEvent.as:27-65
	public var tX(get, set):Float;
	public var tY(get, set):Float;
	public var tipType(get, set):String;
	public var tipArgument(get, set):Dynamic;

	private function get_tY():Float {
		return this._tY;
	}

	private function set_tY(param1:Float):Float {
		this._tY = param1;
		return param1;
	}

	private function get_tX():Float {
		return this._tX;
	}

	private function set_tX(param1:Float):Float {
		this._tX = param1;
		return param1;
	}

	private function get_tipType():String {
		return this._tipType;
	}

	private function set_tipType(param1:String):String {
		this._tipType = param1;
		return param1;
	}

	private function get_tipArgument():Dynamic {
		return this._tipArgument;
	}

	private function set_tipArgument(param1:Dynamic):Dynamic {
		this._tipArgument = param1;
		return param1;
	}
}
