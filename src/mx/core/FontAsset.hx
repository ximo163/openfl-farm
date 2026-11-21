package mx.core;

import openfl.text.Font;

// mx.core.FontAsset —— FontAsset.as 逐句对应（issue #18 Flex 资产壳）。
// 嵌入字体资产的载体：空壳（只带 VERSION），语义全在 Font 父类。
// 原版 VERSION 带 mx_internal namespace 修饰（包内可见），平铺成 public。
@:keep
class FontAsset extends Font implements IFlexAsset {
	// FontAsset.as:10（mx_internal static const）
	public static final VERSION:String = "3.2.0.3958";

	public function new() {
		super();
	}
}
