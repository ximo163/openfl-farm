package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// HarvestFishFlag —— water_ui_v_0.swf 的 SymbolClass 导出符号（char#49，
// DefineSprite）。WaterPool.createPool 经 Utils.getMaterial
// ("HarvestFishFlag") 反射构造：成熟可收标志，`fish` 动态属性（ClipProps
// 侧表）记当前跟的 FishMover（#37）。
@:keep
class HarvestFishFlag extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "water_ui_v_0", "HarvestFishFlag");
	}
}
