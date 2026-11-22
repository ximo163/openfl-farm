package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// PoolInfoContent —— water_ui_v_0.swf 的 SymbolClass 导出符号（char#95，
// DefineSprite）。PoolInfoWindow.createWindowContent 经 Utils.getMaterial
// ("PoolInfoContent") 反射构造：item0-5 行（tfName/tfNum/tfSize）+ 总容量
// tfSize，1-4 帧四档行数（#37）。
@:keep
class PoolInfoContent extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "water_ui_v_0", "PoolInfoContent");
	}
}
