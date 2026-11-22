package com.qzone.qui.skins;

import openfl.display.MovieClip;
import shim.SymbolClass;

// 列表条目选中皮肤符号（farmui_full_v_40.swf，char#657）。原工程无同名脚本
// 类，AS3 侧 ListItemDefaultSkin.selectedSkin 表引用。
@:keep
class ListItemSelectedSkin extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "com.qzone.qui.skins.ListItemSelectedSkin");
	}
}
