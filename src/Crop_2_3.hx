package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// 作物 2 号（白萝卜）第 3 档生长素材（source/core/module/ui/allcrops/
// Crop_2_3.swf 的 SymbolClass 导出符号；nc_data.php:6021 cId=2 的
// asset_id.m3="5483" → :3067 该 swf）。原版由 Crop.setState 经
// RSLManager.requestClass("Crop_2_3",…) 按需网络加载后反射构造；移植版
// 类编译期即注册（requestClass 走 getClass 短路），素材库由
// SymbolClass.bind 按需拉起（库 id 同名，见该 shim 头注释）。
// uid=1 快照四块在种地全是 cId=2（initialized.sql:5718 status 的字母
// a=作物号，farmlandstatus_getoutput.php:62 "cId":$a 可证）；cropGrow
// （nc_data.php:6021 "7200,14400,25200,36000,36000,…"）按 plantTime
// （2026-11-17）推进，CI 墙钟下四块地全在第 5 档——3/4/5 档在
// Crop.setState/Crop.onCropLoaded 折叠到本类（_classStep=3，Crop.as:93-99），
// 档内分段靠 step1/2/3 子件显隐。这是 web-smoke 唯一会实际拉起的作物库
// （attempt 1 的单条 404 即缺它）。
@:keep
class Crop_2_3 extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "Crop_2_3", "Crop_2_3");
	}
}
