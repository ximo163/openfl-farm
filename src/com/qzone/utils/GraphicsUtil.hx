package com.qzone.utils;

import openfl.display.DisplayObject;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.geom.Rectangle;
import shim.As3;

/**
 * com.qzone.utils.GraphicsUtil —— V3b 顺手翻（issue #8 闭包，GraphicsUtil.as
 * 67 loc ≤ 100；FarmLandController.onPlaneLoaded 画弹层遮罩）。原版 final class。
 * legacy/decompiled/main3_v_221/scripts/com/qzone/utils/GraphicsUtil.as 逐句对应。
 */
final class GraphicsUtil {
	public function new() {}

	// 原版 `param1.hasOwnProperty("graphics")`：显示对象里带画布的是
	// Sprite/Shape（MovieClip 派生 Sprite），openfl 的 graphics 是 get-only
	// property、Reflect 探不到，改判型收窄
	private static function hasGraphics(param1:DisplayObject):Bool {
		return Std.isOfType(param1, Sprite) || Std.isOfType(param1, Shape);
	}

	private static function graphicsOf(param1:DisplayObject):Dynamic {
		if (Std.isOfType(param1, Sprite)) {
			return cast(param1, Sprite).graphics;
		}
		return cast(param1, Shape).graphics;
	}

	// GraphicsUtil.as:10-32（hLine：横线）
	public static function hLine(param1:DisplayObject, param2:UInt = 0, param3:Float = 1, param4:Rectangle = null,
			param5:Int = 0):Void {
		var _loc6_:Dynamic = null;
		if (hasGraphics(param1)) {
			_loc6_ = graphicsOf(param1);
			_loc6_.lineStyle(param5, param2, param3);
			if (As3.truthy(param4)) {
				_loc6_.moveTo(param4.x, param4.y);
				_loc6_.lineTo(param4.width, param4.y);
			} else {
				_loc6_.moveTo(param1.x, param1.y);
				_loc6_.lineTo(param1.width, param1.y);
			}
			_loc6_.endFill();
		}
	}

	// GraphicsUtil.as:34-59（draw：填充/描边矩形，遮罩用法在 FarmLandController）
	public static function draw(param1:DisplayObject, param2:UInt = 0, param3:Float = 1, param4:Rectangle = null,
			param5:Bool = false, param6:Bool = true):Void {
		var _loc7_:Dynamic = null;
		if (hasGraphics(param1)) {
			_loc7_ = graphicsOf(param1);
			if (param6) {
				_loc7_.clear();
			}
			if (param5) {
				_loc7_.beginFill(param2, param3);
			} else {
				_loc7_.lineStyle(1, param2, param3);
			}
			if (As3.truthy(param4)) {
				_loc7_.drawRect(param4.x, param4.y, param4.width, param4.height);
			} else {
				_loc7_.drawRect(0, 0, param1.width, param1.height);
			}
			_loc7_.endFill();
		}
	}
}
