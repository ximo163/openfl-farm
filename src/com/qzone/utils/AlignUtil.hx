package com.qzone.utils;

import openfl.display.DisplayObject;

/**
 * com.qzone.utils.AlignUtil —— V3b 顺手翻（issue #8 闭包，AlignUtil.as
 * 42 loc ≤ 100；FarmLandController.onPlaneLoaded 居中飞机窗）。原版 final class。
 * legacy/decompiled/main3_v_221/scripts/com/qzone/utils/AlignUtil.as 逐句对应。
 */
final class AlignUtil {
	public function new() {}

	// AlignUtil.as:13-17（moveToCenter：int() 截断居中位）
	public static function moveToCenter(param1:DisplayObject, param2:Float, param3:Float):Void {
		param1.x = Std.int(middle(param2, param1.width));
		param1.y = Std.int(middle(param3, param1.height));
	}

	// AlignUtil.as:19-27
	public static function moveToBR(param1:DisplayObject, param2:Float, param3:Float):Void {
		var _loc4_:Float = 0;
		var _loc5_:Float = 0;
		_loc4_ = right(param2, param1.width);
		_loc5_ = right(param3, param1.height);
		param1.x = _loc4_;
		param1.y = _loc5_;
	}

	// AlignUtil.as:29-33
	public static function right(param1:Float, param2:Float):Float {
		return param1 - param2;
	}

	// AlignUtil.as:35-39
	public static function middle(param1:Float, param2:Float):Float {
		return param1 / 2 - param2 / 2;
	}
}
