package com.qzone.qui.controls;

import com.qzone.qui.skins.CheckBoxDefaultSkin;
import com.qzone.qui.styles.Style;
import com.qzone.utils.AlignUtil;

// com.qzone.qui.controls.CheckBox —— CheckBox.as（Master2 变体）逐句对应
// （issue #86 牧场库底座，qui CheckBox 片）。复选钮：toggle Button +
// 皮肤/文本左对齐。Master2 独有（main3 无 CheckBox 类），与已译的
// RadioButton（main3 变体）结构同族。
@:keep
class CheckBox extends Button {
	// CheckBox.as:10-20
	public function new(param1:String = "CheckBox", param2:Dynamic = null) {
		super(param1, param2);
		this.defaultSkin = CheckBoxDefaultSkin.skin;
		this.selectedSkin = CheckBoxDefaultSkin.selectedSkin;
		this.paddingH = Style.checkBoxPaddingH;
		this.textDefaultFormat = Style.getLabelFormat();
		this.textSelectedFormat = this.textDefaultFormat;
		this.textOverFormat = this.textDefaultFormat;
		this._toggle = true;
	}

	// CheckBox.as:22-27
	private override function setSelectedSkin():Void {
		super.setSelectedSkin();
		this._skin.x = this.paddingH;
		this._skin.y = AlignUtil.middle(this._height, this._skin.height);
	}

	// CheckBox.as:29-42
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

	// CheckBox.as:44-49
	private override function setDefaultSkin():Void {
		super.setDefaultSkin();
		this._skin.x = this.paddingH;
		this._skin.y = AlignUtil.middle(this._height, this._skin.height);
	}
}
