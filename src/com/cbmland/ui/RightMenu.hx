package com.cbmland.ui;

import openfl.display.InteractiveObject;
import openfl.events.ContextMenuEvent;
import shim.ClipProps;
import shim.ContextMenu;
import shim.ContextMenuItem;

// com.cbmland.ui.RightMenu —— RightMenu.as 逐句对应（issue #86 牧场库底座，
// 右键菜单片）。往 InteractiveObject.contextMenu 挂自定义菜单项的工具
// （Master2.as:145 的"高速模式(&Q)"画质切换项走这里）。
// PORT-NOTE: openfl 没有 flash.ui.ContextMenu/ContextMenuItem，
// InteractiveObject 也没有 contextMenu 属性——类型走 shim.ContextMenu/
// ContextMenuItem 等价物（无宿主菜单、永不显示），contextMenu 属性读写走
// ClipProps 侧表（Dynamic 裸写在 cpp 上抛 Invalid field，见 CLAUDE.md）。
// `param1.contextMenu as ContextMenu` → isOfType 门 + 直取。
@:keep
class RightMenu {
	// RightMenu.as:11-14
	public function new() {}

	// RightMenu.as:16-35
	public static function addMenuItem(param1:InteractiveObject, param2:String, param3:Dynamic, param4:Bool = false, param5:Bool = true,
			param6:Bool = true, param7:Bool = true):Void {
		var _loc8_:ContextMenu = null;
		if (ClipProps.get(param1, "contextMenu") == null) {
			_loc8_ = new ContextMenu();
		} else {
			_loc8_ = Std.isOfType(ClipProps.get(param1, "contextMenu"), ContextMenu) ? cast ClipProps.get(param1, "contextMenu") : null;
		}
		if (param7) {
			_loc8_.hideBuiltInItems();
		}
		var _loc9_:ContextMenuItem = new ContextMenuItem(param2, param4, param5, param6);
		_loc9_.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, param3);
		_loc8_.customItems.push(_loc9_);
		ClipProps.set(param1, "contextMenu", _loc8_);
	}
}
