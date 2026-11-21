package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// 道具边框符号（farmui_full_v_40.swf，char#464）。原版经
// Utils.getClass("ItemBorder") 反射构造（DogFoodWindow.init 的狗粮图边框，
// new _loc3_() as Sprite），swf 无同名脚本类——纯符号绑定，时间轴由
// SymbolClass.bind 补挂（WindowBg 先例）；@:keep + dceAnchor 锚住防裁剪。
@:keep
class ItemBorder extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "ItemBorder");
	}
}
