package com.qzone.qui.skins;

import openfl.display.MovieClip;
import shim.SymbolClass;

// 标签页默认皮肤符号（farmui_full_v_40.swf，char#614）。
// 原工程无同名脚本类，AS3 侧 TabBar ctor 直接赋值。
@:keep
class TabSkin extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "com.qzone.qui.skins.TabSkin");
	}
}
