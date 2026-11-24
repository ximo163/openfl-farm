package com.qzone.qui.managers;

import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.events.EventDispatcher;
import openfl.utils.Dictionary;
import shim.As3;

// com.qzone.qui.managers.EffectManager —— EffectManager.as 逐句对应（issue #44
// 真身，原 #7 闭包 stub 退役）。In/Out 的第 4 参在原版是 ...rest（回调参数表，
// #18 lessons 记过 stub 期的坑）→ Array<Dynamic> = null：缺省 null 对应原版
// rest=[]，apply 侧按零参调用等价。hasOwnProperty("effect") 走 As3.hasProp
//（密封类 trait 语义，#18 教训）；`param3["effect"][param1](…)` 是动态面
// 调用，走 Reflect.callMethod（LandInfoTip 对 _farmInfo 同款先例）。
// legacy/decompiled/main3_v_221/scripts/com/qzone/qui/managers/EffectManager.as
class EffectManager extends EventDispatcher {
	// EffectManager.as:11（Main.setup 写 TweenLite；补间播放本体在 #39）
	public static var tweenerClass:Dynamic;

	// EffectManager.as:13
	public static var comboBaseEffect:Dynamic;

	// EffectManager.as:15（legacy Main 不赋值，恒 null）
	public static var toolTipEffect:Dynamic;

	// EffectManager.as:17（同上）
	public static var popUpEffect:Dynamic;

	// EffectManager.as:19（弱键字典，键是动效目标 DisplayObject——Move 存取
	// tweener、playEffect 收尾用）。K 必须是对象类型：Dictionary 是
	// @:multiType，K=Dynamic 落 StringMap、DisplayObject 键被 JS 对象键强转成
	// toString() 串，两个同名显示对象会撞键（UIComponent.renderCalls 同款坑）
	public static var effectInstances:Dictionary<DisplayObject, Dynamic> = new Dictionary<DisplayObject, Dynamic>(true);

	public function new() {
		super();
	}

	// EffectManager.as:26-29（...rest → Array<Dynamic> = null，见类头）
	public static function In(param1:DisplayObjectContainer, param2:DisplayObject, param3:Dynamic = null, param4:Array<Dynamic> = null):Void {
		playEffect("In", param1, param2, param3, param4);
	}

	// EffectManager.as:31-42（param5 缺省 null 时 AS3 的 apply(null,null) 是
	// 零参调用；Haxe 的 Reflect.callMethod 收 null 数组各目标行为不定，归一
	// 成 [] 复刻零参语义）
	public static function playEffect(param1:String, param2:DisplayObjectContainer, param3:DisplayObject, param4:Dynamic, param5:Array<Dynamic> = null):Void {
		if (As3.hasProp(param3, "effect") && As3.truthy(Reflect.field(param3, "effect")) && EffectManager.effectInstances.get(param3) == null) {
			var _loc1_:Dynamic = Reflect.field(param3, "effect");
			Reflect.callMethod(_loc1_, Reflect.field(_loc1_, param1), [param2, param3, param4, param5]);
		} else {
			var _loc2_:Dynamic = EffectManager.effectInstances.get(param3);
			if (As3.truthy(_loc2_)) {
				Reflect.callMethod(_loc2_, Reflect.field(_loc2_, "complete"), []);
			}
			Reflect.callMethod(null, param4, param5 == null ? [] : param5);
		}
	}

	// EffectManager.as:44-47（原版 param3 无默认值，照抄）
	public static function Out(param1:DisplayObjectContainer, param2:DisplayObject, param3:Dynamic, param4:Array<Dynamic> = null):Void {
		playEffect("Out", param1, param2, param3, param4);
	}
}
