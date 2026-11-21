package;

import openfl.display.MovieClip;

// ButtonMill1 —— 部署包缺符号的空壳（issue #9）。NavigationBar 的
// BUTTONS[4]（NavigationBar.as:80）引用，但 legacy/deploy 的全部 swf 都不
// 导出该符号（farmui_full_v_40 只有 ButtonMill/ShopSuperMarketIcon，无
// ButtonMill1/ButtonMill1/Navigation*Arrow，全包扫描 2026-11-21）：
// main3_v_221 的代码比部署包里的 farmui_full 新一个版本位。原版跑这份
// 部署包同样 getMaterial 得 null、在 btn.name 行（NavigationBar.as:113）
// 抛 #1009；为让移植版可启动（CI web-smoke 门禁），按 #7 光标 stub 先例
// 保空 MovieClip：按钮占位不渲染，行为差异是 deviations 候选（待人登记）。
@:keep
class ButtonMill1 extends MovieClip {
	public function new() {
		super();
	}
}
