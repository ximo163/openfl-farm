package com.qzone.qui.controls;

import com.qzone.qui.controls.scrollClasses.ScrollBar;
import com.qzone.qui.core.Direction;
import com.qzone.qui.skins.HScrollBarDefaultSkin;
import com.qzone.qui.styles.Style;

// com.qzone.qui.controls.HScrollBar —— HScrollBar.as 逐句对应（issue #9
// qui 子集片）。横向滚动条（ScrollBase.showHScroll 懒建）。
class HScrollBar extends ScrollBar {
	// HScrollBar.as:11-22
	public function new() {
		super();
		this._height = Style.hScrollBarHeight;
		this._width = 100;
		this._direction = Direction.HORIZONTAL;
		this.upArrowSkin = HScrollBarDefaultSkin.upArrowSkin;
		this.downArrowSkin = HScrollBarDefaultSkin.downArrowSkin;
		this.trackSkin = HScrollBarDefaultSkin.trackSkin;
		this.thumbSkin = HScrollBarDefaultSkin.thumbSkin;
		this.thumbIconSkin = HScrollBarDefaultSkin.thumbIconSkin;
	}
}
