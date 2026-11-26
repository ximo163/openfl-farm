package mx.utils;

import openfl.utils.ByteArray;

/**
 * mx.utils.Base64Encoder —— Base64Encoder.as 逐句对应（issue #86 牧场库
 * 底座，Flex 资产类片）。
 * legacy/decompiled/Master2_v_142/scripts/mx/utils/Base64Encoder.as。
 *
 * 按位语义（照抄原版、勿「修正」）：
 * - encodeBytes 的窗口界是 :70 的 while(_loc5_ < param3)（_loc5_ 初值
 *   =param2，:69）——起点/终点都是绝对下标，与 encode() 的 :94
 *   param2+param3 窗口模型不同，param3 ≤ param2 的窗口一次都不读；
 * - encode() / encodeBytes() 的窗口尾提前成块（:98/:74
 *   `param2 + param3 - _locX_ == 1`）——返回时尾块已带 '=' 填充进
 *   buffers，flush() 只是 drain+reset；
 * - encodeBlock 的换行（:136-143）每 4 字符推进 _line，恰到 76 时压入
 *   newLine（:10，int 类型，静态可改）；
 * - encodeBlock 的 buffer 翻档（:112-117）按 buffer 项数计（≥ 32767），
 *   :140 的换行也 push 进同一 buffer；
 * - drain()（:154-168）清空 buffers 后重开一个空 buffer（:165-167），
 *   但不动 _count/_line。
 *
 * PORT-NOTE: `String.fromCharCode.apply(null, _loc3_)`（:161）把数组按
 * apply 展开成变参——AS3 的 Function.apply 语义；Haxe 无等价，逐个字符
 * 拼串（码元序列一致，apply 只是批量调用形态）。
 * PORT-NOTE: `_work[_count] = param1[_loc5_]`（:72）读 ByteArray 下标得
 * uint 字节值；openfl ByteArray 下标读照支持（abstract arrayAccess），
 * 原样保留下标形态。
 */
@:keep
class Base64Encoder {
	// Base64Encoder.as:8
	public static final CHARSET_UTF_8:String = "UTF-8";

	// :10（AS3 public static var，非 const——运行期可改）
	public static var newLine:Int = 10;

	// :12
	public static final MAX_BUFFER_SIZE:UInt = 32767;

	// :14（AS3 Number → Float）
	private static final ESCAPE_CHAR_CODE:Float = 61;

	// :16
	private static final ALPHABET_CHAR_CODES:Array<Dynamic> = [65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77,
		78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108,
		109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 43, 47];

	// :18
	private var _line:UInt;

	// :20
	private var _count:UInt;

	// :22
	private var _buffers:Array<Dynamic>;

	// :24
	public var insertNewLines:Bool = true;

	// :26
	private var _work:Array<Dynamic> = [0, 0, 0];

	// :28-32
	public function new() {
		reset();
	}

	// :34-43
	public function flush():String {
		if (_count > 0) {
			encodeBlock();
		}
		var _loc1_:String = drain();
		reset();
		return _loc1_;
	}

	// :45-48
	public function toString():String {
		return flush();
	}

	// :50-59
	public function reset():Void {
		_buffers = [];
		_buffers.push([]);
		_count = 0;
		_line = 0;
		_work[0] = 0;
		_work[1] = 0;
		_work[2] = 0;
	}

	// :61-85（:67/:84 position 保存还原；窗口界 :70 绝对下标 param3——
	// 见类头按位语义；字节读取见类头 PORT-NOTE）
	public function encodeBytes(param1:ByteArray, param2:UInt = 0, param3:UInt = 0):Void {
		if (param3 == 0) {
			param3 = param1.length;
		}
		var _loc4_:UInt = param1.position;
		param1.position = param2;
		var _loc5_:UInt = param2;
		while (_loc5_ < param3) {
			_work[_count] = param1[_loc5_];
			_count++;
			if (_count == _work.length || param2 + param3 - _loc5_ == 1) {
				encodeBlock();
				_count = 0;
				_work[0] = 0;
				_work[1] = 0;
				_work[2] = 0;
			}
			_loc5_++;
		}
		param1.position = _loc4_;
	}

	// :87-108（:96 charCodeAt 取 UTF-16 码元；窗口尾提前成块 :98——
	// encode() 返回时尾块已带 '=' 填充）
	public function encode(param1:String, param2:UInt = 0, param3:UInt = 0):Void {
		if (param3 == 0) {
			param3 = param1.length;
		}
		var _loc4_:UInt = param2;
		while (_loc4_ < param2 + param3) {
			_work[_count] = param1.charCodeAt(_loc4_);
			_count++;
			if (_count == _work.length || param2 + param3 - _loc4_ == 1) {
				encodeBlock();
				_count = 0;
				_work[0] = 0;
				_work[1] = 0;
				_work[2] = 0;
			}
			_loc4_++;
		}
	}

	// :110-144。PORT-NOTE: `_work[i]` 的元素是 Number/uint 混进 Array，
	// 位运算前 AS3 隐式转 int；Haxe 侧经 Dynamic 读出后位运算同语义（值域
	// 0-255，无截断差异）。`(_work[0] & 3) << 4` 等混合位移按 AS3 分组
	// 原样加括号
	private function encodeBlock():Void {
		var _loc1_:Array<Dynamic> = cast(_buffers[_buffers.length - 1], Array<Dynamic>);
		if (_loc1_.length >= MAX_BUFFER_SIZE) {
			_loc1_ = [];
			_buffers.push(_loc1_);
		}
		var w0:Int = _work[0];
		var w1:Int = _work[1];
		var w2:Int = _work[2];
		_loc1_.push(ALPHABET_CHAR_CODES[(w0 & 0xFF) >> 2]);
		_loc1_.push(ALPHABET_CHAR_CODES[((w0 & 3) << 4) | ((w1 & 0xF0) >> 4)]);
		if (_count > 1) {
			_loc1_.push(ALPHABET_CHAR_CODES[((w1 & 0x0F) << 2) | ((w2 & 0xC0) >> 6)]);
		} else {
			_loc1_.push(ESCAPE_CHAR_CODE);
		}
		if (_count > 2) {
			_loc1_.push(ALPHABET_CHAR_CODES[w2 & 0x3F]);
		} else {
			_loc1_.push(ESCAPE_CHAR_CODE);
		}
		if (insertNewLines) {
			_line = _line + 4;
			if (_line == 76) {
				_loc1_.push(newLine);
				_line = 0;
			}
		}
	}

	// :146-152
	public function encodeUTFBytes(param1:String):Void {
		var _loc2_:ByteArray = new ByteArray();
		_loc2_.writeUTFBytes(param1);
		_loc2_.position = 0;
		encodeBytes(_loc2_);
	}

	// :154-168（apply 展开 → 逐字符拼串，见类头 PORT-NOTE）
	public function drain():String {
		var _loc3_:Array<Dynamic> = null;
		var _loc1_:String = "";
		var _loc2_:UInt = 0;
		while (_loc2_ < _buffers.length) {
			_loc3_ = cast(_buffers[_loc2_], Array<Dynamic>);
			for (_loc4_ in _loc3_) {
				_loc1_ += String.fromCharCode(_loc4_);
			}
			_loc2_++;
		}
		_buffers = [];
		_buffers.push([]);
		return _loc1_;
	}
}
