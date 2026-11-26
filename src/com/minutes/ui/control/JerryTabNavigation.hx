package com.minutes.ui.control;

import com.minutes.ui.core.LipiSkin;
import com.minutes.ui.core.LipiUIComponent;
import com.minutes.ui.core.UIEvent;
import openfl.display.DisplayObject;
import openfl.events.Event;

/**
 * com.minutes.ui.control.JerryTabNavigation —— JerryTabNavigation.as 逐句
 * 对应（issue #86 牧场库底座，LipiUI 组件库片）。
 * legacy/decompiled/Master2_v_142/scripts/com/minutes/ui/control/JerryTabNavigation.as。
 *
 * PORT-NOTE（width/height setter 覆写，:41-46/:53-58）：先 super 写基类
 * 存储通道再排布 menu/tabContainer——Haxe 属性覆写形态：基类访问器
 * private override 链（LipiUIComponent 类头），super.set_width/set_height
 * 直调。
 * PORT-NOTE（`JerryNavigation(param1.currentTarget)`，:62/:64）：AS3 的
 * Type(x) 强转（失配抛 TypeError）——事件源恒为构造时挂监听的 this.menu，
 * cast 直取等价。:62 的连锁赋值 `this._selectedIndex = this.tabContainer
 * .selectedIndex = …selectedIndex`——tabContainer setter 先进（返 param1
 * 原文值），再进自身字段；Haxe 属性 setter 返值同形态，逐字。
 */
@:keep
class JerryTabNavigation extends LipiUIComponent {
	// JerryTabNavigation.as:12
	public static final TAB_SELECT:String = "tabSelect";

	// :14-20
	private var unInit:Bool = true;
	public var menu:JerryNavigation;
	private var tabContainer:JerryTabContainer;
	private var _selectedIndex:Int = 0;

	// :22-29
	public function new() {
		super();
		this.bgAlpha = 0;
		this.menu = new JerryNavigation();
		this.tabContainer = new JerryTabContainer();
		this.menu.addEventListener(JerryNavigation.MOUSE_DOWN, this.dosomething);
	}

	// :31-34
	public var menuDefaultButtonHeight(get, set):Float;

	private function set_menuDefaultButtonHeight(param1:Float):Float {
		this.menu.menuButtonHeight = param1;
		return param1;
	}

	// :36-39
	public function selectedFontStyle(param1:UInt = 12, param2:UInt = 13369344, param3:String = "", param4:Bool = false):Void {
		this.menu.selectedFontStyle(param1, param2, param3, param4);
	}

	// :41-46
	private override function set_width(param1:Float):Float {
		super.set_width(param1);
		this.menu.width = param1 - this.menu.x;
		this.tabContainer.width = param1;
		return param1;
	}

	// :48-51
	public var menuDefaultSkin(never, set):Class<Dynamic>;

	private function set_menuDefaultSkin(param1:Class<Dynamic>):Class<Dynamic> {
		this.menu.defaultSkin = param1;
		return param1;
	}

	// :53-58
	private override function set_height(param1:Float):Float {
		super.set_height(param1);
		this.menu.height = this.menu.menuHeight;
		this.tabContainer.height = param1 - this.menu.menuHeight;
		return param1;
	}

	// :60-66（连锁赋值见类头 PORT-NOTE）
	private function dosomething(param1:Event):Void {
		this._selectedIndex = this.tabContainer.selectedIndex = cast(param1.currentTarget, JerryNavigation).selectedIndex;
		var _loc2_:UIEvent = new UIEvent(JerryTabNavigation.TAB_SELECT, true);
		_loc2_.data = cast(param1.currentTarget, JerryNavigation).selectedIndex;
		dispatchEvent(_loc2_);
	}

	// :68-71
	public var topHeight(get, set):Float;

	private function set_topHeight(param1:Float):Float {
		this.menu.topHeight = param1;
		return param1;
	}

	// :73-77
	public var menuHeight(never, set):Float;

	private function set_menuHeight(param1:Float):Float {
		this.menu.menuHeight = param1;
		this.autoLayer();
		return param1;
	}

	// :79-85
	public function addItem(param1:String, param2:DisplayObject, param3:Float = 0, param4:Float = 0, param5:Array<Dynamic> = null):Void {
		this.menu.addItem(param1, param3, param4, param5);
		this.tabContainer.addItem(param2);
		this.selectedIndex = 0;
		this.show();
	}

	// :87-90
	public function getTabItem(param1:Int):DisplayObject {
		return this.menu.getItem(param1);
	}

	// :92-95（原文返 `this.menu.leftDistance`——Number 通道经 int 属性
	// 出口，AS3 隐式截断；int 形参写法见 menuLeftDistance setter）
	public var menuLeftDistance(get, set):Int;

	private function get_menuLeftDistance():Int {
		return shim.As3.intOf(this.menu.leftDistance);
	}

	// :97-100
	private function get_topHeight():Float {
		return this.menu.topHeight;
	}

	// :102-105
	public function defaultFontStyle(param1:UInt = 12, param2:UInt = 0, param3:String = "", param4:Bool = false):Void {
		this.menu.defaultFontStyle(param1, param2, param3, param4);
	}

	// :107-113
	private function autoLayer():Void {
		this.tabContainer.width = this.width;
		this.tabContainer.height = this.height - this.menu.menuHeight;
		this.tabContainer.x = 0;
		this.tabContainer.y = this.menu.menuHeight;
	}

	// :115-118
	public var menuDefaultButtonWidth(get, set):Float;

	private function set_menuDefaultButtonWidth(param1:Float):Float {
		this.menu.menuButtonWidth = param1;
		return param1;
	}

	// :120-123
	public var bgClass(never, set):Class<Dynamic>;

	private function set_bgClass(param1:Class<Dynamic>):Class<Dynamic> {
		this.bgSkin = new LipiSkin(param1);
		return param1;
	}

	// :125-128
	public var menuBgClass(never, set):Class<Dynamic>;

	private function set_menuBgClass(param1:Class<Dynamic>):Class<Dynamic> {
		this.menu.bgSkin = new LipiSkin(param1);
		return param1;
	}

	// :130-135
	public var selectedIndex(get, set):Int;

	private function set_selectedIndex(param1:Int):Int {
		this._selectedIndex = param1;
		this.menu.selectedIndex = param1;
		this.tabContainer.selectedIndex = param1;
		return param1;
	}

	// :137-140
	private function get_menuDefaultButtonWidth():Float {
		return this.menu.menuButtonWidth;
	}

	// :142-145
	public var contentBgClass(never, set):Class<Dynamic>;

	private function set_contentBgClass(param1:Class<Dynamic>):Class<Dynamic> {
		this.tabContainer.bgSkin = new LipiSkin(param1);
		return param1;
	}

	// :147-150
	public var menuSelectedSkin(never, set):Class<Dynamic>;

	private function set_menuSelectedSkin(param1:Class<Dynamic>):Class<Dynamic> {
		this.menu.selectedSkin = param1;
		return param1;
	}

	// :152-155
	private function set_menuLeftDistance(param1:Int):Int {
		this.menu.leftDistance = param1;
		return param1;
	}

	// :157-160
	private function get_selectedIndex():Int {
		return this._selectedIndex;
	}

	// :162-165
	public var menuSpaceDistance(get, set):Int;

	private function set_menuSpaceDistance(param1:Int):Int {
		this.menu.spaceBetween = param1;
		return param1;
	}

	// :167-170
	private function get_menuDefaultButtonHeight():Float {
		return this.menu.menuButtonHeight;
	}

	// :172-175
	private function get_menuSpaceDistance():Int {
		return this.menu.spaceBetween;
	}

	// :177-186
	private function show():Void {
		if (this.unInit) {
			this.unInit = false;
			addChild(this.tabContainer);
			addChild(this.menu);
		}
		this.autoLayer();
	}
}
