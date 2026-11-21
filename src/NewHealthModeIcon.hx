package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// newHealthModeIcon —— farmui2_v_58.swf 的 SymbolClass 导出符号（char#170），
// 普通剪辑（非按钮符号）。原符号名小写开头（CanPickIcon 先例）：Haxe 类名必须
// 大写，@:native 把 js 运行时注册键改回原符号名，ToolBoxBar 经
// Utils.getMaterial("newHealthModeIcon") 的反射字符串一字不动；构造后照原样
// cast MovieClip 调 stop()。时间轴由 SymbolClass.bind 补挂。
@:keep
@:native("newHealthModeIcon")
class NewHealthModeIcon extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui2_v_58", "newHealthModeIcon");
	}
}
