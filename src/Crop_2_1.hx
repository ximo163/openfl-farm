package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// 作物 2 号（白萝卜）第 1 档生长素材（source/core/module/ui/allcrops/
// Crop_2_1.swf 的 SymbolClass 导出符号；nc_data.php:6021 cId=2 的
// asset_id.m1="5481" → :3065 该 swf）。原版由 Crop.setState 经
// RSLManager.requestClass("Crop_2_1",…) 按需网络加载后反射构造；移植版
// 类编译期即注册（requestClass 走 getClass 短路），素材库由
// SymbolClass.bind 按需拉起（库 id 同名，见该 shim 头注释）。
// uid=1 快照四块在种地全是 cId=2（initialized.sql:5718 status 的字母
// a=作物号，farmlandstatus_getoutput.php:62 "cId":$a 可证），本档只在
// plantTime 后 2~4 小时的生长窗口请求——CI 墙钟（≥2026-11-18）下不会
// 拉起，声明是为钉住白萝卜全生长档位（见 libraries.xml 分组注释）。
@:keep
class Crop_2_1 extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "Crop_2_1", "Crop_2_1");
	}
}
