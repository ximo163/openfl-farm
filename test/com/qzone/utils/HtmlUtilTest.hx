package com.qzone.utils;

import utest.Assert;

/**
 * HtmlUtil 纯逻辑（issue #18）：HTML 转义与双字节长度。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/com/qzone/utils/HtmlUtil.as
 * （escHTML :15-18、getRealLength :20-23）。
 *
 * escHTML 是链式 replace，顺序与标志逐字保留：& 最先（已转义串不会二次
 * 展开 < >）、空格 → &nbsp;、< > 转义，然后单引号 **无 /g**（只替换第一个，
 * AS3 非全局正则 replace 语义）、双引号全局。restHTML 走 TextField.htmlText
 * → text（显示对象），不进单测。
 */
class HtmlUtilTest {
	public function new() {}

	// :15-18 & 最先转义（其后替换产生的 &amp;/&lt; 不受影响）
	public function test_escHTML_escapes_ampersand_first() {
		Assert.equals("a&amp;b", HtmlUtil.escHTML("a&b"));
		Assert.equals("&amp;&lt;", HtmlUtil.escHTML("&<")); // & 先行 → < 转义产物不再进 & 替换
	}

	// :15-18 空格 → &nbsp;、尖括号转义
	public function test_escHTML_replaces_space_and_angle_brackets() {
		Assert.equals("a&nbsp;b", HtmlUtil.escHTML("a b"));
		Assert.equals("&lt;a&gt;", HtmlUtil.escHTML("<a>"));
		Assert.equals("", HtmlUtil.escHTML(""));
	}

	// :17 单引号 replace 无 /g：只有第一个 ' 被替换，其后保留原字符（逐字保留
	// 的原版笔误，deviations 候选）；双引号全局替换
	public function test_escHTML_replaces_only_first_single_quote_but_all_double() {
		Assert.equals("it&apos;s&nbsp;&quot;x&quot;&nbsp;'y'",
			HtmlUtil.escHTML("it's \"x\" 'y'"));
	}

	// :20-23 非 ASCII（>\xff）按 2 计长：[^\x00-\xff] 替换为 "00" 后取长度
	public function test_getRealLength_counts_non_ascii_as_two() {
		var cases:Array<{s:String, expect:UInt}> = [
			{s: "", expect: 0},
			{s: "abc", expect: 3},
			{s: "农场", expect: 4}, // 每个汉字 → "00"
			{s: "farm农场", expect: 8}, // 4 + 2 + 2
			{s: "，。", expect: 4} // 全角标点同按双字节
		];
		for (c in cases) {
			Assert.equals(c.expect, HtmlUtil.getRealLength(c.s), 's=${c.s}');
		}
	}
}
