package com.qzone.utils;

import utest.Assert;

/**
 * DateTimeUtils 纯逻辑（issue #18）：时间格式化、日期解析、闰年、同日判断。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/com/qzone/utils/DateTimeUtils.as
 * （formatSecondCount :34-66、parseDate :68-72、formatMillisecond :74-89、
 * formatSecond :91-106、isSameDay :114-127、isLeapYear :129-144）。
 *
 * getTime/getDate/getDateTime/getTimeString 读真实时钟（new Date()），
 * 不进单测（测试规则：不读真实时间）。isSameDay 的入参用本地时钟构造的
 * Date 折算秒值（原版 :120-121 也是秒×1000 后按本地时区取 getDate），
 * 输入与期望同走本地映射，用例不依赖运行时区。
 */
class DateTimeUtilsTest {
	public function new() {}

	// :34-66 中文缩写格式：小时>0 才带“小时”、分>0 才带“分”、
	// 仅当小时==0 且秒>0 才带“秒”（:55）；全量格式（:62）各段照拼不省略。
	// 入参 <=0 一律空串（:40 的 param1 > 0 门）。
	public function test_formatSecondCount_short_and_full_formats() {
		var cases:Array<{s:Int, cn:Bool, expect:String}> = [
			{s: 3661, cn: true, expect: "1小时1分"}, // 1:01:01 —— 有小时 → 秒省略
			{s: 3601, cn: true, expect: "1小时"}, // 1:00:01 —— 分=0 → “分”省略
			{s: 61, cn: true, expect: "1分1秒"}, // 0:01:01 —— 无小时 → 秒保留
			{s: 59, cn: true, expect: "59秒"}, // 0:00:59
			{s: 0, cn: true, expect: ""}, // :40 门
			{s: -1, cn: true, expect: ""},
			{s: 3661, cn: false, expect: "1小时1分1秒"}, // :62 全量格式
			{s: 300, cn: false, expect: "0小时5分0秒"}, // 0 段照拼
			{s: 0, cn: false, expect: ""}
		];
		for (c in cases) {
			Assert.equals(c.expect, DateTimeUtils.formatSecondCount(c.s, c.cn), 's=${c.s} cn=${c.cn}');
		}
	}

	// :74-89 毫秒 → “分:秒”，两位补零；分钟不向小时进位（:76 直接整除 60000）
	public function test_formatMillisecond_pads_and_never_rolls_to_hours() {
		var cases:Array<{ms:Float, expect:String}> = [
			{ms: 0, expect: "00:00"},
			{ms: 59000, expect: "00:59"},
			{ms: 60000, expect: "01:00"},
			{ms: 65000, expect: "01:05"},
			{ms: 3599999, expect: "59:59"},
			{ms: 3600000, expect: "60:00"} // 不进位，分钟可到 60+
		];
		for (c in cases) {
			Assert.equals(c.expect, DateTimeUtils.formatMillisecond(c.ms), 'ms=${c.ms}');
		}
	}

	// :91-106 秒 → “分:秒”，两位补零；:94 先 floor(秒) 再 %60（59.9 → 00:59），
	// 分钟同样不进位
	public function test_formatSecond_pads_and_truncates_fraction() {
		var cases:Array<{sec:Float, expect:String}> = [
			{sec: 0, expect: "00:00"},
			{sec: 59.9, expect: "00:59"}, // :94 floor(param1) 截断小数
			{sec: 60, expect: "01:00"},
			{sec: 61, expect: "01:01"},
			{sec: 125.9, expect: "02:05"},
			{sec: 3599, expect: "59:59"},
			{sec: 3600, expect: "60:00"} // 不进位
		];
		for (c in cases) {
			Assert.equals(c.expect, DateTimeUtils.formatSecond(c.sec), 'sec=${c.sec}');
		}
	}

	// :68-72 “YYYY-MM-DD” → 本地 Date：月份减 1（AS3 月 0 基），时分秒为 0
	public function test_parseDate_builds_local_date_with_zero_based_month() {
		var d = DateTimeUtils.parseDate("2026-11-21");
		Assert.equals(2026, d.getFullYear());
		Assert.equals(10, d.getMonth()); // :71 parseInt(month) - 1
		Assert.equals(21, d.getDate());
		Assert.equals(0, d.getHours());
		Assert.equals(0, d.getMinutes());

		var jan = DateTimeUtils.parseDate("2000-01-01");
		Assert.equals(0, jan.getMonth());
		Assert.equals(1, jan.getDate());
	}

	// :114-127 isSameDay：param1 == 0 直接 false（:116）；否则只比较
	// getDate()（每月几号，:122）——跨月/跨年同“日”也为 true，逐字保留
	public function test_isSameDay_compares_day_of_month_only() {
		Assert.isFalse(DateTimeUtils.isSameDay(0, 100)); // :116 首参 0 门

		var sameDayDiffHour = secondsOf(2026, 10, 21, 8, 30, 0);
		var sameDayLate = secondsOf(2026, 10, 21, 23, 59, 0);
		Assert.isTrue(DateTimeUtils.isSameDay(sameDayDiffHour, sameDayLate));

		var prevDay = secondsOf(2026, 10, 20, 23, 0, 0);
		Assert.isFalse(DateTimeUtils.isSameDay(sameDayDiffHour, prevDay));

		// 原版只比 getDate()（:122-126）：十月 21 与十一月 21 判“同天”
		var oct21 = secondsOf(2026, 9, 21, 12, 0, 0);
		var nov21 = secondsOf(2026, 10, 21, 12, 0, 0);
		Assert.isTrue(DateTimeUtils.isSameDay(oct21, nov21));

		// 跨年同理
		var y2025 = secondsOf(2025, 10, 21, 12, 0, 0);
		Assert.isTrue(DateTimeUtils.isSameDay(y2025, nov21));
	}

	// :129-144 闰年：先 100/400 整除档，再 4 整除档
	public function test_isLeapYear_century_and_four_year_rules() {
		var cases:Array<{y:Int, expect:Bool}> = [
			{y: 2000, expect: true}, // %400
			{y: 1600, expect: true},
			{y: 1900, expect: false}, // %100 但非 %400
			{y: 2100, expect: false},
			{y: 2024, expect: true}, // %4 非 %100
			{y: 1996, expect: true},
			{y: 2025, expect: false},
			{y: 2023, expect: false}
		];
		for (c in cases) {
			Assert.equals(c.expect, DateTimeUtils.isLeapYear(c.y), 'y=${c.y}');
		}
	}

	// 本地时钟构造整秒时间戳（isSameDay 的入参形态，避免时区依赖）
	static function secondsOf(y:Int, m:Int, d:Int, h:Int, mi:Int, s:Int):Float {
		return new Date(y, m, d, h, mi, s).getTime() / 1000;
	}
}
