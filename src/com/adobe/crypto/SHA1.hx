package com.adobe.crypto;

import com.adobe.utils.IntUtil;
import mx.utils.Base64Encoder;
import openfl.utils.ByteArray;
import openfl.utils.Endian;

/**
 * com.adobe.crypto.SHA1 —— SHA1.as 逐句对应（issue #86 牧场库底座，第三方
 * 库片；com.adobe.crypto.MD5 的姊妹类，IntUtil 已随 MD5 翻译）。
 * legacy/decompiled/Master2_v_142/scripts/com/adobe/crypto/SHA1.as。
 *
 * PORT-NOTE: hashBlocks 用默认字节序的 ByteArray.writeInt 写散列字
 * （:121-125）。AS3 ByteArray 缺省 BIG_ENDIAN；openfl 非 Flash 目标缺省随
 * 系统序（eval/x86 落小端）——照抄 new ByteArray() 会落小端、digest 字节序
 * 与原版相反，故两处建 ByteArray 后显式钉 Endian.BIG_ENDIAN（hashBlocks 的
 * _loc10_ 与 digest 副本同源，副本经 writeBytes 继承原字节内容、readInt
 * 回读也须同序）。
 * PORT-NOTE: createBlocks 系的稀疏数组（AS3 空洞读 undefined、进位运算
 * 按 0）统一走 readWord 归一化（MD5.hx 同款，见彼处注释）。
 * PORT-NOTE: AS3 int 算术即 Int32 回绕，Haxe Int 在 eval/js 上同语义。
 */
@:keep
class SHA1 {
	// SHA1.as:10
	public static var digest:ByteArray;

	public function new() {}

	// SHA1.as:17-34。`param1.readByte()` 从 position 0 顺序读——窗口外下标
	// 不经下标运算。位序：24 - _loc6_ % 32（大端字内填充）
	private static function createBlocksFromByteArray(param1:ByteArray):Array<Int> {
		var _loc2_:Int = param1.position;
		param1.position = 0;
		var _loc3_:Array<Int> = new Array<Int>();
		var _loc4_:Int = param1.length * 8;
		var _loc5_:Int = 255;
		var _loc6_:Int = 0;
		while (_loc6_ < _loc4_) {
			_loc3_[_loc6_ >> 5] = readWord(_loc3_, _loc6_ >> 5) | ((param1.readByte() & _loc5_) << (24 - _loc6_ % 32));
			_loc6_ += 8;
		}
		_loc3_[_loc4_ >> 5] = readWord(_loc3_, _loc4_ >> 5) | (128 << (24 - _loc4_ % 32));
		_loc3_[((_loc4_ + 64 >> 9) << 4) + 15] = _loc4_;
		param1.position = _loc2_;
		return normalize(_loc3_);
	}

	// SHA1.as:36-51。PORT-NOTE: Haxe 的 & 与 | 同优先级左结合（AS3 是
	// & > ^ > |），混合位运算显式括号保 AS3 分组
	private static function f(param1:Int, param2:Int, param3:Int, param4:Int):Int {
		if (param1 < 20) {
			return (param2 & param3) | (~param2 & param4);
		}
		if (param1 < 40) {
			return param2 ^ param3 ^ param4;
		}
		if (param1 < 60) {
			return (param2 & param3) | (param2 & param4) | (param3 & param4);
		}
		return param2 ^ param3 ^ param4;
	}

	// SHA1.as:53-68（1518500249/1859775393/2400959708 越 int 正界，AS3 字
	// 面量即 Int32 回绕；Haxe 同位宽直接写超界字面量是编译错，按位等价写
	// 成负值——bit pattern 相同）
	private static function k(param1:Int):Int {
		if (param1 < 20) {
			return 1518500249;
		}
		if (param1 < 40) {
			return 1859775393;
		}
		if (param1 < 60) {
			return -1894007588; // 2400959708
		}
		return -899497514; // 3395469782
	}

	// MD5.hx 同款：稀疏数组读（AS3 undefined 进位运算按 0）→ 越界判下标、
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

	// 长度字与数据字之间的空洞、以及 16 对齐洞位的统一归一化（MD5.hx 同款
	// 注释）：AS3 读出 undefined、轮函数按 0 用；动态目标洞位 null 补 0，
	// 静态目标洞位已是 0
	private static function normalize(param1:Array<Int>):Array<Int> {
		var _loc1_:Int = 0;
		while (_loc1_ < param1.length) {
			param1[_loc1_] = readWord(param1, _loc1_);
			_loc1_++;
		}
		while (param1.length % 16 != 0) {
			param1.push(0);
		}
		return param1;
	}

	// SHA1.as:70-131。PORT-NOTE: _loc6_ 初值 3285377520 越 int 正界（Int32
	// 回绕成负，同 k()）；_loc10_/digest 显式钉大端（见类头 PORT-NOTE）
	private static function hashBlocks(param1:Array<Int>):ByteArray {
		var _loc11_:Int = 0;
		var _loc12_:Int = 0;
		var _loc13_:Int = 0;
		var _loc14_:Int = 0;
		var _loc15_:Int = 0;
		var _loc16_:Int = 0;
		var _loc17_:Int = 0;
		var _loc2_:Int = 1732584193;
		var _loc3_:Int = -271733879; // 4023233417
		var _loc4_:Int = -1732584194; // 2562383102
		var _loc5_:Int = 271733878;
		var _loc6_:Int = -1009589776; // 3285377520
		var _loc7_:Int = param1.length;
		var _loc8_:Array<Int> = [for (_ in 0...80) 0];
		var _loc9_:Int = 0;
		while (_loc9_ < _loc7_) {
			_loc11_ = _loc2_;
			_loc12_ = _loc3_;
			_loc13_ = _loc4_;
			_loc14_ = _loc5_;
			_loc15_ = _loc6_;
			_loc16_ = 0;
			while (_loc16_ < 80) {
				if (_loc16_ < 16) {
					_loc8_[_loc16_] = param1[_loc9_ + _loc16_];
				} else {
					_loc8_[_loc16_] = IntUtil.rol(_loc8_[_loc16_ - 3] ^ _loc8_[_loc16_ - 8] ^ _loc8_[_loc16_ - 14] ^ _loc8_[_loc16_ - 16], 1);
				}
				_loc17_ = IntUtil.rol(_loc11_, 5) + f(_loc16_, _loc12_, _loc13_, _loc14_) + _loc15_ + _loc8_[_loc16_] + k(_loc16_);
				_loc15_ = _loc14_;
				_loc14_ = _loc13_;
				_loc13_ = IntUtil.rol(_loc12_, 30);
				_loc12_ = _loc11_;
				_loc11_ = _loc17_;
				_loc16_++;
			}
			_loc2_ += _loc11_;
			_loc3_ += _loc12_;
			_loc4_ += _loc13_;
			_loc5_ += _loc14_;
			_loc6_ += _loc15_;
			_loc9_ += 16;
		}
		var _loc10_:ByteArray = new ByteArray();
		_loc10_.endian = Endian.BIG_ENDIAN; // PORT-NOTE: AS3 缺省序，openfl 非 Flash 目标缺省随系统序
		_loc10_.writeInt(_loc2_);
		_loc10_.writeInt(_loc3_);
		_loc10_.writeInt(_loc4_);
		_loc10_.writeInt(_loc5_);
		_loc10_.writeInt(_loc6_);
		_loc10_.position = 0;
		digest = new ByteArray();
		digest.endian = Endian.BIG_ENDIAN; // PORT-NOTE: 同上
		digest.writeBytes(_loc10_);
		digest.position = 0;
		return _loc10_;
	}

	// SHA1.as:133-147。`_loc5_ / 8`：AS3 除法得 Number 再作下标（隐式取整），
	// _loc5_ 步进 8 恒整除，Std.int 等价；charCodeAt & 255 按 UTF-16 码元截
	// 断取字节（非 ASCII 不走 UTF-8 展开——原版如此）
	private static function createBlocksFromString(param1:String):Array<Int> {
		var _loc2_:Array<Int> = new Array<Int>();
		var _loc3_:Int = param1.length * 8;
		var _loc4_:Int = 255;
		var _loc5_:Int = 0;
		while (_loc5_ < _loc3_) {
			_loc2_[_loc5_ >> 5] = readWord(_loc2_, _loc5_ >> 5) | ((param1.charCodeAt(Std.int(_loc5_ / 8)) & _loc4_) << (24 - _loc5_ % 32));
			_loc5_ += 8;
		}
		_loc2_[_loc3_ >> 5] = readWord(_loc2_, _loc3_ >> 5) | (128 << (24 - _loc3_ % 32));
		_loc2_[((_loc3_ + 64 >> 9) << 4) + 15] = _loc3_;
		return normalize(_loc2_);
	}

	// SHA1.as:149-154
	public static function hashBytes(param1:ByteArray):String {
		var _loc2_:Array<Int> = SHA1.createBlocksFromByteArray(param1);
		var _loc3_:ByteArray = hashBlocks(_loc2_);
		return IntUtil.toHex(_loc3_.readInt(), true) + IntUtil.toHex(_loc3_.readInt(), true) + IntUtil.toHex(_loc3_.readInt(), true)
			+ IntUtil.toHex(_loc3_.readInt(), true) + IntUtil.toHex(_loc3_.readInt(), true);
	}

	// SHA1.as:156-161
	public static function hash(param1:String):String {
		var _loc2_:Array<Int> = createBlocksFromString(param1);
		var _loc3_:ByteArray = hashBlocks(_loc2_);
		return IntUtil.toHex(_loc3_.readInt(), true) + IntUtil.toHex(_loc3_.readInt(), true) + IntUtil.toHex(_loc3_.readInt(), true)
			+ IntUtil.toHex(_loc3_.readInt(), true) + IntUtil.toHex(_loc3_.readInt(), true);
	}

	// SHA1.as:163-180
	public static function hashToBase64(param1:String):String {
		var _loc7_:UInt = 0;
		var _loc2_:Array<Int> = SHA1.createBlocksFromString(param1);
		var _loc3_:ByteArray = hashBlocks(_loc2_);
		var _loc4_:String = "";
		_loc3_.position = 0;
		var _loc5_:Int = 0;
		while (_loc5_ < _loc3_.length) {
			_loc7_ = _loc3_.readUnsignedByte();
			_loc4_ += String.fromCharCode(_loc7_);
			_loc5_++;
		}
		var _loc6_:Base64Encoder = new Base64Encoder();
		_loc6_.encode(_loc4_);
		return _loc6_.flush();
	}
}
