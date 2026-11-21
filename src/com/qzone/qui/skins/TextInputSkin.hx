package com.qzone.qui.skins;

import openfl.display.MovieClip;
import shim.SymbolClass;

// 文本输入框默认皮肤符号（farmui_full_v_40.swf，char#610）。
// 原工程无同名脚本类，AS3 侧 TextInputDefaultSkin.skin 表引用。
@:keep
class TextInputSkin extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "com.qzone.qui.skins.TextInputSkin");
	}
}
