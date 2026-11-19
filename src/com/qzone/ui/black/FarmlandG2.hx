package com.qzone.ui.black;

import openfl.display.MovieClip;
import shim.SymbolClass;

// 黑土地生长+水润帧（farmui2_v_58.swf SymbolClass 导出符号，char#102）。原 swf 无同名
// 脚本类；LandTile 经 Utils.getMaterial("com.qzone.ui.black.FarmlandG2") 反射
// 构造，时间轴由 SymbolClass.bind 补挂（FarmLoading_Lite 先例）。
@:keep
class FarmlandG2 extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui2_v_58", "com.qzone.ui.black.FarmlandG2");
	}
}
