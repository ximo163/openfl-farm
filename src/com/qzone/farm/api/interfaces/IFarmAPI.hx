package com.qzone.farm.api.interfaces;

import interfaces.ILogicParser;
import interfaces.IMsgCenter;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;

/**
 * com.qzone.farm.api.interfaces.IFarmAPI —— IFarmAPI.as 逐句对应（issue #18
 * 插件接口片）。农场主程序暴露给插件/IPluginProxy 的 API 面（FarmAPI 实现）。
 * AS3 Function/Object/* → Dynamic。接口默认参原样保留（Haxe 接口允许默认值，
 * 语义与 AS3 同：经接口类型的调用点同样吃到缺省）。
 */
interface IFarmAPI {
	// IFarmAPI.as:7-51
	function confirm(param1:String, param2:String, param3:String, param4:Int, param5:Int, param6:Bool, param7:Bool,
		param8:Dynamic):Void;

	function requestClass(param1:String, param2:Dynamic, param3:String = null, param4:Dynamic = null):Void;

	var messageCenter(get, never):IMsgCenter;

	function sendRequest(param1:UInt, param2:Dynamic, param3:Dynamic, param4:Dynamic):Bool;

	function showStrongGuide(param1:Sprite, param2:Int, param3:Int, param4:String, param5:Int = 5,
		param6:Bool = false):Void;

	function reportReturnCode(param1:String, param2:String):Void;

	function hidePopUp(param1:DisplayObjectContainer):Void;

	function createWindow(param1:String, param2:DisplayObjectContainer, param3:Dynamic, param4:Dynamic):Bool;

	function showWindow(param1:String, param2:Bool):Void;

	function popMouseTip(param1:String):Void;

	function showPopUp(param1:DisplayObjectContainer, param2:Bool):Void;

	function popFloatTip(param1:Int, param2:String, param3:DisplayObjectContainer = null):Void;

	function registerNetCommand(param1:UInt, param2:String, param3:ILogicParser):Void;

	function payByPlatform(param1:Int, param2:Int, param3:Int, param4:Int, param5:Dynamic):Bool;

	function useSystemCursor(param1:Bool):Void;

	function executeCommand(param1:Int, param2:Int, param3:Dynamic):Dynamic;

	function hideMouseTip():Void;

	function reportSuccessError(param1:String, param2:Dynamic, param3:Int = -1, param4:String = null):Void;

	function alert(param1:Int, param2:String, param3:String, param4:Int, param5:Int, param6:Dynamic):Void;
}
