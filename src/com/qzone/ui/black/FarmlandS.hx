package com.qzone.ui.black;

import openfl.display.MovieClip;
import shim.SymbolClass;

// 黑土地快照帧（farmui2_v_58.swf SymbolClass 导出符号，char#89）。原 swf 无同名
// 脚本类；LandTile 经 Utils.getMaterial("com.qzone.ui.black.FarmlandS") 反射
// 构造，时间轴由 SymbolClass.bind 补挂（FarmLoading_Lite 先例）。
@:keep
class FarmlandS extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui2_v_58", "com.qzone.ui.black.FarmlandS");
	}
}
