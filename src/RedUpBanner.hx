package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// RedUpBanner —— redUpBanner_v_2.swf 的 SymbolClass 导出符号（char#18，
// 3 帧 DefineSprite）：红/黑/金牌土地升级窗顶横幅，帧 1 红/帧 2 黑/帧 3 金牌，
// 具名子件 chanceTime/buyTime/allIsGoldLand（金牌页签的次数/购买按钮/状态
// 文本）。RedUpWindow.init 经 requestClass("redUpBanner")（secondList
// nc_data.php:36 → module/ui/main/redUpBanner_v_2.swf）、onRedBannerLoaded
// 经 Utils.getMaterial 反射构造。符号名小写开头（Task7 先例）：@:native 把
// 运行时注册键改回原名，反射字符串一字不动。库非预载：bind 按需拉起，
// gotoAndStop 的帧落点经 SymbolClass.afterAttach 登记（RedUpWindow.hx 头注）。
// （#41）
@:keep
@:native("redUpBanner")
class RedUpBanner extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "redUpBanner_v_2", "redUpBanner");
	}
}
