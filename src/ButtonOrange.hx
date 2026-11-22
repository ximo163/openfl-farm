package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// ButtonOrange —— farmui_full_v_40.swf 的 SymbolClass 导出符号（char#580）。
// 橙色按钮皮肤：AdvertisementItem（defaultSkin = Utils.getClass("ButtonOrange")）
// 与各买入窗口 confirmButton（getMaterial("ButtonOrange")）反射构造；swf 无
// 同名脚本类——纯符号绑定（ButtonRestaurant 先例）。
@:keep
class ButtonOrange extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "ButtonOrange");
	}
}
