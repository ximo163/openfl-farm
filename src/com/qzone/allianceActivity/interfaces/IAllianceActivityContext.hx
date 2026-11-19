package com.qzone.allianceActivity.interfaces;

import com.qzone.allianceActivity.AllianceActivityInfo;

/**
 * com.qzone.allianceActivity.interfaces.IAllianceActivityContext —— V3b
 * 顺手翻（issue #8 闭包，接口 39 loc ≤ 100；FarmLandController.onGameLoop
 * 经 AllianceActivityManager.getActivityContext 取上下文调 execute）。
 * legacy/decompiled/main3_v_221/scripts/com/qzone/allianceActivity/interfaces/
 * IAllianceActivityContext.as 逐句对应（destory 是原版拼写，照抄）。
 */
interface IAllianceActivityContext {
	var startTime(never, set):Float;
	var currentTime(get, set):Float;
	var activityId(get, set):String;
	var expireTime(never, set):Float;
	var appHelper(get, set):IAllianceAppHelper;
	var appId(get, set):String;

	function initialize(param1:AllianceActivityInfo):Void;
	function execute(param1:String, param2:Dynamic = null):Dynamic;
	function destory():Void;
}
