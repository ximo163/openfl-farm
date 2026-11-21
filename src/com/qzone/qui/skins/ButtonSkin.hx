package com.qzone.qui.skins;

import openfl.display.MovieClip;
import shim.SymbolClass;

// 按钮默认皮肤符号（farmui_full_v_40.swf，char#672）。
// 原工程无同名脚本类，AS3 侧 ButtonDefaultSkin.skin 表引用。
@:keep
class ButtonSkin extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "com.qzone.qui.skins.ButtonSkin");
	}
}
