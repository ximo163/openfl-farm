package com.qzone.utils;

import openfl.display.InteractiveObject;

/**
 * com.qzone.utils.RightMenu —— V3b/V3c 模块翻译，闭包 stub（issue #7 UI
 * 控件/右键菜单族，明确「一律 stub」清单成员）。原版 56 loc：往
 * InteractiveObject.contextMenu 挂 ContextMenuItem（flash.ui），Main.setup
 * 的画质切换右键项与 VersionUtil.setRightMenu 的版本项走这里。openfl 没有
 * flash.ui.ContextMenu/ContextMenuItem 类，右键菜单语义随 qui 片接入时再
 * 定载体；本片保两个静态签名让调用点照原样编译。
 */
@:keep
class RightMenu {
	public function new() {
	}

	// RightMenu.as:13-35（addMenuItem(target, caption, onSelect, ...)）
	public static function addMenuItem(param1:InteractiveObject, param2:String, param3:Dynamic = null, param4:Bool = false,
			param5:Bool = true, param6:Bool = true, param7:Bool = true):Void {}

	// RightMenu.as:37-51
	public static function hideBuiltInItems(param1:InteractiveObject):Void {}
}
