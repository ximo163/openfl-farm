package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// 窗口标签条背景皮肤符号（farmui_full_v_40.swf，char#550）。AS3 侧
// WindowTabBarMaker 经 Utils.getClass("TabBg") 反射取类（原工程无脚本类），
// @:keep + dceAnchor 锚住防裁剪（#9 getMaterial 图标同款机制）。
@:keep
class TabBg extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "TabBg");
	}
}
