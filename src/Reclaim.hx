package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// 荒地开垦按钮符号，widgets.Wasteland 经 Utils.getMaterial("Reclaim") 反射构造（farmui_full_v_40.swf SymbolClass 导出符号，char#217）。原 swf 无同名
// 脚本类（FFDec 未导出——纯符号绑定）；时间轴由 SymbolClass.bind 补挂，
// 见该 shim 头注释（FarmLoading_Lite 先例）。
@:keep
class Reclaim extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "Reclaim");
	}
}
