package common.view.window;

import common.view.window.UpgradeBlackWindow;
import utest.Assert;

/**
 * UpgradeBlackWindow 纯逻辑（issue #41）：formatNumber 的万/亿位逗号分组。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/common/view/window/
 * UpgradeBlackWindow.as:68-86（0 → ""；长度 >8 先在 [len-8] 处插逗号，
 * >4 再按**当前串长**在 [len-4] 处插——第二刀的基准含第一刀插进的逗号，
 * 9 位数因此得 "1,2345,6789" 而非对称分组，照原文不修）。消费方 :110
 * `tfNum.text = formatNumber(data["rank"])`（黑土地升级分享窗的名次数字）。
 *
 * ctor 在 eval 上不可构造（:23 Utils.getMaterial("BlackUpgradeShare")
 * 无素材返回 null、:24 gotoAndStop 即 NPE），用 Type.createEmptyInstance
 * 驱动纯函数（ToolBarTest 先例）；onShare 的分享 URL 拼装走 QzoneJSAPI
 * 域外联（无宿主环境早退、串不可观测），不进单测。
 */
@:access(common.view.window.UpgradeBlackWindow)
class UpgradeBlackWindowTest {
	public function new() {}

	public function test_formatNumber_groups_at_4_and_8_digits() {
		var win = Type.createEmptyInstance(UpgradeBlackWindow);
		// 表：输入 uint → 期望串（按 :68-86 逐步推）
		var cases:Array<{n:UInt, expected:String, why:String}> = [
			// :70-72：0 恒空串
			{n: 0, expected: "", why: "0 → 空"},
			// ≤4 位不分组
			{n: 1, expected: "1", why: "个位"},
			{n: 999, expected: "999", why: "3 位无逗号"},
			{n: 1000, expected: "1000", why: "恰 4 位不分组"},
			// 5-8 位：只在 [len-4] 一刀（万位分组）
			{n: 10000, expected: "1,0000", why: "5 位万位一刀"},
			{n: 12345678, expected: "1234,5678", why: "8 位万位一刀"},
			// >8 位：先 [len-8] 一刀，再按含逗号的当前串长 [len-4] 一刀
			{n: 123456789, expected: "1,2345,6789", why: "9 位两刀（第二刀基准含逗号）"}
		];
		for (c in cases) {
			Assert.equals(c.expected, win.formatNumber(c.n), 'n=${c.n}（${c.why}）');
		}
	}
}
