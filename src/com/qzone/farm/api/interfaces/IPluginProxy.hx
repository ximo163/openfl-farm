package com.qzone.farm.api.interfaces;

// com.qzone.farm.api.interfaces.IPluginProxy —— IPluginProxy.as 逐句对应
// （issue #9）。插件代理接口（MaterialProxy 经 PluginManager.getPluginByID
// 取代理后 executeCommand(2102) 拿精灵渲染类）。Haxe 接口属性声明即
// get/set 存取。
interface IPluginProxy {
	// IPluginProxy.as:6
	function initialize(param1:Dynamic):Bool;

	// IPluginProxy.as:8
	var config(get, never):Dynamic;

	// IPluginProxy.as:10
	function executeCommand(param1:Int, param2:Dynamic):Dynamic;
}
