package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// FishFoodEffect —— Fertilizer_v_7.swf 的 SymbolClass 导出符号（char#7，15 帧）：
// 喂鱼食落水特效。FishMover.playFeedEffect 经 Utils.getMaterial 反射构造
// （FishMover.as:362；原版里类定义随鱼食装备拉起的宿主库就位）。（#37）
@:keep
class FishFoodEffect extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "Fertilizer_v_7", "FishFoodEffect");
	}
}
