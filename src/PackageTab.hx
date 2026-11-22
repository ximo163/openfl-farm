package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// PackageTab —— farmui_full_v_40.swf 的 SymbolClass 导出符号（char#439）。
// 背包页签三帧开关（1 普通/3 鱼苗/2 道具，帧内按钮派发 seed/tool/fish）：
// MyBagView.createButtons 里 Utils.getMaterial("PackageTab") 反射构造；
// swf 无同名脚本类——纯符号绑定（PackBarBg 先例）。
@:keep
class PackageTab extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "PackageTab");
	}
}
