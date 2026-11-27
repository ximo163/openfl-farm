package mc.api;

import openfl.display.DisplayObjectContainer;
import openfl.events.IEventDispatcher;

/**
 * mc.api.IAPIHelper —— IAPIHelper.as 的签名面 stub（issue #87「API」片
 * 充真身）。API 桥接接口：弹窗开闭、鼠标尖提示、alert、网络命令注册/
 * 发送、messageCenter 暴露。成员签名逐字取自反编译原文。
 * legacy/decompiled/Master2_v_142/scripts/mc/api/IAPIHelper.as。
 */
@:keep
interface IAPIHelper {
	// IAPIHelper.as:9
	function reportReturnCode(param1:String, param2:String):Void;

	// IAPIHelper.as:11
	function registerNetCommand(param1:UInt, param2:String):Void;

	// IAPIHelper.as:13
	var messageCenter(get, never):IEventDispatcher;

	// IAPIHelper.as:15
	function popMouseTip(param1:String):Void;

	// IAPIHelper.as:17
	function hideMouseTip():Void;

	// IAPIHelper.as:19
	function getDisableFilter():Array<Dynamic>;

	// IAPIHelper.as:21
	function hidePopUp(param1:DisplayObjectContainer):Void;

	// IAPIHelper.as:23
	function alert(param1:String, param2:String):Void;

	// IAPIHelper.as:25
	function sendRequest(param1:UInt, param2:Dynamic, param3:Dynamic):Bool;

	// IAPIHelper.as:27
	function showPopUp(param1:DisplayObjectContainer):Void;
}
