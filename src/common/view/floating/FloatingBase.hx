package common.view.floating;

import interfaces.IMsgCenter;
import openfl.display.Sprite;
import openfl.errors.Error;

/**
 * common.view.floating.FloatingBase —— issue #9 write-tests 签名 stub
 * （FloatingBase.as 82 loc，V3c 飘字片整类翻译）。#7 的闭包壳只有类形态，
 * 本阶段补齐成员签名（extends Sprite、ctor 带 IMsgCenter）。飘字段基类：
 * fid 计数、floatName 注册名、start 落点。方法体 throw not implemented。
 */
@:keep
class FloatingBase extends Sprite {
	// FloatingBase.as:10（静态 fid 计数）
	private static var ID_COUNTER:Int = 0;

	// FloatingBase.as:12-18
	private var _fid:Int;
	private var m_msgCenter:IMsgCenter;
	private var _data:Dynamic;
	private var _name:String;

	// FloatingBase.as:20-26（挂 msgCenter、fid = ID_COUNTER++、名置空串）
	public function new(param1:IMsgCenter) {
		super();
	}

	// FloatingBase.as:28-32
	public var fid(get, set):Int;

	private function get_fid():Int {
		throw new Error("not implemented");
	}

	private function set_fid(param1:Int):Int {
		throw new Error("not implemented");
	}

	// FloatingBase.as:34-45
	public var floatName(get, set):String;

	private function get_floatName():String {
		throw new Error("not implemented");
	}

	private function set_floatName(param1:String):String {
		throw new Error("not implemented");
	}

	// FloatingBase.as:47-65（null 早退；_data 存原对象；x/y 判键后经
	// parseInt 落坐标）
	public function start(param1:Dynamic):Void {
		throw new Error("not implemented");
	}

	// FloatingBase.as:67-80（FloatingEvent.FLOATING_CLOSE 带 floating/fid
	// 经 msgCenter 派发；AS3 protected → Haxe private）
	private function close():Void {
		throw new Error("not implemented");
	}

	// FloatingBase.as:81-82（空实现）
	public function end():Void {}
}
