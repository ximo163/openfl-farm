package;

import openfl.display.SimpleButton;
import shim.SymbolClass;

// ToolFishNet —— water_ui_v_0.swf 的 SymbolClass 导出符号（char#37），tag 是
// DefineButton2（按钮符号：AnimateButtonSymbol.__constructor 往实例写四态），
// 所以基类是 SimpleButton、走 bindButton（#9；MovieClip 基类在 js 上炸
// set_downState）。ToolBar TOOLS 表（水池开启时） 经 Utils.getMaterial("ToolFishNet")
// 反射构造。
@:keep
class ToolFishNet extends SimpleButton {
	public function new() {
		super();
		SymbolClass.bindButton(this, "water_ui_v_0", "ToolFishNet");
	}
}
