package com.adobe.crypto;

import openfl.utils.ByteArray;
import support.AsciiBytes;
import utest.Assert;

/**
 * SHA1 纯逻辑（issue #86 牧场库底座，第三方库片）：hash/hashBytes/
 * hashToBase64 三入口、digest 静态副本的标准（大端）字节序、hashBytes 的
 * position 保存还原。
 *
 * 出处：legacy/decompiled/Master2_v_142/scripts/com/adobe/crypto/SHA1.as
 * （createBlocksFromByteArray :17-34（position 保存 :19/还原 :32、readByte
 * :27）；hashBlocks :70-131（writeInt 写散列字 :121-125、digest 副本
 * :127-129）；createBlocksFromString :133-147（charCodeAt & 255 :141）；
 * hashBytes :149-154；hash :156-161；hashToBase64 :163-180（:169-175
 * readUnsignedByte 逐字节 + :177-179 Base64Encoder））。
 *
 * 期望值推导：该实现是标准 SHA1（:79-83 的 h0-h4 初值与 :53-68 的轮常数
 * 即 RFC 3174 的 0x5A827999/0x6ED9EBA1/0x8F1BBCDC/0xCA62C1D6），ASCII 期望
 * 值即标准测试向量（"abc"→a9993e36… 为 RFC 3174 附录 A.2 的官方向量），
 * 并用独立实现（python hashlib/base64）对同一输入求值交叉核对；非 ASCII
 * 的 "é" 行按 :141 的 charCodeAt & 255 语义对单字节 233 求值（sha1(0xE9)）。
 *
 * 字节序：hashBlocks 用默认字节序的 ByteArray.writeInt 写散列字
 * （:121-125），而 AS3 ByteArray 缺省 BIG_ENDIAN（Adobe 官方文档
 * flash/utils/ByteArray 的 endian：「The default value is
 * Endian.BIG_ENDIAN」；openfl ByteArray 的 defaultEndian 文档注释同证：
 * Flash/AIR 目标恒为 BIG_ENDIAN）——原版 digest 的字节流就是标准摘要序
 * （"abc" → a9 99 3e 36 …），hashToBase64 的值即常规 base64(digest)
 * （对拍 python base64.b64encode(hashlib.sha1(b"abc").digest()) = "qZk+…"）。
 * openfl 非 Flash 目标 ByteArray 缺省随系统序（ByteArray.hx defaultEndian
 * 初始化为系统序，eval/x86 落小端）——这是平台差异不是原版行为：implement
 * 真身须显式钉大端（// PORT-NOTE:），未登记偏差不得与原版相异；
 * hash()/hashBytes() 走 readInt + IntUtil.toHex 往返，与字节序无关。
 */
class SHA1Test {
	public function new() {}

	// :156-161（createBlocksFromString + hashBlocks + IntUtil.toHex）：
	// ASCII 输入的十六进制 == 标准 SHA1。含空串（:144-145 填充）、55/56/64
	// 字节的填充块边界与 100 字节的多块路径（>64 字节跨块）。
	public function test_hash_ascii_matches_standard_vectors() {
		var cases:Array<{input:String, expect:String}> = [
			{input: "", expect: "da39a3ee5e6b4b0d3255bfef95601890afd80709"},
			{input: "abc", expect: "a9993e364706816aba3e25717850c26c9cd0d89d"}, // RFC 3174 A.2 官方向量
			{input: "Hello", expect: "f7ff9e8b7bb2e09b70935a5d785e0cc5d9d0abf0"},
			{input: "The quick brown fox jumps over the lazy dog", expect: "2fd4e1c67a2d28fced849ee1bb76e7391b93eb12"},
			{input: StringTools.rpad("", "a", 55), expect: "c1c8bbdc22796e28c0e15163d20899b65621d65a"}, // 55B：0x80 恰进本块尾
			{input: StringTools.rpad("", "a", 56), expect: "c2db330f6083854c99d4b5bfb6e8f29f201be699"}, // 56B：0x80 逼出第二块
			{input: StringTools.rpad("", "a", 64), expect: "0098ba824b5c16427bd7a1122a5a442a25ec644d"}, // 64B 整块
			{input: StringTools.rpad("", "a", 100), expect: "7f9000257a4918d7072655ea468540cdcbd42e0c"} // 多块路径
		];
		for (c in cases) {
			Assert.equals(c.expect, SHA1.hash(c.input), 'input len=${c.input.length}');
		}
	}

	// :141 createBlocksFromString 按 charCodeAt & 255 取字节（UTF-16 码元），
	// 非 ASCII 不展开 UTF-8——"é"（码元 233）按单字节 0xE9 散列，与 UTF-8
	// 展开（C3 A9 两字节）的常规摘要不同
	public function test_hash_non_ascii_uses_char_code_units() {
		Assert.equals("1599e9fa41ec68c80230491902786bee889f5bcb", SHA1.hash("é"));
	}

	// :149-154（createBlocksFromByteArray + hashBlocks）：字节串入口给出与
	// hash() 相同的摘要；:17-34 从 position 0 读（:20），与调用时的
	// position 无关；:19/:32 把 position 原样保存还原。字节经
	// support.AsciiBytes 建造（openfl ByteArray 在 eval 上 writeUTFBytes
	// 写零，见该文件头）
	public function test_hashBytes_and_position_preserved() {
		var ba = AsciiBytes.of("The quick brown fox jumps over the lazy dog");
		ba.position = 3; // 半中腰
		Assert.equals("2fd4e1c67a2d28fced849ee1bb76e7391b93eb12", SHA1.hashBytes(ba));
		Assert.equals(3, ba.position); // :19/:32 还原

		var empty = AsciiBytes.of(""); // 空字节流 == hash("")
		Assert.equals("da39a3ee5e6b4b0d3255bfef95601890afd80709", SHA1.hashBytes(empty));
	}

	// hash("é") 与 hashBytes(单字节 233) 同源：码元截断面从两个入口取值一致
	public function test_hashBytes_single_byte_matches_hash_of_char() {
		var ba = new ByteArray();
		ba.writeByte(233); // 0xE9 == "é".charCodeAt(0)
		Assert.equals("1599e9fa41ec68c80230491902786bee889f5bcb", SHA1.hashBytes(ba));
	}

	// :127-129 + :121-125：digest 是最近一次散列的 20 字节副本、position 0。
	// 字节序按 AS3 缺省 BIG_ENDIAN 的 writeInt 字序落字——a9993e36 字写为
	// a9 99 3e 36 …，与常规工具的 sha1 摘要字节序一致（推导见类头「字节序」）
	public function test_digest_is_big_endian_word_copy() {
		SHA1.hash("abc");
		var d = SHA1.digest;
		Assert.notNull(d);
		Assert.equals(20, d.length);
		Assert.equals(0, d.position);
		var bytes:Array<Int> = [for (i in 0...20) d.readUnsignedByte()];
		Assert.same([0xa9, 0x99, 0x3e, 0x36, 0x47, 0x06, 0x81, 0x6a, 0xba, 0x3e, 0x25, 0x71, 0x78, 0x50, 0xc2, 0x6c, 0x9c, 0xd0, 0xd8, 0x9d], bytes);
		Assert.equals(20, d.position); // 读到底
	}

	// :163-180：hashToBase64 把 :121-125 writeInt 写出的 ByteArray 按 :169-175
	// readUnsignedByte 逐字节取字符再编码——字节序即 AS3 缺省大端，所以值与
	// 常规工具的 base64(digest) 一致（python b64encode 对拍，见类头「字节序」）；
	// 28 字符 < 76，Base64Encoder 的 insertNewLines 缺省开也不压换行
	public function test_hashToBase64_matches_standard_digest_base64() {
		Assert.equals("qZk+NkcGgWq6PiVxeFDCbJzQ2J0=", SHA1.hashToBase64("abc"));
		Assert.equals("L9ThxnotKPzthJ7hu3bnORuT6xI=", SHA1.hashToBase64("The quick brown fox jumps over the lazy dog"));
		Assert.equals("2jmj7l5rSw0yVb/vlWAYkK/YBwk=", SHA1.hashToBase64(""));
	}
}
