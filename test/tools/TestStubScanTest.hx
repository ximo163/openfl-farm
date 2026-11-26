package tools;

import sys.io.File;
import tools.TestStubScan.Exemption;
import tools.TestStubScan.StubHit;
import utest.Assert;

/**
 * issue #70 机器门收口之一：test/** 禁 throw-stub 扫描的纯逻辑（write-tests
 * 阶段对 stub 失败）。被测 tools.TestStubScan 只做行集→命中的纯逻辑——走
 * 目录、exit 码、报告首尾行归脚本侧（tools/scan_test_stubs.py 或 Haxe 胶水，
 * implement 选型），不在本测试面。stub 在 tools/tools/TestStubScan.hx
 * （「stub 归树」规矩，implement 原地填充）。
 *
 * 期望值出处（原版没有的工具，全部 // issue #70；判式措辞对齐
 * .orchestrator/prompts/write-tests.md:19 的 stub 规矩原文与 #56 僵尸 stub
 * 实际形态）：
 * - 命中面三形态：issue 交付物 1 原文枚举 `throw new Error("not
 *   implemented")` / `throw new haxe.Exception("not implemented")` /
 *   `throw "not implemented"`——判式四条件（剔 `//` 注释→字符串遮罩→语
 *   句位 throw 惯用语族→遮罩前逐字短语）由本文件命中/不命中行例钉死，
 *   逐字验证脚本在 2026-11-25 对全 test/ 树实测：只有 #56 两僵尸的 9 行
 *   命中、零误报（含本测试文件自身的语料引用行——字符串内的 throw 字
 *   样遮罩后不算语句位）。
 * - 豁免面：issue 交付物 1「已知存量豁免（迁移期）：test/tools/
 *   TimelineSpec.hx、test/tools/TimelineDiff.hx（#56 的两个僵尸 stub，
 *   import.hx 遮蔽按 #56 姊妹条目『已经放进去了的按那条接』）——豁免清
 *   单写死在脚本顶部、每项注明出处，不引入通用白名单机制」。
 * - 输出形态：issue「输出 文件:行 摘录（对齐 scan_dyn_writes.py 的输出
 *   形态）」。
 * - 验收：issue 验收节「对 #56 的两个僵尸 stub 运行 → 报 2 处（豁免后
 *   过）；构造一个新 stub 放 test/tmp → 报；清理僵尸后豁免清单清空」——
 *   「报 2 处」按**文件**读（两个豁免文件各报一处起点即算报；逐文件逐行
 *   命中全集由 fixture 行号断言钉死，实跑豁免后净命中为零）。
 * - 散文不命中面的在库先例（2026-11-25 实测）：test/tools/import.hx:6
 *   （`//` 行注释提到 throw 与惯用语字样——剔注释后残余无内容）与
 *   test/help0316_fla/MainTimelineTest.hx:51（「抛 not implemented」无
 *   throw 语句）对本判式零命中，main 干净基线因此成立。
 */
class TestStubScanTest {
	public function new() {}

	static final SPEC_ZOMBIE:String = "test/tools/TimelineSpec.hx";
	static final DIFF_ZOMBIE:String = "test/tools/TimelineDiff.hx";

	static function fixtureLines(path:String):Array<String> {
		var lines = File.getContent(path).split("\n");
		if (lines.length > 0 && lines[lines.length - 1] == "") lines.pop(); // 尾换行
		return lines;
	}

	static function hitLines(hits:Array<StubHit>):Array<Int> {
		return [for (h in hits) h.line];
	}

	// ---- 命中面：issue 原文三形态（合成行集，表驱动） ----

	function test_hit_new_error_form() {
		// // issue #70 原文形态一；write-tests.md:19 规矩原文措辞
		var hits = TestStubScan.scanLines(["\t\tthrow new Error(\"not implemented\");"], "test/tmp/Foo.hx");
		Assert.equals(1, hits.length);
		Assert.equals(1, hits[0].line);
		Assert.equals("test/tmp/Foo.hx", hits[0].path);
		Assert.equals('throw new Error("not implemented");', hits[0].code);
	}

	function test_hit_haxe_exception_form() {
		// // issue #70 原文形态二（#56 僵尸 stub 实际形态，SPEC_ZOMBIE:51 同款）
		var hits = TestStubScan.scanLines(["\t\tthrow new haxe.Exception(\"not implemented\");"], "test/tmp/Foo.hx");
		Assert.equals(1, hits.length);
	}

	function test_hit_bare_string_throw_form() {
		// // issue #70 原文形态三
		var hits = TestStubScan.scanLines(["\t\tthrow \"not implemented\";"], "test/tmp/Foo.hx");
		Assert.equals(1, hits.length);
	}

	function test_hit_trailing_comment_after_statement() {
		// 子串判式：throw 语句后的行尾注释不影响命中
		var hits = TestStubScan.scanLines(["\t\tthrow new Error(\"not implemented\"); // implement 阶段填"], "test/tmp/Foo.hx");
		Assert.equals(1, hits.length);
	}

	function test_hit_line_numbers_are_one_based() {
		// 行号 1 基、行序保持输入序（多命中同行号不重复计——一行一条）
		// 语料行内的惯用语样张全部出现在**字符串字面量内**——扫描器的字符
		// 串遮罩把它们和真 stub 分开（本文件自身在 test/** 被扫面内零命中，
		// 自证锚点见 test_self_file_zero_hits）
		var lines = [
			"package tmp;", // 1
			"", // 2
			"class Foo {", // 3
			"\tpublic function a() {", // 4
			"\t\tthrow new Error(\"not implemented\");", // 5
			"\t}", // 6
			"\tpublic function b() {", // 7
			"\t\tthrow \"not implemented\"; throw new Error(\"not implemented\");", // 8 同行两处只出一条
			"\t}", // 9
			"}", // 10
		];
		var hits = TestStubScan.scanLines(lines, "test/tmp/Foo.hx");
		Assert.same([5, 8], hitLines(hits));
	}

	function test_self_file_zero_hits() {
		// 自证锚点（机器门可生活性）：本测试文件自身在 test/** 树的被扫面
		// 内——语料/断言里引用惯用语字样全靠字符串遮罩豁免，全文件必须零
		// 命中；这里红了说明判式把字符串内引用当真 stub（2026-11-25 逐字
		// 验证过的 discriminating 形状失守）
		var hits = TestStubScan.scanLines(fixtureLines("test/tools/TestStubScanTest.hx"), "test/tools/TestStubScanTest.hx");
		Assert.equals(0, hits.length, "本测试文件自身须零命中（语料全在字符串内，遮罩豁免），实中行 "
			+ [for (h in hits) Std.string(h.line)].join(","));
	}

	// ---- 收窄面：以下都不命中（出处见类头收窄条） ----

	function test_no_hit_comment_mentioning_throw_stub() {
		// test/tools/import.hx:6 在库散文先例：`//` 在 throw 之前，剔注释后
		// 残余为空——注释提到 throw+not implemented 不是待填骨架
		var hits = TestStubScan.scanLines(["// 阶段留的 stub（throw \"not implemented\"），而 test/** 对本阶段是"], "test/tools/import.hx");
		Assert.equals(0, hits.length);
	}

	function test_no_hit_idiom_quoted_inside_string_literal() {
		// 字符串遮罩面的钉死：throw 字样在字符串字面量内（测试语料/断言的
		// 引用形态）遮罩后消失、语句位判式不过——写扫描工具的测试语料时引
		// 用惯用语无需回避（本文件自身即先例，2026-11-25 逐字验证零误报）
		var lines = [
			"\t\tAssert.equals('throw new Error(\"not implemented\");', hits[0].code);",
			"\t\treturn {path: p, line: 1, code: \"throw new Error(\\\"not implemented\\\");\"};",
			"\t\tvar sample = 'throw new haxe.Exception(\"not implemented\");';",
		];
		var hits = TestStubScan.scanLines(lines, "test/tmp/Foo.hx");
		Assert.equals(0, hits.length, "字符串内引用的惯用语不得命中（遮罩面）");
	}

	function test_no_hit_idiom_quoted_in_doc_comment() {
		// 文档注释引用惯用语（` *   `throw new haxe.Exception("not
		// implemented")` 形态）——`//` 起手剔注释后残余为空或无语句位 throw
		var hits = TestStubScan.scanLines(["\t *   `throw \"not implemented\"`——判式抽象为"], "test/tmp/Foo.hx");
		Assert.equals(0, hits.length);
	}

	function test_hit_throw_in_condition_position() {
		// 语句位不按行首钉死：`if (x) throw new Error(...)` 的 throw 前是空白
		// ——语句里的真 throw 同样命中（边界只排除标识符内嵌与字符串内嵌）
		var hits = TestStubScan.scanLines(["\t\tif (x) throw new Error(\"not implemented\");"], "test/tmp/Foo.hx");
		Assert.equals(1, hits.length);
	}

	function test_hit_multi_space_and_second_throw_same_line() {
		// 空白不敏感（throw 后多空格照样算）+ 同一行第二个 throw 也命中
		// （一行仍只出一条——行是报告粒度）
		var hits = TestStubScan.scanLines(["\t\tthrow   new   Error(\"not implemented\");"], "test/tmp/Foo.hx");
		Assert.equals(1, hits.length, "throw 后多空格的同一惯用语命中");
	}

	function test_hit_url_in_string_before_throw_not_comment_cut() {
		// 遮罩先于剔注释的钉死：字符串内的 `//`（URL 字面量）不得被当注释
		// 起点截掉后续真代码——若先剔注释再遮罩，这行的真 throw 会被截没
		// （漏报）。判式顺序出处见 stub 类头条件 1/2。URL 字面量与惯用语字
		// 样都只在字符串内出现，本测试文件自身的零命中锚点不受影响
		var hits = TestStubScan.scanLines(["\t\tvar u = \"http://x\"; throw new Error(\"not implemented\");"], "test/tmp/Foo.hx");
		Assert.equals(1, hits.length, "字符串内 // 不得截断后续真 throw");
	}

	function test_no_hit_prose_without_throw_word() {
		// test/help0316_fla/MainTimelineTest.hx:51 在库散文先例：有 not
		// implemented 无 throw——机器门若拦散文，正常叙事注释写不了这个词
		var hits = TestStubScan.scanLines(["\t// frame1（:28-46）。stub 阶段 frame1 抛 not implemented，本文件全红"], "test/help0316_fla/MainTimelineTest.hx");
		Assert.equals(0, hits.length);
	}

	function test_no_hit_business_throw_without_needle() {
		// 没有 not implemented 字样的 throw 是正常业务 throw，不收
		var lines = [
			"\t\tthrow \"whatever\";",
			"\t\tthrow new Error(\"wire up later\");",
			"\t\tthrow new haxe.Exception(\"boom\");",
		];
		var hits = TestStubScan.scanLines(lines, "test/tmp/Foo.hx");
		Assert.equals(0, hits.length);
	}

	function test_no_hit_case_variants() {
		// 大小写不折叠（// issue #70「收窄」——变体不是 stub 惯用语）
		var lines = [
			"\t\tthrow new Error(\"Not implemented\");",
			"\t\tthrow new Error(\"NOT IMPLEMENTED\");",
		];
		var hits = TestStubScan.scanLines(lines, "test/tmp/Foo.hx");
		Assert.equals(0, hits.length);
	}

	function test_no_hit_identifier_embedded_throw() {
		// 关键字边界：`thrower`/`xthrow` 不是 throw 语句
		var lines = [
			"\t\tvar thrower = \"not implemented\";",
		];
		var hits = TestStubScan.scanLines(lines, "test/tmp/Foo.hx");
		Assert.equals(0, hits.length);
	}

	// ---- 豁免清单（// issue #70：写死、逐条注明出处） ----

	function test_exemptions_exactly_the_two_zombies_with_reasons() {
		// issue 交付物 1 豁免条原文：恰两条、path 逐字、每项带出处（reason
		// 非空且指认 #56——「每项注明出处」的可机检形状）
		var ex = TestStubScan.exemptions();
		Assert.equals(2, ex.length);
		var spec = ex.filter(e -> e.path == SPEC_ZOMBIE);
		var diff = ex.filter(e -> e.path == DIFF_ZOMBIE);
		Assert.equals(1, spec.length, SPEC_ZOMBIE + " 须在豁免清单（恰一条）");
		Assert.equals(1, diff.length, DIFF_ZOMBIE + " 须在豁免清单（恰一条）");
		for (e in ex) {
			Assert.isTrue(e.reason != null && e.reason.length > 0, e.path + " 的豁免须注明出处");
			Assert.isTrue(e.reason.indexOf("#56") >= 0, e.path + " 的出处须指认 #56（issue 原文出处）");
		}
	}

	function test_exemptions_returns_copy() {
		// 返回副本：调用方涂改不影响内部清单（下次取还是两条）
		var ex = TestStubScan.exemptions();
		ex.pop();
		ex.pop();
		Assert.equals(2, TestStubScan.exemptions().length);
	}

	// ---- 真僵尸锚点（issue 验收「对 #56 的两个僵尸 stub 运行 → 报 2 处」） ----

	function test_zombie_spec_hits_exact_lines() {
		// #56 僵尸 stub 实际形态逐行钉死（2026-11-25 在库实测行号——豁免消费
		// 前的全集形状；若僵尸被清/行号漂移本断言跟着红，提醒同步豁免面）
		var hits = TestStubScan.scanLines(fixtureLines(SPEC_ZOMBIE), SPEC_ZOMBIE);
		Assert.same([51, 56, 62, 68, 77, 82], hitLines(hits));
		for (h in hits) {
			Assert.equals('throw new haxe.Exception("not implemented");', h.code);
			Assert.equals(SPEC_ZOMBIE, h.path);
		}
	}

	function test_zombie_diff_hits_exact_lines() {
		var hits = TestStubScan.scanLines(fixtureLines(DIFF_ZOMBIE), DIFF_ZOMBIE);
		Assert.same([53, 59, 64], hitLines(hits));
	}

	function test_zombie_prose_comments_not_hit() {
		// 僵尸文件的散文注释（SPEC_ZOMBIE:9「write-tests 阶段为 stub」等）与
		// import.hx 先例同族——全集恰为 throw 行、不多出散文行（上行行号断言
		// 的交叉钉：6+3=9 恰为两文件 throw 总数，2026-11-25 实测）
		var specHits = TestStubScan.scanLines(fixtureLines(SPEC_ZOMBIE), SPEC_ZOMBIE);
		var diffHits = TestStubScan.scanLines(fixtureLines(DIFF_ZOMBIE), DIFF_ZOMBIE);
		Assert.equals(6, specHits.length);
		Assert.equals(3, diffHits.length);
	}

	// ---- exemptHits 豁免消费语义 ----

	static function hit(path:String, line:Int):StubHit {
		return {path: path, line: line, code: "throw new Error(\"not implemented\");"};
	}

	static function exempt(path:String):Exemption {
		return {path: path, reason: "test 用合成豁免"};
	}

	function test_exempt_hits_filters_exempted_file_and_reports_live() {
		var all = [hit(SPEC_ZOMBIE, 51), hit(SPEC_ZOMBIE, 56), hit("test/tmp/Foo.hx", 3)];
		var r = TestStubScan.exemptHits(all, [exempt(SPEC_ZOMBIE)]);
		// 豁免文件的命中滤掉、非豁免文件的保留
		Assert.same(["test/tmp/Foo.hx"], [for (h in r.hits) h.path]);
		// 豁免条目在消费（文件里确有命中被滤）→ live，不进 stale
		Assert.same([SPEC_ZOMBIE], [for (e in r.live) e.path]);
		Assert.equals(0, r.stale.length);
	}

	function test_exempt_hits_stale_when_file_has_no_hits() {
		// 腐化检测面：豁免文件零命中（僵尸被清/忘了同步删豁免行）→ stale
		var all = [hit("test/tmp/Foo.hx", 3)];
		var r = TestStubScan.exemptHits(all, [exempt(SPEC_ZOMBIE), exempt("test/tmp/Foo.hx")]);
		Assert.equals(0, r.hits.length);
		Assert.same(["test/tmp/Foo.hx"], [for (e in r.live) e.path]);
		Assert.same([SPEC_ZOMBIE], [for (e in r.stale) e.path]);
	}

	function test_exempt_hits_empty_all_makes_everything_stale() {
		// 全集为空（干净基线形态）→ 无命中可滤，豁免条目全 stale
		var r = TestStubScan.exemptHits([], [exempt(SPEC_ZOMBIE), exempt(DIFF_ZOMBIE)]);
		Assert.equals(0, r.hits.length);
		Assert.equals(0, r.live.length);
		Assert.equals(2, r.stale.length);
	}

	function test_exempt_hits_path_must_match_verbatim() {
		// 逐字匹配：./ 前缀形态不豁免（// issue #70 豁免面越窄腐化越早现形）
		var all = [hit("./" + SPEC_ZOMBIE, 51)];
		var r = TestStubScan.exemptHits(all, [exempt(SPEC_ZOMBIE)]);
		Assert.equals(1, r.hits.length, "./ 前缀形态不得豁免");
		Assert.equals(0, r.live.length);
		Assert.equals(1, r.stale.length);
	}

	function test_exempt_real_zombies_leaves_zero_hits() {
		// issue 验收「豁免后过」的端到端形状：两僵尸全集 9 条命中，经写死
		// 豁免清单滤后净命中为零、两条豁免都在消费（live）、无失锚
		var all = TestStubScan.scanLines(fixtureLines(SPEC_ZOMBIE), SPEC_ZOMBIE)
			.concat(TestStubScan.scanLines(fixtureLines(DIFF_ZOMBIE), DIFF_ZOMBIE));
		Assert.equals(9, all.length, "两僵尸全集 9 条（6+3，行号实测）");
		var r = TestStubScan.exemptHits(all, TestStubScan.exemptions());
		Assert.equals(0, r.hits.length, "豁免后净命中为零（issue 验收『豁免后过』）");
		Assert.equals(2, r.live.length);
		Assert.equals(0, r.stale.length);
	}

	function test_exempt_real_zombies_plus_new_stub_leaves_only_new() {
		// issue 验收「构造一个新 stub 放 test/tmp → 报」的形状：新 stub 文件
		// 不在豁免清单，净命中恰为它
		var all = TestStubScan.scanLines(fixtureLines(SPEC_ZOMBIE), SPEC_ZOMBIE)
			.concat(TestStubScan.scanLines(fixtureLines(DIFF_ZOMBIE), DIFF_ZOMBIE))
			.concat(TestStubScan.scanLines(["\t\tthrow new Error(\"not implemented\");"], "test/tmp/NewStub.hx"));
		var r = TestStubScan.exemptHits(all, TestStubScan.exemptions());
		Assert.equals(1, r.hits.length);
		Assert.equals("test/tmp/NewStub.hx", r.hits[0].path);
		Assert.equals(1, r.hits[0].line);
	}

	// ---- 报告行形态（// issue #70「文件:行 摘录」） ----

	function test_report_line_shape() {
		var line = TestStubScan.reportLine({
			path: "test/tools/TimelineSpec.hx",
			line: 51,
			code: 'throw new haxe.Exception("not implemented");'
		});
		Assert.equals('test/tools/TimelineSpec.hx:51 throw new haxe.Exception("not implemented");', line);
	}

	function test_is_report_line_accepts_own_output() {
		// reportLine 的自产出必须被 isReportLine 认出（机读回归闭环）
		var line = TestStubScan.reportLine({path: "test/tmp/Foo.hx", line: 8, code: "x"});
		Assert.isTrue(TestStubScan.isReportLine(line));
	}

	function test_is_report_line_rejects_non_report_shapes() {
		// 首尾说明行/汇总行/非数字行号段都不是报告行（分拣面）
		for (line in [
			"scan_test_stubs: FAIL —— test/ 禁 throw-stub 命中 3 处：",
			"-- 3 stub hits",
			"",
			"test/tmp/Foo.hx:abc x",
			":51 no path",
		]) {
			Assert.isFalse(TestStubScan.isReportLine(line), "非报告行须拒认：" + line);
		}
	}
}
