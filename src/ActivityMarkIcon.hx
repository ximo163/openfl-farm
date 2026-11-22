package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// ActivityMarkIcon —— farmui_full_v_40.swf 的 SymbolClass 导出符号
//（char#539）。作物瓦片「活动」角标：CropItem `new ActivityMarkIcon()`
// 直接构造（编译期引用）；swf 无同名脚本类——纯符号绑定（ItemBorder
// 先例）。
@:keep
class ActivityMarkIcon extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "ActivityMarkIcon");
	}
}
