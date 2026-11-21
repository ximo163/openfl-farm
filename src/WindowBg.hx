package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// 通用窗口底板皮肤符号（farmui_full_v_40.swf，char#552）。AS3 侧
// BaseWindow 构造里 `defaultSkin = WindowBg` 直接当类用（原工程无脚本类），
// @:keep + dceAnchor 锚住防裁剪（#9 getMaterial 图标同款机制）。
@:keep
class WindowBg extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "WindowBg");
	}
}
