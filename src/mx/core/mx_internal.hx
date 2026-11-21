package mx.core;

/**
 * mx.core.mx_internal —— mx_internal.as 的对应文件（issue #18 Flex 资产壳）。
 * 原版是 AS3 namespace 声明（`public namespace mx_internal`，Flex 的包内开放
 * 修饰符），运行期根本没有类型实体；Haxe 没有 namespace 概念，且小写类型名
 * 解析器直接红（"Type name should start with an uppercase letter"，全量
 * include 扫描即暴露），故本文件**不声明任何类型**，仅保住 spec 类清点的
 * 路径对应。带 mx_internal 修饰的 VERSION 常量已平铺成普通 public
 * static final（见 ByteArrayAsset/FontAsset 的头注），包内可见语义一致。
 */
