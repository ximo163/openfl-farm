package;

import openfl.display.BitmapData;
import shim.SymbolClass;

// RequestErrorHP —— RequestError_2.swf 的 SymbolClass 导出位图（char#2，
// DefineBitsJPEG2，天然 270×125）。限流错误窗的配图（翻地限流/和平天使，
// set_errorUrl 的 scarify 路 m_imgName="RequestErrorHP"）：RequestErrorWindow
// 经 requestClass 短路命中本 shim、onImageLoaded `new _loc1_(270,125)` 构造
//（VipL1 同款纯符号绑定，位图路径；库非预载，bindBitmap 按需拉起）。（#41）
@:keep
class RequestErrorHP extends BitmapData {
	public function new(param1:Int, param2:Int) {
		super(param1, param2, true, 0);
		SymbolClass.bindBitmap(this, "RequestError_2", "RequestErrorHP");
	}
}
