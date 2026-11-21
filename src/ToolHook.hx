package;

import openfl.display.SimpleButton;
import shim.SymbolClass;

// ToolHook —— farmui_full_v_40.swf 的 SymbolClass 导出符号（char#510），tag 是
// DefineButton2（按钮符号：AnimateButtonSymbol.__constructor 往实例写四态），
// 所以基类是 SimpleButton、走 bindButton（#9；MovieClip 基类在 js 上炸
// set_downState）。ToolBoxBar.addToolBtn 经 Utils.getMaterial("ToolHook") 反射构造。
@:keep
class ToolHook extends SimpleButton {
	public function new() {
		super();
		SymbolClass.bindButton(this, "farmui_full_v_40", "ToolHook");
	}
}
