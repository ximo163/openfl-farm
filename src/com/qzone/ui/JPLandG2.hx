package com.qzone.ui;

import openfl.display.MovieClip;
import shim.SymbolClass;

// 金牌地皮生长+水润帧（farmui_full_v_40.swf SymbolClass 导出符号，char#30）。原 swf 无同名
// 脚本类；LandTile 经 Utils.getMaterial("com.qzone.ui.JPLandG2") 反射
// 构造，时间轴由 SymbolClass.bind 补挂（FarmLoading_Lite 先例）。
@:keep
class JPLandG2 extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "com.qzone.ui.JPLandG2");
	}
}
