package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// CursorHoe —— farmui_full_v_40.swf 的 SymbolClass 导出符号（char#398），
// 锄头光标。FarmStage 的 m_cursorCtrl.register 直接引用本类（FarmStage.as
// :138-146 一一对应），#7 曾以空壳保引用，#9 光标片接入真实时间轴。
@:keep
class CursorHoe extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "CursorHoe");
	}
}
