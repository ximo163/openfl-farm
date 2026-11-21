package com.qzone.qui.controls;

import com.qzone.qui.skins.RadioButtonDefaultSkin;
import com.qzone.qui.styles.Style;
import com.qzone.utils.AlignUtil;
import openfl.events.Event;
import openfl.events.MouseEvent;

/**
 * com.qzone.qui.controls.RadioButton —— RadioButton.as 逐句对应（issue #18
 * qui 收尾：控件片）。单选钮：toggle Button + 皮肤/文本左对齐（RadioGroup
 * 成组管理选中互斥）。
 */
class RadioButton extends Button {
	// RadioButton.as:15-25
	public function new(param1:String = "RadioButton", param2:Dynamic = null) {
		super(param1, param2);
		this.defaultSkin = RadioButtonDefaultSkin.skin;
		this.selectedSkin = RadioButtonDefaultSkin.selectedSkin;
		this.paddingH = Style.radioButtonPaddingH;
		this.textDefaultFormat = Style.getLabelFormat();
		this.textSelectedFormat = this.textDefaultFormat;
		this.textOverFormat = this.textDefaultFormat;
		this._toggle = true;
	}

	// :27-37（未选中才翻转并广播 CHANGE——已选中不响应重复点击）
	private override function onClick(param1:MouseEvent):Void {
		if (this._toggle) {
			if (this._selected == false) {
				this.selected = !this._selected;
				this.dispatchEvent(new Event(Event.CHANGE));
			}
		}
	}

	// :39-52
	private override function setSize():Void {
		if (this._skin != null) {
			if (this._resized == false) {
				this._width = this._textField.textWidth + 3 + this.paddingH * 2 + this._skin.width;
			}
			this._textField.width = this._width - this.paddingH * 2 - this._skin.width;
			this._textField.height = Math.max(20, this._textField.textHeight);
			this._textField.x = this._skin.width + this.paddingH * 2;
			this._textField.y = Math.round(this._height - this._textField.height) / 2;
		}
	}

	// :54-60
	private override function setDefaultSkin():Void {
		super.setDefaultSkin();
		this._skin.x = this.paddingH;
		this._skin.y = AlignUtil.middle(this._height, this._skin.height);
	}

	// :62-68
	private override function setSelectedSkin():Void {
		super.setSelectedSkin();
		this._skin.x = this.paddingH;
		this._skin.y = AlignUtil.middle(this._height, this._skin.height);
	}
}
