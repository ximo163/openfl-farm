package com.adobe.crypto;

import mx.utils.Base64Encoder;
import openfl.errors.Error;
import openfl.utils.ByteArray;

/**
 * com.adobe.crypto.SHA1 —— SHA1.as 的 write-tests stub（issue #86 牧场库
 * 底座，第三方库片；com.adobe.crypto.MD5 的姊妹类，IntUtil 已随 MD5 翻译）。
 * 本阶段只立签名面：digest 静态 + 三个静态散列入口，方法体 throw，真身随
 * implement 按反编译原文逐句补齐（私有辅助 createBlocksFromByteArray/f/k/
 * hashBlocks/createBlocksFromString 由 implement 补）。
 * legacy/decompiled/Master2_v_142/scripts/com/adobe/crypto/SHA1.as。
 *
 * 真身落码时的两个坑（测试已钉，别「修正」它们）：
 * - hashBlocks 用默认字节序的 ByteArray.writeInt 写散列字（:121-125），
 *   而 AS3 ByteArray 缺省 BIG_ENDIAN（Adobe 官方文档）——原版 digest/
 *   hashToBase64 因此是标准摘要字节序 / 常规 base64(digest)（测试钉的即
 *   这组大端值）。openfl 非 Flash 目标 ByteArray 缺省随系统序
 *   （ByteArray.hx defaultEndian 初始化为系统序，eval/x86 落小端），照抄
 *   new ByteArray() + writeInt 会落小端、测试红——真身须显式钉大端
 *   （如 :120 建后设 endian = Endian.BIG_ENDIAN，标 // PORT-NOTE: AS3
 *   缺省序）；hash()/hashBytes() 走 readInt + IntUtil.toHex 往返，与
 *   字节序无关；
 * - createBlocksFromString 按字符 charCodeAt & 255 取字节（:141），非
 *   ASCII 走 UTF-16 码元截断而非 UTF-8 展开。
 */
@:keep
class SHA1 {
	// :10（最近一次 hash/hashBytes 的 20 字节散列副本，position 0）
	public static var digest:ByteArray;

	public function new() {
		throw new Error("not implemented");
	}

	// :149-154（write-tests stub：真身随 implement）
	public static function hashBytes(param1:ByteArray):String {
		throw new Error("not implemented");
	}

	// :156-161（write-tests stub：真身随 implement）
	public static function hash(param1:String):String {
		throw new Error("not implemented");
	}

	// :163-180（write-tests stub：真身随 implement）
	public static function hashToBase64(param1:String):String {
		throw new Error("not implemented");
	}
}
