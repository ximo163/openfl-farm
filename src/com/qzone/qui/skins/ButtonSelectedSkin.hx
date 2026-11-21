package com.qzone.qui.skins;

import openfl.display.MovieClip;
import shim.SymbolClass;

// 按钮选中皮肤符号（farmui_full_v_40.swf，char#674）。
// 原工程无同名脚本类，AS3 侧 ButtonDefaultSkin.selectedSkin 表引用。
@:keep
class ButtonSelectedSkin extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "com.qzone.qui.skins.ButtonSelectedSkin");
	}
}
