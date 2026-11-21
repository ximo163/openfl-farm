package com.qzone.utils;

import shim.As3;

// com.qzone.utils.DateUtil —— DateUtil.as 逐句对应（issue #9）。AS3
// `final class`（Haxe 无 final 类，语义只差禁止继承，无运行时影响）。
class DateUtil {
	// DateUtil.as:6-9
	public function new() {}

	// DateUtil.as:11-18（时/分/秒拼 HHMMSS 后折回小数时值）
	public static function getTimeNumber(param1:Date):Float {
		var _loc2_:Float = Math.NaN;
		_loc2_ = param1.getHours() * 10000;
		_loc2_ += param1.getMinutes() * 100;
		_loc2_ += param1.getSeconds();
		return _loc2_ / 10000;
	}

	// DateUtil.as:20-26（"Y-M-D H:m:s" 按分隔符拆解；各段是字符串，
	// AS3 Date ctor 隐式 Number 强转经 As3.intOf 复刻）
	public static function getDateFromString(param1:String, param2:String = "-", param3:String = ":"):Date {
		var _loc4_:Array<Dynamic> = param1.split(" ");
		var _loc5_:Array<Dynamic> = Std.string(_loc4_[0]).split(param2);
		var _loc6_:Array<Dynamic> = Std.string(_loc4_[1]).split(param3);
		return new Date(As3.intOf(_loc5_[0]), As3.intOf(_loc5_[1]) - 1, As3.intOf(_loc5_[2]), As3.intOf(_loc6_[0]),
			As3.intOf(_loc6_[1]), As3.intOf(_loc6_[2]));
	}
}
