package com.qzone.qui.controls;

import com.qzone.qui.controls.scrollClasses.ScrollBar;
import com.qzone.qui.core.Direction;
import com.qzone.qui.skins.VScrollBarDefaultSkin;
import com.qzone.qui.styles.Style;

// com.qzone.qui.controls.VScrollBar —— VScrollBar.as 逐句对应（issue #9
// qui 子集片）。纵向滚动条（ScrollBase.showVScroll 懒建）。
class VScrollBar extends ScrollBar {
	// VScrollBar.as:11-22
	public function new() {
		super();
		this._width = Style.vScrollBarWidth;
		this._height = 100;
		this._direction = Direction.VERTICAL;
		this.upArrowSkin = VScrollBarDefaultSkin.upArrowSkin;
		this.downArrowSkin = VScrollBarDefaultSkin.downArrowSkin;
		this.trackSkin = VScrollBarDefaultSkin.trackSkin;
		this.thumbSkin = VScrollBarDefaultSkin.thumbSkin;
		this.thumbIconSkin = VScrollBarDefaultSkin.thumbIconSkin;
	}
}
