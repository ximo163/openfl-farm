package com.adobe.images;

// com.adobe.images.BitString —— BitString.as 逐句对应（issue #86 牧场库底座，
// adobe.images JPEG 编码器片）。JPEG 哈夫曼编码的位串载体（值 + 位长）。
@:keep
class BitString {
	// BitString.as:6-8
	public var val:Int = 0;

	public var len:Int = 0;

	// BitString.as:10-13
	public function new() {}
}
