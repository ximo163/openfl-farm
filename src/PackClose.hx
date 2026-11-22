package;

import openfl.display.SimpleButton;
import shim.SymbolClass;

// PackClose —— farmui2_v_58.swf 的 SymbolClass 导出符号（char#179）。
// 背包条右上关闭钮：MyBagView.createButtons 里 Utils.getMaterial("PackClose")
// 反射构造；swf 无同名脚本类——纯符号绑定（ButtonOrange 先例）。DefineButton2
// 按钮符号走 bindButton（AnimateButtonSymbol 四态写进 SimpleButton）。
@:keep
class PackClose extends SimpleButton {
	public function new() {
		super();
		SymbolClass.bindButton(this, "farmui2_v_58", "PackClose");
	}
}
