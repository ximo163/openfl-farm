package;

import openfl.display.BitmapData;
import shim.SymbolClass;

// RequestErrorFZ —— RequestError_2.swf 的 SymbolClass 导出位图（char#3，
// DefineBitsJPEG2，天然 270×125）。限流错误窗的配图（访问好友农场限流/
// 2012 黑暗，set_errorUrl 的 cgi_farm_index 路 m_imgName="RequestErrorFZ"）：
// RequestErrorWindow 经 requestClass 短路命中本 shim、onImageLoaded
// `new _loc1_(270,125)` 构造（VipL1 同款纯符号绑定，位图路径；库非预载，
// bindBitmap 按需拉起）。（#41）
@:keep
class RequestErrorFZ extends BitmapData {
	public function new(param1:Int, param2:Int) {
		super(param1, param2, true, 0);
		SymbolClass.bindBitmap(this, "RequestError_2", "RequestErrorFZ");
	}
}
