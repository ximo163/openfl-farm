package;

import openfl.display.MovieClip;

// NavigationLeftArrow —— 部署包缺符号的空壳（issue #9）。NavigationBar
// 平移箭头（NavigationBar.as:148 getMaterial("NavigationLeftArrow")）；全
// 部署包 swf 均不导出该符号（同 ButtonSuperMarket 头注），原版在这份部署
// 包上同样 null 后 NPE。空 MovieClip 保启动（#7 光标 stub 先例），箭头不
// 渲染是 deviations 候选（待人登记）。
@:keep
class NavigationLeftArrow extends MovieClip {
	public function new() {
		super();
	}
}
