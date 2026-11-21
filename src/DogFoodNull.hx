package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// 狗粮盆（空盆）符号（farmui_full_v_40.swf，char#402）。原版经
// Utils.getMaterial("DogFoodNull") 反射构造（DogBowl 空盆/DogFoodWindow
// 空盆图），swf 无同名脚本类——纯符号绑定，时间轴由 SymbolClass.bind 补挂
// （WindowBg 先例）；@:keep + dceAnchor 锚住防裁剪。
@:keep
class DogFoodNull extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "DogFoodNull");
	}
}
