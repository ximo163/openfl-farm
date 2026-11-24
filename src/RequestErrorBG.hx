package;

import openfl.display.BitmapData;
import shim.SymbolClass;

// RequestErrorBG —— RequestError_2.swf 的 SymbolClass 导出位图（char#4，
// DefineBitsJPEG3，天然 270×124——四张里唯一 124 高的一张）。限流/封禁错误
// 窗的配图（收获/耕种限流共用）：RequestErrorWindow.set_errorUrl 经
// requestClass（secondList nc_data.php:35 id="RequestErrorBG"）短路命中本
// shim，onImageLoaded `new _loc1_(270,125)` 构造（VipL1 同款纯符号绑定，
// 位图路径；库非预载，bindBitmap 按需拉起）。（#41）
@:keep
class RequestErrorBG extends BitmapData {
	public function new(param1:Int, param2:Int) {
		super(param1, param2, true, 0);
		SymbolClass.bindBitmap(this, "RequestError_2", "RequestErrorBG");
	}
}
