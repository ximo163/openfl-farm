package common;

import com.qzone.corelib.net.RSLLoader;
import com.qzone.corelib.net.RSLManager;
import common.misc.Cookies;
import openfl.system.ApplicationDomain;
import shim.As3.getTimer; // PORT-NOTE: openfl 的 getTimer 在 eval 上纪元溢出为负，见 shim/As3.hx

// CommonData.as 逐句对应。
class CommonData {
	// CommonData.as:12
	public static var _root:Dynamic;

	// CommonData.as:14
	public static var freeGift:Dynamic;

	// CommonData.as:16
	public static var APP_DOMAIN:ApplicationDomain;

	// CommonData.as:18
	public static var swfUrl:String;

	// CommonData.as:20
	public static var speed_indexer:Dynamic;

	// CommonData.as:22
	public static var useExpressUser:Bool;

	// CommonData.as:24
	public static var expressUser:Dynamic;

	// CommonData.as:26
	public static var getRequestData:Dynamic;

	// CommonData.as:28。Function → Dynamic
	public static var addCallBackProxy:Dynamic;

	// CommonData.as:30
	public static var rslManager:RSLManager;

	// CommonData.as:32。Function → Dynamic
	public static var getKey:Dynamic;

	// CommonData.as:34
	public static var applicationDomain:ApplicationDomain;

	// CommonData.as:36
	public static var rslLoader:RSLLoader;

	// CommonData.as:38
	private static var _serverTime:Float = 0;

	// CommonData.as:40
	private static var _clientTime:Float = 0;

	public function new() {
		trace("construct CommonData");
	}

	// CommonData.as:48-68
	public static function beBackTimeIsToday():Bool {
		var _loc1_:Bool = false;
		if (Cookies.getObject("getZhaohui") == null) {
			return false;
		}
		var _loc2_:Date = Date.fromTime(CommonData.serverTime * 1000);
		var _loc3_:Date = Date.fromTime(Reflect.field(Cookies.getObject("getZhaohui"), "time") * 1000);
		if (_loc2_.getFullYear() == _loc3_.getFullYear()) {
			if (_loc2_.getMonth() == _loc3_.getMonth()) {
				if (_loc2_.getDate() == _loc3_.getDate()) {
					_loc1_ = true;
				}
			}
		}
		return _loc1_;
	}

	// CommonData.as:70-73
	public static var root(get, set):Dynamic;

	private static function set_root(param1:Dynamic):Dynamic {
		_root = param1;
		return param1;
	}

	// CommonData.as:75-95
	public static function isCardsGameActivityToday(param1:UInt):Bool {
		var _loc2_:Bool = true;
		var _loc3_:UInt = param1;
		if (Cookies.getObject("cardsgame_" + _loc3_) == null) {
			return _loc2_;
		}
		var _loc4_:Date = Date.fromTime(CommonData.serverTime * 1000);
		var _loc5_:Date = Date.fromTime(Std.int(Cookies.getObject("cardsgame_" + _loc3_)) * 1000);
		if (_loc4_.getFullYear() == _loc5_.getFullYear()) {
			if (_loc4_.getMonth() == _loc5_.getMonth()) {
				if (_loc4_.getDate() == _loc5_.getDate()) {
					_loc2_ = false;
				}
			}
		}
		return _loc2_;
	}

	// CommonData.as:98-124。String.replace(String,String) 只换第一处
	public static function getFormatNumber(param1:Float):String {
		var _loc4_:String = null;
		var _loc2_:String = Std.string(param1);
		var _loc3_:String = "";
		while (_loc2_.length != 0) {
			if (_loc2_.length < 3) {
				_loc4_ = _loc2_.substr(0, _loc2_.length);
			} else {
				_loc4_ = _loc2_.substr(_loc2_.length - 3, _loc2_.length);
			}
			if (_loc3_ != "") {
				_loc3_ = _loc4_ + "," + _loc3_;
			} else {
				_loc3_ += _loc4_;
			}
			_loc2_ = shim.As3.replaceFirst(_loc2_, _loc4_, "");
		}
		return _loc3_;
	}

	// CommonData.as:126-134
	public static var serverTime(get, set):Float;

	private static function set_serverTime(param1:Float):Float {
		if (Math.abs(_serverTime - param1) <= 1) {
			return param1;
		}
		_serverTime = param1;
		_clientTime = Std.int(getTimer() / 1000);
		return param1;
	}

	// CommonData.as:136-139
	private static function get_root():Dynamic {
		return _root;
	}

	// CommonData.as:141-148
	private static function get_serverTime():Float {
		if (_serverTime == 0) {
			return 0;
		}
		return _serverTime + (Math.floor(getTimer() / 1000) - _clientTime);
	}

	// CommonData.as:150-170
	public static function BackHandTimeIsToday(param1:Int):Bool {
		var _loc2_:Bool = false;
		if (Cookies.getObject("z_" + param1) == null) {
			return false;
		}
		var _loc3_:Date = Date.fromTime(CommonData.serverTime * 1000);
		var _loc4_:Date = Date.fromTime(Reflect.field(Cookies.getObject("z_" + param1), "time") * 1000);
		if (_loc3_.getFullYear() == _loc4_.getFullYear()) {
			if (_loc3_.getMonth() == _loc4_.getMonth()) {
				if (_loc3_.getDate() == _loc4_.getDate()) {
					_loc2_ = true;
				}
			}
		}
		return _loc2_;
	}

	// CommonData.as:172-193
	public static function isMonthEndToday(param1:UInt):Bool {
		var _loc2_:Bool = true;
		var _loc3_:UInt = param1;
		if (Cookies.getObject("monthend_" + _loc3_) == null) {
			return _loc2_;
		}
		var _loc4_:Date = Date.fromTime(CommonData.serverTime * 1000);
		var _loc5_:Date = Date.fromTime(Std.int(Cookies.getObject("monthend_" + _loc3_)) * 1000);
		if (_loc4_.getFullYear() == _loc5_.getFullYear()) {
			if (_loc4_.getMonth() == _loc5_.getMonth()) {
				if (_loc4_.getDate() == _loc5_.getDate()) {
					_loc2_ = false;
				}
			}
		}
		return _loc2_;
	}
}
