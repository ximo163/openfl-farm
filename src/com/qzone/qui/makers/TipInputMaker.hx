package com.qzone.qui.makers;

import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.FocusEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * com.qzone.qui.makers.TipInputMaker —— TipInputMaker.as 逐句对应（issue #18
 * qui 收尾：makers 片）。输入框占位提示：聚焦清掉 tipText 并还原格式，失焦
 * 空值时回填 tipText 并置灰（textOutFormat.color = tipTextColor）。
 */
@:keep
class TipInputMaker extends EventDispatcher {
	// TipInputMaker.as:12
	public var tipText:String = "按名称查找";

	// :14
	private var textInFormat:TextFormat;

	// :16（0xAAAAAA）
	public var tipTextColor:UInt = 11184810;

	// :18
	private var _textFiled:TextField;

	// :20
	private var textOutFormat:TextFormat;

	// :22-25
	public function new() {
		super();
	}

	// :27-39（AS3 纯 setter）+ :50-57（getter text，无 setter）
	public var target(never, set):TextField;

	private function set_target(param1:TextField):TextField {
		this.removeEvent();
		if (param1 != null) {
			this._textFiled = param1;
			this.textInFormat = this._textFiled.defaultTextFormat;
			this.textOutFormat = new TextFormat();
			this.textOutFormat.color = this.tipTextColor;
			this.addEvent();
			this._FOCUS_OUT(null);
		}
		return param1;
	}

	// :41-48
	private function _FOCUS_IN(param1:Event):Void {
		if (this._textFiled.text == this.tipText) {
			this._textFiled.text = "";
			this._textFiled.setTextFormat(this.textInFormat);
		}
	}

	// :50-57
	public var text(get, never):String;

	private function get_text():String {
		if (this._textFiled == null) {
			return "";
		}
		return this._textFiled.text != this.tipText ? this._textFiled.text : "";
	}

	// :59-66
	private function _FOCUS_OUT(param1:FocusEvent):Void {
		if (this._textFiled.text == "") {
			this._textFiled.text = this.tipText;
			this._textFiled.setTextFormat(this.textOutFormat);
		}
	}

	// :68-75
	private function removeEvent():Void {
		if (this._textFiled != null) {
			this._textFiled.removeEventListener(FocusEvent.FOCUS_IN, this._FOCUS_IN);
			this._textFiled.removeEventListener(FocusEvent.FOCUS_OUT, this._FOCUS_OUT);
		}
	}

	// :77-81
	private function addEvent():Void {
		this._textFiled.addEventListener(FocusEvent.FOCUS_IN, this._FOCUS_IN);
		this._textFiled.addEventListener(FocusEvent.FOCUS_OUT, this._FOCUS_OUT);
	}
}
