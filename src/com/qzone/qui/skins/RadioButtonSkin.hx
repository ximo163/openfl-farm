package com.qzone.qui.skins;

import openfl.display.MovieClip;
import shim.SymbolClass;

// 单选钮默认皮肤符号（farmui_full_v_40.swf，char#637）。
// 原工程无同名脚本类，AS3 侧 RadioButtonDefaultSkin.skin 表引用。
@:keep
class RadioButtonSkin extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "com.qzone.qui.skins.RadioButtonSkin");
	}
}
