package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// PoolMap —— water_ui_v_0.swf 的 SymbolClass 导出符号（char#67，DefineSprite）。
// PoolMap.createPoolMap 经 Utils.getMaterial("PoolMap") 反射构造：holder 挂鱼
// 层、limit 池边界（a1-a4 锚点）、c* 出生圈的宿主（#37）。
@:keep
class PoolMap extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "water_ui_v_0", "PoolMap");
	}
}
