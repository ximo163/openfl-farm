package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// NPC 对话气泡旗，NPCView 直接 new（farmui_full_v_40.swf SymbolClass 导出符号，char#232）。原 swf 里有同名
// ABC 类：frame1 脚本做 infoTxt.text = talkInfo、frame24 stop（FFDec 未把它导出到 scripts/——纯符号绑定的
// 壳）；帧脚本在本地化库处理时被丢弃（见 LandTalkTip/NPCView 的 PORT-NOTE），时间轴由 SymbolClass.bind
// 补挂（FarmLoading_Lite 先例）。
@:keep
class MaoPaoFlag extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "MaoPaoFlag");
	}
}
