package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// FishUnlock —— water_ui_v_0.swf 的 SymbolClass 导出符号（char#9）。
// 鱼苗瓦片「可解锁」角标：FishItem _lock=2 分支 getMaterial("FishUnlock")
// 反射构造；swf 无同名脚本类——纯符号绑定（ItemBorder 先例）。
@:keep
class FishUnlock extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "water_ui_v_0", "FishUnlock");
	}
}
