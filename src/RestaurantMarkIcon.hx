package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// RestaurantMarkIcon —— farmui_full_v_40.swf 的 SymbolClass 导出符号
//（char#555）。作物瓦片「餐厅」角标：CropItem `new RestaurantMarkIcon()`
// 直接构造（编译期引用）；swf 无同名脚本类——纯符号绑定（ItemBorder
// 先例）。
@:keep
class RestaurantMarkIcon extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "RestaurantMarkIcon");
	}
}
