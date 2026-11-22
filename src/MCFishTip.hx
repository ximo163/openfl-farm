package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// MCFishTip —— water_ui_v_0.swf 的 SymbolClass 导出符号（char#75，
// DefineSprite）。FishInfoTip 经 Utils.getMaterial("MCFishTip") 反射构造：
// stepText/growText/growBar 三具名子件的宿主（#37）。
@:keep
class MCFishTip extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "water_ui_v_0", "MCFishTip");
	}
}
