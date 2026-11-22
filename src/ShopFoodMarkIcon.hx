package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// ShopFoodMarkIcon —— farmui_full_v_40.swf 的 SymbolClass 导出符号
//（char#531）。作物瓦片「食材」角标：CropItem `new ShopFoodMarkIcon()`
// 直接构造（编译期引用）；swf 无同名脚本类——纯符号绑定（ItemBorder
// 先例）。直接 new 之外仍入 dceAnchor：反射入口（getMaterial）同用。
@:keep
class ShopFoodMarkIcon extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "ShopFoodMarkIcon");
	}
}
