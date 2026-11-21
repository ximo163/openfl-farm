package com.qzone.farm.api.interfaces;

import openfl.display.Sprite;

/**
 * com.qzone.farm.api.interfaces.IPlugin —— IPlugin.as 逐句对应（issue #18
 * 插件接口片）。牧场插件（mcloader 加载的 Master2 等）对农场主程序的接入面。
 * AS3 Function/Object → Dynamic。
 */
interface IPlugin {
	// IPlugin.as:7-13
	function createMainUI(param1:Dynamic):Sprite;

	function executeCommand(param1:Int, param2:Dynamic):Dynamic;

	function load(param1:Int, param2:IFarmAPI):Bool;

	function unload():Void;
}
