package common.view.floating;

import utest.Assert;

/**
 * HarvestAnimation 收获飘字的数值文本格式化纯逻辑（issue #9）。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/common/view/floating/
 * HarvestAnimation.as（set text :76-86）。收获数来自
 * legacy/deploy/QFarmFlash/source/core/source/nc/mod/farmlandstatus_harvest.php
 * :36（$harvest = $status[$id]['m']）→ :95 回包 "harvest" 字段 →
 * onHarvestData 的飘字 text。
 *
 * 规则：首字符非 -/+ 且 parseFloat 非 NaN → 补 "+ " 前缀（:78-81）；文本列
 * 固定 x=65（:86）。断言经 @:access 读 _numText（TextField.text 在 eval
 * 可用，#8 scratch 已验证；构造不取素材——MaterialProxy 空构造）。
 */
@:access(common.view.floating.HarvestAnimation)
class HarvestAnimationTest {
	public function new() {}

	// 裸数字 → "+ 42"（带空格的前缀，:80 的 "+ " 原样）
	public function test_text_prefixes_plus_space_for_bare_numbers() {
		var ha = new HarvestAnimation(null);
		ha.text = "42";
		Assert.equals("+ 42", ha._numText.text);
		Assert.equals(65.0, ha._numText.x); // :86
	}

	// 显式符号与非数字原样
	public function test_text_keeps_explicit_sign_and_non_numbers() {
		var ha = new HarvestAnimation(null);
		ha.text = "-7";
		Assert.equals("-7", ha._numText.text); // 首字符 - → 不加前缀
		ha.text = "+9";
		Assert.equals("+9", ha._numText.text); // 首字符 + → 不加前缀
		ha.text = "abc";
		Assert.equals("abc", ha._numText.text); // parseFloat NaN → 不加前缀
	}

	// :78-80 的 parseFloat 只看前缀：混合串仍算数字
	public function test_text_numeric_prefix_mixed_still_prefixed() {
		var ha = new HarvestAnimation(null);
		ha.text = "12abc";
		Assert.equals("+ 12abc", ha._numText.text);
	}
}
