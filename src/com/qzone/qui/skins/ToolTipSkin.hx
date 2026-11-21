package com.qzone.qui.skins;

import openfl.display.MovieClip;
import shim.SymbolClass;

// 工具提示背景皮肤符号（farmui_full_v_40.swf SymbolClass 导出符号，char#608）。
// 原工程无同名脚本类，AS3 侧 ToolTip.setSkin 直接 new；时间轴由
// SymbolClass.bind 补挂（HScrollBarThumb 先例）。
@:keep
class ToolTipSkin extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "com.qzone.qui.skins.ToolTipSkin");
	}
}
