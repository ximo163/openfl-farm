package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// 窗口标签条默认态符号（farmui_full_v_40.swf，char#548）。AS3 侧
// WindowTabBarMaker 经 Utils.getClass("TabDefault") 反射取类。
@:keep
class TabDefault extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "TabDefault");
	}
}
