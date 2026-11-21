package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// 通用窗口关闭按钮皮肤符号（farmui_full_v_40.swf，char#544）。AS3 侧
// BaseWindow 构造里 `closeButtonSkin = CloseButton` 直接当类用（原工程
// 无脚本类），@:keep + dceAnchor 锚住防裁剪（#9 getMaterial 图标同款机制）。
@:keep
class CloseButton extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "CloseButton");
	}
}
