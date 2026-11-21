package com.minutes.ui.control;

import com.minutes.ui.core.LipiUIComponent;
import openfl.text.TextField;
import openfl.text.TextFieldType;

/**
 * com.minutes.ui.control.LipiTextArea —— LipiTextArea.as 的签名面 stub
 * （原类 155 loc，minutes UI 片真身待译——#pasture；issue #19 只保 profile
 * 窗族用到的通道，但 textField/htmlText/text/type 直通真实 TextField，
 * numLines/滚动条显隐依赖它们）。原类成员见
 * legacy/decompiled/Master2_v_142/scripts/com/minutes/ui/control/LipiTextArea.as。
 */
@:keep
class LipiTextArea extends LipiUIComponent {
	// LipiTextArea.as:20
	public var vLipiScrollBar:LipiScrollBar;

	private var _textField:TextField;

	public function new() {
		super();
		this._textField = new TextField();
		addChild(this._textField);
		this.vLipiScrollBar = new LipiScrollBar();
	}

	// LipiTextArea.as:50/96
	public var textField(get, set):TextField;

	private function get_textField():TextField {
		return this._textField;
	}

	private function set_textField(param1:TextField):TextField {
		this._textField = param1;
		return param1;
	}

	// LipiTextArea.as:55/62
	public var text(get, set):String;

	private function get_text():String {
		return this._textField.text;
	}

	private function set_text(param1:String):String {
		this._textField.text = param1;
		return param1;
	}

	// LipiTextArea.as:142/147
	public var htmlText(get, set):String;

	private function get_htmlText():String {
		return this._textField.htmlText;
	}

	private function set_htmlText(param1:String):String {
		this._textField.htmlText = param1;
		return param1;
	}

	// LipiTextArea.as:74/130（TextFieldType.DYNAMIC/INPUT 字串直通）
	public var type(get, set):String;

	private function get_type():String {
		return this._textField.type;
	}

	private function set_type(param1:String):String {
		this._textField.type = param1;
		return param1;
	}

	// LipiTextArea.as:67
	public function appendText(param1:String):Void {
		this._textField.appendText(param1);
	}
}
