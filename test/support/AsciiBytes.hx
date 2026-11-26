package support;

import openfl.utils.ByteArray;

/**
 * 测试侧字节串垫子（issue #86）：经 writeByte 逐码元建 ByteArray。
 *
 * 为什么不用 writeUTFBytes/writeMultiByte/fromBytes：openfl ByteArray 在
 * eval 目标上这三条通道全部写零——write-tests 阶段实测（2026-11-26）
 * writeUTFBytes("Hello") 得 5 字节 00 00 00 00 00、writeMultiByte 与
 * ByteArray.fromBytes(Bytes.ofString("Hello")) 同病，而 writeByte/
 * writeBytes 的字节正确（48 65 6C 6C 6F）——html5 真跑下 writeUTFBytes
 * 语义才正确，单测（--interp）只能走逐 writeByte。只覆盖 ASCII 码元面
 * （与被测入口 SHA1.hashBytes/Base64Encoder.encodeBytes 的取字节面一致；
 * UTF-8 展开面在 eval 上钉不住，不进单测）。
 */
class AsciiBytes {
	public static function of(s:String):ByteArray {
		var ba = new ByteArray();
		for (i in 0...s.length) {
			ba.writeByte(s.charCodeAt(i));
		}
		return ba;
	}
}
