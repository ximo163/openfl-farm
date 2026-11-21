package;

import openfl.display.SimpleButton;
import shim.SymbolClass;

// PoolInfoBtn —— water_ui_v_0.swf 的 SymbolClass 导出符号（char#80），tag 是
// DefineButton2（按钮符号：AnimateButtonSymbol.__constructor 往实例写四态），
// 所以基类是 SimpleButton、走 bindButton（#9；MovieClip 基类在 js 上炸
// set_downState）。UIController.onRefreshPoolInfo 经
// Utils.getMaterial("PoolInfoBtn") 反射构造（原样 cast SimpleButton）。
@:keep
class PoolInfoBtn extends SimpleButton {
	public function new() {
		super();
		SymbolClass.bindButton(this, "water_ui_v_0", "PoolInfoBtn");
	}
}
