package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// FlowerCardUI —— farmui_full_v_40.swf 的 SymbolClass 导出符号（char#606）。
// 鲜花卡片窗的文本版式（txtDesc/txtMasterName/txtWord/txtFriendName 四个
// 具名 TextField）：FlowerCard.addedToLayer 里 Utils.getMaterial
// ("FlowerCardUI") 反射构造；swf 无同名脚本类——纯符号绑定（ShopSeedForm
// 先例，具名子件经 getChildByName 访问）。
@:keep
class FlowerCardUI extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "FlowerCardUI");
	}
}
