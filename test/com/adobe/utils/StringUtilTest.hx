package com.adobe.utils;

import utest.Assert;

/**
 * com.adobe.utils.StringUtil 整类纯函数（issue #43）：#7 闭包只译了 trim，
 * 本片补齐其余 8 个方法。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/com/adobe/utils/StringUtil.as
 * （beginsWith :11-14、trim :16-19、stringsAreEqual :21-28、replace :30-63、
 * rtrim :65-78、endsWith :80-83、stringHasValue :85-88、remove :90-93、
 * ltrim :95-108）。裁剪集的 `charCode > 32` 判据在 :71/:101。
 *
 * stub 阶段失败点：trim 已是 #7 真身（StringTools.trim 等价体，本文件各用例
 * 在两侧实现下同值——含 U+00A0 边界，eval 的 StringTools.trim 也不裁 160），
 * 其余 8 个方法是 throw stub。
 */
class StringUtilTest {
	public function new() {}

	// :11-14 beginsWith：前缀整段比对，大小写敏感；空前缀 substring(0,0)=="" 恒真
	public function test_beginsWith_prefix_compare() {
		Assert.isTrue(StringUtil.beginsWith("Hello World", "Hello"));
		Assert.isFalse(StringUtil.beginsWith("Hello World", "hello")); // :13 == 直比，不归一大小写
		Assert.isFalse(StringUtil.beginsWith("Hello", "Hello World")); // 前缀比源串长必假
		Assert.isTrue(StringUtil.beginsWith("abc", ""));
		Assert.isFalse(StringUtil.beginsWith("World", "Worlds"));
	}

	// :80-83 endsWith：后缀整段比对；空后缀 substring(len)=="" 恒真
	public function test_endsWith_suffix_compare() {
		Assert.isTrue(StringUtil.endsWith("Hello World", "World"));
		Assert.isFalse(StringUtil.endsWith("Hello World", "world")); // 大小写敏感
		Assert.isFalse(StringUtil.endsWith("World", "Hello World")); // 后缀比源串长必假
		Assert.isTrue(StringUtil.endsWith("abc", ""));
		Assert.isFalse(StringUtil.endsWith("World", "Wrld"));
	}

	// :21-28 stringsAreEqual：caseSensitive 走 ==，否则两侧 toUpperCase 后比
	public function test_stringsAreEqual_case_modes() {
		Assert.isTrue(StringUtil.stringsAreEqual("ABC", "ABC", true)); // :25
		Assert.isFalse(StringUtil.stringsAreEqual("Hello", "hello", true)); // :25
		Assert.isTrue(StringUtil.stringsAreEqual("Hello", "hello", false)); // :27
		Assert.isTrue(StringUtil.stringsAreEqual("hello", "HELLO", false)); // :27
		Assert.isFalse(StringUtil.stringsAreEqual("hello", "world", false));
	}

	// :25 stringsAreEqual 的 null 语义：AS3 里 null 只等于 null
	public function test_stringsAreEqual_null_equality() {
		Assert.isTrue(StringUtil.stringsAreEqual(null, null, true));
		Assert.isFalse(StringUtil.stringsAreEqual(null, "", true));
		Assert.isFalse(StringUtil.stringsAreEqual("", null, true));
	}

	// :30-63 replace：手工逐字符扫描。命中后 _loc8_ += 针长-1 再自增
	// （:56），整段跳过不重叠匹配："aaa" 换 "aa" → 第一段命中跳到下标 2，
	// 尾部单 a 拼回
	public function test_replace_manual_scan() {
		Assert.equals("hello farm", StringUtil.replace("hello world", "world", "farm"));
		Assert.equals("ba", StringUtil.replace("aaa", "aa", "b")); // 跳针语义
		Assert.equals("baNANA", StringUtil.replace("banana", "na", "NA")); // 相邻两段各自命中
		Assert.equals("abc", StringUtil.replace("abc", "x", "y")); // 无命中
	}

	// :40 空针：charAt(0) 恒 ""，与任何字符都不等 → 原样返回
	public function test_replace_empty_needle_is_noop() {
		Assert.equals("abc", StringUtil.replace("abc", "", "Z"));
		Assert.equals("", StringUtil.replace("", "a", "B"));
	}

	// :90-93 remove：replace 的第三参空串
	public function test_remove_strips_all_occurrences() {
		Assert.equals("helloworld", StringUtil.remove("hello world", " "));
		Assert.equals("abc", StringUtil.remove("a.b.c", "."));
		Assert.equals("abc", StringUtil.remove("abc", "xyz"));
	}

	// :95-108 ltrim：左侧 charCode <= 32（空格/\t/\n/\r）剥掉；160 的
	// 不间断空格 > 32 保留（:101 判据），全空白串归 ""
	public function test_ltrim_strips_leading_whitespace_only() {
		Assert.equals("abc", StringUtil.ltrim("   abc"));
		Assert.equals("x", StringUtil.ltrim("\t\n\r x"));
		Assert.equals("", StringUtil.ltrim("   "));
		Assert.equals("abc", StringUtil.ltrim("abc"));
		Assert.equals("\u00A0a", StringUtil.ltrim("\u00A0a")); // 160 前缀保留
		Assert.equals("a  ", StringUtil.ltrim("  a  ")); // 右侧不动
	}

	// :65-78 rtrim：右侧 <= 32 剥掉，160 保留，全空白归 ""
	public function test_rtrim_strips_trailing_whitespace_only() {
		Assert.equals("abc", StringUtil.rtrim("abc   "));
		Assert.equals("x", StringUtil.rtrim("x\t\n"));
		Assert.equals("", StringUtil.rtrim("   "));
		Assert.equals("a\u00A0", StringUtil.rtrim("a\u00A0")); // 160 后缀保留
		Assert.equals("  a", StringUtil.rtrim("  a  ")); // 左侧不动
	}

	// :16-19 trim = ltrim(rtrim(s))：两侧裁剪、内部空格保留
	public function test_trim_both_sides() {
		Assert.equals("hello", StringUtil.trim("  hello  "));
		Assert.equals("hi", StringUtil.trim("\t hi \r\n"));
		Assert.equals("", StringUtil.trim("   ")); // rtrim 先归 ""
		Assert.equals("a b", StringUtil.trim("  a b  ")); // 内部空格不动
	}

	// :85-88 stringHasValue：非 null 且长度 > 0
	public function test_stringHasValue() {
		Assert.isTrue(StringUtil.stringHasValue("x"));
		Assert.isTrue(StringUtil.stringHasValue(" ")); // 空格也是字符
		Assert.isFalse(StringUtil.stringHasValue(""));
		Assert.isFalse(StringUtil.stringHasValue(null)); // :87 null 门
	}
}
