package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// FS_01_2_2 —— fish_01.swf 的 SymbolClass 导出符号（char#41）：游动/待机动画，
// 档 2、向 2。命名约定 F{S,J}_<鱼型两位>_<档>_<向 0|2>（FishMover.
// formatFishName）；加载链与各库清单见 FishAnimationMgr 头注释。（#37）
@:keep
class FS_01_2_2 extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "fish_01", "FS_01_2_2");
	}
}
