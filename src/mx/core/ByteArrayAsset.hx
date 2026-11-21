package mx.core;

import openfl.utils.ByteArray;

// mx.core.ByteArrayAsset —— ByteArrayAsset.as 逐句对应（issue #18 Flex 资产
// 壳）。嵌入二进制资产的载体：空壳（只带 VERSION），语义全在 ByteArray 父类。
// 原版 VERSION 带 mx_internal namespace 修饰（包内可见），平铺成 public。
@:keep
class ByteArrayAsset extends ByteArray implements IFlexAsset {
	// ByteArrayAsset.as:10（mx_internal static const）
	public static final VERSION:String = "3.2.0.3958";

	public function new() {
		super();
	}
}
