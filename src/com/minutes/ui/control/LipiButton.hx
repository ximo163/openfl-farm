package com.minutes.ui.control;

import com.minutes.ui.core.LipiUIComponent;
import openfl.text.TextField;

/**
 * com.minutes.ui.control.LipiButton —— LipiButton.as 的签名面 stub（原类
 * 293 loc，minutes UI 片真身待译——#pasture；issue #19 只保留言/提示按钮
 * 用到的 label/textColor/enable 与继承面）。
 * legacy/decompiled/Master2_v_142/scripts/com/minutes/ui/control/LipiButton.as。
 */
@:keep
class LipiButton extends LipiUIComponent {
	private var _label:String = "";
	private var _textColor:UInt = 0;
	private var _enable:Bool = true;

	public function new() {
		super();
	}

	// LipiButton.as:222/261
	public var label(get, set):String;

	private function get_label():String {
		return this._label;
	}

	private function set_label(param1:String):String {
		this._label = param1;
		return param1;
	}

	// LipiButton.as:133/234
	public var textColor(get, set):UInt;

	private function get_textColor():UInt {
		return this._textColor;
	}

	private function set_textColor(param1:UInt):UInt {
		this._textColor = param1;
		return param1;
	}

	// LipiButton.as:49/54
	public var enable(get, set):Bool;

	private function get_enable():Bool {
		return this._enable;
	}

	private function set_enable(param1:Bool):Bool {
		this._enable = param1;
		return param1;
	}

	// 未用成员占位（真身补）：iconLeft/textSize/textFont/textBold/labelFilters
	private var _iconLeft:Int = 0;
	private var _textSize:Int = 12;
	private var _textFont:String = "Verdana";
	private var _textBold:Bool = false;
	private var _labelFilters:Array<Dynamic>;
	private var _iconTextField:TextField;
}
