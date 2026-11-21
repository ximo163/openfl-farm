package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// CursorFishNet —— water_ui_v_0.swf 的 SymbolClass 导出符号（char#42），
// 渔网光标。FarmStage 经 Utils.getClass("CursorFishNet") 反射取类注册（FarmStage.as
// :152-153），#7 曾以空壳保引用，#9 光标片接入真实时间轴。
@:keep
class CursorFishNet extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "water_ui_v_0", "CursorFishNet");
	}
}
