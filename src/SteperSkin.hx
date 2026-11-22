package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// SteperSkin —— farmui_full_v_40.swf 的 SymbolClass 导出符号（char#457，
// 原版拼写就少一个 p）。数量步进器皮肤（next_btn/prev_btn/num_txt 三件）：
// BuyItemWindow `new SteperSkin()` 直接构造、BuyFishWindow/BuyAdSeedWindow/
// BuySeedWindow 经 getMaterial("SteperSkin") 反射给 StepperMaker.setSkin；
// swf 无同名脚本类——纯符号绑定（ItemBorder 先例）。
@:keep
class SteperSkin extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "SteperSkin");
	}
}
