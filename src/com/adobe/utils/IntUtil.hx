package com.adobe.utils;

// com.adobe.utils.IntUtil —— IntUtil.as 逐句对应（52 loc ≤ 100，随 MD5 整体翻）。
class IntUtil {
	// IntUtil.as:7
	private static var hexChars:String = "0123456789abcdef";

	public function new() {}

	// IntUtil.as:15-35。PORT-NOTE: Haxe 的 & 与 | 同优先级左结合（AS3 是
	// & > ^ > |），混合位运算必须显式括号才能保 AS3 分组
	public static function toHex(param1:Int, param2:Bool = false):String {
		var _loc4_:Int = 0;
		var _loc5_:Int = 0;
		var _loc3_:String = "";
		if (param2) {
			_loc4_ = 0;
			while (_loc4_ < 4) {
				_loc3_ += hexChars.charAt((param1 >> ((3 - _loc4_) * 8 + 4)) & 0x0F) + hexChars.charAt((param1 >> ((3 - _loc4_) * 8)) & 0x0F);
				_loc4_++;
			}
		} else {
			_loc5_ = 0;
			while (_loc5_ < 4) {
				_loc3_ += hexChars.charAt((param1 >> (_loc5_ * 8 + 4)) & 0x0F) + hexChars.charAt((param1 >> (_loc5_ * 8)) & 0x0F);
				_loc5_++;
			}
		}
		return _loc3_;
	}

	// IntUtil.as:37-41。加减高于移位、移位高于 |（两边一致），括号照 AS3 分组写死
	public static function ror(param1:Int, param2:Int):UInt {
		var _loc3_:Int = 32 - param2;
		return (param1 << _loc3_) | (param1 >>> (32 - _loc3_));
	}

	// IntUtil.as:43-46
	public static function rol(param1:Int, param2:Int):Int {
		return (param1 << param2) | (param1 >>> (32 - param2));
	}
}
