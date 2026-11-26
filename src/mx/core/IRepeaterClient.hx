package mx.core;

// mx.core.IRepeaterClient —— IRepeaterClient.as 逐句对应（issue #86 牧场库
// 底座，Flex 核心片）。Repeater 文档客户端接口（NameUtil.displayObjectToString
// 的 instanceIndices 拼接用）。
// Haxe 接口属性行转 get_/set_ 访问器签名（ITip 先例）。
interface IRepeaterClient {
	// IRepeaterClient.as:6
	function get_instanceIndices():Array<Dynamic>;

	// IRepeaterClient.as:8
	function set_instanceIndices(param1:Array<Dynamic>):Void;

	// IRepeaterClient.as:10
	function get_isDocument():Bool;

	// IRepeaterClient.as:12
	function set_repeaters(param1:Array<Dynamic>):Void;

	// IRepeaterClient.as:14
	function initializeRepeaterArrays(param1:IRepeaterClient):Void;

	// IRepeaterClient.as:16
	function get_repeaters():Array<Dynamic>;

	// IRepeaterClient.as:18
	function set_repeaterIndices(param1:Array<Dynamic>):Void;

	// IRepeaterClient.as:20
	function get_repeaterIndices():Array<Dynamic>;
}
