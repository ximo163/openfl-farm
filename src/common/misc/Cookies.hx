package common.misc;

import openfl.events.NetStatusEvent;
import openfl.net.SharedObject;
import openfl.net.SharedObjectFlushStatus;
import shim.Save;

// Cookies.as 逐句对应。
// PORT-NOTE: SharedObject.getLocal → shim.Save.getLocal（CLAUDE.md：SharedObject
// 的平台差异集中到 shim 封装，调用点保持原形态）。
class Cookies {
	// Cookies.as:10
	private static var Cookie:SharedObject = null;

	public function new() {
	}

	// Cookies.as:17-38
	public static function hasObject(param1:String):Bool {
		var _loc4_:Int = 0;
		if (Cookie == null) {
			return false;
		}
		var _loc2_:Bool = false;
		var _loc3_:Int = Std.int(Date.now().getTime());
		if (Reflect.hasField(Cookie.data, param1)) {
			if (Reflect.hasField(Reflect.field(Cookie.data, param1), "time")) {
				_loc4_ = Std.int(Reflect.field(Reflect.field(Cookie.data, param1), "time") - _loc3_);
				if (_loc4_ > 0) {
					_loc2_ = true;
				}
			}
		}
		return _loc2_;
	}

	// Cookies.as:40-65
	public static function setObject(param1:String, param2:Dynamic, param3:Float = 0, param4:Bool = false):Bool {
		var _loc5_:Bool = false;
		if (Cookie == null) {
			return false;
		}
		if (param3 == 0) {
			param3 = new Date(2038, 12, 31, 0, 0, 0).getTime();
		}
		Reflect.setField(Cookie.data, param1, {
			"value": param2,
			"time": param3
		});
		if (param4) {
			_loc5_ = flush();
			if (_loc5_ == false) {
				Reflect.deleteField(Cookie.data, param1);
			}
			return _loc5_;
		}
		return param4;
	}

	// Cookies.as:67-83
	public static function Set(param1:String, param2:String):Bool {
		if (Cookie == null) {
			return false;
		}
		if (param1 == null || param1 == "") {
			return false;
		}
		if (param2 == null || param2 == "") {
			return false;
		}
		Reflect.setField(Cookie.data, param1, param2);
		return flush();
	}

	// Cookies.as:85-123
	public static function getObject(param1:String, param2:Float = 0):Dynamic {
		var returnValue:Dynamic;
		var diff:Float = Math.NaN;
		var name:String = param1;
		var time:Float = param2;
		if (Cookie == null) {
			return null;
		}
		returnValue = null;
		try {
			if (time == 0) {
				time = Date.now().getTime();
			}
			if (Reflect.hasField(Cookie.data, name)) {
				if (Reflect.hasField(Reflect.field(Cookie.data, name), "time")) {
					diff = Reflect.field(Reflect.field(Cookie.data, name), "time") - time;
					if (diff >= 0) {
						returnValue = Reflect.field(Reflect.field(Cookie.data, name), "value");
					}
				} else {
					returnValue = Reflect.field(Cookie.data, name);
				}
			}
		} catch (e:Dynamic) {
			trace("Cookies exception: " + e);
		}
		return returnValue;
	}

	// Cookies.as:125-136
	public static function Get(param1:String):String {
		if (Cookie == null) {
			return null;
		}
		if (param1 == null || param1 == "") {
			return null;
		}
		return Reflect.field(Cookie.data, param1);
	}

	// Cookies.as:138-141
	private static function onNetStatusError(param1:NetStatusEvent):Void {
		trace("Cookies exception: " + param1);
	}

	// Cookies.as:143-168
	private static function flush():Bool {
		var flushResult:String = null;
		if (Cookie == null) {
			return false;
		}
		try {
			flushResult = Cookie.flush();
			if (flushResult == SharedObjectFlushStatus.PENDING) {
				trace("Cookies: PENDING -- 数据超出限制");
			} else if (flushResult == SharedObjectFlushStatus.FLUSHED) {
				trace("Cookies: FlUSHED -- 成功写入");
			}
		} catch (e:Dynamic) {
			trace("Cookies exception: " + e);
			return false;
		}
		return true;
	}

	// Cookies.as:170-184
	public static function clear():Void {
		if (Cookie == null) {
			return;
		}
		try {
			Cookie.clear();
		} catch (e:Dynamic) {
			trace("Cookies exception: " + e);
		}
	}

	// Cookies.as:186-198
	public static function intialize(param1:String):Void {
		var game:String = param1;
		try {
			Cookie = Save.getLocal(game);
			Cookie.addEventListener(NetStatusEvent.NET_STATUS, onNetStatusError, false, 0, true);
		} catch (e:Dynamic) {
			trace("Cookies exception: " + e);
		}
	}
}
