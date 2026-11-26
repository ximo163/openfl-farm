package mx.utils;

import support.AsciiBytes;
import utest.Assert;

/**
 * Base64Encoder 纯逻辑（issue #86 牧场库底座，Flex 资产类片）：编码块
 * 数学、窗口尾提前成块、76 字符换行、drain/reset/flush 流转、ByteArray
 * 通道的 position 保存还原。
 *
 * 出处：legacy/decompiled/Master2_v_142/scripts/mx/utils/Base64Encoder.as
 * （常量 :8/:10/:12；ctor reset :28-32；flush :34-43；reset :50-59；
 * encodeBytes :61-85（position 保存 :67/还原 :84、窗口界 :70 的
 * param3 绝对下标、窗口尾 :74）；
 * encode :87-108（charCodeAt :96、窗口尾提前成块 :98）；
 * encodeBlock :110-144（buffer 翻档 :112-117、字母表写入 :118-131、
 * '=' 逃逸 :126/:134、换行 :136-143）；encodeUTFBytes :146-152；
 * drain :154-168（buffers 清后重开 :165-167））。
 *
 * 期望值推导：按 SHA1.as 同款反编译算法定义的 Base64（RFC 4648 字母表，
 * :16 的 ALPHABET_CHAR_CODES 即标准表），期望串由独立实现
 * （python base64 + 对 :70/:74/:94/:98/:112-143 逐条仿真的字节级核对）
 * 对同一输入求值得出；「窗口尾提前成块」意味着 encode() 返回时填充 '='
 * 已进 buffers。
 *
 * 覆盖边界说明：encodeUTFBytes（:146-152）整条通道不进单测——它经
 * ByteArray.writeUTFBytes 建 UTF-8 字节，而 openfl ByteArray 在 eval 目标
 * 上 writeUTFBytes/writeMultiByte/fromBytes 全部写零（write-tests 阶段
 * 实测：writeUTFBytes("Hello") 得 5 字节 00 00 00 00 00，ASCII 也零；
 * html5 真跑语义才正确），跨目标钉不住；与 encode() 的码元差异面
 * （:96 vs :149）归 CI html5/画面链路。测试里的 ByteArray 一律经
 * support.AsciiBytes（逐 writeByte，eval 实测字节正确）建造。
 */
class Base64EncoderTest {
	public function new() {}

	// :8/:10/:12：公开常量与缺省换行符（newLine 是 var，AS3 可改）；
	// :28-32 ctor reset 后全新编码器 flush 为空串
	public function test_public_constants_and_fresh_flush_empty() {
		Assert.equals("UTF-8", Base64Encoder.CHARSET_UTF_8); // :8
		Assert.equals(10, Base64Encoder.newLine); // :10
		Assert.equals(32767, Base64Encoder.MAX_BUFFER_SIZE); // :12
		Assert.isTrue(new Base64Encoder().insertNewLines); // :24 缺省 true
		Assert.equals("", new Base64Encoder().flush()); // :52-53 ctor 的 reset → 空 buffers
	}

	// :87-108 + :110-144 + flush :34-43：len%3 三档 + 基本 ASCII。窗口尾
	// 提前成块（:98），flush 只 drain，'=' 填充已在 encode 内发生。
	public function test_encode_padding_and_basic_vectors() {
		var cases:Array<{input:String, expect:String}> = [
			{input: "Hello", expect: "SGVsbG8="}, // 5 字节：3+2 → 尾块带一个 '='
			{input: "a", expect: "YQ=="}, // 1 字节 → 2 字符 + '=='
			{input: "ab", expect: "YWI="}, // 2 字节 → 3 字符 + '='
			{input: "abc", expect: "YWJj"}, // 3 字节整块 → 无填充
			{input: "Hello, World!", expect: "SGVsbG8sIFdvcmxkIQ=="}
		];
		for (c in cases) {
			var enc = new Base64Encoder();
			enc.encode(c.input);
			Assert.equals(c.expect, enc.flush(), 'input=${c.input}');
		}
	}

	// :96 encode 取 charCodeAt（UTF-16 码元）而非 UTF-8 字节："é"（233）
	// 单码元进一个字节——encodeUTFBytes 才会展开成 2 字节 UTF-8
	public function test_encode_char_codes_not_utf8_bytes() {
		var enc = new Base64Encoder();
		enc.encode("é");
		Assert.equals("6Q==", enc.flush()); // 233 → 0xE9
	}

	// :87/:89/:94：param2/param3 偏移窗口只在窗口内取码元，窗口尾照常成块
	public function test_encode_offset_windows() {
		var win1 = new Base64Encoder();
		win1.encode("abcdef", 3, 2); // "de"
		Assert.equals("ZGU=", win1.flush());

		var win2 = new Base64Encoder();
		win2.encode("Hello", 1, 3); // "ell"
		Assert.equals("ZWxs", win2.flush());
	}

	// :136-143：insertNewLines 缺省 true，每 4 字符推进 _line，恰好 76 时压
	// newLine 并清零——57 字节 → 76 字符 + 换行；58 字节 → 尾块换行后追加；
	// 114 字节 → 两条满行各带一个换行
	public function test_newline_every_76_chars() {
		var a57 = StringTools.rpad("", "A", 57);
		var qufb19 = StringTools.rpad("", "QUFB", 76); // "QUFB" × 19 = 76 字符

		var e57 = new Base64Encoder();
		e57.encode(a57);
		Assert.equals(qufb19 + "\n", e57.flush());

		var e58 = new Base64Encoder();
		e58.encode(a57 + "A");
		Assert.equals(qufb19 + "\n" + "QQ==", e58.flush());

		var e114 = new Base64Encoder();
		e114.encode(a57 + a57);
		Assert.equals(qufb19 + "\n" + qufb19 + "\n", e114.flush());
	}

	// :24 + :136-143：insertNewLines=false 时不压任何换行
	public function test_insertNewLines_false_suppresses_newlines() {
		var enc = new Base64Encoder();
		enc.insertNewLines = false; // :24
		enc.encode(StringTools.rpad("", "A", 57));
		Assert.equals(StringTools.rpad("", "QUFB", 76), enc.flush());
	}

	// :10：newLine 是静态 var，换行符按它取值；先恢复静态再断言，断言失败
	// 也不污染后续用例
	public function test_newLine_static_controls_line_break_char() {
		var enc = new Base64Encoder();
		Base64Encoder.newLine = 13; // \r
		enc.encode(StringTools.rpad("", "A", 57));
		var result = enc.flush();
		Base64Encoder.newLine = 10; // 先恢复再断言
		Assert.equals(StringTools.rpad("", "QUFB", 76) + "\r", result);
	}

	// :154-168：drain 取走全部已成块内容并清 buffers 重开（:165-167），不
	// 碰 _count/_line；:98 使 encode() 返回时尾块已带填充进 buffers——
	// 5 字节经 drain 直接拿到完整 "SGVsbG8="；成块前的 3 字节流（"Hel"）
	// 只有一个整块，drain 拿到无填充的 "SGVs"。drain 后 flush 为空。
	public function test_drain_takes_encoded_and_flush_after_drain_is_empty() {
		var full = new Base64Encoder();
		full.encode("Hello");
		Assert.equals("SGVsbG8=", full.drain());
		Assert.equals("", full.flush()); // buffers 已清、_count==0

		var partial = new Base64Encoder();
		partial.encode("Hel"); // 单个整块，无尾块
		Assert.equals("SGVs", partial.drain());
		Assert.equals("", partial.flush());
	}

	// :45-48：toString() == flush()；flush 后再 flush 为空（:34-43 的 reset）
	public function test_toString_flushes_once() {
		var enc = new Base64Encoder();
		enc.encode("Hello");
		Assert.equals("SGVsbG8=", enc.toString());
		Assert.equals("", enc.flush());
	}

	// :50-59：reset() 丢内容并复位行计数——reset 后 flush 拿空串
	public function test_reset_discards_pending_content() {
		var enc = new Base64Encoder();
		enc.encode("Hello");
		enc.reset();
		Assert.equals("", enc.flush());
	}

	// :61-85：encodeBytes 的窗口界是 :70 的 while(_loc5_ < param3)、_loc5_
	// 初值=param2（:69）——起点 param2 与终点 param3 都是「绝对下标」，与
	// encode() 的 :94 param2+param3 窗口模型不同：offset=3/length=2 时
	// 3 < 2 一次都不进循环 → flush 为空串，不是 [3, 3+2) 的 "lo"；真取
	// "lo" 得用窗口 [3, 5)。:67/:84 的 position 保存还原不受窗口空否影响。
	// 字节经 AsciiBytes（见类头 eval 边界说明）建造
	public function test_encodeBytes_window_and_position_preserved() {
		var ba = AsciiBytes.of("Hello");
		ba.position = 2; // 故意停在半中腰
		var enc = new Base64Encoder();
		enc.encodeBytes(ba, 3, 2); // 窗口 [3, 2) 为空 → 不成任何块
		Assert.equals(2, ba.position); // :67/:84 还原
		Assert.equals("", enc.flush());

		enc.encodeBytes(ba, 3, 5); // 窗口 [3, 5) = "lo"
		Assert.equals(2, ba.position); // :67/:84 还原
		Assert.equals("bG8=", enc.flush());

		enc.encodeBytes(ba); // 全窗 "Hello"（缺省 param2=param3=0 → :63 全长）
		Assert.equals(2, ba.position); // :67/:84 还原
		Assert.equals("SGVsbG8=", enc.flush());
	}

	// :112-117 + :154-168：32767 的 buffer 上限翻档——drain 逐档拼回，翻档
	// 不得丢块/错序。buffer 按「项数」计且 :140 的换行也 push 进同一 buffer
	// （insertNewLines 缺省开：每 19 块 76 字符多 1 项），第 8087 块进场时
	// 上一档已积 4×8086+425=32769 项 ≥ 32767、翻第二档；即便按「每块纯 4
	// 项、不计换行」的口径，24579 字节 = 8193 块也达 8193×4=32772 > 32767，
	// 两种口径都真正跨档。8193 恰为 3 的倍数：无填充尾块。结构断言（总长/
	// 去换行串/头/尾/换行数）而不落 33k 字面量。
	public function test_multi_buffer_drain_across_MAX_BUFFER_SIZE() {
		var enc = new Base64Encoder();
		enc.encode(StringTools.rpad("", "A", 24579)); // 8193 个整块
		var result = enc.flush();
		var qufb19 = StringTools.rpad("", "QUFB", 76);

		Assert.equals(33203, result.length); // 8193×4 + 431 换行
		Assert.equals(StringTools.rpad("", "QUFB", 32772), result.split("\n").join("")); // 内容完整不丢块
		Assert.equals(qufb19 + "\n", result.substr(0, 77)); // 头 76 字符 + 换行
		Assert.equals(StringTools.rpad("", "QUFB", 16), result.substr(result.length - 16)); // 尾 4 块（8193%19：最后换行在 8189 块后）
		var newlines = 0;
		for (i in 0...result.length) {
			if (result.charCodeAt(i) == 10) {
				newlines++;
			}
		}
		Assert.equals(431, newlines); // floor(8193/19) = 431
	}
}
