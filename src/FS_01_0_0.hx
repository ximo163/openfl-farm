package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// FS_01_0_0 —— fish_01.swf 的 SymbolClass 导出符号（char#49）：游动/待机动画，
// 档 0、向 0。命名约定 F{S,J}_<鱼型两位>_<档>_<向 0|2>（FishMover.
// formatFishName）；加载链与各库清单见 FishAnimationMgr 头注释。（#37）
@:keep
class FS_01_0_0 extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "fish_01", "FS_01_0_0");
	}
}
