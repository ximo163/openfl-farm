package com.qzone.qui.containers;

import com.qzone.qui.containers.boxClasses.Box;
import com.qzone.qui.skins.PanelDefaultSkin;
import com.qzone.qui.styles.Style;

// com.qzone.qui.containers.ControlBar —— ControlBar.as 逐句对应（issue #18
// qui 收尾：容器片）。面板底部控制条（定高、无内边距、控制条皮肤）。
class ControlBar extends Box {
	// ControlBar.as:12-19
	public function new() {
		super();
		this._height = Style.panelControlBarHeight;
		this.paddingV = 0;
		this.gapV = 0;
		this.defaultSkin = PanelDefaultSkin.controlBarSkin;
		this.backgroundAlpha = 0;
	}
}
