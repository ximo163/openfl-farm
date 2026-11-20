package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// 公共枯死作物素材（source/core/module/ui/allcrops/Crop_1_4.swf 的
// SymbolClass 导出符号，符号名是 Crop_1_6 不是文件名的 Crop_1_4——库文件
// 按 getCropUrl 的 URL 折叠（6→4，无 m4 作物回退 publicCropPrefix+4）命名，
// 类名按 Crop.as:104/199 的公共分支带未折叠档位 6）。白萝卜 cId=2 无 m4
// （nc_data.php:6021），specialGrow=SG_PUBLIC_SEED_PUBLIC_DEAD
// （GetCropID.specialGrow），cropStatus≥7（updateLandItem 抬 step 到 6）时
// 由 Crop.setState 经 RSLManager.requestClass("Crop_1_6",…,Crop_1_4.swf)
// 请求。uid=1 快照无枯死作物（b 最大 6），CI 冒烟窗口不会拉起——声明钉住
// 该作物的全档位（见 libraries.xml 分组注释）。
@:keep
class Crop_1_6 extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "Crop_1_4", "Crop_1_6");
	}
}
