package com.adobe.serialization.json;

// JSON.as 逐句对应（as3corelib 门面）。解析器/编码器本体（JSONDecoder/
// JSONEncoder/JSONTokenizer…）不逐类移植，等价落到 haxe.Json：
// PORT-NOTE: as3corelib 与 haxe.Json 的两处严格性差异——
// 1) decode(param1, param2) 第二参允许注释/尾逗号等宽松语法（默认开）。本 swf
//    的 decode 输入全部来自自家 mync.php/宿主 getAppParams，都是标准 JSON
//    语法，等价（deviations 候选）。
// 2) JSONTokenizer.readString（happyfarm3_v_149/scripts/com/adobe/serialization/
//    json/JSONTokenizer.as:277-307）按「下一个未转义引号」定界字符串，串内
//    裸露的控制字符原样进值——真实 xml.php 的 nc_data crops/item_info JSON
//    的 gossip/tip 文本含裸 \n（nc_data.php 源码多行文案）；haxe.Json 在 js
//    目标即 JSON.parse，按 RFC 8259 拒绝串内控制字符（eval 的实现又接受，
//    两目标行为不一致）。decode 里先按同款定界把串内裸控制字符改写成
//    \u00XX 再解析，解析出的值与 as3corelib 逐字符一致。
class JSON {
	public function new() {
	}

	// JSON.as:11-14
	public static function decode(param1:String, param2:Bool = true):Dynamic {
		return haxe.Json.parse(escapeStringControlChars(param1));
	}

	// JSON.as:16-19
	public static function encode(param1:Dynamic):String {
		return haxe.Json.stringify(param1);
	}

	// readString 的定界语义：引号开串，反斜杠转义下一字符（含引号），串内
	// 其余字符（控制字符在内）都属值。只改写串内出现的裸控制字符，串外
	//（含合法空白）不动。先探测（免改写时的整串拷贝），命中再改写
	private static function escapeStringControlChars(param1:String):String {
		if (!hasStringControlChar(param1)) {
			return param1;
		}
		var _loc1_:StringBuf = new StringBuf();
		var _loc2_:Bool = false;
		var _loc3_:Bool = false;
		var _loc4_:Int = 0;
		var _loc5_:Int = 0;
		while (_loc4_ < param1.length) {
			_loc5_ = param1.charCodeAt(_loc4_);
			if (_loc2_) {
				if (_loc3_) {
					_loc1_.addChar(_loc5_);
					_loc3_ = false;
				} else if (_loc5_ == 92) {
					// 反斜杠：转义下一字符
					_loc1_.addChar(_loc5_);
					_loc3_ = true;
				} else if (_loc5_ == 34) {
					_loc1_.addChar(_loc5_);
					_loc2_ = false;
				} else if (_loc5_ < 32) {
					_loc1_.add("\\u00" + StringTools.hex(_loc5_, 2));
				} else {
					_loc1_.addChar(_loc5_);
				}
			} else {
				if (_loc5_ == 34) {
					_loc2_ = true;
				}
				_loc1_.addChar(_loc5_);
			}
			_loc4_++;
		}
		return _loc1_.toString();
	}

	private static function hasStringControlChar(param1:String):Bool {
		var _loc1_:Bool = false;
		var _loc2_:Bool = false;
		var _loc3_:Int = 0;
		var _loc4_:Int = 0;
		while (_loc3_ < param1.length) {
			_loc4_ = param1.charCodeAt(_loc3_);
			if (_loc1_) {
				if (_loc2_) {
					_loc2_ = false;
				} else if (_loc4_ == 92) {
					_loc2_ = true;
				} else if (_loc4_ == 34) {
					_loc1_ = false;
				} else if (_loc4_ < 32) {
					return true;
				}
			} else if (_loc4_ == 34) {
				_loc1_ = true;
			}
			_loc3_++;
		}
		return false;
	}
}
