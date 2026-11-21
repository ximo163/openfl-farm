package;

import openfl.display.MovieClip;

// Update.nextLandPanel —— 部署包缺符号的空壳（issue #18）。LevelUpWindow 的
// ONLY_LAND_NEXT 分支引用（LevelUpWindow.as:384），全 swf 无导出（见
// UpdateLandPanel 注），原版跑这份部署包同样 null 后抛；按 #9 空壳先例
// 保占位，行为差异是 deviations 候选（待人登记）。
@:keep
@:native("Update.nextLandPanel")
class UpdateNextLandPanel extends MovieClip {
	public function new() {
		super();
	}
}
