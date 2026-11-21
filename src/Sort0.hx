package;

import openfl.display.BitmapData;
import shim.SymbolClass;

// Sort0 —— 好友等级底图（farmui_full_v_40.swf SymbolClass 导出位图符号，
// char#2；DefineBits 绑 flash.display.BitmapData 子类）。FriendsView.initSkin
// 经 Utils.getCachedBitmapData("Sort0",24,24) 反射构造（add 的默认档）。
// 原构造宽高被 Flash 无视、实例即图像自身像素，底传 0 全透明（不落 AS3
// BitmapData 默认的 0xFFFFFFFF 白）；像素由 SymbolClass.bindBitmap 从库图
// copyPixels（Weed 同款纯符号绑定，位图路径）。
@:keep
class Sort0 extends BitmapData {
	public function new(param1:Int, param2:Int) {
		super(param1, param2, true, 0);
		SymbolClass.bindBitmap(this, "farmui_full_v_40", "Sort0");
	}
}
