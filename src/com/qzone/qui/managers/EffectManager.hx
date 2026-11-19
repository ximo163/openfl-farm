package com.qzone.qui.managers;

import openfl.events.EventDispatcher;

/**
 * com.qzone.qui.managers.EffectManager —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * qui 动效管理器（EffectManager.as 50 loc）；Main.setup 写
 * tweenerClass = TweenLite，In/Out/playEffect 随 qui 片翻译。
 */
@:keep
class EffectManager extends EventDispatcher {
	// EffectManager.as:11-19
	public static var tweenerClass:Dynamic;
	public static var comboBaseEffect:Dynamic;
	public static var toolTipEffect:Dynamic;
	public static var popUpEffect:Dynamic;

	public function new() {
		super();
	}

	// EffectManager.as:26-（In：入场动效，qui 片翻译）
	public static function In(param1:Dynamic, param2:Dynamic, param3:Dynamic = null, param4:Array<Dynamic> = null):Void {}

	// EffectManager.as:31-（playEffect：按名放动效，qui 片翻译）
	public static function playEffect(param1:String, param2:Dynamic, param3:Dynamic, param4:Dynamic, param5:Array<Dynamic> = null):Void {}

	// EffectManager.as:44-（Out：出场动效，qui 片翻译）
	public static function Out(param1:Dynamic, param2:Dynamic, param3:Dynamic, param4:Array<Dynamic> = null):Void {}
}
