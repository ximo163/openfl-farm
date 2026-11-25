package;

import utest.Assert;
import Issue68TriageNotes;

/**
 * issue #68 的验收门：17 件无归属农场侧带代码 swf 的加载链考证定级
 * （研究任务）。issue 验收原文：「17 件各有一段『引用出处 → 活跃/非活跃
 * → 定级建议』结论，出处全部可核对」「查不清的写『未验证』+ 卡在哪，不猜」
 * 「定级建议给所有者拍板用，不自行裁决」。
 *
 * 考证结论的落点（// issue #68 需求 + 「stub 归树」规矩）：17 件全部已在
 * 前置 commit 收编进 main_swfs（scripts/decompile-legacy.sh:52-86 区段），
 * baseline 无账可写——结论是研究交付物（产品数据非测试零件），按 stub 归树
 * 放 src/Issue68TriageNotes.hx（17 个 static var 空串 stub，write-tests 建）。
 * implement 原地填结论即转绿——src/ 不受 test/ append-only 约束，这避开
 * 了 #67 的 test/import.hx DCE 通道在 #68 不可用的死结（import.hx 已被
 * #67 创建进 main，implement 改它违反 append-only）。本测试直接 import
 * stub 类（write-tests 阶段已存在，编译得过）作编译图锚点。
 *
 * 17 件清单（// issue #68 原文「17 件现状」表）：
 *   collect/CollectingMain_v_3、plugin/FairyPlugin_v_21、
 *   plugin/MailPromotionPlugin_v_3、plugin/PromotionsPlugin_v_1、
 *   plugin/WeekendPlugin_v_3、ui/dialogs/ArborDayActivityContext_v_0、
 *   arborDayLv2PanelView_v_0、arborDayMainPanelView_v_0、ui/lite_ui_v_0、
 *   ui/freegift_v_5、ui/monthEnd_v_5、ui/recall_v_3、ui/sellyouji_v_1、
 *   ui/singleFes_v_0、ui/stocks_v_2、ui/QDSeed_v_1、ui/farm/houseKeeper_v_0
 *
 * 期望值出处：issue #68 验收原文 + 各断言注释里的 legacy 事实锚点
 * （文件:行已在 legacy/ 逐一核过，legacy 冻结不变）。tracked/定级最终
 * 取值是所有者拍板权，本门只钉「17 件全覆盖 + 要素齐全 + 引用出处可核对
 * + 活跃判定有表态 + 未验证不裸奔」。
 */
class Issue68TriageTest {
	public function new() {}

	static function notes():Map<String, String> {
		var out = new Map<String, String>();
		// 直接读 stub 类的 static var（编译图锚点：import 已让类进编译，
		// 无需 Type.resolveClass）。implement 填非空后这些读到的就是结论。
		out.set("COLLECTING_MAIN_V_3", Issue68TriageNotes.COLLECTING_MAIN_V_3);
		out.set("FAIRY_PLUGIN_V_21", Issue68TriageNotes.FAIRY_PLUGIN_V_21);
		out.set("MAIL_PROMOTION_PLUGIN_V_3", Issue68TriageNotes.MAIL_PROMOTION_PLUGIN_V_3);
		out.set("PROMOTIONS_PLUGIN_V_1", Issue68TriageNotes.PROMOTIONS_PLUGIN_V_1);
		out.set("WEEKEND_PLUGIN_V_3", Issue68TriageNotes.WEEKEND_PLUGIN_V_3);
		out.set("ARBOR_DAY_ACTIVITY_CONTEXT_V_0", Issue68TriageNotes.ARBOR_DAY_ACTIVITY_CONTEXT_V_0);
		out.set("ARBOR_DAY_LV2_PANEL_VIEW_V_0", Issue68TriageNotes.ARBOR_DAY_LV2_PANEL_VIEW_V_0);
		out.set("ARBOR_DAY_MAIN_PANEL_VIEW_V_0", Issue68TriageNotes.ARBOR_DAY_MAIN_PANEL_VIEW_V_0);
		out.set("LITE_UI_V_0", Issue68TriageNotes.LITE_UI_V_0);
		out.set("FREEGIFT_V_5", Issue68TriageNotes.FREEGIFT_V_5);
		out.set("MONTH_END_V_5", Issue68TriageNotes.MONTH_END_V_5);
		out.set("RECALL_V_3", Issue68TriageNotes.RECALL_V_3);
		out.set("SELLYOUJI_V_1", Issue68TriageNotes.SELLYOUJI_V_1);
		out.set("SINGLE_FES_V_0", Issue68TriageNotes.SINGLE_FES_V_0);
		out.set("STOCKS_V_2", Issue68TriageNotes.STOCKS_V_2);
		out.set("QD_SEED_V_1", Issue68TriageNotes.QD_SEED_V_1);
		out.set("HOUSE_KEEPER_V_0", Issue68TriageNotes.HOUSE_KEEPER_V_0);
		return out;
	}

	static final KEYS = [
		"COLLECTING_MAIN_V_3",
		"FAIRY_PLUGIN_V_21",
		"MAIL_PROMOTION_PLUGIN_V_3",
		"PROMOTIONS_PLUGIN_V_1",
		"WEEKEND_PLUGIN_V_3",
		"ARBOR_DAY_ACTIVITY_CONTEXT_V_0",
		"ARBOR_DAY_LV2_PANEL_VIEW_V_0",
		"ARBOR_DAY_MAIN_PANEL_VIEW_V_0",
		"LITE_UI_V_0",
		"FREEGIFT_V_5",
		"MONTH_END_V_5",
		"RECALL_V_3",
		"SELLYOUJI_V_1",
		"SINGLE_FES_V_0",
		"STOCKS_V_2",
		"QD_SEED_V_1",
		"HOUSE_KEEPER_V_0"
	];

	static function assertContains(haystack:String, fragments:Array<String>, evidence:String, ?pos:haxe.PosInfos):Void {
		for (frag in fragments) {
			Assert.isTrue(haystack.indexOf(frag) >= 0, '缺结论要素「' + frag + '」（' + evidence + '）；实际文本: ' + haystack, pos);
		}
	}

	// ---------------------------------------------------------- 横切契约

	/** issue #68 验收：17 件**各有一段**结论——键集合恰为 17 且每件非空
	 *  （空串 stub=未考证，等同缺失）。 */
	public function test_all_17_notes_present_and_nonempty() {
		var ns = notes();
		Assert.equals(17, KEYS.length, "17 键清单自身完整性（issue #68 点名 17 件）");
		for (key in KEYS) {
			var note = ns.get(key);
			Assert.isTrue(note != null && note.length > 200, key + " 考证结论缺失或过短（issue #68：17 件各有一段『引用出处→活跃/非活跃→定级建议』结论）；实际长度: " + (note == null ? 0 : note.length));
		}
	}

	/** issue #68 验收：「定级建议：立项翻译 / 冻结 / 牧场批次给所有者
	 *  拍板用，不自行裁决」——每件必须给建议表态。 */
	public function test_every_note_has_grading_recommendation() {
		var ns = notes();
		for (key in KEYS) {
			var note = ns.get(key) ?? "";
			var hasGrading = note.indexOf("立项") >= 0 || note.indexOf("冻结") >= 0 || note.indexOf("牧场批次") >= 0;
			Assert.isTrue(hasGrading, key + " 考证结论须含定级建议（issue #68：立项翻译/冻结/牧场批次表态给所有者拍板）；实际: " + note);
		}
	}

	/** issue #68 验收：「引用出处」可核对——每件结论须含行号级出处
	 *  （`<文件>.php:<行>` 或 `<类>.as:<行>`），或明写「部署内零引用」
	 *  （issue 允许：「查不到任何引用的明说部署内零引用」）。 */
	public function test_every_note_has_checkable_reference() {
		var ns = notes();
		for (key in KEYS) {
			var note = ns.get(key) ?? "";
			if (note.length == 0) {
				Assert.fail(key + " 结论缺失（issue #68）");
				continue;
			}
			var hasLineRef = ~/\.(php|as):[0-9]+/.match(note);
			var hasZeroRef = note.indexOf("零引用") >= 0;
			Assert.isTrue(hasLineRef || hasZeroRef, key + " 引用出处须带行号级出处（.php:行/.as:行）或明示零引用（issue #68：出处全部可核对）；实际: " + note);
		}
	}

	/** issue #68 验收：「查不清的写『未验证』并说明卡在哪，不猜」——
	 *  反向钉：出现「未验证」必须跟随卡点说明（同段含「卡」/「缺」/冒号）。 */
	public function test_unverified_items_must_be_marked_not_guessed() {
		var ns = notes();
		for (key in KEYS) {
			var txt = ns.get(key) ?? "";
			var idx = txt.indexOf("未验证");
			if (idx >= 0) {
				var tail = txt.substr(idx);
				var hasExplanation = tail.indexOf("卡") >= 0 || tail.indexOf("缺") >= 0 || tail.indexOf("：") >= 0;
				Assert.isTrue(hasExplanation, key + " 结论的「未验证」必须说明卡在哪（issue #68：不猜）；实际: " + txt);
			}
		}
		Assert.isTrue(true, "未验证条件式契约（无未验证字样时恒过）");
	}

	/** issue #68 边界：「留账冻结的不碰」——labor 孤儿/shop_v_0/
	 *  warehouse_v_0/ui/main decorate_v_0 副本/4 损坏文件已在 baseline，
	 *  非本 issue 对象，结论不该把它们拉进本批定级。 */
	public function test_notes_do_not_regrade_baseline_frozen_items() {
		var ns = notes();
		for (key in KEYS) {
			var note = ns.get(key) ?? "";
			if (note.length == 0)
				continue;
			Assert.isFalse(note.indexOf("LaborDayMain") >= 0, key + " 不该把 labor 孤儿拉进本批（issue #68 边界：留账冻结的不碰）；实际: " + note);
		}
	}

	// ---------------------------------------------------------- 逐件要素钉板

	/** CollectingMain_v_3：issue 点名锚点「nc_addon.php:128 activity
	 *  id="collecting" standalone gray expire 2050（按时间仍活跃）」。
	 *  事实锚点（已核）：nc_addon.php:128 配置行 start_time=2012-7-31 /
	 *  expire_time=2050-1-1 / gray="1"；加载链 main3 AllianceActivityController
	 *  .as:79 loadActivityModule + :246-249 enter_type=customize 分支 +
	 *  app4/activities/common/ActivityController.as:46 collecting helper 绑定；
	 *  gray 门 :27-39（黄钻 status>0 且 level>=gray 才预载）。 */
	public function test_collecting_note_has_load_chain_and_activity() {
		var note = notes().get("COLLECTING_MAIN_V_3") ?? "";
		assertContains(note, [
			"nc_addon.php:128",
			"collecting"
		], "issue #68 引用出处：nc_addon.php:128 activity id=\"collecting\" 配置行");
		assertContains(note, [
			"expire",
			"gray"
		], "issue #68 活跃判定：expire_time 2050 窗口内 + gray 黄钻门（nc_addon.php:128 属性）");
		// 活跃判定须落到 serverTime 比对（issue #68 点名「该链路在固定快照里
		// 会不会走到」）：start 2012-7-31/expire 2050-1-1 窗口对 snapshot
		// serverTime=1794915896（≈2026）为真——但 gray="1" 黄钻门是第二道闸
		// （ActivityController.as:27-39 黄钻 status>0 且 level>=gray 才预载），
		// uid1 yellowstatus=0/yellowlevel=0 不过门。两层必须分开表态。
		var hasServerTime = note.indexOf("serverTime") >= 0 || note.indexOf("1794915896") >= 0 || note.indexOf("2050") >= 0;
		Assert.isTrue(hasServerTime, "COLLECTING 活跃判定须落到 serverTime/expire 窗口比对（issue #68 点名「按时间仍活跃」）；实际: " + note);
	}

	/** FairyPlugin_v_21：issue 点名锚点「nc_addon.php:303-305 plugins 节
	 *  proxy=plugins.FairyPluginProxy、amount 3 挂载点、:300 注释、
	 *  :326-328 fairy f0-f3」。事实锚点（已核）：nc_addon.php:305 plugins
	 *  JSON 唯一条目 id:2；加载机制 main3 framework/api/PluginManager.as:51-53
	 *  hasDefinition(proxy) 反射；**活跃判定核心**：nc_addon.php:104
	 *  `<fairy>0</fairy>` 灰度总开关，FairyPluginProxy.as:111-114 fairy=="0"
	 *  直接 break——本部署 fairy=0 时 loadResource 永不调用、swf 不加载。 */
	public function test_fairy_note_has_load_chain_and_gray_verdict() {
		var note = notes().get("FAIRY_PLUGIN_V_21") ?? "";
		assertContains(note, [
			"plugins",
			"FairyPluginProxy",
			"amount"
		], "issue #68 引用出处：nc_addon.php:305 plugins 节 proxy=plugins.FairyPluginProxy + amount 3 挂载点");
		var hasMechanism = note.indexOf("PluginManager") >= 0 || note.indexOf("applicationDomain") >= 0 || note.indexOf("hasDefinition") >= 0;
		Assert.isTrue(hasMechanism, "FAIRY_PLUGIN_V_21 结论须写清插件框架加载机制（main3 PluginManager.as 反射 proxy，issue #68 加载链待查项）；实际: " + note);
		// 活跃判定核心：fairy 灰度开关 0 决定 swf 是否真加载（issue #68 点名
		// 活跃判定须查「开关」——nc_addon.php:104 <fairy>0</fairy> 正是开关）
		var hasGrayVerdict = note.indexOf("fairy") >= 0 && (note.indexOf("灰度") >= 0 || note.indexOf("<fairy>") >= 0 || note.indexOf("nc_addon.php:104") >= 0);
		Assert.isTrue(hasGrayVerdict, "FAIRY_PLUGIN_V_21 活跃判定须含 fairy 灰度总开关（nc_addon.php:104 <fairy>0</fairy> 决定 swf 是否加载，issue #68 活跃判定点名项「开关」）；实际: " + note);
	}

	/** 插件三兄弟：issue 原文「普查在 nc_addon.php / main3_v_221 反编译
	 *  里无文件名直接命中……加载链待查」。事实锚点（已核）：PluginManager
	 *  .as:45 纯配置驱动遍历，nc_addon.php plugins JSON 只有 id:2 FairyPlugin
	 *  一条——三件不在配置里→proxy 永不实例化→swf 永不加载。结论须收口
	 *  为「部署内零引用」+ 排查范围，或找到真实链路。 */
	public function test_plugin_trio_zero_reference_or_chain() {
		var trio = [
			"MAIL_PROMOTION_PLUGIN_V_3",
			"PROMOTIONS_PLUGIN_V_1",
			"WEEKEND_PLUGIN_V_3"
		];
		var ns = notes();
		for (key in trio) {
			var note = ns.get(key) ?? "";
			Assert.isTrue(note.length > 200, key + " 结论缺失（issue #68）");
			var hasZeroRef = note.indexOf("零引用") >= 0;
			var hasLineRef = ~/\.(php|as):[0-9]+/.match(note);
			Assert.isTrue(hasZeroRef || hasLineRef, key + " 加载链待查项必须收口：找到链路（行号级出处）或明写部署内零引用+排查范围（issue #68 点名三兄弟无文件名直接命中）；实际: " + note);
		}
	}

	/** ArborDay 三件套：issue 原文「植树节活动面板族，未定位引用（未验证）」。
	 *  事实锚点（已核）：nc_addon.php activity_list 块（:125-205）仅
	 *  olympicGames/collecting 两条，无 arbor 条目；三件套共享 com/qzone/
	 *  allianceActivity/arborDayActivity 包，内部 cross 引用（context 的 view
	 *  import 两件 panel view）。结论须写清三件套内部关系 + 外部引用裁决。 */
	public function test_arborday_trio_notes_have_cross_reference_facts() {
		var trio = [
			"ARBOR_DAY_ACTIVITY_CONTEXT_V_0",
			"ARBOR_DAY_LV2_PANEL_VIEW_V_0",
			"ARBOR_DAY_MAIN_PANEL_VIEW_V_0"
		];
		var ns = notes();
		for (key in trio) {
			var note = ns.get(key) ?? "";
			Assert.isTrue(note.length > 200, key + " 结论缺失（issue #68）");
			var hasInternal = note.indexOf("rborDay") >= 0; // ArborDay/arborDay 大小写皆可
			var hasVerdict = note.indexOf("零引用") >= 0 || ~/\.(php|as):[0-9]+/.match(note);
			Assert.isTrue(hasInternal && hasVerdict, key + " 结论须含三件套内部关系（arborDayActivity 包族）与外部引用裁决（行号出处或零引用+排查范围）（issue #68：未定位引用项）；实际: " + note);
		}
	}

	/** lite_ui_v_0：issue 原文「10 个 *_Lite 类……加载链待查」。
	 *  事实锚点（已核）：happyfarm3_v_149 FarmLite.as:366
	 *  `uiResUrl = this._settings.replaceAppImg("module/ui/lite_ui_v_0.swf")`
	 *  + :367-371 加载键 "lite_ui"（预加载器硬引用，非 URL 表配置 key——
	 *  issue #67 已要求区分两者）。消费侧：module/lite/FarmLiteView.as
	 *  直接 new *_Lite 符号（:67/183/200/204/208/220/232）。lite_ui 是
	 *  boot 阶段加载界面素材库，非「低配置模式」。 */
	public function test_lite_ui_note_has_preloader_chain() {
		var note = notes().get("LITE_UI_V_0") ?? "";
		assertContains(note, [
			"lite_ui_v_0",
			"FarmLite"
		], "issue #68 加载链待查项：预加载器 happyfarm3_v_149 FarmLite.as:366 lite_ui URL 拼接（硬引用）");
		assertContains(note, [
			"_Lite"
		], "issue #68 lite_ui 消费链：FarmLiteView new *_Lite 符号（decompiled happyfarm3_v_149 module/lite/FarmLiteView.as）");
	}

	/** freegift_v_5：issue 原文「nc_addon freegift 键族；配置指 v_6、
	 *  部署是 v_5（版本漂移待核）」。事实锚点（已核）：nc_addon.php:289
	 *  `{"id":"freegift", "src":"module/ui/freegift_v_6.swf"}` secondList 键；
	 *  部署包 ui/ 下只有 freegift_v_5.swf 无 v_6；且 main3 grep 不到
	 *  getSecondUrl("freegift") 调用方（freegift≠gifts，gifts 是 FreeGift
	 *  Module 另案）。漂移 + 无调用方是活跃判定核心。 */
	public function test_freegift_note_has_version_drift_verdict() {
		var note = notes().get("FREEGIFT_V_5") ?? "";
		assertContains(note, [
			"nc_addon.php:289",
			"freegift"
		], "issue #68 引用出处：nc_addon.php:289 secondList freegift 键");
		Assert.isTrue(note.indexOf("v_6") >= 0 && note.indexOf("v_5") >= 0, "FREEGIFT_V_5 结论须含版本漂移事实（nc_addon.php:289 配置指 v_6、部署是 v_5，issue #68 点名项）；实际: " + note);
	}

	/** monthEnd_v_5：issue 原文「nc_addon.php:121 monthEnd 配置指
	 *  monthEnd_v_8（部署只有 v_5，漂移）；窗口期 2012-7-20~8-13 已过期；
	 *  Master2 有 monthBegin 模块关联」。活跃判定双要素：漂移 + 窗口过期
	 *  （serverTime 1794915896≈2026 远在 2012 窗外）。 */
	public function test_monthend_note_has_drift_and_expired_window() {
		var note = notes().get("MONTH_END_V_5") ?? "";
		assertContains(note, [
			"nc_addon.php:121",
			"monthEnd"
		], "issue #68 引用出处：nc_addon.php:121 monthEnd 配置行");
		Assert.isTrue(note.indexOf("v_8") >= 0, "MONTH_END_V_5 结论须含版本漂移（配置指 monthEnd_v_8、部署只有 v_5，issue #68 点名项）；实际: " + note);
		var hasWindow = note.indexOf("2012") >= 0 && (note.indexOf("过期") >= 0 || note.indexOf("窗外") >= 0 || note.indexOf("7/20") >= 0 || note.indexOf("8/13") >= 0);
		Assert.isTrue(hasWindow, "MONTH_END_V_5 活跃判定须含窗口期 2012-7-20~8-13 已过期（issue #68 点名项）；实际: " + note);
		// 加载链须写清：monthEnd 不是独立模块，是 main3 内嵌 MonthEndWin 经
		// getMonthEnds 取 URL 加载（MonthEndWin.as:603）+ isGiftTime 窗口门
		// （Settings.as:460-479）。issue 点名「Master2 monthBegin 模块关联」——
		// 结论须澄清 monthEnd(农场) 与 monthBegin(牧场) 是两个模块的关系。
		var hasChain = note.indexOf("MonthEndWin") >= 0 || note.indexOf("isGiftTime") >= 0 || note.indexOf("getMonthEnds") >= 0;
		Assert.isTrue(hasChain, "MONTH_END_V_5 引用出处须写清加载链（main3 MonthEndWin.as:603 getMonthEnds 取 URL + isGiftTime 窗口门，非独立模块）；实际: " + note);
		var hasMonthBegin = note.indexOf("monthBegin") >= 0 || note.indexOf("MonthBegin") >= 0;
		Assert.isTrue(hasMonthBegin, "MONTH_END_V_5 结论须澄清与 Master2 monthBegin 模块的关联（issue #68 点名项）；实际: " + note);
	}

	/** recall_v_3：issue 原文「Master2 mc/control/FarmCommand.as 有
	 *  recall 命中；nc_addon 亦有」。事实锚点（已核）：nc_addon.php:288
	 *  `{"id":"recall", "src":"module/ui/recall_v_3.swf"}` secondList；
	 *  main3 module/recall/ModuleRecall.as:37 RecallController +
	 *  RecallView.as:65 getSecondUrl("recall") 消费 + FarmApplication.as:1029
	 *  new ModuleRecall 注册。农场侧模块链必须写清（区分 Master2 命中）。 */
	public function test_recall_note_has_module_chain() {
		var note = notes().get("RECALL_V_3") ?? "";
		assertContains(note, [
			"nc_addon.php:288",
			"recall"
		], "issue #68 引用出处：nc_addon.php:288 secondList recall 键");
		var hasFarmChain = note.indexOf("ModuleRecall") >= 0 || note.indexOf("RecallView") >= 0 || note.indexOf("getSecondUrl") >= 0;
		Assert.isTrue(hasFarmChain, "RECALL_V_3 结论须写清农场侧模块链（main3 module/recall 族 + getSecondUrl 消费，issue #68 区分 Master2 命中与农场侧）；实际: " + note);
		// 活跃判定：zhaohuiOpen 开关（nc_addon.php:64 <zhaohuiOpen>1</zhaohuiOpen>，
		// Settings.as:455-457 openZhaoHui() 判定）是 recall 的活跃开关——issue
		// #68 点名活跃判定须查「开关」。且 Master2 的 recall 命中（FarmCommand.as
		// _recallTime）经考证是拍蚊子重试计数器伪命中，与召回无关——结论须排除
		// 这条干扰线索（issue 原文误引，考证须澄清牧场/农场归属）。
		var hasSwitch = note.indexOf("zhaohuiOpen") >= 0 || note.indexOf("开关") >= 0;
		Assert.isTrue(hasSwitch, "RECALL_V_3 活跃判定须含 zhaohuiOpen 开关（nc_addon.php:64，issue #68 活跃判定点名项「开关」）；实际: " + note);
		var hasFarmVsPasture = note.indexOf("农场") >= 0 || note.indexOf("牧场") >= 0 || note.indexOf("FarmCommand") >= 0;
		Assert.isTrue(hasFarmVsPasture, "RECALL_V_3 结论须区分农场侧/牧场侧归属（issue #68 点名 Master2 FarmCommand.as 命中须澄清——经考证为拍蚊子计数器伪命中）；实际: " + note);
	}

	/** 五件「未定位引用（未验证）」（issue 原文）：sellyouji_v_1 /
	 *  singleFes_v_0 / stocks_v_2 / QDSeed_v_1 / houseKeeper_v_0。
	 *  结论须收口为「部署内零引用」+ 排查范围，或找到真实链路。 */
	public function test_unlocated_five_zero_reference_or_chain() {
		var five = [
			"SELLYOUJI_V_1",
			"SINGLE_FES_V_0",
			"STOCKS_V_2",
			"QD_SEED_V_1",
			"HOUSE_KEEPER_V_0"
		];
		var ns = notes();
		for (key in five) {
			var note = ns.get(key) ?? "";
			Assert.isTrue(note.length > 200, key + " 结论缺失（issue #68）");
			var hasZeroRef = note.indexOf("零引用") >= 0;
			var hasLineRef = ~/\.(php|as):[0-9]+/.match(note);
			Assert.isTrue(hasZeroRef || hasLineRef, key + " 未定位引用项必须收口：找到链路（行号级出处）或明写部署内零引用+排查范围（issue #68 点名五件未验证）；实际: " + note);
		}
	}
}
