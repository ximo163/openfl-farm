package mc.control;

import common.CommonData;
import common.INI;
import mc.control.ModuleManager;
import module.weekendSale.WeekendSaleHelper;
import support.McCommandEnv;
import utest.Assert;

/**
 * mc.control.ModuleManager 纯逻辑（issue #88 write-tests，对 stub 失败）：
 * 子模块（周末特卖等活动）的时间窗判定与 ids 解析。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/control/ModuleManager.as
 * —— checkSubModule :25-69（**静态方法**——无实例；首次调用把 INI data
 * 缓存进私有静态 _xml :33-36；data.submodule[0] 缺失直返 :37-40；
 * 遍历 module 列表：@start/@end 属性经 new Date(str).time 换算毫秒窗
 * :50-52；serverTime*1000 严格落在 (start,end) 开区间内 → 激活：
 *   · @name == WeekendSaleHelper.activityName（"weekendSale" 小写——
 *     WeekendSaleHelper.as:20）→ WeekendSaleHelper.ids =
 *     JSON.decode(StringUtil.trim(module.ids))——ids 是**子元素**（无 @
 *     ——:56 E4X child 访问）trim 后 JSON 解码；
 *   · 随后无条件 new MoudeLoader().addModule(module)——加载面（材质
 *     url 经 GetCropID.addPrefix、@url 主 url、@className →
 *     rslManager.requestClass——MoudeLoader :97-130）涉 Loader/资产，
 *     不进纯逻辑断言。
 * 窗外 → 不激活）。
 *
 * 日期格式说明：真实配置里 submodule 系的日期是 M/D/YYYY（mc_main.php:114
 * magicalBaby "7/2/2012 00:00:00"——submodule 本体部署包里无实例，格式
 * 参照同族）；AS3 new Date(str) 兼收。测试 fixture 用 ISO 格式
 * "YYYY-MM-DD hh:mm:ss" 以便 Haxe 侧解析——解析差异属 implement 的
 * PORT-NOTE 面，测试只锚「窗内命中/窗外不命中」语义。
 *
 * _xml 静态缓存（:33-36——**只读一次 INI**）：各用例经 @:access 复位
 * ModuleManager._xml，否则首用例的 fixture 粘住后续。
 */
class ModuleManagerTest {
	var env:McCommandEnv;

	public function new() {}

	function setup() {
		env = new McCommandEnv();
		env.resetStatics();
		env.swapInRecorder();
		env.captureViewControl([]);
		resetModuleXml();
		WeekendSaleHelper.ids = null;
	}

	function teardown() {
		env.restoreRecorder();
		env.releaseViewControl();
	}

	function injectSubmodule(xml:String) {
		INI.getInstance().data = Xml.parse(xml);
	}

	@:access(mc.control.ModuleManager)
	static function resetModuleXml() {
		ModuleManager._xml = null;
	}

	// 时间窗内命中（ModuleManager.as:47-57）：serverTime*1000 ∈ (start,
	// end) 且 @name "weekendSale" → ids trim+JSON.decode。serverTime
	// 1700000000 秒 = 2023-11-14T22:13:20Z
	public function test_checkSubModule_inside_window_decodes_ids() {
		CommonData.serverTime = 1700000000;
		injectSubmodule('<data><submodule>'
			+ '<module name="weekendSale" start="2023-11-13 00:00:00" end="2023-11-15 23:59:59" url="m.swf"><ids>[1001, 1002 ,1003]</ids></module>'
			+ '</submodule></data>');
		ModuleManager.checkSubModule();
		var ids:Array<Dynamic> = cast WeekendSaleHelper.ids;
		Assert.notNull(ids);
		Assert.equals(3, ids.length);
		Assert.equals(1001, ids[0]);
		Assert.equals(1003, ids[2]);
	}

	// 窗外不激活（:53 闸）：now < start → ids 不动
	public function test_checkSubModule_before_window_noop() {
		CommonData.serverTime = 1600000000; // 2020-09-13
		injectSubmodule('<data><submodule>'
			+ '<module name="weekendSale" start="2023-11-13 00:00:00" end="2023-11-15 23:59:59" url="m.swf"><ids>[1]</ids></module>'
			+ '</submodule></data>');
		ModuleManager.checkSubModule();
		Assert.isNull(WeekendSaleHelper.ids);
	}

	// 过期窗不激活：now > end
	public function test_checkSubModule_after_window_noop() {
		CommonData.serverTime = 1800000000; // 2027-01-15
		injectSubmodule('<data><submodule>'
			+ '<module name="weekendSale" start="2023-11-13 00:00:00" end="2023-11-15 23:59:59" url="m.swf"><ids>[1]</ids></module>'
			+ '</submodule></data>');
		ModuleManager.checkSubModule();
		Assert.isNull(WeekendSaleHelper.ids);
	}

	// ids 子元素 trim（:56——StringUtil.trim 后 JSON.decode）：首尾空白
	// 剥掉仍正确解码
	public function test_checkSubModule_ids_trimmed_decode() {
		CommonData.serverTime = 1700000000;
		injectSubmodule('<data><submodule>'
			+ '<module name="weekendSale" start="2023-11-13 00:00:00" end="2023-11-15 23:59:59" url="m.swf"><ids>  [7,8]  </ids></module>'
			+ '</submodule></data>');
		ModuleManager.checkSubModule();
		var ids:Array<Dynamic> = cast WeekendSaleHelper.ids;
		Assert.notNull(ids);
		Assert.equals(2, ids.length);
		Assert.equals(7, ids[0]);
		Assert.equals(8, ids[1]);
	}

	// 非 weekendSale 名字的模块在窗内：ids 不写（:55 名闸）——但
	// addModule 加载面照走（不进断言）
	public function test_checkSubModule_other_name_skips_ids() {
		CommonData.serverTime = 1700000000;
		injectSubmodule('<data><submodule>'
			+ '<module name="otherActivity" start="2023-11-13 00:00:00" end="2023-11-15 23:59:59" url="m.swf"><ids>[9]</ids></module>'
			+ '</submodule></data>');
		ModuleManager.checkSubModule();
		Assert.isNull(WeekendSaleHelper.ids);
	}

	// submodule 节缺失 → 直返不崩（:37-40）
	public function test_checkSubModule_missing_section_noop() {
		CommonData.serverTime = 1700000000;
		injectSubmodule('<data></data>');
		ModuleManager.checkSubModule();
		Assert.isNull(WeekendSaleHelper.ids);
	}

	// 边界严格开区间（:55 `<` 严格——`_loc7_ < _loc9_ && _loc9_ < _loc8_`）：
	// now == start 不命中、now == end 不命中。窗换算用与实现同一只解析器
	// （Date.fromString——实现侧 Haxe 等价物对应 AS3 new Date(str)）：
	// 两端都用本地时间换算，差值与容器时区无关（裸 epoch 换算按 UTC 是
	// 时区脆弱的——Haxe/AS3 日期串解析皆本地时间）
	public function test_checkSubModule_boundary_exclusive() {
		var startStr = "2023-11-13 00:00:00";
		var endStr = "2023-11-15 00:00:00";
		injectSubmodule('<data><submodule>'
			+ '<module name="weekendSale" start="' + startStr + '" end="' + endStr + '" url="m.swf"><ids>[1]</ids></module>'
			+ '</submodule></data>');
		// now == start → 不命中（严格小于）
		CommonData.serverTime = Date.fromString(startStr).getTime() / 1000;
		ModuleManager.checkSubModule();
		Assert.isNull(WeekendSaleHelper.ids);
		// now == end → 不命中
		CommonData.serverTime = Date.fromString(endStr).getTime() / 1000;
		resetModuleXml();
		ModuleManager.checkSubModule();
		Assert.isNull(WeekendSaleHelper.ids);
		// 对照：窗内 1 秒 → 命中（同一 fixture 证明窗本体有效）
		CommonData.serverTime = Date.fromString(startStr).getTime() / 1000 + 1;
		resetModuleXml();
		ModuleManager.checkSubModule();
		Assert.notNull(WeekendSaleHelper.ids);
	}
}
