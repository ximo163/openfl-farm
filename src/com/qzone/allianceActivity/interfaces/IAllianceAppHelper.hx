package com.qzone.allianceActivity.interfaces;

import openfl.display.DisplayObject;
import openfl.display.Sprite;

/**
 * com.qzone.allianceActivity.interfaces.IAllianceAppHelper —— V3b 顺手翻
 * （issue #8 闭包，接口 42 loc ≤ 100；IAllianceActivityContext.appHelper 的
 * 类型，活动片接入时由 FarmApplication 实现）。
 * legacy/decompiled/main3_v_221/scripts/com/qzone/allianceActivity/interfaces/
 * IAllianceAppHelper.as 逐句对应。
 */
interface IAllianceAppHelper {
	function payActivityByPlatform(param1:Int, param2:Int, param3:Int, param4:Int, param5:Dynamic):Void;
	function getItemIcon(param1:Int, param2:Int):DisplayObject;
	function popupWindow(param1:DisplayObject):Bool;
	function execute(param1:String, param2:Dynamic = null):Dynamic;
	function removePopup(param1:DisplayObject):Bool;
	function acceptRewards(param1:Array<Dynamic>):Void;
	function addIconEntrance(param1:DisplayObject):Void;
	var loginUin(get, never):String;
	function showLoadingState():Void;
	function showTips(param1:DisplayObject, param2:String):Void;
	function addNpcEntrance(param1:String, param2:String, param3:Int, param4:Int, param5:String, param6:String):Sprite;
	function hideLoadingState():Void;
	function debugLog(param1:String):Void;
	function hideTips(param1:DisplayObject):Void;
	function alert(param1:String):Void;
	function showBubbleMessage(param1:String):Void;
}
