package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// 窗口标签条选中态符号（farmui_full_v_40.swf，char#546）。AS3 侧
// WindowTabBarMaker 经 Utils.getClass("TabSelected") 反射取类。
@:keep
class TabSelected extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "TabSelected");
	}
}
