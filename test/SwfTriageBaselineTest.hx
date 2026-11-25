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
	//   活跃性：nc_addon.php:228-258 freegifts 表 25 项，visible="1" 恰 8 项
	//     （id 18-25），其余 visible="0"（gifts_v_11 SetPage.as:99 按 visible
	//     =="0" 过滤）；mync.php:146/:149-150 白名单有 cgi_farm_request_count/
	//     list/recv、**无 cgi_farm_request_gift_send**（main3 ServerServices
	//     .as:167 的送礼 mod 在本部署不可达——写路径死）；
	//   活动窗口（issue #67 点名项「活动窗口是否过期」）：nc_addon.php:114
	//     `<freeGiftAutopop>8/20/2012-9/3/2012 23:59:59</freeGiftAutopop>`
	//     （注释原文「免费礼物的强弹」）是功能性日期门——门控 main3
	//     LeftSideToolBar.as:397-432 checkFreeGiftAutoPop() 整条强弹子链：
	//     :417 读配置、:422 按 "-" 拆起止日期、:425-428 与 CommonData.
	//     serverTime 比对不在窗内直接 return；窗内才执行 :430 freeIcon.
	//     showAnimation() + :431 发 AUTO_POP（CommandDefs.as:268=666，
	//     mod=cgi_fetch_strategy_rules，mync.php:157 白名单内）请示 bit_flag，
	//     bit_flag==true 回调里 :414 openFreeGift() 自动弹窗。snapshot 固定
	//     基线 serverTime=1794915896（initialized.sql:5718 healthMode、
	//     tools/nodeboot/fixtures/mync-user-run.json:18 同值）≈2026-11-17
	//     远在 2012 窗外——强弹子链在本部署必死。相邻 :115 freeGiftTime
	//     "8.20 — 9.3"（注释「免费礼物的七夕外观日期」）是纯展示串，唯一
	//     消费点 gifts_v_11 FreeGiftView.as:537 原样写进窗口 time 文本框。
	//     【2026-11-25 补】review-impl 指出 write-tests 初版漏钉此条——
	//     issue 明确要查「活动窗口是否过期」，:114 正是这样的窗口；
	//   用户入口：main3 LeftSideToolBar.as:143/:147 dispatch MSG_SHOW_FREEGIFT
	//     （openIndex 1/0，:143 是 unread>=1 分支 openIndex 1、:147 是 else
	//     分支 openIndex 0）；手动点击入口 :226-227 case "__freegift__" →
	//     openFreeGift()（无日期门）；
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

	/** review-impl（2026-11-25）驳回点钉板：gifts 活跃判定漏掉
	 *  freeGiftAutopop 日期门分析。issue #67 明确要求查「活动窗口是否
	 *  过期」，nc_addon.php:114 `<freeGiftAutopop>8/20/2012-9/3/2012
	 *  23:59:59</freeGiftAutopop>`（注释「免费礼物的强弹」）正是这样的
	 *  窗口——它门控 LeftSideToolBar.as:397-432 checkFreeGiftAutoPop()
	 *  整条自动强弹子链（图标动画 + bit_flag 自动弹窗），snapshot 的
	 *  serverTime（1794915896 ≈ 2026）远在窗外，该子链在本部署必死。
	 *  结论必须把「autopop 子链死（2012 窗口过期）、手动入口活」分开写，
	 *  不能只引相邻的 :115 freeGiftTime（纯展示串）了事。 */
	public function test_gifts_note_has_autopop_gate_analysis() {
		var note = triageNotes().gifts;
		// issue #67 点名项「活动窗口是否过期」：autopop 配置行与功能门
		assertContains(note, [
			"freeGiftAutopop",
			"nc_addon.php:114"
		], "issue #67 活动窗口：nc_addon.php:114 freeGiftAutopop 是功能性日期门（review-impl 驳回点）");
		// 子链证据：门控的消费代码与窗口比对（LeftSideToolBar.as:417/422/425-431）
		assertContains(note, [
			"checkFreeGiftAutoPop",
			"serverTime"
		], "issue #67 autopop 子链：LeftSideToolBar.as checkFreeGiftAutoPop 按 serverTime 比对窗口（review-impl 驳回点）");
	}

	/** autopop 子链的活跃判定必须落到「死/活」结论上：snapshot 基线
	 *  serverTime=1794915896（initialized.sql:5718、tools/nodeboot/
	 *  fixtures/mync-user-run.json:18 同值）≈2026-11-17 远在 2012-09-03
	 *  窗外——强弹子链在本部署必死；手动点击入口无日期门不受影响，故
	 *  总判定仍是链路活。结论须把这条「子链死、手动活」分开表态。 */
	public function test_gifts_note_autopop_verdict_distinguishes_dead_subechain() {
		var note = triageNotes().gifts;
		// issue #67：活跃判定须覆盖 autopop 子链的死因（窗口过期）——
		// 出现「强弹」字样且与「死/窗外/过期」语义同现，证明不是只引
		// freeGiftTime 展示串了事（review-impl：:115 是纯展示、:114 才是门）
		var hasAutopopVerdict = note.indexOf("强弹") >= 0
			&& (note.indexOf("窗外") >= 0 || note.indexOf("过期") >= 0 || note.indexOf("必死") >= 0);
		Assert.isTrue(hasAutopopVerdict, "gifts_v_11 活跃判定须含 autopop 强弹子链窗口过期的死活结论（issue #67 活动窗口点名项，review-impl 驳回点）；实际: " + note);
	}

	// ------------------------------------------------------- farmui_full_v_40
	// 事实锚点：
	//   引用出处：nc_main.php:11 <material url=".../farmui_full_v_40.swf"
	//     statusText="加载UI素材..."/>——main 的 material 素材预载（URL 表
	//     配置 key，非代码硬引用；issue #67 要求区分两者）；
	//   207 DoABC 定性（legacy/decompiled/farmui_full_v_40/scripts/ 207 类
	//     逐类核过，2026-11-25 按文件逐一复查）：189/207 纯空壳 stub（构造体
	//     仅 super()、零帧脚本零方法零逻辑）= 172 件带 [Embed] 标记的 IDE
	//     库符号自动空壳 + 17 件不带 Embed 的 SimpleButton 纯按钮壳
	//     （Tool*/CameraButton/OneClickHand/Renewal 族，extends SimpleButton
	//     无需 Embed）；其余 18 件全部带 addFrameScript 登记即帧脚本族
	//     （18 件同时也带 [Embed]——两集合不互斥，Embed 总数 190=172+18）：
	//     12 件纯 stop 壳（frame1=stop() 同型光标族/特效 11 件 +
	//     farmui_full_1_fla/lock_mc_46，CursorArrow 双帧各 stop 变体）、
	//     3 件时间轴行为件（MaoPaoFlag.as frame24 写文本+stop、FarmLoading.as
	//     frame48 gotoAndPlay("loop") 回绕、GiftIcon.as frame42 循环）、
	//     2 件真活代码在 18 件帧脚本族之内（唯一带监听的 PackageTab.as
	//     三页签 CLICK → gotoAndStop+dispatch、唯一带业务方法的
	//     FarmInfoPlus.as 地块信息提示版面）。
	//     即「量级异常」= Flash IDE 自动 stub 涨量，不是隐藏的半个模块。
	//     【2026-11-25 修正】原注释写「177 个 [Embed] 空壳 stub」——实测
	//     Embed 纯壳是 172 件（177 在任何口径下都不成立：Embed 总数 190、
	//     纯壳总数 189、Embed 纯壳 172），见同文件新增的计数钉板测试；
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
		], "issue #67 207 DoABC 定性：172 Embed 纯壳+17 SimpleButton 纯壳=189 纯壳、18 帧脚本族、PackageTab、farmui2 同族挂 #58");
	}

	public function test_farmui_full_note_has_grading_recommendation() {
		var note = triageNotes().farmuiFull;
		var hasGrading = note.indexOf("立项") >= 0 || note.indexOf("冻结") >= 0 || note.indexOf("牧场批次") >= 0 || note.indexOf("#58") >= 0;
		Assert.isTrue(hasGrading, "farmui_full_v_40 考证结论须含定级建议（issue #67 三选一或归 #58 帧脚本族）；实际: " + note);
	}

	/** review-impl（2026-11-25）驳回点钉板：成分计数必须自洽且与反编译
	 *  实测吻合。2026-11-25 按 legacy/decompiled/farmui_full_v_40/scripts/
	 *  207 个 .as 逐文件复查（grep [Embed / addFrameScript 全覆盖）：
	 *    207 = 172（带 [Embed] 纯空壳）+ 17（不带 Embed 的 SimpleButton
	 *          纯按钮壳）+ 18（addFrameScript 帧脚本族）；
	 *    纯空壳总数 189 = 172 + 17；
	 *    Embed 总数 190 = 172（纯壳）+ 18（帧脚本件全带 Embed，两集合不互斥）。
	 *  write-tests 初版注释写「177 个 [Embed] 空壳 stub」、implement 初版
	 *  结论写「206/207 是纯 stub」「190 件带 [Embed]」——206/177 在任何
	 *  口径下都不成立（review-impl 原文）。本测试钉死正确计数，三个数字
	 *  （189/172/17/18/190）必须在结论里自洽同现，错误数字（206/177）
	 *  不许出现。 */
	/** 词边界感知的数字匹配：裸子串 "17" 会被 "172"/"170" 之类吞掉
	 *  （172 含 17），裸 "18" 会被 "180"/"118" 吞掉——成分计数钉板必须
	 *  断言的是**独立数字**（前后非数字字符），不是子串。 */
	static function hasStandaloneNumber(text:String, num:String):Bool {
		var idx = -1;
		var from = 0;
		while ((idx = text.indexOf(num, from)) >= 0) {
			var beforeOk = idx == 0 || !isDigit(text.charAt(idx - 1));
			var afterIdx = idx + num.length;
			var afterOk = afterIdx >= text.length || !isDigit(text.charAt(afterIdx));
			if (beforeOk && afterOk)
				return true;
			from = idx + 1;
		}
		return false;
	}

	static function isDigit(c:String):Bool {
		if (c == null || c.length == 0)
			return false;
		var code = c.charCodeAt(0);
		return code >= 48 && code <= 57;
	}

	public function test_farmui_full_note_counts_are_self_consistent() {
		var note = triageNotes().farmuiFull;
		// issue #67 207 DoABC 定性（review-impl 驳回点）——正确计数必须同现。
		// 189/172 用子串即可（无更长数字含它们作前缀歧义）；17/18 必须词边界
		// 匹配——否则 "172" 里的子串 "17" 会让「没提 17 件 SimpleButton 壳」
		// 的错误结论也蒙混过关。
		assertContains(note, [
			"189",
			"172"
		], "issue #67 成分计数（2026-11-25 逐文件实测）：189 纯壳、172 Embed 纯壳");
		Assert.isTrue(hasStandaloneNumber(note, "17"), "farmui_full 结论须含独立数字 17（17 件不带 Embed 的 SimpleButton 纯按钮壳，2026-11-25 实测）——不许被 172 的子串蒙混；实际: " + note);
		Assert.isTrue(hasStandaloneNumber(note, "18"), "farmui_full 结论须含独立数字 18（18 件 addFrameScript 帧脚本族，2026-11-25 实测）——不许被 180/118 的子串蒙混；实际: " + note);
		// 错误计数不许出现（206/177 在任何口径下都不成立，review-impl 原文）
		Assert.isFalse(note.indexOf("206") >= 0, "farmui_full 结论不许出现错误计数 206（实测纯壳 189，review-impl 驳回点）；实际: " + note);
		Assert.isFalse(note.indexOf("177") >= 0, "farmui_full 结论不许出现错误计数 177（实测 Embed 纯壳 172，review-impl 驳回点）；实际: " + note);
	}

	/** Embed 总数的自洽关系：18 件帧脚本类全部也带 [Embed]（两个集合
	 *  不互斥），故 Embed 总数 190 = 172 纯壳 + 18 帧脚本件。结论若提
	 *  Embed 总数必须是 190 且讲清与帧脚本族的重叠——否则「172 Embed
	 *  纯壳 + 18 帧脚本 + 190 Embed 总数」三个数字放在一起会自相矛盾
	 *  （172+18=190 恰是重叠解释，漏掉重叠就成了 172+18+190=380 > 207
	 *  的荒谬）。review-impl 要求计数「自洽」。 */
	public function test_farmui_full_note_embed_overlap_explained() {
		var note = triageNotes().farmuiFull;
		// issue #67：若提 Embed 总数，必须是实测的 190 且带出重叠解释
		if (note.indexOf("190") >= 0) {
			var hasOverlap = note.indexOf("不互斥") >= 0 || note.indexOf("重叠") >= 0 || note.indexOf("172") >= 0;
			Assert.isTrue(hasOverlap, "farmui_full 提 Embed 总数 190 须讲清与 18 帧脚本族的重叠（190=172 纯壳+18 帧脚本件，2026-11-25 实测）；实际: " + note);
		} else {
			Assert.isTrue(true, "未提 Embed 总数——本条件式断言恒过（计数齐全性由 test_farmui_full_note_counts_are_self_consistent 钉）");
		}
	}

	/** 帧脚本族内部结构（2026-11-25 逐文件实测，18 件分三档）：12 件纯
	 *  stop 壳（frame1=stop() 同型光标族/特效 11 件 + farmui_full_1_fla/
	 *  lock_mc_46，CursorArrow 双帧各 stop 变体）、3 件时间轴行为件
	 *  （MaoPaoFlag.as:17 addFrameScript(0,frame1,23,frame24) frame24 写
	 *  文本+stop、FarmLoading.as:12 frame48 gotoAndPlay("loop") 回绕、
	 *  GiftIcon.as:12 frame42 循环）、2 件真活代码在 18 件帧脚本族之内
	 *  （唯一带监听的 PackageTab.as:28-48 CLICK、唯一带业务方法的
	 *  FarmInfoPlus.as:48/90 setInfo/setOutput）。review-impl 特别强调
	 *  「PackageTab/FarmInfoPlus 本身就在 18 件帧脚本族之内」——不许写成
	 *  帧脚本族之外的额外活代码（那样 18+2=20 超出帧脚本总数）。 */
	public function test_farmui_full_note_framescript_taxonomy() {
		var note = triageNotes().farmuiFull;
		// issue #67 207 DoABC 定性：两件活代码须定位为帧脚本族之内
		assertContains(note, [
			"PackageTab",
			"FarmInfoPlus",
			"MaoPaoFlag"
		], "issue #67 帧脚本族成分：PackageTab/FarmInfoPlus 活代码 + MaoPaoFlag 时间轴行为件（2026-11-25 逐文件实测）");
		// review-impl：活代码在 18 件帧脚本族之内，不是额外的——结论须带
		// 「之内/其中/帧脚本族」的归属表述，不许把两者写成帧脚本族外的补充
		var hasWithinFramescript = note.indexOf("帧脚本族之内") >= 0 || note.indexOf("帧脚本族") >= 0;
		Assert.isTrue(hasWithinFramescript, "farmui_full 结论须把 PackageTab/FarmInfoPlus 定位为 18 件帧脚本族之内（review-impl：非额外活代码）；实际: " + note);
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
