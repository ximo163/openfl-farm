package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// monthEndArrow —— farmui2_v_58.swf 的 SymbolClass 导出符号（char#212）。
// 原符号名小写开头（CanPickIcon 先例）：Haxe 类名必须大写，@:native 把
// js 运行时注册键改回原符号名，getMaterial("monthEndArrow") 的反射字符串
// 一字不动。ShortcutBar/NavigationBar 经 Utils.getMaterial 反射构造，时间轴
// 由 SymbolClass.bind 补挂。
@:keep
@:native("monthEndArrow")
class MonthEndArrow extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui2_v_58", "monthEndArrow");
	}
}
