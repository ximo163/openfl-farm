package com.minutes.ui.control;

import com.minutes.ui.core.LipiUIComponent;
import openfl.display.DisplayObject;

/**
 * com.minutes.ui.control.JerryTabNavigation —— JerryTabNavigation.as 的
 * 签名面 stub（原类 189 loc，minutes UI 片真身待译——#pasture；issue #19
 * 只保 ProfileWindow 用到的样式位/addItem/selectedIndex/menu 通道；真身
 * 按 selectedIndex 切换页签内容并派发 UIEvent(TAB_SELECT)）。成员清单见
 * legacy/decompiled/Master2_v_142/scripts/com/minutes/ui/control/JerryTabNavigation.as。
 */
@:keep
class JerryTabNavigation extends LipiUIComponent {
	// JerryTabNavigation.as:12
	public static final TAB_SELECT:String = "tabSelect";

	// JerryTabNavigation.as:16
	public var menu:JerryNavigation;

	private var _tabs:Array<DisplayObject> = [];
	private var _selectedIndex:Int = -1;
	private var _menuLeftDistance:Int = 0;
	private var _menuSpaceDistance:Int = 0;
	private var _menuDefaultButtonWidth:Float = 0;
	private var _menuDefaultButtonHeight:Float = 0;
	private var _menuHeight:Float = 0;
	private var _topHeight:Float = 0;
	private var _menuBgClass:Class<Dynamic>;
	private var _menuDefaultSkin:Class<Dynamic>;
	private var _menuSelectedSkin:Class<Dynamic>;

	public function new() {
		super();
		this.menu = new JerryNavigation();
		addChild(this.menu);
	}

	// JerryTabNavigation.as:36（selectedFontStyle(uint=12,uint=13369344,"",false)）
	public function selectedFontStyle(param1:UInt = 12, param2:UInt = 13369344, param3:String = "", param4:Bool = false):Void {}

	// JerryTabNavigation.as:102（defaultFontStyle(uint=12,uint=0,"",false)）
	public function defaultFontStyle(param1:UInt = 12, param2:UInt = 0, param3:String = "", param4:Bool = false):Void {}

	// JerryTabNavigation.as:79（addItem(label, 内容件, 宽, 高, 滤镜)）
	public function addItem(param1:String, param2:DisplayObject, param3:Float = 0, param4:Float = 0, param5:Array<Dynamic> = null):Void {
		this._tabs.push(param2);
		addChild(param2);
		this.menu.addItem(param1, param3, param4, param5);
	}

	// JerryTabNavigation.as:87
	public function getTabItem(param1:Int):DisplayObject {
		return this._tabs[param1];
	}

	// JerryTabNavigation.as:130/157
	public var selectedIndex(get, set):Int;

	private function get_selectedIndex():Int {
		return this._selectedIndex;
	}

	private function set_selectedIndex(param1:Int):Int {
		this._selectedIndex = param1;
		for (i in 0...this._tabs.length) {
			this._tabs[i].visible = i == param1;
		}
		// 真身的 TAB_SELECT 由导航钮点击派发（JerryNavigation），setter 不派发
		return param1;
	}

	// JerryTabNavigation.as:92/152
	public var menuLeftDistance(get, set):Int;

	private function get_menuLeftDistance():Int {
		return this._menuLeftDistance;
	}

	private function set_menuLeftDistance(param1:Int):Int {
		this._menuLeftDistance = param1;
		return param1;
	}

	// JerryTabNavigation.as:162/172
	public var menuSpaceDistance(get, set):Int;

	private function get_menuSpaceDistance():Int {
		return this._menuSpaceDistance;
	}

	private function set_menuSpaceDistance(param1:Int):Int {
		this._menuSpaceDistance = param1;
		return param1;
	}

	// JerryTabNavigation.as:115/137
	public var menuDefaultButtonWidth(get, set):Float;

	private function get_menuDefaultButtonWidth():Float {
		return this._menuDefaultButtonWidth;
	}

	private function set_menuDefaultButtonWidth(param1:Float):Float {
		this._menuDefaultButtonWidth = param1;
		return param1;
	}

	// JerryTabNavigation.as:31/167
	public var menuDefaultButtonHeight(get, set):Float;

	private function get_menuDefaultButtonHeight():Float {
		return this._menuDefaultButtonHeight;
	}

	private function set_menuDefaultButtonHeight(param1:Float):Float {
		this._menuDefaultButtonHeight = param1;
		return param1;
	}

	// JerryTabNavigation.as:73
	public var menuHeight(get, set):Float;

	private function get_menuHeight():Float {
		return this._menuHeight;
	}

	private function set_menuHeight(param1:Float):Float {
		this._menuHeight = param1;
		return param1;
	}

	// JerryTabNavigation.as:68/97
	public var topHeight(get, set):Float;

	private function get_topHeight():Float {
		return this._topHeight;
	}

	private function set_topHeight(param1:Float):Float {
		this._topHeight = param1;
		return param1;
	}

	// JerryTabNavigation.as:125
	public var menuBgClass(get, set):Class<Dynamic>;

	private function get_menuBgClass():Class<Dynamic> {
		return this._menuBgClass;
	}

	private function set_menuBgClass(param1:Class<Dynamic>):Class<Dynamic> {
		this._menuBgClass = param1;
		return param1;
	}

	// JerryTabNavigation.as:48
	public var menuDefaultSkin(get, set):Class<Dynamic>;

	private function get_menuDefaultSkin():Class<Dynamic> {
		return this._menuDefaultSkin;
	}

	private function set_menuDefaultSkin(param1:Class<Dynamic>):Class<Dynamic> {
		this._menuDefaultSkin = param1;
		return param1;
	}

	// JerryTabNavigation.as:147
	public var menuSelectedSkin(get, set):Class<Dynamic>;

	private function get_menuSelectedSkin():Class<Dynamic> {
		return this._menuSelectedSkin;
	}

	private function set_menuSelectedSkin(param1:Class<Dynamic>):Class<Dynamic> {
		this._menuSelectedSkin = param1;
		return param1;
	}
}
