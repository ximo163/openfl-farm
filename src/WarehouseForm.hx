package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// WarehouseForm —— farmui_full_v_40.swf 的 SymbolClass 导出符号（char#594）。
// 卖出窗右侧表单板（cropName/price/sprice/income 文本与 lock_mc 锁）：
// SellPlantWindow/SellFishWindow/SellToolWindow 的 addedToLayer/init 里
// `new WarehouseForm()` 直名引用；swf 无同名脚本类——纯符号绑定
// （ShopSeedForm 先例，具名子件经 As3.childOf 访问）。
@:keep
class WarehouseForm extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "WarehouseForm");
	}
}
