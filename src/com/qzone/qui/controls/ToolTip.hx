package com.qzone.qui.controls;

import com.qzone.qui.managers.EffectManager;
import com.qzone.qui.skins.ToolTipSkin;
import com.qzone.qui.styles.Style;
import openfl.display.Sprite;
import openfl.geom.Point;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import shim.As3;

/**
 * com.qzone.qui.controls.ToolTip —— ToolTip.as 逐句对应（issue #18 qui 收尾：
 * 控件片）。工具提示本体（ToolTipLayer 挂载）。`param1 || ""` → As3.or。
 */
class ToolTip extends UIComponent {
	// ToolTip.as:11-18
	private var _skin:Sprite;

	private var paddingV:Int;

	private var _textField:TextField;

	public var effect:Dynamic;

	public var offset:Point;

	private var paddingH:Int;

	// :20-34
	public function new() {
		super();
		this.mouseEnabled = false;
		this.mouseChildren = false;
		this.paddingH = Style.toolTipPaddingH;
		this.paddingV = Style.toolTipPaddingV;
		this._textField = new TextField();
		this._textField.defaultTextFormat = Style.getToolTipFormat();
		this._textField.selectable = false;
		this._textField.autoSize = TextFieldAutoSize.LEFT;
		this._textField.multiline = true;
		this.offset = Style.toolTipOffset;
		this.effect = EffectManager.toolTipEffect;
	}

	// :36-40 + :98-102（AS3 get/set text 对；set 里 `param1 || ""` → As3.or）
	public var text(get, set):String;

	private function set_text(param1:String):String {
		this._textField.htmlText = As3.or(param1, "");
		this.setSize();
		return param1;
	}

	private function get_text():String {
		return this._textField.text;
	}

	// :42-46
	private override function init():Void {
		super.init();
		this.addChild(this._textField);
	}

	// :48-60
	private override function setSize():Void {
		this._textField.x = this.paddingH;
		this._textField.y = this.paddingV - 1;
		this._width = this._textField.width + this.paddingH * 2;
		this._height = this._textField.height + this.paddingV * 2;
		if (this._skin != null) {
			this._skin.width = this._width;
			this._skin.height = this._height;
		}
	}

	// :62-67
	private override function setSkin():Void {
		this._skin = new ToolTipSkin();
		this.addChildAt(this._skin, 0);
		this.filters = cast Style.getShadowFilter();
	}
}
