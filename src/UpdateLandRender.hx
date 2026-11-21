package;

import openfl.display.MovieClip;

// Update.landRender —— 部署包缺符号的空壳（issue #18）。LandRender 的地块
// 行素材（LandRender.as:28），全 swf 无导出（见 UpdateLandPanel 注），
// 原版跑这份部署包同样 getMaterial 得 null、在 addChild 行抛 #1009；按
// #9 空壳先例保占位（无时间轴，landTxt/landIcon 具名子件查空，赋值行
// 与原版同点崩），行为差异是 deviations 候选（待人登记）。
@:keep
@:native("Update.landRender")
class UpdateLandRender extends MovieClip {
	public function new() {
		super();
	}
}
