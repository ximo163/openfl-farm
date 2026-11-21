package events;

import openfl.events.Event;

// events.FloatingEvent —— FloatingEvent.as 逐句对应（issue #9 write-tests
// 签名 stub：纯数据事件类，存取对成员按原版直存——farmscene.md 的一句话半
// 成员真实现口径）。FloatControl/FloatingBase 经 msgCenter 派发。
class FloatingEvent extends Event {
	// FloatingEvent.as:9/:11
	public static final FLOATING_CLOSE:String = "floatingClose";
	public static final FLOATING_OPEN:String = "floatingOpen";

	// FloatingEvent.as:13-19
	private var _fid:Int;
	private var _floating:String;
	private var _data:Dynamic;

	// FloatingEvent.as:21-25
	public function new(param1:String, param2:Bool = false, param3:Bool = false) {
		super(param1, param2, param3);
		this._fid = -1;
		this._data = null;
		this._floating = null;
	}

	// FloatingEvent.as:27-35
	public var fid(get, set):Int;

	private function get_fid():Int {
		return this._fid;
	}

	private function set_fid(param1:Int):Int {
		this._fid = param1;
		return param1;
	}

	// FloatingEvent.as:37-41
	public var floating(get, set):String;

	private function get_floating():String {
		return this._floating;
	}

	private function set_floating(param1:String):String {
		this._floating = param1;
		return param1;
	}

	// FloatingEvent.as:43-47
	public var data(get, set):Dynamic;

	private function get_data():Dynamic {
		return this._data;
	}

	private function set_data(param1:Dynamic):Dynamic {
		this._data = param1;
		return param1;
	}
}
