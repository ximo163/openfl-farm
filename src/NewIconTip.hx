package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// newIconTip —— farmui2_v_58.swf 的 SymbolClass 导出符号（char#193）。
// 原符号名小写开头（CanPickIcon 先例）：Haxe 类名必须大写，@:native 把
// js 运行时注册键改回原符号名，UIController 经 Utils.getMaterial
// ("newIconTip") 的反射字符串一字不动。时间轴由 SymbolClass.bind 补挂。
@:keep
@:native("newIconTip")
class NewIconTip extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui2_v_58", "newIconTip");
	}
}
