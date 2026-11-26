package com.minutes.ui.control;

import com.minutes.ui.constant.ScrollPolicy;
import com.minutes.ui.core.LipiContainer;
import com.minutes.ui.core.LipiSkin;
import com.minutes.ui.core.UIEvent;
import openfl.display.DisplayObject;
import openfl.events.MouseEvent;

/**
 * com.minutes.ui.control.JerryNavigation —— JerryNavigation.as 逐句对应
 * （issue #86 牧场库底座，LipiUI 组件库片）。
 * legacy/decompiled/Master2_v_142/scripts/com/minutes/ui/control/JerryNavigation.as。
 *
 * PORT-NOTE（`as ToggleButton` 批量取件，setSelectedButton/skinPack）：
 * eval 裸 cast 不做运行时检查（lessons #7）——buttonList 元素恒为
 * addItem 自造的 ToggleButton，isOfType 门 + 直取；skinPack 的
 * `this.buttonList[_loc1_].defaultSkin`（JerryNavigation.as:140-141）是无
 * cast 的动态属性直写（Array 元素 Dynamic）——元素恒 ToggleButton，cast
 * 真类型后写（CLAUDE.md Dynamic 写禁条三选一之「openfl 真属性/真类型」）。
 * PORT-NOTE（menuHeight setter 的 `super.height = param1`，:194-198）：
 * 绕过自身 width/height 覆写直写基类存储——Haxe 无 super 属性写法等价物
 * 之外的形态，super.set_height 直调（访问器覆写链见 LipiUIComponent 类头）。
 * PORT-NOTE（`ToggleButton(param1.currentTarget)`，:267）：AS3 的 Type(x)
 * 是强转（非 as——失配抛 TypeError 而非 null）。监听只挂在自家
 * ToggleButton 上，cast 直取等价。
 */
@:keep
class JerryNavigation extends LipiContainer {
	// JerryNavigation.as:13
	public static final MOUSE_DOWN:String = "mousedown";

	// :15-57
	private var _spaceBetween:Int = 0;
	private var indexChanged:Bool = false;
	private var _leftDistance:Float = 0;
	private var _defaultColor:UInt = 0;
	private var buttonList:Array<Dynamic> = [];
	private var _selectedSkin:Class<Dynamic> = null;
	private var _selectedColor:UInt = 10027008;
	private var _defaultButtonHeight:Float = 40;
	private var _defaultSkin:Class<Dynamic> = null;
	private var layerChanged:Bool = false;
	private var _selectedBold:Bool = false;
	private var _defaultBold:Bool = false;
	private var _defaultSize:UInt = 12;
	private var _selectedSize:UInt = 12;
	private var _defaultButtonWidth:Float = 120;
	private var SkinChanged:Bool = false;
	private var _topHeight:Float = 10;
	private var _defaultWidthSet:Bool = false;
	private var _selectedFont:String = "";
	private var _defaultFont:String = "";
	private var _trueHeight:Float = 20;
	private var _selectedIndex:Int = 0;

	// :59-68
	public function new() {
		super();
		this.bgAlpha = 0;
		this.width = 0;
		this.height = 0;
		this.verticalScrollPolicy = ScrollPolicy.OFF;
		this.horizontalScrollPolicy = ScrollPolicy.OFF;
		this.menuHeight = 30;
	}

	// :70-73
	public var menuButtonHeight(get, set):Float;

	private function get_menuButtonHeight():Float {
		return this._defaultButtonHeight;
	}

	// :75-78
	private function set_menuButtonHeight(param1:Float):Float {
		this._defaultButtonHeight = param1;
		return param1;
	}

	// :80-83
	public function getItem(param1:Int):DisplayObject {
		return this.getChildAt(param1);
	}

	// :85-91
	public override function addChildAt(param1:DisplayObject, param2:Int):DisplayObject {
		super.addChildAt(param1, param2);
		this.layerChanged = true;
		invalidateDisplayList();
		return param1;
	}

	// :93-96
	public var leftDistance(get, set):Float;

	private function get_leftDistance():Float {
		return this._leftDistance;
	}

	// :98-101
	public var spaceBetween(get, set):Int;

	private function get_spaceBetween():Int {
		return this._spaceBetween;
	}

	// :103-108
	public var menuButtonWidth(get, set):Float;

	private function set_menuButtonWidth(param1:Float):Float {
		this._defaultButtonWidth = param1;
		this._defaultWidthSet = true;
		this.autoLayer();
		return param1;
	}

	// :110-133（`as ToggleButton` 见类头 PORT-NOTE；元素恒 ToggleButton）
	private function setSelectedButton():Void {
		var _loc1_:Int = 0;
		while (_loc1_ < this.buttonList.length) {
			cast(this.buttonList[_loc1_], ToggleButton).selected = false;
			cast(this.buttonList[_loc1_], ToggleButton).textSize = this._defaultSize;
			cast(this.buttonList[_loc1_], ToggleButton).textColor = this._defaultColor;
			if (this._defaultFont != "") {
				cast(this.buttonList[_loc1_], ToggleButton).textFont = this._defaultFont;
			}
			cast(this.buttonList[_loc1_], ToggleButton).textBold = this._defaultBold;
			_loc1_++;
		}
		cast(this.buttonList[this.selectedIndex], ToggleButton).selected = true;
		cast(this.buttonList[this.selectedIndex], ToggleButton).textSize = this._selectedSize;
		cast(this.buttonList[this.selectedIndex], ToggleButton).textColor = this._selectedColor;
		if (this._selectedFont != "") {
			cast(this.buttonList[this.selectedIndex], ToggleButton).textFont = this._selectedFont;
		}
		cast(this.buttonList[this.selectedIndex], ToggleButton).textBold = this._selectedBold;
	}

	// :135-144（动态属性直写 → cast 真类型，见类头 PORT-NOTE）
	private function skinPack():Void {
		var _loc1_:Int = 0;
		while (_loc1_ < this.buttonList.length) {
			cast(this.buttonList[_loc1_], ToggleButton).defaultSkin = new LipiSkin(this.defaultSkin);
			cast(this.buttonList[_loc1_], ToggleButton).selectedSkin = new LipiSkin(this.selectedSkin);
			_loc1_++;
		}
	}

	// :146-149
	public var selectedSkin(get, set):Class<Dynamic>;

	private function get_selectedSkin():Class<Dynamic> {
		return this._selectedSkin;
	}

	// :151-156
	public var defaultSkin(get, set):Class<Dynamic>;

	private function set_defaultSkin(param1:Class<Dynamic>):Class<Dynamic> {
		this._defaultSkin = param1;
		this.SkinChanged = true;
		invalidateDisplayList();
		return param1;
	}

	// :158-163
	private function set_leftDistance(param1:Float):Float {
		this._leftDistance = param1;
		this.layerChanged = true;
		invalidateDisplayList();
		return param1;
	}

	// :165-177
	private function getSelectedIndex(param1:ToggleButton):Int {
		var _loc2_:Int = 0;
		while (_loc2_ < this.buttonList.length) {
			if (this.buttonList[_loc2_] == param1) {
				return _loc2_;
			}
			_loc2_++;
		}
		return this.selectedIndex;
	}

	// :179-184
	private function set_spaceBetween(param1:Int):Int {
		this._spaceBetween = param1;
		this.layerChanged = true;
		invalidateDisplayList();
		return param1;
	}

	// :186-192
	public function selectedFontStyle(param1:UInt = 12, param2:UInt = 13369344, param3:String = "", param4:Bool = false):Void {
		this._selectedSize = param1;
		this._selectedColor = param2;
		this._selectedFont = param3;
		this._selectedBold = param4;
	}

	// :194-198（super.height 直写见类头 PORT-NOTE）
	public var menuHeight(get, set):Float;

	private function set_menuHeight(param1:Float):Float {
		this._trueHeight = param1;
		super.set_height(param1);
		return param1;
	}

	// :200-204
	public var topHeight(get, set):Float;

	private function set_topHeight(param1:Float):Float {
		this._topHeight = param1;
		this.autoLayer();
		return param1;
	}

	// :206-235
	public function addItem(param1:String, param2:Float = 0, param3:Float = 0, param4:Array<Dynamic> = null):Void {
		var _loc5_:ToggleButton = new ToggleButton();
		_loc5_.bgAlpha = 0;
		_loc5_.label = param1;
		_loc5_.labelFilters = param4;
		_loc5_.textSize = this._defaultSize;
		_loc5_.textColor = this._defaultColor;
		if (this._defaultFont != "") {
			_loc5_.textFont = this._defaultFont;
		}
		this.buttonList.push(_loc5_);
		if (param2 != 0 && param3 != 0) {
			_loc5_.width = param2;
			_loc5_.height = param3;
			_loc5_.name = "selfSize";
		} else {
			_loc5_.width = this._defaultButtonWidth;
			_loc5_.height = this._defaultButtonHeight;
			_loc5_.name = "defaultSize";
		}
		this.addChild(_loc5_);
		_loc5_.addEventListener(MouseEvent.MOUSE_DOWN, this.mouseDownDispatcher);
		this.SkinChanged = true;
		invalidateDisplayList();
	}

	// :237-240
	private function get_menuButtonWidth():Float {
		return this._defaultButtonWidth;
	}

	// :242-245
	private function get_topHeight():Float {
		return this._topHeight;
	}

	// :247-253
	public function defaultFontStyle(param1:UInt = 12, param2:UInt = 0, param3:String = "", param4:Bool = false):Void {
		this._defaultSize = param1;
		this._defaultColor = param2;
		this._defaultFont = param3;
		this._defaultBold = param4;
	}

	// :255-258
	private function get_defaultSkin():Class<Dynamic> {
		return this._defaultSkin;
	}

	// :260-263
	private function get_menuHeight():Float {
		return this._trueHeight;
	}

	// :265-272
	private function mouseDownDispatcher(param1:MouseEvent):Void {
		var _loc2_:ToggleButton = cast(param1.currentTarget, ToggleButton);
		this.selectedIndex = this.getSelectedIndex(_loc2_);
		var _loc3_:UIEvent = new UIEvent(JerryNavigation.MOUSE_DOWN);
		_loc3_.data = this;
		this.dispatchEvent(_loc3_);
	}

	// :274-279
	private function set_selectedSkin(param1:Class<Dynamic>):Class<Dynamic> {
		this._selectedSkin = param1;
		this.SkinChanged = true;
		invalidateDisplayList();
		return param1;
	}

	// :281-293
	public var selectedIndex(get, set):Int;

	private function set_selectedIndex(param1:Int):Int {
		if (param1 < 0) {
			param1 = 0;
		}
		if (param1 < this.buttonList.length) {
			this._selectedIndex = param1;
			this.indexChanged = true;
			invalidateDisplayList();
		}
		return param1;
	}

	// :295-298
	private function get_selectedIndex():Int {
		return this._selectedIndex;
	}

	// :300-320
	private function autoLayer():Void {
		var _loc4_:DisplayObject = null;
		var _loc1_:Float = this._leftDistance;
		var _loc2_:Int = 0;
		var _loc3_:Int = this.numChildren;
		while (_loc2_ < _loc3_) {
			_loc4_ = this.getChildAt(_loc2_);
			if (_loc4_.name == "defaultSize") {
				_loc4_.width = this._defaultButtonWidth;
				_loc4_.height = this._defaultButtonHeight;
			}
			_loc4_.x = _loc1_;
			_loc4_.y = this._topHeight;
			_loc1_ += _loc4_.width + this._spaceBetween;
			_loc2_++;
		}
		resetSize();
	}

	// :322-328
	public override function addChild(param1:DisplayObject):DisplayObject {
		super.addChild(param1);
		this.layerChanged = true;
		invalidateDisplayList();
		return param1;
	}

	// :330-348
	private override function updateDisplayList(param1:Float, param2:Float):Void {
		super.updateDisplayList(param1, param2);
		if (this.SkinChanged) {
			this.skinPack();
			this.SkinChanged = false;
		}
		if (this.indexChanged) {
			this.setSelectedButton();
			this.indexChanged = false;
		}
		if (this.layerChanged) {
			this.autoLayer();
			this.layerChanged = false;
		}
	}
}
