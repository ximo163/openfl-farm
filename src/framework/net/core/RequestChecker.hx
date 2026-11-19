package framework.net.core;

import common.CommonData;
import common.Settings;
import common.misc.Cookies;
import shim.As3;

// framework.net.core.RequestChecker —— RequestChecker.as 逐句对应。
// PORT-NOTE: `_data[param1]` 判键/删键 → Reflect.hasField/deleteField（_data 是
// Cookies 反序列化出的匿名对象）。
@:final
class RequestChecker {
	// RequestChecker.as:11
	private static var _data:Dynamic = null;

	// RequestChecker.as:13
	private static var _errorLimit:Int = 10;

	// RequestChecker.as:15
	private static var _instance:RequestChecker = null;

	public function new() {}

	// RequestChecker.as:21-28
	public static function getInofByUrl(param1:String):Dynamic {
		if (_data == null) {
			return null;
		}
		return Reflect.field(_data, param1);
	}

	// RequestChecker.as:30-71
	public static function checkRequest(param1:String):Bool {
		var _loc3_:Dynamic = null;
		var _loc4_:Int = 0;
		if (param1 == null || param1.length == 0) {
			return false;
		}
		if (_data == null) {
			return true;
		}
		var _loc2_:Bool = false;
		if (param1.indexOf("harvest") == -1 && param1.indexOf("scrounge") == -1 && param1.indexOf("planting") == -1 && param1.indexOf("scarify") == -1) {
			if (param1.indexOf("cgi_farm_index") != -1 && param1.indexOf("flag=1") != -1) {
				_loc2_ = true;
			}
		}
		if (_loc2_) {
			return true;
		}
		_loc2_ = true;
		if (Reflect.hasField(_data, param1)) {
			_loc3_ = Reflect.field(_data, param1);
			if (_loc3_ != null && Std.int(Reflect.field(_loc3_, "limitMinute")) > 0) {
				_loc2_ = false;
				_loc4_ = Std.int(CommonData.serverTime / 60 - Std.int(Reflect.field(_loc3_, "time")) / 60);
				if (_loc4_ >= Std.int(Reflect.field(_loc3_, "limitMinute"))) {
					Reflect.deleteField(_data, param1);
					save();
					_loc2_ = true;
				}
			}
		}
		return _loc2_;
	}

	// RequestChecker.as:73-88
	public static function clean(param1:String):Void {
		if (param1 == null || param1.length == 0) {
			return;
		}
		if (_data == null) {
			return;
		}
		if (Reflect.hasField(_data, param1)) {
			Reflect.deleteField(_data, param1);
			save();
		}
	}

	// RequestChecker.as:90-122
	public static function addErrorRequest(param1:String):Void {
		if (param1 == null || param1.length == 0) {
			return;
		}
		if (_data == null) {
			return;
		}
		var _loc2_:Dynamic = null;
		if (Reflect.hasField(_data, param1)) {
			_loc2_ = Reflect.field(_data, param1);
			Reflect.setField(_loc2_, "errorCount", Std.int(Reflect.field(_loc2_, "errorCount")) + 1);
			Reflect.setField(_loc2_, "time", CommonData.serverTime);
			if (Std.int(Reflect.field(_loc2_, "errorCount")) >= _errorLimit) {
				Reflect.setField(_loc2_, "limitMinute", Std.int(Math.random() * 9 + 1));
			}
		} else {
			_loc2_ = {
				"errorCount": 1,
				"time": CommonData.serverTime,
				"limitMinute": 0,
				"showed": false
			};
		}
		Reflect.setField(_data, param1, _loc2_);
		save();
	}

	// RequestChecker.as:124-132
	public static function initialize():Void {
		if (_instance == null) {
			_errorLimit = Std.int(As3.or(As3.intOf(Settings.getInstance().getStringAttribute("snowslide")), _errorLimit));
			_instance = new RequestChecker();
			_data = As3.or(Cookies.getObject("requestManager2"), {});
		}
	}

	// RequestChecker.as:134-137（AS3 protected static → Haxe private static）
	private static function save():Void {
		Cookies.setObject("requestManager2", _data, 0, false);
	}
}
