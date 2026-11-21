package com.qzone.qui.skins;

import openfl.display.MovieClip;
import shim.SymbolClass;

// 单选钮选中皮肤符号（farmui_full_v_40.swf，char#639）。
// 原工程无同名脚本类，AS3 侧 RadioButtonDefaultSkin.selectedSkin 表引用。
@:keep
class RadioButtonSelectedSkin extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "com.qzone.qui.skins.RadioButtonSelectedSkin");
	}
}
