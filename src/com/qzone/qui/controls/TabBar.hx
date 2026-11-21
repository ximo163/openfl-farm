package com.qzone.qui.controls;

import com.qzone.qui.containers.HBox;
import com.qzone.qui.containers.ViewStack;
import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
import com.qzone.qui.core.Align;
import com.qzone.qui.skins.TabSelectedSkin;
import com.qzone.qui.skins.TabSkin;
import com.qzone.qui.styles.Style;
import openfl.display.DisplayObject;
import openfl.display.Shape;
import openfl.events.Event;
import openfl.text.TextFormat;
import shim.As3;

/**
 * com.qzone.qui.controls.TabBar —— TabBar.as 逐句对应（issue #18 qui 收尾：
 * 控件片）。标签条：Button 逐个成页签，点击互斥选中并驱动 ViewStack。
 * _childObject 是 AS3 Object 当字符串键表用（name → 索引）→ Reflect.field/
 * setField。PORT-NOTE: `param2/param3:Number = NaN` 默认参 → Null<Float> =
 * null + 归一（Haxe 默认参须常量）。
 */
class TabBar extends HBox {
	// TabBar.as:13-30
	private var _currentChild:Button;

	public var tabDefaultFormat:TextFormat;

	public var tabDefaultSkin:Class<Dynamic>;

	private var _childArray:Array<Dynamic> = [];

	public var tabOverFormat:TextFormat;

	public var viewStack:ViewStack;

	public var tabSelectedFormat:TextFormat;

	public var tabSelectedSkin:Class<Dynamic>;

	private var _currentIndex:Int = -1;

	private var _childObject:Dynamic = {};

	// :32-52
	public function new() {
		super();
		this._height = 20;
		this.backgroundAlpha = 0;
		this.gapH = -1;
		this.paddingH = 0;
		this.paddingV = 0;
		this.alignV = Align.TOP;
		this.alignH = Align.LEFT;
		this.defaultSkin = Shape;
		this.borderSizeH = 0;
		this.borderSizeV = 0;
		this.horizontalScrollPolicy = ScrollPolicy.OFF;
		this.verticalScrollPolicy = ScrollPolicy.OFF;
		this.tabDefaultSkin = TabSkin;
		this.tabSelectedSkin = TabSelectedSkin;
		this.tabDefaultFormat = Style.getButtonFormat();
		this.tabSelectedFormat = Style.getButtonSelectedFormat();
		this.tabOverFormat = Style.getButtonOverFormat();
	}

	// :54-57
	private function select(param1:Button):Void {
		param1.selected = true;
	}

	// :59-62
	private function unselect(param1:Button):Void {
		param1.selected = false;
	}

	// :64-76 + :112-114（AS3 public get/set selectedIndex 对）
	public var selectedIndex(get, set):Int;

	private function set_selectedIndex(param1:Int):Int {
		if (this._currentIndex == param1) {
			return param1;
		}
		this.unselect(this._currentChild);
		this._currentChild = this._childArray[param1];
		this.select(this._currentChild);
		this._currentIndex = param1;
		if (this.viewStack != null) {
			this.viewStack.selectedIndex = this._currentIndex;
		}
		return param1;
	}

	// :112-114
	private function get_selectedIndex():Int {
		return this._currentIndex;
	}

	// :78-84
	public var tabNum(get, never):Int;

	private function get_tabNum():Int {
		if (this._childArray == null) {
			return 0;
		}
		return this._childArray.length;
	}

	// :86-108
	public function addTab(param1:String = "新建标签", param2:Null<Float> = null, param3:Null<Float> = null):DisplayObject {
		if (param2 == null) {
			param2 = Math.NaN;
		}
		if (param3 == null) {
			param3 = Math.NaN;
		}
		var _loc4_:Button = new Button(param1, this.tabClick);
		_loc4_.defaultSkin = this.tabDefaultSkin;
		_loc4_.selectedSkin = this.tabSelectedSkin;
		_loc4_.textDefaultFormat = this.tabDefaultFormat;
		_loc4_.textOverFormat = this.tabOverFormat;
		_loc4_.textSelectedFormat = this.tabSelectedFormat;
		this._childArray.push(_loc4_);
		Reflect.setField(this._childObject, _loc4_.name, this._childArray.length - 1);
		this.addElement(_loc4_);
		if (As3.truthy(param3)) {
			_loc4_.height = param3;
		}
		if (As3.truthy(param2)) {
			_loc4_.width = param2;
		}
		if (this._childArray.length == 1) {
			_loc4_.selected = true;
			this._currentChild = _loc4_;
			this._currentIndex = 0;
		}
		param2 = this.content.width;
		return _loc4_;
	}

	// :112-114（get selectedIndex 已随 set 上移）

	// :116-130
	private function tabClick(param1:Event):Void {
		if (this._currentIndex != Reflect.field(this._childObject, param1.target.name)) {
			this.unselect(this._currentChild);
			this._currentChild = Std.isOfType(param1.target, Button) ? cast param1.target : null;
			this.select(this._currentChild);
			this._currentIndex = Reflect.field(this._childObject, this._currentChild.name);
			if (this.viewStack != null) {
				this.viewStack.selectedIndex = this._currentIndex;
			}
			this.dispatchEvent(new Event(Event.CHANGE));
		}
	}
}
