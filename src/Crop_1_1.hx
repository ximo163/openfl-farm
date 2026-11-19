package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// 作物 1 号第 1 档生长素材（source/core/module/ui/allcrops/
// Crop_1_1.swf 的 SymbolClass 导出符号）。原版由 Crop.setState 经
// RSLManager.requestClass("Crop_1_1",…) 按需网络加载后反射构造；
// 移植版类编译期即注册（requestClass 走 getClass 短路），素材库由
// SymbolClass.bind 按需拉起（库 id 同名，见 shim 头注释）。
@:keep
class Crop_1_1 extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "Crop_1_1", "Crop_1_1");
	}
}
