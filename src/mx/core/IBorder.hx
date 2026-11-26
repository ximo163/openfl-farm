package mx.core;

// mx.core.IBorder —— IBorder.as 逐句对应（issue #86 牧场库底座，Flex 核心片）。
// 边框度量接口（MovieClipAsset 实现，scale9Grid → EdgeMetrics）。
// Haxe 接口属性行转 get_/set_ 访问器签名（ITip 先例）。
interface IBorder {
	// IBorder.as:6
	function get_borderMetrics():EdgeMetrics;
}
