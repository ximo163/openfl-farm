package com.adobe.utils;

/**
 * com.adobe.utils.StringUtil —— StringUtil.as 逐句对应（issue #43 整类补齐，
 * 替换 #7 只翻 trim 的闭包 stub）。裁剪判据 charCode > 32：空格/\t/\n/\r 被裁，
 * U+00A0（160）保留——StringTools.trim 同判据，等价（测试两侧实现同值钉过）。
 */
@:keep
class StringUtil {
	// StringUtil.as:11-14
	public static function beginsWith(param1:String, param2:String):Bool {
		return param2 == param1.substring(0, param2.length);
	}

	// StringUtil.as:16-19
	public static function trim(param1:String):String {
		return StringUtil.ltrim(StringUtil.rtrim(param1));
	}

	// StringUtil.as:21-28
	public static function stringsAreEqual(param1:String, param2:String, param3:Bool):Bool {
		if (param3) {
			return param1 == param2;
		}
		return param1.toUpperCase() == param2.toUpperCase();
	}

	// StringUtil.as:30-63（replace：手工逐字符扫描，命中即跳过整段针串不重叠
	// 匹配；continue 展开为 _loc8_ 双自增——AS3 for 头部的 _loc8_++ 在 continue
	// 后仍执行）
	public static function replace(param1:String, param2:String, param3:String):String {
		var _loc9_:Int = 0;
		var _loc4_:String = "";
		var _loc5_:Bool = false;
		var _loc6_:Int = param1.length;
		var _loc7_:Int = param2.length;
		var _loc8_:Int = 0;
		while (_loc8_ < _loc6_) {
			if (param1.charAt(_loc8_) == param2.charAt(0)) {
				_loc5_ = true;
				_loc9_ = 0;
				while (_loc9_ < _loc7_) {
					if (param1.charAt(_loc8_ + _loc9_) != param2.charAt(_loc9_)) {
						_loc5_ = false;
						break;
					}
					_loc9_++;
				}
				if (_loc5_) {
					_loc4_ += param3;
					_loc8_ += _loc7_ - 1;
					_loc8_++;
					continue;
				}
			}
			_loc4_ += param1.charAt(_loc8_);
			_loc8_++;
		}
		return _loc4_;
	}

	// StringUtil.as:65-78
	public static function rtrim(param1:String):String {
		var _loc2_:Int = param1.length;
		var _loc3_:Int = _loc2_;
		while (_loc3_ > 0) {
			if (param1.charCodeAt(_loc3_ - 1) > 32) {
				return param1.substring(0, _loc3_);
			}
			_loc3_--;
		}
		return "";
	}

	// StringUtil.as:80-83
	public static function endsWith(param1:String, param2:String):Bool {
		return param2 == param1.substring(param1.length - param2.length);
	}

	// StringUtil.as:85-88
	public static function stringHasValue(param1:String):Bool {
		return param1 != null && param1.length > 0;
	}

	// StringUtil.as:90-93
	public static function remove(param1:String, param2:String):String {
		return StringUtil.replace(param1, param2, "");
	}

	// StringUtil.as:95-108
	public static function ltrim(param1:String):String {
		var _loc2_:Int = param1.length;
		var _loc3_:Int = 0;
		while (_loc3_ < _loc2_) {
			if (param1.charCodeAt(_loc3_) > 32) {
				return param1.substring(_loc3_);
			}
			_loc3_++;
		}
		return "";
	}

	public function new() {}
}
