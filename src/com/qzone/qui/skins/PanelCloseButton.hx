package com.qzone.qui.skins;

import openfl.display.MovieClip;
import shim.SymbolClass;

// 面板右上角关闭按钮符号（farmui_full_v_40.swf，char#649，DefineSprite）。
// 原工程无同名脚本类，AS3 侧 PanelDefaultSkin.closeButtonSkin 表引用。
@:keep
class PanelCloseButton extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "com.qzone.qui.skins.PanelCloseButton");
	}
}
