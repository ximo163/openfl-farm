package mx.core;

import openfl.utils.ByteArray.ByteArrayData;

// mx.core.ByteArrayAsset —— ByteArrayAsset.as 逐句对应（issue #18 Flex 资产
// 壳）。嵌入二进制资产的载体：空壳（只带 VERSION），语义全在 ByteArray 父类。
// 原版 VERSION 带 mx_internal namespace 修饰（包内可见），平铺成 public。
// PORT-NOTE: openfl 的 ByteArray 是 abstract ByteArray(ByteArrayData)，
// AS3 的 `extends ByteArray` 在 Haxe 编译不了（不能继承 abstract）；改继承其
// 底层运行时类 ByteArrayData（模块子类型，全限定
// openfl.utils.ByteArray.ByteArrayData）。openfl 的 ByteArray 对 ByteArrayData 双向隐式
// 转换（`from ByteArrayData to ByteArrayData`），ByteArrayAsset 实例仍可
// 无缝传入任何 ByteArray 形参，IS-A 语义保持。
@:keep
class ByteArrayAsset extends ByteArrayData implements IFlexAsset {
	// ByteArrayAsset.as:10（mx_internal static const）
	public static final VERSION:String = "3.2.0.3958";

	public function new() {
		super();
	}
}
