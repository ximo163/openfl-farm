package com.qzone.qui.controls;

import com.qzone.qui.skins.TextInputDefaultSkin;
import com.qzone.qui.styles.Style;
import com.qzone.utils.DisplayUtil;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;
import shim.As3;

/**
 * com.qzone.qui.controls.TextInput —— TextInput.as 逐句对应（issue #18 qui
 * 收尾：控件片）。单行文本输入框：INPUT/DYNAMIC 类型切换、焦点换肤
 * （default/selected 双皮肤）、启用/禁用滤镜。
 */
class TextInput extends UIComponent {
	// TextInput.as:12-29
	private var _readOnly:Bool;

	private var _text:String;

	private var _textField:TextField;

	private var paddingH:Int;

	private var _skin:DisplayObject;

	public var defaultSkin:Class<Dynamic>;

	public var textDisabledFormat:TextFormat;

	private var paddingV:Int;

	public var textDefaultFormat:TextFormat;

	public var selectedSkin:Class<Dynamic>;

	private var _selected:Bool;

	// :31-48
	public function new() {
		super();
		this._width = 100;
		this._height = 20;
		this.paddingH = Style.textInputPaddingH;
		this.paddingV = Style.textInputPaddingV;
		this.textDefaultFormat = Style.getTextInputFormat();
		this.textDisabledFormat = Style.getDisabledFormat();
		this._textField = new TextField();
		this._textField.type = TextFieldType.INPUT;
		this._textField.multiline = false;
		this._textField.autoSize = TextFieldAutoSize.NONE;
		this.defaultSkin = TextInputDefaultSkin.skin;
		this.selectedSkin = TextInputDefaultSkin.selectedSkin;
	}

	// :50-58
	private function setSelectedSkin():Void {
		DisplayUtil.removeChild(this, this._skin);
		if (this.selectedSkin != null) {
			this._skin = Type.createInstance(this.selectedSkin, []);
			this.addChildAt(this._skin, 0);
		}
	}

	// :60-70
	private override function setSize():Void {
		if (this._skin != null) {
			this._skin.width = this._width;
			this._skin.height = this._height;
		}
		this._textField.x = this.paddingH;
		this._textField.y = this.paddingV;
		this._textField.width = this._width - this.paddingH * 2;
		this._textField.height = this._height - this.paddingV * 2;
	}

	// :72-76 + :133-139（AS3 public get/set readOnly 对）
	public var readOnly(get, set):Bool;

	private function set_readOnly(param1:Bool):Bool {
		this._readOnly = param1;
		this.setReadOnly();
		return param1;
	}

	private function get_readOnly():Bool {
		return this._readOnly;
	}

	// :78-87
	private override function setSkin():Void {
		if (this._selected) {
			this.setSelectedSkin();
		} else {
			this.setDefaultSkin();
		}
	}

	// :89-92
	public var htmlText(get, set):String;

	private function get_htmlText():String {
		return this._textField.htmlText;
	}

	// :94-97
	public var textField(get, never):TextField;

	private function get_textField():TextField {
		return this._textField;
	}

	// :99-101
	private function _CHANGE(param1:Event):Void {}

	// :103-109
	private override function init():Void {
		this._textField.defaultTextFormat = this.textDefaultFormat;
		this._textField.mouseWheelEnabled = false;
		this.text = this._text;
		this.addChild(this._textField);
		super.init();
	}

	// :111-114 + :166-172（AS3 public get/set text 对；set 里 `param1 || ""`）
	public var text(get, set):String;

	private function get_text():String {
		return this._textField.text;
	}

	private function set_text(param1:String):String {
		this._text = As3.or(param1, "");
		this._textField.text = this._text;
		return param1;
	}

	// :116-131
	private override function setEnabled():Void {
		if (false == this._enabled) {
			this.removeEvent();
			this._textField.setTextFormat(this.textDisabledFormat);
			this.filters = cast Style.getDisableFilter();
		} else {
			this.addEvent();
			this._textField.setTextFormat(this.textDefaultFormat);
			this.filters = cast Style.getRollOutFilter();
		}
		this.mouseEnabled = this._enabled;
		this.setReadOnly();
	}

	// :133-139（get readOnly 已随 :72-76 声明上移）

	// :141-155
	private function setReadOnly():Void {
		if (this._readOnly) {
			this._textField.type = TextFieldType.DYNAMIC;
		} else if (this._enabled) {
			this._textField.type = TextFieldType.INPUT;
		} else {
			this._textField.type = TextFieldType.DYNAMIC;
		}
	}

	// :157-164
	private function _FOCUS_OUT(param1:Event):Void {
		this.removeEvent();
		this._selected = false;
		this.setSkin();
		this.setSize();
	}

	// :166-172（get text 已随 :111-114 声明上移）

	// :174-181
	private function _FOCUS_IN(param1:Event):Void {
		this._textField.addEventListener(FocusEvent.FOCUS_OUT, this._FOCUS_OUT);
		this._textField.addEventListener(Event.CHANGE, this._CHANGE);
		this._selected = true;
		this.setSkin();
		this.setSize();
	}

	// :183-186
	private function removeEvent():Void {
		this._textField.removeEventListener(Event.CHANGE, this._CHANGE);
		this._textField.removeEventListener(FocusEvent.FOCUS_OUT, this._FOCUS_OUT);
	}

	// :188-190（AS3 `param1 || ""`）
	private function set_htmlText(param1:String):String {
		this._text = As3.or(param1, "");
		this._textField.htmlText = this._text;
		return param1;
	}

	// :192-194
	private function addEvent():Void {
		this._textField.addEventListener(FocusEvent.FOCUS_IN, this._FOCUS_IN);
	}

	// :196-204
	private function setDefaultSkin():Void {
		DisplayUtil.removeChild(this, this._skin);
		if (this.defaultSkin != null) {
			this._skin = Type.createInstance(this.defaultSkin, []);
			this.addChildAt(this._skin, 0);
		}
	}
}
