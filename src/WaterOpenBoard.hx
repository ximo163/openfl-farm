package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// WaterOpenBoard —— water_ui_v_0.swf 的 SymbolClass 导出符号（char#46，
// DefineSprite，30 帧）。WaterGrayOpen.flag 经 Utils.getMaterial
// ("WaterOpenBoard") 反射构造：鱼塘未开通的开通引导板（#37）。
@:keep
class WaterOpenBoard extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "water_ui_v_0", "WaterOpenBoard");
	}
}
