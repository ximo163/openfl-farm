package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// CardsGameIcon —— farmui_full_v_40.swf 的 SymbolClass 导出符号（char#63）。原 swf 无同名脚本类
// （FFDec 未导出——纯符号绑定）；LeftSideToolBar 经 Utils.getMaterial("CardsGameIcon") 反射构造，
// 时间轴由 SymbolClass.bind 补挂（Weed 先例）。
@:keep
class CardsGameIcon extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "CardsGameIcon");
	}
}
