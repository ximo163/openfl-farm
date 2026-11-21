package;

import openfl.display.BitmapData;
import shim.SymbolClass;

// VipL1 —— 黄钻等级 1 徽标位图（farmui_full_v_40.swf SymbolClass 导出，
// char#10）。FriendsView.initSkin 预热与 FriendItemRender set user 的
// `new vipDataClass(16,13)`（_vipLevelMaterial="VipL" + vipLevel 反射）
// 构造。底传 0 全透明、像素由 SymbolClass.bindBitmap 从库图 copyPixels
//（Weed 同款纯符号绑定，位图路径）。
@:keep
class VipL1 extends BitmapData {
	public function new(param1:Int, param2:Int) {
		super(param1, param2, true, 0);
		SymbolClass.bindBitmap(this, "farmui_full_v_40", "VipL1");
	}
}
