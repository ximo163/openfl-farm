package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// NPC 对话气泡旗，NPCView 直接 new（farmui_full_v_40.swf SymbolClass 导出符号，char#232）。原 swf 无同名
// 脚本类（FFDec 未导出——纯符号绑定）；时间轴由 SymbolClass.bind 补挂，
// 见该 shim 头注释（FarmLoading_Lite 先例）。
@:keep
class MaoPaoFlag extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "MaoPaoFlag");
	}
}
