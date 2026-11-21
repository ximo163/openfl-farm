package module.levelup;

import openfl.display.DisplayObject;
import openfl.display.Sprite;

/**
 * module.levelup.AlignUtils —— AlignUtils.as 逐句对应（issue #18 升级模块片）。
 * 升级面板的对齐/布局数学（无状态静态工具）。`int(...)` 截断 → Std.int。
 */
class AlignUtils {
	public function new() {}

	// AlignUtils.as:11-13
	public static function align_LEFT_CENTER(param1:Sprite, param2:DisplayObject):Void {
		param2.y = Std.int((param1.height - param2.height) * 0.5);
	}

	// :15-18
	public static function getPositionX_ROW(param1:Int, param2:Int):Int {
		return param2 * param1;
	}

	// :20-24
	public static function scale_TO_WIDTH(param1:DisplayObject, param2:Int):Void {
		var _loc3_:Float = param2 / param1.width;
		param1.height *= _loc3_;
		param1.width = param2;
	}

	// :26-28
	public static function align_TOP_CENTER(param1:Sprite, param2:DisplayObject):Void {
		param2.x = Std.int((param1.width - param2.width) * 0.5);
	}

	// :30-32
	public static function getPositionY_COLUMN(param1:Int, param2:Int):Int {
		return param2 * param1;
	}

	// :34-37
	public static function align_CENTER(param1:Sprite, param2:DisplayObject):Void {
		param2.x = Std.int((param1.width - param2.width) * 0.5);
		param2.y = Std.int((param1.height - param2.height) * 0.5);
	}
}
