package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// ButtonGreen —— farmui_full_v_40.swf 的 SymbolClass 导出符号（char#445）。
// 绿色按钮皮肤：PlantsPage/WarehouseSeedsPage/WarehouseFishPage 的
// 「卖出」按钮 defaultSkin = Utils.getClass("ButtonGreen") 反射取类；swf
// 无同名脚本类——纯符号绑定（ButtonOrange 先例）。
@:keep
class ButtonGreen extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "ButtonGreen");
	}
}
