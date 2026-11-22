package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// FishUnlockBg —— water_ui_v_0.swf 的 SymbolClass 导出符号（char#27）。
// 解锁鱼苗窗的说明底板：UnlockFishWindow addedToLayer 经
// getMaterial("FishUnlockBg") 反射构造；swf 无同名脚本类——纯符号绑定
// （ItemBorder 先例）。
@:keep
class FishUnlockBg extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "water_ui_v_0", "FishUnlockBg");
	}
}
