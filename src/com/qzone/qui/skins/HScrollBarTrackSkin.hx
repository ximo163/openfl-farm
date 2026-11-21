package com.qzone.qui.skins;

import openfl.display.MovieClip;
import shim.SymbolClass;

// 横向滚动条轨道皮肤符号（farmui_full_v_40.swf SymbolClass 导出符号，char#632）。
// 原工程无同名脚本类，AS3 侧同包裸名引用（HScrollBarDefaultSkin 等）；
// 时间轴由 SymbolClass.bind 补挂（JPLandS 先例）。
@:keep
class HScrollBarTrackSkin extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "com.qzone.qui.skins.HScrollBarTrackSkin");
	}
}
