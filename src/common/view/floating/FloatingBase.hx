package common.view.floating;

import events.FloatingEvent;
import interfaces.IMsgCenter;
import openfl.display.Sprite;
import shim.As3;

/**
 * common.view.floating.FloatingBase —— FloatingBase.as 逐句对应（issue #9）。
 * 飘字段基类：fid 计数、floatName 注册名、start 落点/存数据、close 经
 * msgCenter 派发 FLOATING_CLOSE。AS3 protected（_data）→ Haxe private
 * （子类可见）。
 */
@:keep
class FloatingBase extends Sprite {
	// FloatingBase.as:10（静态 fid 计数）
	private static var ID_COUNTER:Int = 0;

	// FloatingBase.as:12-18
	private var _fid:Int;
	private var m_msgCenter:IMsgCenter;

	// FloatingBase.as:16（AS3 protected → Haxe private，子类可见）
	private var _data:Dynamic;
	private var _name:String;

	// FloatingBase.as:20-26（挂 msgCenter、fid = ID_COUNTER++、名置空串）
	public function new(param1:IMsgCenter) {
		super();
		this.m_msgCenter = param1;
		this._fid = ID_COUNTER++;
		this._name = "";
	}

	// FloatingBase.as:28-31
	public var fid(get, set):Int;

	private function get_fid():Int {
		return this._fid;
	}

	// FloatingBase.as:71-73
	private function set_fid(param1:Int):Int {
		this._fid = param1;
		return param1;
	}

	// FloatingBase.as:33-45
	public var floatName(get, set):String;

	private function get_floatName():String {
		return this._name;
	}

	private function set_floatName(param1:String):String {
		this._name = param1;
		return param1;
	}

	// FloatingBase.as:47-58（null 早退；_data 存原对象；x/y 判键后经
	// parseInt 落坐标）
	public function start(param1:Dynamic):Void {
		if (param1 == null) {
			return;
		}
		this._data = param1;
		if (Reflect.hasField(param1, "x")) {
			this.x = As3.parseInt(Reflect.field(param1, "x"));
		}
		if (Reflect.hasField(param1, "y")) {
			this.y = As3.parseInt(Reflect.field(param1, "y"));
		}
	}

	// FloatingBase.as:60-68（FloatingEvent.FLOATING_CLOSE 带 floating/fid
	// 经 msgCenter 派发；AS3 protected → Haxe private）
	private function close():Void {
		var _loc1_:FloatingEvent = new FloatingEvent(FloatingEvent.FLOATING_CLOSE);
		_loc1_.floating = this._name;
		_loc1_.fid = this._fid;
		if (this.m_msgCenter != null) {
			this.m_msgCenter.dispatchEvent(_loc1_);
		}
	}

	// FloatingBase.as:76-78（空实现）
	public function end():Void {}
}
