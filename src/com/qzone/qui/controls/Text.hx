package com.qzone.qui.controls;

import com.qzone.qui.styles.Style;
import openfl.text.TextFieldAutoSize;

// com.qzone.qui.controls.Text —— Text.as 逐句对应（issue #9 qui 子集片）。
// 多行换行文本（TextTipFloating 等飘字用）。
class Text extends Label {
	// Text.as:9-18
	public function new(param1:Float = 100, param2:String = "Text") {
		super(param2);
		this._width = param1;
		this._height = 20;
		this.textDefaultFormat = Style.getTextFormat();
		this._textField.multiline = true;
		this._textField.wordWrap = true;
		this._textField.autoSize = TextFieldAutoSize.NONE;
	}

	// Text.as:20-24
	private override function init():Void {
		this._textField.defaultTextFormat = this.textDefaultFormat;
		super.init();
	}

	// Text.as:26-31
	private override function setSize():Void {
		this._textField.width = this._width;
		this._textField.height = Math.max(20, this._textField.textHeight + 5);
		this._height = this._textField.height;
	}
}
