package mx.core;

/**
 * mx.core.mx_internal —— mx_internal.as 逐句对应（issue #18 Flex 资产壳）。
 * 原版是 AS3 namespace 声明（Flex 的包内开放修饰符），Haxe 没有 namespace
 * 概念，落成同名标记类占位：mx.core 里的 VERSION 常量原带 mx_internal 修饰
 * （包内可见），平铺成普通 public static final（见 ByteArrayAsset/FontAsset）。
 * 运行期无引用面，小写类名不可再被 Haxe 引用（CanPickIcon 同款），仅作
 * spec 类清点的对应文件。
 */
@:keep
class mx_internal {
	public function new() {}
}
