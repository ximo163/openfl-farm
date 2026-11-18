package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// lite_ui_v_0.swf SymbolClass 导出符号（char#23），FarmLiteView 按原类名
// 直接 new。原 swf 无同名脚本类（FFDec 未导出——纯符号绑定）；时间轴由
// SymbolClass.bind 补挂，见该 shim 头注释。
// PORT-NOTE(haxe-typename)：原符号/类名 canPickIcon_Lite（小写 c 开头），
// Haxe 语法要求类型名大写开头（类型位置与 new 均无法引用小写类型），故
// Haxe 类名取 CanPickIcon_Lite；符号查找用下面的字符串，保持原名不变。
@:keep
class CanPickIcon_Lite extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "lite_ui_v_0", "canPickIcon_Lite");
	}
}
