package com.qzone.qui.controls.listClasses;

import com.qzone.qui.controls.Label;
import com.qzone.qui.controls.UIComponent;
import com.qzone.qui.skins.ListItemDefaultSkin;
import com.qzone.qui.styles.Style;
import com.qzone.utils.DisplayUtil;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.events.MouseEvent;
import shim.As3;

/**
 * com.qzone.qui.controls.listClasses.ListItemRenderer —— ListItemRenderer.as
 * 逐句对应（issue #36 功能 swf 翻译：仓库）。qui 本地副本：列表条目渲染器
 * 基类（ListBase.rebuild 经 itemRenderer 反射构造，skin 双态 + ROLL 过滤
 * 器）。PackItem 继承本类挂背包瓦片。
 *
 * PORT-NOTE: `_data.hasOwnProperty(labelField)`/`_data[labelField]` 的动态
 * 键访问 → As3.hasProp/Reflect.field（WelcomeModel 先例）；`new this.
 * defaultSkin()` 的 Class 实例化 → Type.createInstance（Class<Dynamic> 字段
 * 持有符号 shim 类）；AS3 `a && b()` 短路调用 → 显式 if（语义同形）；
 * AS3 protected 成员 → Haxe private（子类可见，CLAUDE.md 映射）。
 */
class ListItemRenderer extends UIComponent {
	// ListItemRenderer.as:10（AS3 protected → Haxe private）
	private var _selected:Bool;

	// ListItemRenderer.as:12
	private var _data:Dynamic;

	// ListItemRenderer.as:14
	private var _index:Int;

	// ListItemRenderer.as:16
	private var _skin:DisplayObject;

	// ListItemRenderer.as:18
	public var defaultSkin:Class<Dynamic>;

	// ListItemRenderer.as:20
	public var labelField:String = "label";

	// ListItemRenderer.as:22
	private var _label:Label;

	// ListItemRenderer.as:24
	public var selectedSkin:Class<Dynamic>;

	// ListItemRenderer.as:26-38
	public function new(param1:Int) {
		super();
		this._index = param1;
		this.defaultSkin = ListItemDefaultSkin.skin;
		this.selectedSkin = ListItemDefaultSkin.selectedSkin;
		this._height = 18;
		this._width = 100;
		this._label = null;
		this.buttonMode = true;
		this.useHandCursor = false;
		this.mouseChildren = false;
	}

	// ListItemRenderer.as:40-53
	override private function setSize():Void {
		if (this._skin != null) {
			this._skin.width = this._width;
			this._skin.height = this._height;
		}
		if (this._label != null) {
			this._label.width = this._width;
			this._label.height = this._height;
		}
	}

	// ListItemRenderer.as:55-63
	override private function setSkin():Void {
		if (this._selected) {
			this.setSelectedSkin();
		} else {
			this.setDefaultSkin();
		}
	}

	// ListItemRenderer.as:65-80
	override private function init():Void {
		super.init();
		if (this._label == null) {
			this._label = new Label();
			addChild(this._label);
		}
		var _loc1_:String = "";
		if (this._data != null) {
			_loc1_ = As3.hasProp(this._data, this.labelField) ? Reflect.field(this._data, this.labelField) : Std.string(this._data);
		}
		this._label.text = _loc1_;
		this.addEvent();
	}

	// ListItemRenderer.as:82-93（set）与 :135-138（get）合成一对
	public var data(get, set):Dynamic;

	private function set_data(param1:Dynamic):Dynamic {
		var _loc2_:String = null;
		if (param1 != null) {
			this._data = param1;
			_loc2_ = As3.hasProp(this._data, this.labelField) ? Reflect.field(this._data, this.labelField) : Std.string(this._data);
			if (this._label != null) {
				this._label.text = _loc2_;
			}
		}
		return this._data;
	}

	// ListItemRenderer.as:95-98
	public var index(get, never):Int;

	private function get_index():Int {
		return this._index;
	}

	// ListItemRenderer.as:100-103
	public var selected(get, set):Bool;

	private function get_selected():Bool {
		return this._selected;
	}

	// ListItemRenderer.as:105-116
	private function setDefaultSkin():Void {
		if (this._skin != null) {
			DisplayUtil.removeChild(this, this._skin);
			this._skin = null;
		}
		this._skin = Type.createInstance(this.defaultSkin, []);
		this._skin.alpha = 0;
		this.addChildAt(this._skin, 0);
		// AS3 `_added && this.setSize()` 的短路调用 → 显式 if
		if (this._added) {
			this.setSize();
		}
	}

	// ListItemRenderer.as:117-120（get）
	private function get_data():Dynamic {
		return this._data;
	}

	// ListItemRenderer.as:122-128
	private function onRollOut(param1:Event):Void {
		this.filters = cast Style.getRollOutFilter();
		if (!this._selected) {
			this._skin.alpha = 0;
		}
	}

	// ListItemRenderer.as:130-136（set）
	private function set_selected(param1:Bool):Bool {
		if (this._selected != param1) {
			this._selected = param1;
			this.setSkin();
		}
		return this._selected;
	}

	// ListItemRenderer.as:138-142
	private function onRollOver(param1:Event):Void {
		this.filters = cast Style.getRollOverFilter();
		this._skin.alpha = 1;
	}

	// ListItemRenderer.as:144-148
	private function addEvent():Void {
		this.addEventListener(MouseEvent.ROLL_OVER, this.onRollOver, false, 0, true);
		this.addEventListener(MouseEvent.ROLL_OUT, this.onRollOut, false, 0, true);
	}

	// ListItemRenderer.as:150-169
	private function setSelectedSkin():Void {
		if (this._skin != null) {
			DisplayUtil.removeChild(this, this._skin);
			this._skin = null;
		}
		this._skin = Type.createInstance(this.selectedSkin, []);
		this.addChildAt(this._skin, 0);
		// AS3 `_added && this.setSize()` 的短路调用 → 显式 if
		if (this._added) {
			this.setSize();
		}
	}

	// ListItemRenderer.as:171-175
	private function removeEvent():Void {
		this.removeEventListener(MouseEvent.ROLL_OVER, this.onRollOver);
		this.removeEventListener(MouseEvent.ROLL_OUT, this.onRollOut);
	}
}
