package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// 物料装载动画符号，MaterialProxy.showLoading 直接 `new ItemLoading()` 构造
// （farmui_full_v_40.swf SymbolClass 导出符号，char#467；导出名无包，AS3 裸
// 名引用落到应用域顶层）。原 swf 无同名脚本类（FFDec 未导出——纯符号绑定）；
// 时间轴由 SymbolClass.bind 补挂（Reclaim 先例）。
@:keep
class ItemLoading extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "ItemLoading");
	}
}
