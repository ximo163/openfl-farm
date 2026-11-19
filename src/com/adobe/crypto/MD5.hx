package com.adobe.crypto;

import com.adobe.utils.IntUtil;
import openfl.utils.ByteArray;

// com.adobe.crypto.MD5 —— MD5.as 逐句对应（190 loc ≤ 100 规则之外，但它是
// Main.getKey farmKey 的关键路径——CI 冒烟里真实 PHP 后端校验 farmKey，
// 照原版整体翻译，不引入 haxe.crypto.md5）。
// PORT-NOTE: AS3 int 算术即 Int32 回绕，Haxe Int 在 eval/js 上同语义；
// createBlocks 的稀疏数组（AS3 空洞读 undefined、进位运算按 0）补一遍 0，
// 见函数尾注释。
class MD5 {
	// MD5.as:9
	public static var digest:ByteArray;

	public function new() {}

	// MD5.as:24-27
	private static function ff(param1:Int, param2:Int, param3:Int, param4:Int, param5:Int, param6:Int, param7:Int):Int {
		return transform(f, param1, param2, param3, param4, param5, param6, param7);
	}

	// MD5.as:29-32。PORT-NOTE: Haxe 的 & 与 | 同优先级左结合（AS3 是
	// & > ^ > |），混合位运算显式括号保 AS3 分组
	private static function f(param1:Int, param2:Int, param3:Int):Int {
		return (param1 & param2) | (~param1 & param3);
	}

	// MD5.as:34-37
	private static function g(param1:Int, param2:Int, param3:Int):Int {
		return (param1 & param3) | (param2 & ~param3);
	}

	// MD5.as:39-42
	private static function h(param1:Int, param2:Int, param3:Int):Int {
		return param1 ^ param2 ^ param3;
	}

	// MD5.as:44-47
	private static function i(param1:Int, param2:Int, param3:Int):Int {
		return param2 ^ (param1 | ~param3);
	}

	// MD5.as:49-53。Function → 具名函数类型
	private static function transform(param1:Int->Int->Int->Int, param2:Int, param3:Int, param4:Int, param5:Int, param6:Int, param7:Int, param8:Int):Int {
		var _loc9_:Int = param2 + Std.int(param1(param3, param4, param5)) + param6 + param8;
		return IntUtil.rol(_loc9_, param7) + param3;
	}

	// MD5.as:55-58
	private static function hh(param1:Int, param2:Int, param3:Int, param4:Int, param5:Int, param6:Int, param7:Int):Int {
		return transform(h, param1, param2, param3, param4, param5, param6, param7);
	}

	// MD5.as:60-64
	public static function hash(param1:String):String {
		var _loc2_:ByteArray = new ByteArray();
		_loc2_.writeUTFBytes(param1);
		return hashBinary(_loc2_);
	}

	// MD5.as:66-78。`param1[_loc5_ / 8]`：AS3 除法得 Number 再作下标（隐式
	// 取整），_loc5_ 步进 8 恒整除，Std.int 等价。
	// PORT-NOTE: 稀疏数组读（AS3 undefined 进位运算按 0）→ 越界判下标、
	// 洞位读经 Dynamic 判 null（静态目标 Array<Int> 与 null 比较不过编译，
	// 且其洞位本就是 0；动态目标洞位是 null），两边语义同为「缺位补 0」
	private static function readWord(param1:Array<Int>, param2:Int):Int {
		if (param2 < 0 || param2 >= param1.length) {
			return 0;
		}
		var _loc3_:Dynamic = param1[param2];
		if (_loc3_ == null) {
			return 0;
		}
		return _loc3_;
	}

	private static function createBlocks(param1:ByteArray):Array<Int> {
		var _loc2_:Array<Int> = new Array<Int>();
		var _loc3_:Int = param1.length * 8;
		var _loc4_:Int = 255;
		var _loc5_:Int = 0;
		while (_loc5_ < _loc3_) {
			_loc2_[Std.int(_loc5_ >> 5)] = readWord(_loc2_, Std.int(_loc5_ >> 5)) | ((param1[Std.int(_loc5_ / 8)] & _loc4_) << (_loc5_ % 32));
			_loc5_ += 8;
		}
		_loc2_[Std.int(_loc3_ >> 5)] = readWord(_loc2_, Std.int(_loc3_ >> 5)) | (128 << (_loc3_ % 32));
		_loc2_[Std.int((_loc3_ + 64 >>> 9 << 4) + 14)] = _loc3_;
		// PORT-NOTE: 长度字与数据字之间的空洞、以及尾块第 16 个字（长度字在
		// 第 15 下标、数组永远缺 1 个字到 16 对齐）在 AS3 里读出 undefined、轮
		// 函数按 0 用；这里统一走 readWord 归一化（动态目标洞位是 null 补 0，
		// 静态目标 Array<Int> 没有 null、洞位已是 0，赋 0 是空操作）
		var _loc6_:Int = 0;
		while (_loc6_ < _loc2_.length) {
			_loc2_[_loc6_] = readWord(_loc2_, _loc6_);
			_loc6_++;
		}
		while (_loc2_.length % 16 != 0) {
			_loc2_.push(0);
		}
		return _loc2_;
	}

	// MD5.as:80-197
	public static function hashBinary(param1:ByteArray):String {
		var _loc6_:Int = 0;
		var _loc7_:Int = 0;
		var _loc8_:Int = 0;
		var _loc9_:Int = 0;
		var _loc2_:Int = 1732584193;
		var _loc3_:Int = -271733879;
		var _loc4_:Int = -1732584194;
		var _loc5_:Int = 271733878;
		var _loc10_:Array<Int> = createBlocks(param1);
		var _loc11_:Int = Std.int(_loc10_.length);
		var _loc12_:Int = 0;
		while (_loc12_ < _loc11_) {
			_loc6_ = _loc2_;
			_loc7_ = _loc3_;
			_loc8_ = _loc4_;
			_loc9_ = _loc5_;
			_loc2_ = ff(_loc2_, _loc3_, _loc4_, _loc5_, _loc10_[Std.int(_loc12_ + 0)], 7, -680876936);
			_loc5_ = ff(_loc5_, _loc2_, _loc3_, _loc4_, _loc10_[Std.int(_loc12_ + 1)], 12, -389564586);
			_loc4_ = ff(_loc4_, _loc5_, _loc2_, _loc3_, _loc10_[Std.int(_loc12_ + 2)], 17, 606105819);
			_loc3_ = ff(_loc3_, _loc4_, _loc5_, _loc2_, _loc10_[Std.int(_loc12_ + 3)], 22, -1044525330);
			_loc2_ = ff(_loc2_, _loc3_, _loc4_, _loc5_, _loc10_[Std.int(_loc12_ + 4)], 7, -176418897);
			_loc5_ = ff(_loc5_, _loc2_, _loc3_, _loc4_, _loc10_[Std.int(_loc12_ + 5)], 12, 1200080426);
			_loc4_ = ff(_loc4_, _loc5_, _loc2_, _loc3_, _loc10_[Std.int(_loc12_ + 6)], 17, -1473231341);
			_loc3_ = ff(_loc3_, _loc4_, _loc5_, _loc2_, _loc10_[Std.int(_loc12_ + 7)], 22, -45705983);
			_loc2_ = ff(_loc2_, _loc3_, _loc4_, _loc5_, _loc10_[Std.int(_loc12_ + 8)], 7, 1770035416);
			_loc5_ = ff(_loc5_, _loc2_, _loc3_, _loc4_, _loc10_[Std.int(_loc12_ + 9)], 12, -1958414417);
			_loc4_ = ff(_loc4_, _loc5_, _loc2_, _loc3_, _loc10_[Std.int(_loc12_ + 10)], 17, -42063);
			_loc3_ = ff(_loc3_, _loc4_, _loc5_, _loc2_, _loc10_[Std.int(_loc12_ + 11)], 22, -1990404162);
			_loc2_ = ff(_loc2_, _loc3_, _loc4_, _loc5_, _loc10_[Std.int(_loc12_ + 12)], 7, 1804603682);
			_loc5_ = ff(_loc5_, _loc2_, _loc3_, _loc4_, _loc10_[Std.int(_loc12_ + 13)], 12, -40341101);
			_loc4_ = ff(_loc4_, _loc5_, _loc2_, _loc3_, _loc10_[Std.int(_loc12_ + 14)], 17, -1502002290);
			_loc3_ = ff(_loc3_, _loc4_, _loc5_, _loc2_, _loc10_[Std.int(_loc12_ + 15)], 22, 1236535329);
			_loc2_ = gg(_loc2_, _loc3_, _loc4_, _loc5_, _loc10_[Std.int(_loc12_ + 1)], 5, -165796510);
			_loc5_ = gg(_loc5_, _loc2_, _loc3_, _loc4_, _loc10_[Std.int(_loc12_ + 6)], 9, -1069501632);
			_loc4_ = gg(_loc4_, _loc5_, _loc2_, _loc3_, _loc10_[Std.int(_loc12_ + 11)], 14, 643717713);
			_loc3_ = gg(_loc3_, _loc4_, _loc5_, _loc2_, _loc10_[Std.int(_loc12_ + 0)], 20, -373897302);
			_loc2_ = gg(_loc2_, _loc3_, _loc4_, _loc5_, _loc10_[Std.int(_loc12_ + 5)], 5, -701558691);
			_loc5_ = gg(_loc5_, _loc2_, _loc3_, _loc4_, _loc10_[Std.int(_loc12_ + 10)], 9, 38016083);
			_loc4_ = gg(_loc4_, _loc5_, _loc2_, _loc3_, _loc10_[Std.int(_loc12_ + 15)], 14, -660478335);
			_loc3_ = gg(_loc3_, _loc4_, _loc5_, _loc2_, _loc10_[Std.int(_loc12_ + 4)], 20, -405537848);
			_loc2_ = gg(_loc2_, _loc3_, _loc4_, _loc5_, _loc10_[Std.int(_loc12_ + 9)], 5, 568446438);
			_loc5_ = gg(_loc5_, _loc2_, _loc3_, _loc4_, _loc10_[Std.int(_loc12_ + 14)], 9, -1019803690);
			_loc4_ = gg(_loc4_, _loc5_, _loc2_, _loc3_, _loc10_[Std.int(_loc12_ + 3)], 14, -187363961);
			_loc3_ = gg(_loc3_, _loc4_, _loc5_, _loc2_, _loc10_[Std.int(_loc12_ + 8)], 20, 1163531501);
			_loc2_ = gg(_loc2_, _loc3_, _loc4_, _loc5_, _loc10_[Std.int(_loc12_ + 13)], 5, -1444681467);
			_loc5_ = gg(_loc5_, _loc2_, _loc3_, _loc4_, _loc10_[Std.int(_loc12_ + 2)], 9, -51403784);
			_loc4_ = gg(_loc4_, _loc5_, _loc2_, _loc3_, _loc10_[Std.int(_loc12_ + 7)], 14, 1735328473);
			_loc3_ = gg(_loc3_, _loc4_, _loc5_, _loc2_, _loc10_[Std.int(_loc12_ + 12)], 20, -1926607734);
			_loc2_ = hh(_loc2_, _loc3_, _loc4_, _loc5_, _loc10_[Std.int(_loc12_ + 5)], 4, -378558);
			_loc5_ = hh(_loc5_, _loc2_, _loc3_, _loc4_, _loc10_[Std.int(_loc12_ + 8)], 11, -2022574463);
			_loc4_ = hh(_loc4_, _loc5_, _loc2_, _loc3_, _loc10_[Std.int(_loc12_ + 11)], 16, 1839030562);
			_loc3_ = hh(_loc3_, _loc4_, _loc5_, _loc2_, _loc10_[Std.int(_loc12_ + 14)], 23, -35309556);
			_loc2_ = hh(_loc2_, _loc3_, _loc4_, _loc5_, _loc10_[Std.int(_loc12_ + 1)], 4, -1530992060);
			_loc5_ = hh(_loc5_, _loc2_, _loc3_, _loc4_, _loc10_[Std.int(_loc12_ + 4)], 11, 1272893353);
			_loc4_ = hh(_loc4_, _loc5_, _loc2_, _loc3_, _loc10_[Std.int(_loc12_ + 7)], 16, -155497632);
			_loc3_ = hh(_loc3_, _loc4_, _loc5_, _loc2_, _loc10_[Std.int(_loc12_ + 10)], 23, -1094730640);
			_loc2_ = hh(_loc2_, _loc3_, _loc4_, _loc5_, _loc10_[Std.int(_loc12_ + 13)], 4, 681279174);
			_loc5_ = hh(_loc5_, _loc2_, _loc3_, _loc4_, _loc10_[Std.int(_loc12_ + 0)], 11, -358537222);
			_loc4_ = hh(_loc4_, _loc5_, _loc2_, _loc3_, _loc10_[Std.int(_loc12_ + 3)], 16, -722521979);
			_loc3_ = hh(_loc3_, _loc4_, _loc5_, _loc2_, _loc10_[Std.int(_loc12_ + 6)], 23, 76029189);
			_loc2_ = hh(_loc2_, _loc3_, _loc4_, _loc5_, _loc10_[Std.int(_loc12_ + 9)], 4, -640364487);
			_loc5_ = hh(_loc5_, _loc2_, _loc3_, _loc4_, _loc10_[Std.int(_loc12_ + 12)], 11, -421815835);
			_loc4_ = hh(_loc4_, _loc5_, _loc2_, _loc3_, _loc10_[Std.int(_loc12_ + 15)], 16, 530742520);
			_loc3_ = hh(_loc3_, _loc4_, _loc5_, _loc2_, _loc10_[Std.int(_loc12_ + 2)], 23, -995338651);
			_loc2_ = ii(_loc2_, _loc3_, _loc4_, _loc5_, _loc10_[Std.int(_loc12_ + 0)], 6, -198630844);
			_loc5_ = ii(_loc5_, _loc2_, _loc3_, _loc4_, _loc10_[Std.int(_loc12_ + 7)], 10, 1126891415);
			_loc4_ = ii(_loc4_, _loc5_, _loc2_, _loc3_, _loc10_[Std.int(_loc12_ + 14)], 15, -1416354905);
			_loc3_ = ii(_loc3_, _loc4_, _loc5_, _loc2_, _loc10_[Std.int(_loc12_ + 5)], 21, -57434055);
			_loc2_ = ii(_loc2_, _loc3_, _loc4_, _loc5_, _loc10_[Std.int(_loc12_ + 12)], 6, 1700485571);
			_loc5_ = ii(_loc5_, _loc2_, _loc3_, _loc4_, _loc10_[Std.int(_loc12_ + 3)], 10, -1894986606);
			_loc4_ = ii(_loc4_, _loc5_, _loc2_, _loc3_, _loc10_[Std.int(_loc12_ + 10)], 15, -1051523);
			_loc3_ = ii(_loc3_, _loc4_, _loc5_, _loc2_, _loc10_[Std.int(_loc12_ + 1)], 21, -2054922799);
			_loc2_ = ii(_loc2_, _loc3_, _loc4_, _loc5_, _loc10_[Std.int(_loc12_ + 8)], 6, 1873313359);
			_loc5_ = ii(_loc5_, _loc2_, _loc3_, _loc4_, _loc10_[Std.int(_loc12_ + 15)], 10, -30611744);
			_loc4_ = ii(_loc4_, _loc5_, _loc2_, _loc3_, _loc10_[Std.int(_loc12_ + 6)], 15, -1560198380);
			_loc3_ = ii(_loc3_, _loc4_, _loc5_, _loc2_, _loc10_[Std.int(_loc12_ + 13)], 21, 1309151649);
			_loc2_ = ii(_loc2_, _loc3_, _loc4_, _loc5_, _loc10_[Std.int(_loc12_ + 4)], 6, -145523070);
			_loc5_ = ii(_loc5_, _loc2_, _loc3_, _loc4_, _loc10_[Std.int(_loc12_ + 11)], 10, -1120210379);
			_loc4_ = ii(_loc4_, _loc5_, _loc2_, _loc3_, _loc10_[Std.int(_loc12_ + 2)], 15, 718787259);
			_loc3_ = ii(_loc3_, _loc4_, _loc5_, _loc2_, _loc10_[Std.int(_loc12_ + 9)], 21, -343485551);
			_loc2_ += _loc6_;
			_loc3_ += _loc7_;
			_loc4_ += _loc8_;
			_loc5_ += _loc9_;
			_loc12_ += 16;
		}
		digest = new ByteArray();
		digest.writeInt(_loc2_);
		digest.writeInt(_loc3_);
		digest.writeInt(_loc4_);
		digest.writeInt(_loc5_);
		digest.position = 0;
		return IntUtil.toHex(_loc2_) + IntUtil.toHex(_loc3_) + IntUtil.toHex(_loc4_) + IntUtil.toHex(_loc5_);
	}

	// MD5.as:199-202
	private static function gg(param1:Int, param2:Int, param3:Int, param4:Int, param5:Int, param6:Int, param7:Int):Int {
		return transform(g, param1, param2, param3, param4, param5, param6, param7);
	}

	// MD5.as:204-207
	private static function ii(param1:Int, param2:Int, param3:Int, param4:Int, param5:Int, param6:Int, param7:Int):Int {
		return transform(i, param1, param2, param3, param4, param5, param6, param7);
	}

	// MD5.as:209-212
	public static function hashBytes(param1:ByteArray):String {
		return hashBinary(param1);
	}
}
