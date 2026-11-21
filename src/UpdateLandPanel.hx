package;

import openfl.display.MovieClip;

// Update.landPanel —— 部署包缺符号的空壳（issue #18）。LevelUpWindow 的
// ONLY_LAND 分支引用（LevelUpWindow.as:380），但 legacy/deploy 的全部 swf 都
// 不导出 Update.landPanel（levelUpUI_v_1 只导出 bigPanel/seedsPanel/
// emptyPanel/seedsRender/denShed 两枚，全包扫描 2026-11-21）：main3_v_221 的
// 代码比部署包里的素材库新。原版跑这份部署包同样 getMaterial 得 null、在
// createPanel 尾部 addChild 行抛 #1009；按 #9 ButtonSuperMarket 先例保空
// MovieClip 让面板占位可构造，行为差异是 deviations 候选（待人登记）。
// @:native 注册键照常给足，Type.resolveClass 可得。
@:keep
@:native("Update.landPanel")
class UpdateLandPanel extends MovieClip {
	public function new() {
		super();
	}
}
