package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// lite_ui_v_0.swf SymbolClass 导出符号（char#45），FarmLiteView 按原类名
// 直接 new。原 swf 无同名脚本类（FFDec 未导出——纯符号绑定）；时间轴由
// SymbolClass.bind 补挂，见该 shim 头注释。
@:keep
class Farmland_Lite extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "lite_ui_v_0", "Farmland_Lite");
	}
}
