package com.qzone.qui.controls;

import com.qzone.qui.styles.Style;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import shim.As3;

/**
 * com.qzone.qui.controls.Label —— Label.as 逐句对应（issue #9 qui 子集片）。
 * 文本控件基类（Button/Text 的父类）。原版 padingH/padingV setter 拼写照抄。
 * _clickFn: AS3 protected Function → Haxe private Dynamic。
 */
class Label extends UIComponent {
	// Label.as:13-25
	private var _text:String;
	private var _textField:TextField;
	private var paddingH:Int;
	public var textDisabledFormat:TextFormat;
	private var paddingV:Int;
	public var textDefaultFormat:TextFormat;
	private var _clickFn:Dynamic;

	// Label.as:27-55
	public function new(param1:String = "Label", param2:Dynamic = null, param3:String = "") {
		super();
		this._width = 100;
		this._height = 20;
		this.paddingH = Style.labelPaddingH;
		this.paddingV = 0;
		this._text = param1;
		this._clickFn = param2;
		if (param2 == null) {
			this.mouseEnabled = false;
		}
		this.textDefaultFormat = Style.getLabelFormat();
		this.textDisabledFormat = Style.getDisabledFormat();
		this._textField = new TextField();
		this._textField.selectable = false;
		this._textField.multiline = true;
		if (param3 == "") {
			this._textField.autoSize = TextFieldAutoSize.NONE;
		} else {
			this._textField.autoSize = param3;
		}
		this.useHandCursor = false;
		this.mouseChildren = false;
	}

	// Label.as:57-71
	private override function setSize():Void {
		if (this._textField == null) {
			return;
		}
		if (this._resized == false) {
			this._width = this._textField.textWidth + 8 + this.paddingH * 2;
		}
		this._textField.width = this._width - this.paddingH * 2;
		this._textField.height = Math.max(25, this._textField.textHeight);
		this._textField.x = this.paddingH;
		this._textField.y = this.paddingV;
	}

	// Label.as:73-82
	private function textChanged():Void {
		var _loc1_:Float = this._width;
		var _loc2_:Float = this._height;
		this.setSize();
		if (_loc1_ != this._width || _loc2_ != this._height) {
			this.dispatchEvent(new Event(Event.RESIZE));
		}
	}

	// Label.as:84-87
	public var textField(get, never):TextField;

	private function get_textField():TextField {
		return this._textField;
	}

	// Label.as:89-95
	private override function init():Void {
		this.text = this._text;
		this.clickFn = this._clickFn;
		this.addChild(this._textField);
		super.init();
	}

	// Label.as:97-100（原版拼写 padingV）
	public var padingV(never, set):Int;

	private function set_padingV(param1:Int):Int {
		this.paddingV = param1;
		return param1;
	}

	// Label.as:102-108（AS3 `param1 || ""`）
	public var text(get, set):String;

	private function set_text(param1:String):String {
		this._textField.defaultTextFormat = this.textDefaultFormat;
		this._text = As3.or(param1, "");
		this._textField.htmlText = this._text;
		this.textChanged();
		return param1;
	}

	// Label.as:110-116
	public var embedFonts(get, set):Bool;

	private function set_embedFonts(param1:Bool):Bool {
		if (this._textField != null) {
			this._textField.embedFonts = param1;
		}
		return param1;
	}

	// Label.as:118-127
	public var clickFn(never, set):Dynamic;

	private function set_clickFn(param1:Dynamic):Dynamic {
		this.removeClickEvent();
		if (param1 != null) {
			this._clickFn = param1;
			this.addEventListener(MouseEvent.CLICK, this._clickFn, false, 0, true);
			this.buttonMode = true;
		}
		return param1;
	}

	// Label.as:129-136
	private function get_text():String {
		if (this._textField != null) {
			return this._textField.text;
		}
		return "";
	}

	private function get_embedFonts():Bool {
		if (this._textField != null) {
			return this._textField.embedFonts;
		}
		return false;
	}

	// Label.as:147-155
	private function removeClickEvent():Void {
		if (this._clickFn != null) {
			this.removeEventListener(MouseEvent.CLICK, this._clickFn);
			this.buttonMode = false;
			this._clickFn = null;
		}
	}

	// Label.as:157-160（原版拼写 padingH）
	public var padingH(never, set):Int;

	private function set_padingH(param1:Int):Int {
		this.paddingH = param1;
		return param1;
	}

	// Label.as:162-176
	private override function setEnabled():Void {
		if (this._textField != null) {
			if (this._enabled == false) {
				this._textField.setTextFormat(this.textDisabledFormat);
			} else {
				this._textField.setTextFormat(this.textDefaultFormat);
			}
		}
		this.mouseEnabled = this._enabled;
	}
}
