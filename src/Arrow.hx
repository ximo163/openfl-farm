package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// Arrow —— farmui2_v_58.swf 的 SymbolClass 导出符号（char#240，DefineSprite
// 20 帧的引导箭头动画；牧场 farmui2_v_44 同名符号是 Master2 侧宿主，本仓
// 绑农场宿主）。GameGuide ctor 经 Utils.getMaterial("Arrow") 反射构造
// （spec/modules/farm-basic.json GameGuide 条 assets），编译期零引用，
// 进 SymbolClass.dceAnchor。
@:keep
class Arrow extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui2_v_58", "Arrow");
	}
}
