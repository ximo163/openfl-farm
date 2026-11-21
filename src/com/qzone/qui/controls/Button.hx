package com.qzone.qui.controls;

import com.qzone.qui.skins.ButtonDefaultSkin;
import com.qzone.qui.styles.Style;
import com.qzone.utils.DisplayUtil;
import openfl.display.DisplayObject;
import openfl.display.MovieClip;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.text.TextFormat;

/**
 * com.qzone.qui.controls.Button —— Button.as 逐句对应（issue #18 qui 收尾：
 * 控件片整类翻译，替换 #9 的签名 stub）。按钮：点按/换肤状态机（rollover/
 * press/release 滤镜、default/selected 双皮肤、toggle 模式）。AS3
 * `param1 is MovieClip` → Std.isOfType；`new this.defaultSkin()` →
 * Type.createInstance（Class<Dynamic> 反射构造）。
 */
@:keep
class Button extends Label {
	// Button.as:15-27
	private var _selected:Bool;

	public var textSelectedFormat:TextFormat;

	public var selectedSkin:Class<Dynamic>;

	private var _currentFormat:TextFormat;

	public var inGroup:Bool = false;

	private var _skin:DisplayObject;

	public var defaultSkin:Class<Dynamic>;

	public var textOverFormat:TextFormat;

	private var _toggle:Bool;

	// :33-46
	public function new(param1:String = "Button", param2:Dynamic = null) {
		super(param1, param2);
		this.defaultSkin = ButtonDefaultSkin.skin;
		this.selectedSkin = ButtonDefaultSkin.selectedSkin;
		this.paddingH = Style.buttonPaddingH;
		this.paddingV = 3;
		this.textDefaultFormat = Style.getButtonFormat();
		this.textOverFormat = Style.getButtonOverFormat();
		this.textSelectedFormat = Style.getButtonSelectedFormat();
		this.buttonMode = true;
		this.useHandCursor = false;
		this.mouseChildren = false;
	}

	// :48-55
	private function addEvent():Void {
		this.addEventListener(MouseEvent.ROLL_OVER, this.onRollOver);
		this.addEventListener(MouseEvent.ROLL_OUT, this.onRollOut);
		this.addEventListener(MouseEvent.MOUSE_DOWN, this.onPress);
		this.addEventListener(MouseEvent.MOUSE_UP, this.onRelease);
		this.addEventListener(MouseEvent.CLICK, this.onClick);
	}

	// :57-65
	private override function setSize():Void {
		super.setSize();
		if (this._skin != null) {
			this._skin.width = this._width;
			this._skin.height = this._height;
		}
	}

	// :67-71
	private function onRollOver(param1:Event):Void {
		this._textField.setTextFormat(this.textOverFormat);
		this.filters = cast Style.getRollOverFilter();
	}

	// :73-82
	private function setSelectedSkin():Void {
		this._currentFormat = this.textSelectedFormat;
		DisplayUtil.removeChild(this, this._skin);
		if (this.selectedSkin != null) {
			this._skin = Type.createInstance(this.selectedSkin, []);
			this.fixSkin(this._skin);
			this.addChildAt(this._skin, 0);
		}
	}

	// :84-99
	private override function setEnabled():Void {
		if (false == this._enabled) {
			this.removeEvent();
			this._textField.setTextFormat(this.textDisabledFormat);
			this.filters = cast Style.getDisableFilter();
		} else {
			this.addEvent();
			this._textField.setTextFormat(this._currentFormat);
			this.filters = cast Style.getRollOutFilter();
		}
		this.tabEnabled = this._enabled;
		this.mouseEnabled = this._enabled;
	}

	// :101-114（AS3 public get/set 对）
	public var toggle(get, set):Bool;

	private function get_toggle():Bool {
		return this._toggle;
	}

	private function set_toggle(param1:Bool):Bool {
		this._toggle = param1;
		return param1;
	}

	// :103-113（setSkin：按选中态换肤后回写当前格式）
	private override function setSkin():Void {
		if (this._selected) {
			this.setSelectedSkin();
		} else {
			this.setDefaultSkin();
		}
		this._textField.setTextFormat(this._currentFormat);
	}

	// :116-119（AS3 public get/set 对；TabBar/RadioGroup 跨类读写）
	public var selected(get, set):Bool;

	private function get_selected():Bool {
		return this._selected;
	}

	// :152-162
	private function set_selected(param1:Bool):Bool {
		if (this._selected != param1) {
			this._selected = param1;
			if (this._added) {
				this.setSkin();
				this.setSize();
			}
		}
		return param1;
	}

	// :121-131
	private function setDefaultSkin():Void {
		this._currentFormat = this.textDefaultFormat;
		DisplayUtil.removeChild(this, this._skin);
		if (this.defaultSkin != null) {
			this._skin = Type.createInstance(this.defaultSkin, []);
			this.fixSkin(this._skin);
			this.addChildAt(this._skin, 0);
		}
	}

	// :133-136
	private function onPress(param1:Event):Void {
		this.filters = cast Style.getHitFilter();
	}

	// :138-149
	private function onClick(param1:MouseEvent):Void {
		if (this._toggle) {
			if (this.inGroup && this._selected) {
				return;
			}
			this.selected = !this._selected;
			this.dispatchEvent(new Event(Event.CHANGE));
		}
	}

	// :151-154
	private function onRelease(param1:Event):Void {
		this.filters = cast Style.getRollOverFilter();
	}

	// :156-161
	private function fixSkin(param1:DisplayObject):Void {
		if (Std.isOfType(param1, MovieClip)) {
			(cast param1 : MovieClip).gotoAndStop(1);
		}
	}

	// :164-168
	private function onRollOut(param1:Event):Void {
		this._textField.setTextFormat(this._currentFormat);
		this.filters = cast Style.getRollOutFilter();
	}

	// :170-176
	private function removeEvent():Void {
		this.removeEventListener(MouseEvent.ROLL_OVER, this.onRollOver);
		this.removeEventListener(MouseEvent.ROLL_OUT, this.onRollOut);
		this.removeEventListener(MouseEvent.MOUSE_DOWN, this.onPress);
		this.removeEventListener(MouseEvent.MOUSE_UP, this.onRelease);
	}
}
