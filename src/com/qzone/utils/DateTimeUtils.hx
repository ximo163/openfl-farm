package com.qzone.utils;

import shim.As3;

/**
 * com.qzone.utils.DateTimeUtils —— DateTimeUtils.as 逐句对应（issue #18
 * farm-basic 收尾：工具函数片整类翻译）。纯静态工具：秒/毫秒格式化、日期解析、
 * 闰年、同日判断。getTime/getDate/getDateTime/getTimeString 读真实时钟
 * （Date.now()），不进单测，运行行为由 CI 场景比对覆盖。
 */
class DateTimeUtils {
	public function new() {}

	// DateTimeUtils.as:11-14
	public static function getDateTime():String {
		return getDate() + " " + getTime();
	}

	// :16-23
	public static function getTime():String {
		var _loc1_:Date = Date.now();
		var _loc2_:String = _loc1_.getHours() > 9 ? Std.string(_loc1_.getHours()) : "0" + _loc1_.getHours();
		var _loc3_:String = _loc1_.getMinutes() > 9 ? Std.string(_loc1_.getMinutes()) : "0" + _loc1_.getMinutes();
		var _loc4_:String = _loc1_.getSeconds() > 9 ? Std.string(_loc1_.getSeconds()) : "0" + _loc1_.getSeconds();
		return _loc2_ + ":" + _loc3_ + ":" + _loc4_;
	}

	// :25-32
	public static function getDate():String {
		var _loc1_:Date = Date.now();
		var _loc2_:String = Std.string(_loc1_.getFullYear());
		var _loc3_:String = _loc1_.getMonth() + 1 > 9 ? Std.string(_loc1_.getMonth() + 1) : "0" + (_loc1_.getMonth() + 1);
		var _loc4_:String = _loc1_.getDate() > 9 ? Std.string(_loc1_.getDate()) : "0" + _loc1_.getDate();
		return _loc2_ + "-" + _loc3_ + "-" + _loc4_;
	}

	// :34-66（AS3 int 槽位接住 Number 除法 → 隐式截断，param1 > 0 门内
	// floor 与截断同值）
	public static function formatSecondCount(param1:Int, param2:Bool):String {
		var _loc4_:Int = 0;
		var _loc5_:Int = 0;
		var _loc6_:Int = 0;
		var _loc3_:String = "";
		if (param1 > 0) {
			_loc4_ = Std.int(param1 / 3600);
			_loc5_ = Std.int((param1 - _loc4_ * 3600) / 60);
			_loc6_ = param1 - _loc4_ * 3600 - _loc5_ * 60;
			if (param2 == true) {
				if (_loc4_ > 0) {
					_loc3_ = _loc4_ + "小时";
				}
				if (_loc5_ > 0) {
					_loc3_ += _loc5_ + "分";
				}
				if (_loc4_ == 0 && _loc6_ > 0) {
					_loc3_ += _loc6_ + "秒";
				}
			} else {
				_loc3_ += _loc4_ + "小时" + _loc5_ + "分" + _loc6_ + "秒";
			}
		}
		return _loc3_;
	}

	// :68-72（AS3 new Date(y,m,d) 时分秒缺省 0；AS3 parseInt(x,10) →
	// As3.parseInt + Std.int 进 Haxe Date 构造）
	public static function parseDate(param1:String):Date {
		var _loc2_:Array<String> = param1.split("-");
		return new Date(Std.int(As3.parseInt(_loc2_[0])), Std.int(As3.parseInt(_loc2_[1])) - 1,
			Std.int(As3.parseInt(_loc2_[2])), 0, 0, 0);
	}

	// :74-89
	public static function formatMillisecond(param1:Float):String {
		var _loc2_:Int = Math.floor(param1 / 60000);
		var _loc3_:Int = Math.floor(Math.floor(param1 / 1000) % 60);
		var _loc4_:String = Std.string(_loc2_);
		var _loc5_:String = Std.string(_loc3_);
		if (_loc2_ < 10) {
			_loc4_ = "0" + Std.string(_loc2_);
		}
		if (_loc3_ < 10) {
			_loc5_ = "0" + Std.string(_loc3_);
		}
		return _loc4_ + ":" + _loc5_;
	}

	// :91-106
	public static function formatSecond(param1:Float):String {
		var _loc2_:Float = Math.floor(param1 / 60);
		var _loc3_:Float = Math.floor(Math.floor(param1) % 60);
		var _loc4_:String = Std.string(_loc2_);
		var _loc5_:String = Std.string(_loc3_);
		if (_loc2_ < 10) {
			_loc4_ = "0" + Std.string(_loc2_);
		}
		if (_loc3_ < 10) {
			_loc5_ = "0" + Std.string(_loc3_);
		}
		return _loc4_ + ":" + _loc5_;
	}

	// :108-112（Haxe Date 无 getMilliseconds，用 getTime() % 1000 等价——
	// 毫秒位与时区无关，AS3 同源）
	public static function getTimeString():String {
		var _loc1_:Date = Date.now();
		return Std.string(_loc1_.getFullYear()) + Std.string(_loc1_.getMonth() + 1) + Std.string(_loc1_.getDate())
			+ Std.string(_loc1_.getHours()) + Std.string(_loc1_.getMinutes())
			+ Std.string(Std.int(_loc1_.getTime() % 1000));
	}

	// :114-127（AS3 new Date(毫秒) → Haxe Date.fromTime）
	public static function isSameDay(param1:Float, param2:Float):Bool {
		if (param1 == 0) {
			return false;
		}
		var _loc3_:Date = Date.fromTime(param1 * 1000);
		var _loc4_:Date = Date.fromTime(param2 * 1000);
		if (_loc3_.getDate() != _loc4_.getDate()) {
			return false;
		}
		return true;
	}

	// :129-144
	public static function isLeapYear(param1:Float):Bool {
		if (param1 % 100 == 0) {
			if (param1 % 400 == 0) {
				return true;
			}
			return false;
		}
		if (param1 % 4 == 0) {
			return true;
		}
		return false;
	}
}
