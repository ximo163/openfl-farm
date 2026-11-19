package com.qzone.utils;

import openfl.display.InteractiveObject;
import openfl.events.ContextMenuEvent;
import openfl.ui.ContextMenu;
import openfl.ui.ContextMenuItem;

// com.qzone.utils.RightMenu —— RightMenu.as 逐句对应（56 loc ≤ 100，闭包规则
// 整类翻译；Main.setup 的画质切换右键菜单走这里）。
class RightMenu {
	public function new() {
		super();
	}

	// RightMenu.as:13-35
	public static function addMenuItem(param1:InteractiveObject, param2:String, param3:Dynamic = null, param4:Bool = false,
			param5:Bool = true, param6:Bool = true, param7:Bool = true):Void {
		var _loc8_:ContextMenu = null;
		if (param1.contextMenu == null) {
			_loc8_ = new ContextMenu();
		} else {
			_loc8_ = cast param1.contextMenu;
		}
		if (param7) {
			_loc8_.hideBuiltInItems();
		}
		var _loc9_:ContextMenuItem = new ContextMenuItem(param2, param4, param5, param6);
		if (param3 != null) {
			_loc9_.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, param3);
		}
		_loc8_.customItems.push(_loc9_);
		param1.contextMenu = _loc8_;
	}

	// RightMenu.as:37-51
	public static function hideBuiltInItems(param1:InteractiveObject):Void {
		var _loc2_:ContextMenu = null;
		if (param1.contextMenu == null) {
			_loc2_ = new ContextMenu();
		} else {
			_loc2_ = cast param1.contextMenu;
		}
		_loc2_.hideBuiltInItems();
		param1.contextMenu = _loc2_;
	}
}
