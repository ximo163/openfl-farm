package app4.activities.common;

import framework.api.FarmAPI;

/**
 * app4.activities.common.ActivityController —— V3b/V3c 模块翻译，闭包
 * stub（issue #7）。运营活动控制器（ActivityController.as 50 loc）；
 * FarmApplication.startup 只 new 后 loadConfig(activity_list, serverTime*1000,
 * appImgPrefix)。活动装载随活动片接入。
 */
@:keep
class ActivityController {
	public function new(param1:FarmAPI) {}

	// ActivityController.as（loadConfig：解析 activity_list 配置，活动片翻译）
	public function loadConfig(param1:Dynamic, param2:Float, param3:String):Void {}
}
