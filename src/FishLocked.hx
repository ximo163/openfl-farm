package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// FishLocked —— water_ui_v_0.swf 的 SymbolClass 导出符号（char#5）。
// 鱼苗瓦片「锁定」角标：FishItem _lock=0 分支 getMaterial("FishLocked")
// 反射构造；swf 无同名脚本类——纯符号绑定（ItemBorder 先例）。
@:keep
class FishLocked extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "water_ui_v_0", "FishLocked");
	}
}
