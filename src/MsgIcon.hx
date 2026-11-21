package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// MsgIcon —— farmui_full_v_40.swf 的 SymbolClass 导出符号（char#49）。原 swf 无同名脚本类
// （FFDec 未导出——纯符号绑定）；PersonInfo 经 Utils.getMaterial("MsgIcon") 反射构造，
// 时间轴由 SymbolClass.bind 补挂（Weed 先例）。
@:keep
class MsgIcon extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "MsgIcon");
	}
}
