package;

import haxe.Json;
import sys.io.File;
import utest.Assert;

/**
 * 普查待分诊桶三件（gifts_v_11 / farmui_full_v_40 / farmui1_v_42）加载链
 * 考证定级的验收门（issue #67，研究任务）。issue 验收原文：
 * 「三个 swf 各有一段『引用出处 → 活跃/非活跃 → 定级建议』的结论，出处
 * 全部可核对」「考证产出后：由 Claude 更新 tools/swf-code-baseline.json
 * 对应条目的 reason/tracked（audit 门禁同 commit 保持绿）」「不动
 * main_swfs、不动 baseline 的匹配口径」「未查清的写『未验证』并说明
 * 卡在哪，不猜」「（定级建议）给所有者拍板用，不自行裁决」。
 *
 * 考证结论的落点（本测试的读法，// issue #67）：
 *   - farmui1_v_42 仍在 baseline 账内（mc/main/* 目录族）——issue 的
 *     「更新对应条目」对它直接适用：结论写进 family reason，本测试直接
 *     钉 reason 文本；
 *   - gifts_v_11 / farmui_full_v_40 已在前置 commit e2ca43b2 收编进
 *     main_swfs（scripts/decompile-legacy.sh:66/:69，产物已落地），main
 *     的 baseline 里**没有**这两件的精确条目、audit 走「在册在译」通道
 *     ——这两件的考证结论没有 baseline 条目可写，按 implement 阶段的
 *     append-only 规则（test/** 只许新增文件）落**新文件**
 *     test/Issue67TriageNotes.hx（一个纯 const 字符串类，一键一结论）。
 *     write-tests 阶段该文件不存在，结论要素断言全红；implement 完成
 *     考证、新建该文件并写入结论后转绿。这个文件本来就是「测试的零件」
 *     之外的特例——它是研究交付物本身，按 issue 需求以 // issue #67
 *     为出处。
 *
 * 期望值出处：事实锚点（考证要核对的 legacy 证据）逐条注在各断言注释
 * （文件:行，已逐一在 legacy/ 核过，legacy 冻结不变）；「结论要素必须
 * 齐全」本身是 issue #67 的验收原文。tracked/定级最终取值是所有者拍板
 * 权，本门只钉「要素齐全 + 建议有表态 + 未验证不裸奔 + 匹配口径不动」。
 */
class SwfTriageBaselineTest {
	static final BASELINE = "tools/swf-code-baseline.json";

	// issue #67 点名的三件
	static final KEY_GIFTS = "source/core/module/ui/gifts_v_11.swf";
	static final KEY_FARMUI_FULL = "source/core/module/ui/main/farmui_full_v_40.swf";
	static final FAMILY_MC_MAIN = "source/core/module/mc/main/*"; // farmui1_v_42 挂靠的目录族

	public function new() {}

	static function readBaseline():Dynamic {
		return Json.parse(File.getContent(BASELINE));
	}

	static function entryFor(doc:Dynamic, key:String):Dynamic {
		var entries:Dynamic = Reflect.field(doc, "entries");
		return entries == null ? null : Reflect.field(entries, key);
	}

	static function familyFor(doc:Dynamic, pattern:String):Dynamic {
		var fams:Array<Dynamic> = Reflect.field(doc, "families");
		if (fams == null)
			return null;
		for (f in fams) {
			if (Reflect.field(f, "pattern") == pattern)
				return f;
		}
		return null;
	}

	static function reasonOf(entry:Dynamic):String {
		if (entry == null)
			return "";
		var r = Reflect.field(entry, "reason");
		return r == null ? "" : Std.string(r);
	}

	function assertContains(haystack:String, fragments:Array<String>, evidence:String, ?pos:haxe.PosInfos):Void {
		for (frag in fragments) {
			Assert.isTrue(haystack.indexOf(frag) >= 0, '缺结论要素「' + frag + '」（' + evidence + '）；实际文本: ' + haystack, pos);
		}
	}

	/** implement 新建的考证结论文件（test/** append-only 只允许新增）。
	 *  编译期拿不到就用空串——结论要素断言自然全红。 */
	static function triageNotes():{gifts:String, farmuiFull:String, farmui1:String} {
		// 用 Type.resolveClass 而不是直接 import：write-tests 阶段类不存在，
		// 直接 import 会让整个测试编译不过（orchestrator 要求测试必须能编译
		// 运行、因新断言而失败——不是编译失败）。
		var cls = Type.resolveClass("Issue67TriageNotes");
		if (cls == null)
			return {gifts: "", farmuiFull: "", farmui1: ""};
		return {
			gifts: Std.string(Reflect.field(cls, "GIFTS_V_11") ?? ""),
			farmuiFull: Std.string(Reflect.field(cls, "FARMUI_FULL_V_40") ?? ""),
			farmui1: Std.string(Reflect.field(cls, "FARMUI1_V_42") ?? "")
		};
	}

	// ---------------------------------------------------------- gifts_v_11
	// 事实锚点（考证推导链，结论必须覆盖这些要素）：
	//   引用出处：legacy/deploy/QFarmFlash/source/core/source/xml/mod/
	//     nc_main.php:22 <module name="FreeGift Module" url="$url/module/ui/
	//     gifts_v_11.swf"/>（URL 表配置 key）；
	//   反射链：legacy/decompiled/main3_v_221/scripts/module/FreeGift/
	//     ModuleFreeGift.as:23 Utils.getClass("module.FreeGift.FreeGiftController")
	//     → 控制器在 gifts_v_11.swf 内（legacy/decompiled/gifts_v_11/scripts/
	//     module/FreeGift/FreeGiftController.as 等 13 类）；
	//   加载触发：main3 FarmApplication.as:1049 loadLater([MSG_LOAD_FREEGIFT,
	//     MSG_SHOW_FREEGIFT]) + :1076-1078 setTimeout 1400ms 自动 dispatch
	//     MSG_LOAD_FREEGIFT（无须用户操作即加载）；
	//   活跃性：nc_addon.php:229-253 freegifts 表 25 项，visible="1" 恰 8 项
	//     （id 18-25），其余 visible="0"（gifts_v_11 SetPage.as:99 按 visible
	//     =="0" 过滤）；mync.php:146/:149-150 白名单有 cgi_farm_request_count/
	//     list/recv、**无 cgi_farm_request_gift_send**（main3 ServerServices
	//     .as:168 的送礼 mod 在本部署不可达——写路径死）；
	//   用户入口：main3 LeftSideToolBar.as:143/:147 dispatch MSG_SHOW_FREEGIFT
	//     （openIndex 0/1）；
	//   分工疑点（issue #67 原文）：「main3 侧对应模块桩是哪个（ModuleGifts?）、
	//     GiftWindow.as（main3 已有）与它的分工是什么」——模块桩答案是
	//     ModuleFreeGift 而非 ModuleGifts（ModuleFreeGift.as 全文），分工
	//     答案须写清（main3 common/view/window/GiftWindow.as 静态礼包窗族
	//     vs gifts_v_11 外部 swf 的收发礼物流程）。

	public function test_gifts_note_exists_with_load_chain() {
		var note = triageNotes().gifts;
		// issue #67：「引用出处」必须可核对——结论须带行号级出处
		assertContains(note, [
			"nc_main.php:22",
			"FreeGift Module",
			"ModuleFreeGift",
			"FreeGiftController",
			"FarmApplication.as"
		], "issue #67 引用出处：nc_main.php:22 moduleList + ModuleFreeGift.as:23 反射 + FarmApplication.as:1049 loadLater");
	}

	public function test_gifts_note_has_activity_and_division() {
		var note = triageNotes().gifts;
		// issue #67：「活跃/非活跃」+ GiftWindow 分工疑点
		assertContains(note, [
			"visible",
			"cgi_farm_request_gift_send",
			"GiftWindow"
		], "issue #67 活跃性：nc_addon.php freegifts visible 表 + mync.php 白名单缺 gift_send + GiftWindow 分工疑点");
	}

	public function test_gifts_note_has_grading_recommendation() {
		var note = triageNotes().gifts;
		// issue #67：「定级建议」——立项翻译/归牧场批次/baseline 登记冻结
		// 三选一表态（最终拍板权在所有者，但建议必须给出）
		var hasGrading = note.indexOf("立项") >= 0 || note.indexOf("冻结") >= 0 || note.indexOf("牧场批次") >= 0;
		Assert.isTrue(hasGrading, "gifts_v_11 考证结论须含定级建议（issue #67 三选一）；实际: " + note);
	}

	// ------------------------------------------------------- farmui_full_v_40
	// 事实锚点：
	//   引用出处：nc_main.php:11 <material url=".../farmui_full_v_40.swf"
	//     statusText="加载UI素材..."/>——main 的 material 素材预载（URL 表
	//     配置 key，非代码硬引用；issue #67 要求区分两者）；
	//   207 DoABC 定性（legacy/decompiled/farmui_full_v_40/scripts/ 207 类
	//     逐类核过）：177 个 [Embed] 空壳 stub（构造体仅 super()——qui
	//     skins 全套/ButtonShop/QB/Navigate 等）；帧脚本族：CursorHand.as:12
	//     addFrameScript(0,frame1) frame1=stop() 同型 11 件、MaoPaoFlag.as
	//     frame24 写文本+stop、GiftIcon/FarmLoading 循环回绕 gotoAndPlay；
	//     唯一带监听的 PackageTab.as（三页签 CLICK → gotoAndStop+dispatch）。
	//     即「量级异常」= Flash IDE 自动 stub 涨量，不是隐藏的半个模块；
	//   #58 对齐：src/shim/FrameScriptCompensation.hx:97-101 已登记
	//     MaoPaoFlag frame24 补偿；farmui2_v_58（nc_main.php:12）同族已挂
	//     #58（baseline entries farmui2 行 tracked="#58"）；
	//   farmui2 关系：两者都是 main 的 material 素材库（nc_main.php:11-12
	//     相邻两行），帧脚本族同源。

	public function test_farmui_full_note_exists_with_load_chain() {
		var note = triageNotes().farmuiFull;
		assertContains(note, [
			"nc_main.php:11",
			"material",
			"素材"
		], "issue #67 引用出处：nc_main.php:11 material 素材预载（URL 表配置 key）");
	}

	public function test_farmui_full_note_has_207_verdict() {
		var note = triageNotes().farmuiFull;
		// issue #67 核心疑点：207 个 DoABC 是否活代码、与 farmui2_v_58 的关系
		assertContains(note, [
			"stub",
			"addFrameScript",
			"PackageTab",
			"farmui2_v_58",
			"#58"
		], "issue #67 207 DoABC 定性：177 Embed 空壳 + 帧脚本族 + PackageTab + farmui2 同族挂 #58");
	}

	public function test_farmui_full_note_has_grading_recommendation() {
		var note = triageNotes().farmuiFull;
		var hasGrading = note.indexOf("立项") >= 0 || note.indexOf("冻结") >= 0 || note.indexOf("牧场批次") >= 0 || note.indexOf("#58") >= 0;
		Assert.isTrue(hasGrading, "farmui_full_v_40 考证结论须含定级建议（issue #67 三选一或归 #58 帧脚本族）；实际: " + note);
	}

	// ---------------------------------------------------------- farmui1_v_42
	// 事实锚点：
	//   牧场侧引用：mc_main.php:21 <material url=".../mc/main/farmui1_v_42.swf"/>
	//     （issue 原文「已确认牧场现役」）；
	//   农场侧排查：nc_main.php 全文无 farmui1（material 三件是
	//     farmui_full_v_40/farmui2_v_58/water_ui_v_0，nc_main.php:11-13）；
	//     legacy/decompiled/main3_v_221/scripts/ 全文 grep 无 farmui1 硬引用
	//     → 农场侧不用 → 归牧场批次（issue：「决定它归牧场批次还是单独定级」）。
	//   这件仍在 baseline 账内（mc/main/* 目录族），issue 的「更新对应条目
	//   reason/tracked」对它直接适用——family reason 必须承载农场侧结论。

	public function test_farmui1_family_reason_carries_farm_side_verdict() {
		var fam = familyFor(readBaseline(), FAMILY_MC_MAIN);
		Assert.notNull(fam, "mc/main/* 目录族必须在 baseline families 里（farmui1_v_42 挂靠处，audit 门禁契约）");
		var reason = reasonOf(fam);
		// issue #67：农场侧是否引用的结论必须写进 family reason
		// （issue 唯一点名更新的文件对这件直接适用）。现 reason 停在
		// 「牧场批次的前置」的考证前状态——没有农场侧排查结论，本断言
		// 在 implement 落地前必须红。
		assertContains(reason, [
			"mc_main.php:21",
			"farmui1_v_42",
			"农场侧"
		], "issue #67：mc_main.php:21 牧场引用 + nc_main/main3 无 farmui1 的农场侧排查结论");
		Assert.isFalse(reason.indexOf("开工时这些进 main_swfs 或专项立项") >= 0
			&& reason.indexOf("农场侧") < 0, "mc/main/* 族 reason 仍是考证前占位（无农场侧结论）——考证未落地（issue #67）");
	}

	public function test_farmui1_note_has_grading_recommendation() {
		var note = triageNotes().farmui1;
		var hasGrading = note.indexOf("牧场批次") >= 0 || note.indexOf("立项") >= 0 || note.indexOf("冻结") >= 0 || note.indexOf("单独定级") >= 0;
		Assert.isTrue(hasGrading, "farmui1_v_42 考证结论须含定级建议（issue #67：归牧场批次或单独定级）；实际: " + note);
	}

	// ---------------------------------------------------------- 横切契约

	public function test_unverified_items_must_be_marked_not_guessed() {
		// issue #67：「未查清的写『未验证』并说明卡在哪，不猜」。反向钉：
		// 结论里若出现「未验证」，必须跟随卡点说明（同句含「卡」/「缺」/
		// 冒号）——不允许裸「未验证」占位。三件全查（notes 与 family reason）。
		var notes = triageNotes();
		var texts = [
			"gifts_v_11" => notes.gifts,
			"farmui_full_v_40" => notes.farmuiFull,
			"farmui1_v_42" => notes.farmui1 + reasonOf(familyFor(readBaseline(), FAMILY_MC_MAIN))
		];
		var checked = 0;
		for (k => txt in texts) {
			var idx = txt.indexOf("未验证");
			if (idx >= 0) {
				checked++;
				var tail = txt.substr(idx);
				var hasExplanation = tail.indexOf("卡") >= 0 || tail.indexOf("缺") >= 0 || tail.indexOf("：") >= 0;
				Assert.isTrue(hasExplanation, k + " 结论的「未验证」必须说明卡在哪（issue #67：不猜）；实际: " + txt);
			}
		}
		// 无「未验证」字样时本测试恒绿——它不是假绿：要素齐全性由上面的
		// 测试钉，本条只钉「未验证不裸奔」这个条件式契约
		Assert.isTrue(true, "未验证条件式契约（无未验证字样时恒过）");
	}

	public function test_baseline_matching_rules_unchanged() {
		// issue #67：「不动 baseline 的匹配口径」——entries 键集合与
		// families pattern 集合相对 main 不许变（匹配口径=哪些路径命中哪些
		// 条目），只允许 reason/tracked 文字更新。本测试钉两件关键事实：
		// gifts/farmui_full 已在 main_swfs（在册在译通道），若重新入账=改
		// 匹配口径；mc/main/* 族必须在（farmui1 的登记处）。
		var doc = readBaseline();
		Assert.isNull(entryFor(doc, KEY_GIFTS), "gifts_v_11 已在 main_swfs（decompile-legacy.sh:66），重新入账=改匹配口径（issue #67 边界）");
		Assert.isNull(entryFor(doc, KEY_FARMUI_FULL), "farmui_full_v_40 已在 main_swfs（decompile-legacy.sh:69），重新入账=改匹配口径（issue #67 边界）");
		Assert.notNull(familyFor(doc, FAMILY_MC_MAIN), "mc/main/* 族必须在（farmui1_v_42 的登记处）");
	}
}
