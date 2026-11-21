package;

import openfl.display.BitmapData;
import shim.SymbolClass;

// VipL5 —— 黄钻等级 5 徽标位图（farmui_full_v_40.swf SymbolClass 导出，
// char#6）。同 VipL1（_vipLevelMaterial + vipLevel 反射 new(16,13)）。
@:keep
class VipL5 extends BitmapData {
	public function new(param1:Int, param2:Int) {
		super(param1, param2, true, 0);
		SymbolClass.bindBitmap(this, "farmui_full_v_40", "VipL5");
	}
}
