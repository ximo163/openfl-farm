package com.greensock;

import shim.As3;

/**
 * com.greensock.TweenLite —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * TweenLite 补间库（TweenLite.as 506 loc + core 三类）在 spec/
 * modules/farm-basic.json 里单列；本片只用到 FarmStage 的
 * TweenLite.to(target, duration, vars)（农场/牧场场景 0.5s 滑动切换）。
 *
 * stub 语义：立即把 vars 里的目标属性写上并同步调 onComplete/
 * onCompleteParams——终态与原版一致（切换完成后 toolbar 派发、光标复位
 * 都会照常发生），中间的插值动画随补间库片整体翻译（届时对拍场景连拍）。
 */
@:keep
class TweenLite {
	public function new(param1:Dynamic = null, param2:Float = 0, param3:Dynamic = null) {}

	// TweenLite.to 的 stub：终态直写 + 同步 onComplete（见类头）
	public static function to(param1:Dynamic, param2:Float, param3:Dynamic):TweenLite {
		var _loc4_:Array<String> = Reflect.fields(param3);
		var _loc5_:String = null;
		for (_loc5_ in (_loc4_:Array<String>)) {
			if (_loc5_ == "onComplete" || _loc5_ == "onCompleteParams" || _loc5_ == "onUpdate" || _loc5_ == "onUpdateParams"
				|| _loc5_ == "delay" || _loc5_ == "ease") {
				continue;
			}
			Reflect.setProperty(param1, _loc5_, Reflect.field(param3, _loc5_));
		}
		var _loc6_:Dynamic = Reflect.field(param3, "onComplete");
		if (_loc6_ != null) {
			var _loc7_:Array<Dynamic> = Reflect.field(param3, "onCompleteParams");
			if (_loc7_ != null) {
				Reflect.callMethod(null, _loc6_, _loc7_);
			} else {
				Reflect.callMethod(null, _loc6_, []);
			}
		}
		return null;
	}

	// TweenLite.from 的 stub：同 to（补间库片翻译）
	public static function from(param1:Dynamic, param2:Float, param3:Dynamic):TweenLite {
		return to(param1, param2, param3);
	}

	// TweenLite.as:188-（delayedCall(delay, onComplete, params, useFrames)：
	// 原版经 delay 秒后调 onComplete(params)。stub 用真延迟（As3.setTimeout
	// 走 openfl Timer，Event.ENTER_FRAME 路径对齐原版帧驱动语义）；补间库片
	// 整体翻译时替换成引擎自己的调度。返回值原版是 TweenLite 实例，stub 的
	// 调用方（LandPickIcon/NPCView 的 0.25-3s 浮层收尾）都不接返回值）
	public static function delayedCall(param1:Float, param2:Dynamic, param3:Array<Dynamic> = null, param4:Bool = false):TweenLite {
		As3.setTimeout(function():Void {
			Reflect.callMethod(null, param2, param3 != null ? param3 : []);
		}, Std.int(param1 * 1000));
		return null;
	}
}
