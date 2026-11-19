package common.misc;

import openfl.utils.ByteArray.ByteArrayData;

// common.misc.VersionUtil_versionXml —— VersionUtil_versionXml.as 逐句对应。
// 原版是 [Embed] 进 swf 的 version.xml 二进制（mx.core.ByteArrayAsset）；
// 内容取自 legacy/decompiled/main3_v_221/binaryData/
// 2_common.misc.VersionUtil_versionXml.bin（CI 反编译导出的同一份字节）。
// PORT-NOTE: openfl 9 的 ByteArray 是 abstract 不能被继承，可继承的底层
// ByteArrayData 是 ByteArray.hx 模块内的类型，路径 openfl.utils.ByteArray.ByteArrayData；
// 构造器把等价字节写进去，VersionUtil 里按原样 readUTFBytes。
@:keep
class VersionUtil_versionXml extends ByteArrayData {
	// 2_….bin 原文（UTF-8）
	static final SOURCE:String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><version app=\"QQFarmNew\" ofp=\"bin-release\">"
		+ "<build count=\"383\" time=\"2012-08-31 11:05:43\"/>"
		+ "<release count=\"1\" time=\"2011-07-14 11:14:30\"/>"
		+ "</version>";

	public function new() {
		super();
		this.writeUTFBytes(SOURCE);
		this.position = 0;
	}
}
