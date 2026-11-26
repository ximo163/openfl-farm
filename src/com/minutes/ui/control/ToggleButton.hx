package com.minutes.ui.control;

import com.minutes.ui.core.LipiSkin;

/**
 * com.minutes.ui.control.ToggleButton —— ToggleButton.as 逐句对应
 * （issue #86 牧场库底座，LipiUI 组件库片）。
 * legacy/decompiled/Master2_v_142/scripts/com/minutes/ui/control/ToggleButton.as。
 */
@:keep
class ToggleButton extends LipiButton {
	// ToggleButton.as:8-12
	private var _selectedSkin:LipiSkin;
	private var _selected:Bool = false;
	private var _defaultSkin:LipiSkin;

	// :14-17
	public function new() {
		super();
	}

	// :19-22
	public var defaultSkin(get, set):LipiSkin;

	private function get_defaultSkin():LipiSkin {
		return this._defaultSkin;
	}

	// :24-35
	public var selectedSkin(get, set):LipiSkin;

	private function set_selectedSkin(param1:LipiSkin):LipiSkin {
		this._selectedSkin = param1;
		if (this.selected) {
			bgSkin = this.selectedSkin;
		} else {
			bgSkin = this.defaultSkin;
		}
		return param1;
	}

	// :37-48
	public var selected(get, set):Bool;

	private function set_selected(param1:Bool):Bool {
		this._selected = param1;
		if (param1) {
			bgSkin = this.selectedSkin;
		} else {
			bgSkin = this.defaultSkin;
		}
		return param1;
	}

	// :50-53
	private function get_selectedSkin():LipiSkin {
		return this._selectedSkin;
	}

	// :55-58
	private function get_selected():Bool {
		return this._selected;
	}

	// :60-71
	private function set_defaultSkin(param1:LipiSkin):LipiSkin {
		this._defaultSkin = param1;
		if (this.selected) {
			bgSkin = this.selectedSkin;
		} else {
			bgSkin = this.defaultSkin;
		}
		return param1;
	}
}
