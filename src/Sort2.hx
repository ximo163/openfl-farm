package;

import openfl.display.BitmapData;
import shim.SymbolClass;

// Sort2 —— 好友等级底图 2 档（farmui_full_v_40.swf SymbolClass 导出位图
// 符号，char#12）。FriendsView.initSkin 经 Utils.getCachedBitmapData
// ("Sort2",24,24) 反射构造（add 的 sort==2 档）。底传 0 全透明、像素由
// SymbolClass.bindBitmap 从库图 copyPixels（Sort0 同款）。
@:keep
class Sort2 extends BitmapData {
	public function new(param1:Int, param2:Int) {
		super(param1, param2, true, 0);
		SymbolClass.bindBitmap(this, "farmui_full_v_40", "Sort2");
	}
}
