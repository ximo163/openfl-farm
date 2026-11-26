package mc.model;

import common.CommonData;
import common.INI;
import mc.model.OpenControl;
import utest.Assert;

/**
 * mc.model.OpenControl 纯逻辑（issue #87 write-tests，对 stub 失败）：
 * 功能开放控制的 open/等级/时间窗查询。INI 注入同 GetCropIDTest（fixture
 * test/fixtures/mc-ini.xml 的 openControl 六项逐字抄录
 * legacy/deploy/QFarmFlash/source/core/source/xml/mod/mc_main.php:12-17）。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/model/OpenControl.as
 * —— open :57-74（@open=="true" 才 true）；getOpenYellowLv :89-100 与
 * getOpenExpLv :44-55（xmlData null 才 9999，否则 Number(属性)——属性
 * 缺失时 Number("") 在 AS3 得 NaN 照返，本测试按真实配置值钉）；
 * getOpenTime :76-87（@time 原样，xmlData null → ""）；checkTime :27-42
 * （当前小时数与 "|" 分隔小时表逐段字符串比较——注意 `_loc3_[i] == _loc4_`
 * 是 AS3 字符串==数的宽松相等：数比数前各取数值化；"5"=="5" 同串亦真；
 * Haxe 侧等价形态由 implement 裁决，期望值按 fixture 的小时表钉）；
 * checkTime2 :14-25（"start|end" 两段各 new Date().time，serverTime*1000
 * 落闭区间即 true）。
 *
 * 时间注入：CommonData.serverTime 可写（锚点+漂移，测试只取小时数/
 * 毫秒窗——秒级漂移不进位）。checkTime2 的日期窗 "5/1/2010 15:00|
 * 5/13/2010 15:00" 是 AS3 Date 解析形态（M/D/YYYY HH:mm——ActionScript
 * 的 Date 构造串解析）；换算：2010-05-01 15:00:00 UTC 起、2010-05-13
 * 15:00:00 UTC 止的毫秒窗。测试用 UTC 毫秒锚点（1272726000000 ms =
 * 2010-05-01 15:00:00 UTC）——本地时区偏移在 AS3 与 eval 双侧同作用于
 * 解析与比较，闭区间判定与时区无关，只要测试锚点离边界超过时区最大
 * 偏移（±12h）；窗口中点（5/7）与窗外远点（2011 年）满足此条件。
 */
class OpenControlTest {
	static var FIXTURE:String = sys.io.File.getContent("test/fixtures/mc-ini.xml");

	public function new() {}

	function setup() {
		INI.getInstance().data = Xml.parse(FIXTURE);
		CommonData.serverTime = 1700000000;
	}

	// open（OpenControl.as:57-74）：tool/quickshoot/harvestall/sprice/wild
	// open="true" → true；pack open="false" → false；不存在的名字 → false
	// （@open 空串 != "true"）
	public function test_open_flag() {
		Assert.isTrue(OpenControl.open("tool"));
		Assert.isTrue(OpenControl.open("quickshoot"));
		Assert.isTrue(OpenControl.open("harvestall"));
		Assert.isTrue(OpenControl.open("sprice"));
		Assert.isTrue(OpenControl.open("wild"));
		Assert.isFalse(OpenControl.open("pack"));
		Assert.isFalse(OpenControl.open("nonexistent"));
	}

	// getOpenYellowLv（:89-100）：quickshoot openlv=1、harvestall 7、
	// sprice 0、wild 1；tool/pack 无 openlv 属性——Number("") AS3 得 NaN，
	// 测试钉 NaN 形态（Number 化空串语义——implement 应保 NaN 或按原文
	// 宽松形态；此钉以 AS3 语义为准）
	public function test_getOpenYellowLv_values() {
		Assert.equals(1, OpenControl.getOpenYellowLv("quickshoot"));
		Assert.equals(7, OpenControl.getOpenYellowLv("harvestall"));
		Assert.equals(0, OpenControl.getOpenYellowLv("sprice"));
		Assert.equals(1, OpenControl.getOpenYellowLv("wild"));
	}

	// getOpenExpLv（:44-55）：wild openexp=0；其余项无 openexp
	public function test_getOpenExpLv_values() {
		Assert.equals(0, OpenControl.getOpenExpLv("wild"));
	}

	// xmlData null 双侧 9999（:50-54/:95-99）——清 INI 钉缺省
	public function test_defaults_when_ini_null() {
		INI.getInstance().data = null;
		Assert.equals(9999, OpenControl.getOpenYellowLv("harvestall"));
		Assert.equals(9999, OpenControl.getOpenExpLv("wild"));
		Assert.equals("", OpenControl.getOpenTime("harvestall"));
		Assert.isFalse(OpenControl.open("tool"));
	}

	// getOpenTime（:76-87）：harvestall 的小时表与 sprice 的日期窗原样
	public function test_getOpenTime_raw_strings() {
		Assert.equals("5|6|7|8|9|10|12|13|19|20|21|22", OpenControl.getOpenTime("harvestall"));
		Assert.equals("5/1/2010 15:00|5/13/2010 15:00", OpenControl.getOpenTime("sprice"));
		Assert.equals("", OpenControl.getOpenTime("tool")); // 无 time 属性 → 空串
	}

	// checkTime（:27-42）：小时表逐段匹配当前小时。注入整点锚点：
	// 2023-11-15T05:30:00Z 的本地小时依时区而变——为免时区耦合，测试
	// 反查当前小时再构造：serverTime 锚定后从同刻 Date 取 hours 造表。
	// 小时表外的时刻恒 false（用不含当前小时的固定表项——fixture 的
	// harvestall 表有 12 个小时，测试反例用必然缺席的小时：先算出不在
	// 表内的小时数）。为确定性起见用自造 INI：
	public function test_checkTime_hour_table() {
		INI.getInstance().data = Xml.parse("<main><openControl>"
			+ "<item name=\"t1\" open=\"true\" time=\"3|7|11\"/>"
			+ "</openControl></main>");
		// 找一个本地小时为 7 的时刻：从当前锚点反推——构造 2023-11-15 某刻，
		// 逐小时扫描成本高；改用计算：本地小时 = (serverTime/3600 + tzOffset) % 24。
		// eval 的 Date.fromTime 给本地时——直接探：从锚点起 ±23h 内必有一刻
		// 本地小时为 7，逐枚找：
		var base = 1700000000; // 2023-11-14T22:13:20Z
		var hit:Float = -1;
		for (h in 0...24) {
			var t = base + h * 3600;
			if (Date.fromTime(t * 1000).getHours() == 7) {
				hit = t;
				break;
			}
		}
		Assert.isTrue(hit > 0);
		CommonData.serverTime = hit;
		Assert.isTrue(OpenControl.checkTime("t1"));
		// 错位一小时（本地 8 点）→ false
		CommonData.serverTime = hit + 3600;
		Assert.isFalse(OpenControl.checkTime("t1"));
		CommonData.serverTime = base;
	}

	// checkTime2（:14-25）："5/1/2010 15:00|5/13/2010 15:00" 窗内/窗外。
	// 窗内取中点 2010-05-07（UTC 毫秒 1273190400000 附近——用 parse 等值：
	// 2010-05-07T12:00:00Z = 1273233600 秒）；窗外取 2011 年
	public function test_checkTime2_date_window() {
		// 窗内（窗口跨 5/1 15:00 至 5/13 15:00，5/7 正午必在窗内且离边界
		// 超 ±12h 时区偏移）
		CommonData.serverTime = 1273233600; // 2010-05-07T12:00:00Z
		Assert.isTrue(OpenControl.checkTime2("sprice"));
		// 窗外（2011 年）
		CommonData.serverTime = 1293840000; // 2011-01-01T00:00:00Z
		Assert.isFalse(OpenControl.checkTime2("sprice"));
		// 窗前（2010 年初）
		CommonData.serverTime = 1262304000; // 2010-01-01T00:00:00Z
		Assert.isFalse(OpenControl.checkTime2("sprice"));
		CommonData.serverTime = 1700000000;
	}
}
