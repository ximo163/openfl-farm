package com.qzone.utils;

import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.InteractiveObject;
import shim.As3;

/**
 * com.qzone.utils.DisplayUtil —— DisplayUtil.as 逐句对应（issue #43 整类补齐，
 * 替换 #8 只翻 removeChild 的闭包 stub）。hasOwnProperty 门 + 下标写的原版
 * 形态按仓库约定译：属性写走 Reflect.setProperty（js 裸 Dynamic 写只落影子
 * 字段）、hasOwnProperty 走 As3.hasProp（存取器属性也查得到，uitools.md
 * 约定同条）。
 */
@:keep
class DisplayUtil {
	public function new() {}

	// DisplayUtil.as:15-41（setEnabled：mouseEnabled 直写，其余三键有才写；
	// filters 无条件写——enable 复位空数组、disable 落第三参）
	public static function setEnabled(param1:Dynamic, param2:Bool, param3:Array<Dynamic>):Void {
		if (As3.truthy(param1)) {
			Reflect.setProperty(param1, "mouseEnabled", param2);
			if (As3.hasProp(param1, "mouseChildren")) {
				Reflect.setProperty(param1, "mouseChildren", param2);
			}
			if (As3.hasProp(param1, "buttonMode")) {
				Reflect.setProperty(param1, "buttonMode", param2);
			}
			if (As3.hasProp(param1, "enabled")) {
				Reflect.setProperty(param1, "enabled", param2);
			}
			if (param2) {
				Reflect.setProperty(param1, "filters", []);
			} else {
				Reflect.setProperty(param1, "filters", param3);
			}
		}
	}

	// DisplayUtil.as:43-45
	public static function copyXYWH(param1:DisplayObject, param2:DisplayObject):Void {
		copyProperties(param1, param2, ["x", "y", "width", "height"]);
	}

	// DisplayUtil.as:48-59（removeChild：只在 param2 还挂在 param1 上时摘）
	public static function removeChild(param1:DisplayObjectContainer, param2:DisplayObject):DisplayObject {
		if (param2 != null && As3.truthy(param2)) {
			if (param2.parent == param1) {
				return param1.removeChild(param2);
			}
			return null;
		}
		return null;
	}

	// DisplayUtil.as:61-66
	public static function removeChildByName(param1:DisplayObjectContainer, param2:String):DisplayObject {
		var _loc3_:DisplayObject = param1.getChildByName(param2);
		return DisplayUtil.removeChild(param1, _loc3_);
	}

	// DisplayUtil.as:68-73
	public static function removeChildAt(param1:DisplayObjectContainer, param2:Int):DisplayObject {
		var _loc3_:DisplayObject = param1.getChildAt(param2);
		return DisplayUtil.removeChild(param1, _loc3_);
	}

	// DisplayUtil.as:75-83（disableMouse：形参 InteractiveObject，正文仍按
	// is 双查——TextField 只关 mouseEnabled 不进容器分支）
	public static function disableMouse(param1:InteractiveObject):Void {
		if (Std.isOfType(param1, InteractiveObject)) {
			param1.mouseEnabled = false;
		}
		if (Std.isOfType(param1, DisplayObjectContainer)) {
			cast(param1, DisplayObjectContainer).mouseChildren = false;
		}
	}

	// DisplayUtil.as:85-98（copyProperties：只拷 param1 有键的项，双真值门）
	public static function copyProperties(param1:Dynamic, param2:Dynamic, param3:Array<Dynamic>):Void {
		var _loc4_:String = null;
		if (As3.truthy(param1) && As3.truthy(param2)) {
			for (_loc4_ in param3) {
				if (As3.hasProp(param1, _loc4_)) {
					Reflect.setProperty(param2, _loc4_, Reflect.getProperty(param1, _loc4_));
				}
			}
		}
	}
}
