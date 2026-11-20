package com.qzone.qui.effects;

import com.qzone.qui.managers.EffectManager;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;

/**
 * com.qzone.qui.effects.Move —— V3b 顺手翻（issue #8 闭包，Move.as 83 loc
 * ≤ 100；onPopupTip 给狗提示挂的滑入滑出效果类）。
 * legacy/decompiled/main3_v_221/scripts/com/qzone/qui/effects/Move.as 逐句对应。
 */
class Move extends TweenEffect {
	// Move.as:10
	public static var distance:Int = 30;

	public function new() {
		super();
	}

	// Move.as:14-53（In：位图快照淡出下坠，落定回调）
	public static function In(param1:DisplayObjectContainer, param2:DisplayObject, param3:Dynamic, param4:Array<Dynamic> = null):Dynamic {
		var parent:DisplayObjectContainer = param1;
		var target:DisplayObject = param2;
		var callBack:Dynamic = param3;
		var parameters:Array<Dynamic> = param4;
		var bitmapData:BitmapData = TweenEffect.getSnap(parent, target);
		var bitmap:Bitmap = new Bitmap(bitmapData);
		parent.addChild(bitmap);
		TweenEffect.setSnap(parent, target, bitmap);
		TweenEffect.setPosition(target, bitmap);
		var tweener:Dynamic = Reflect.field(EffectManager.tweenerClass, "from")(bitmap, TweenEffect.duration / 1000, {
			"alpha": 0,
			"y": bitmap.y + distance,
			"onComplete": function():Void {
				TweenEffect.setSnap(parent, bitmap, target);
				TweenEffect.setPosition(bitmap, target);
				parent.removeChild(bitmap);
				bitmap.bitmapData = null;
				bitmap = null;
				EffectManager.effectInstances.remove(target);
				// 原版 callBack.apply(null, parameters)：null 按 AS3 语义当空参
				Reflect.callMethod(null, callBack, parameters != null ? parameters : []);
			}
		});
		EffectManager.effectInstances.set(target, tweener);
		return tweener;
	}

	// Move.as:55-82（Out：快照淡出上浮——parent 改取 target.parent）
	public static function Out(param1:DisplayObjectContainer, param2:DisplayObject, param3:Dynamic, param4:Array<Dynamic> = null):Dynamic {
		var parent:DisplayObjectContainer = param1;
		var target:DisplayObject = param2;
		var callBack:Dynamic = param3;
		var parameters:Array<Dynamic> = param4;
		parent = target.parent;
		var bitmapData:BitmapData = TweenEffect.getSnap(parent, target);
		var bitmap:Bitmap = new Bitmap(bitmapData);
		parent.addChild(bitmap);
		TweenEffect.setSnap(parent, target, bitmap);
		TweenEffect.setPosition(target, bitmap);
		var tweener:Dynamic = Reflect.field(EffectManager.tweenerClass, "to")(bitmap, TweenEffect.duration / 1000, {
			"alpha": 0,
			"y": bitmap.y - distance,
			"onComplete": function():Void {
				TweenEffect.setSnap(parent, bitmap, target);
				TweenEffect.setPosition(bitmap, target);
				parent.removeChild(bitmap);
				bitmap.bitmapData = null;
				bitmap = null;
				EffectManager.effectInstances.remove(target);
				Reflect.callMethod(null, callBack, parameters != null ? parameters : []);
			}
		});
		EffectManager.effectInstances.set(target, tweener);
		return tweener;
	}
}
