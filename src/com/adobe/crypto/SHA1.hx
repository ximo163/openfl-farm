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
 * - hashBlocks 用默认字节序的 ByteArray.writeInt 写散列字（:121-125）——
 *   AS3 ByteArray 默认小端，digest/hashToBase64 取到的字节序因此是逐字
 *   反转的小端序，与常规 SHA1 工具的 digest 字节序不同（hash()/hashBytes
 *   经 readInt+toHex 往返后十六进制仍为规范值）；
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
