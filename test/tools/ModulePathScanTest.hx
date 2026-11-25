package tools;

import sys.io.File;
import tools.ModulePathScan.ModuleConflict;
import tools.ModulePathScan.ModuleEntry;
import utest.Assert;

/**
 * issue #70 机器门收口之二：跨树重复模块路径扫描的纯逻辑（write-tests 阶
 * 段对 stub 失败）。被测 tools.ModulePathScan 只做枚举/解析/查重纯逻辑—
 * —走目录、exit 码、报告首尾行归脚本侧（tools/scan_module_paths.py 或
 * Haxe 胶水，implement 选型），不在本测试面。stub 在 tools/tools/
 * ModulePathScan.hx（「stub 归树」规矩，implement 原地填充）。
 *
 * 期望值出处（原版没有的工具，全部 // issue #70）：
 * - 模块路径定义：issue 交付物 2 原文「模块路径 = 包声明 + 文件名
 *   （package tools; 的 tools/xx.hx → tools.xx；tools/tools/xx.hx →
 *   tools.xx——两棵树都能产出 tools.xx）」——与文件在哪个目录无关，只
 *   看包声明与文件名。
 * - 冲突判定：issue 原文「枚举三棵树全部 .hx 的模块路径，重复（同一模
 *   块路径出现在 >1 文件）即退出码 1，输出冲突对 + 各自文件」。
 * - 机制背景（为什么重复是事故）：issue 原文「Haxe 对跨 classpath 的同
 *   名模块静默按 -cp 顺序取先者——不报错」；69 资产门禁的
 *   test/tools/import.hx 靠相邻机制活着（t3.TimelineSpec 与
 *   tools.TimelineSpec 是**两个模块**的协作，模块路径不同，不在命中面——
 *   issue 原文钉死「两者模块路径不重复，不豁免也通过」）。
 * - 干净基线：issue 验收「当前 main 三棵树运行 → 0 冲突（干净基线）；
 *   人为复制一个同名模块 → 报」——2026-11-25 全库实测枚举 1063 个 .hx
 *   （test 127 + tools 35 + src 901）零重复，含两个 import.hx 先例对
 *   （test/import.hx 根包 → import；test/tools/import.hx 包 tools →
 *   tools.import，模块路径不同不撞）。
 */
class ModulePathScanTest {
	public function new() {}

	static function fixtureLines(path:String):Array<String> {
		var lines = File.getContent(path).split("\n");
		if (lines.length > 0 && lines[lines.length - 1] == "") lines.pop(); // 尾换行
		return lines;
	}

	static function entry(path:String, lines:Array<String>):ModuleEntry {
		return {path: path, lines: lines};
	}

	static function synthetic(path:String, pack:String):ModuleEntry {
		// 合成最小文件行集：package 声明 + 空类体（模块路径解析只看 package
		// 行与文件名，类内容不参与）
		var lines = pack == "" ? [] : ["package " + pack + ";"];
		return entry(path, lines);
	}

	// ---- parsePackage：包声明解析 ----

	function test_parse_package_normal() {
		Assert.equals("tools", ModulePathScan.parsePackage(["package tools;", "", "class Foo {}"]));
		Assert.equals("com.qzone.qui.makers", ModulePathScan.parsePackage(["package com.qzone.qui.makers;"]));
	}

	function test_parse_package_empty_is_root() {
		// `package;`（空包声明）与无 package 声明同为根包 ""
		Assert.equals("", ModulePathScan.parsePackage(["package;", "class Foo {}"]));
		Assert.equals("", ModulePathScan.parsePackage(["class Foo {}"]));
		Assert.equals("", ModulePathScan.parsePackage([]));
	}

	function test_parse_package_tolerates_leading_whitespace_and_comments() {
		// 仓里真实形态：文件头注释/版权行在前，package 不在第一行也要取到
		// （src/ 的 FS_ 一族符号类文件头有 FFDec 注释行）
		var lines = [
			"// decompiled header comment",
			"",
			"package framework.base;",
			"",
			"class Controller {}"
		];
		Assert.equals("framework.base", ModulePathScan.parsePackage(lines));
	}

	function test_parse_package_line_comment_not_a_declaration() {
		// `// package foo;` 是注释不是声明（行注释剔除后判，stub 类头契约）
		Assert.equals("", ModulePathScan.parsePackage(["// package foo;", "class Foo {}"]));
		// 但同行 `//` 之后的内容不算：`package a; // comment` 仍是 a
		Assert.equals("a", ModulePathScan.parsePackage(["package a; // trailing comment"]));
	}

	function test_parse_package_first_statement_wins() {
		// 取第一个 package 语句（合法 Haxe 文件只有一个，防御性规则）
		Assert.equals("first", ModulePathScan.parsePackage(["package first;", "package second;"]));
	}

	function test_parse_package_real_files() {
		// 真实文件锚点（2026-11-25 在库实测，出处见类头模块路径定义条）：
		// tools 树的 tools.CppTyperPlan 与 test 树的 tools.TimelineTypes
		// 同包不同模块——包声明都是 tools，模块路径靠文件名区分
		Assert.equals("tools", ModulePathScan.parsePackage(fixtureLines("tools/tools/CppTyperPlan.hx")));
		Assert.equals("tools", ModulePathScan.parsePackage(fixtureLines("test/tools/TimelineTypes.hx")));
		Assert.equals("t3", ModulePathScan.parsePackage(fixtureLines("test/t3/TimelineSpec.hx")));
		// 根包先例：src/ 符号类与 test/TestMain.hx 无 package 声明
		Assert.equals("", ModulePathScan.parsePackage(fixtureLines("src/FS_02_1_2.hx")));
		Assert.equals("", ModulePathScan.parsePackage(fixtureLines("test/TestMain.hx")));
		// 两个 import.hx 先例对：根包 vs 包 tools（模块路径不同不撞，见类头）
		Assert.equals("", ModulePathScan.parsePackage(fixtureLines("test/import.hx")));
		Assert.equals("tools", ModulePathScan.parsePackage(fixtureLines("test/tools/import.hx")));
	}

	// ---- moduleNameOf / modulePathOf ----

	function test_module_name_strips_hx_and_directory() {
		Assert.equals("TimelineSpec", ModulePathScan.moduleNameOf("TimelineSpec.hx"));
		Assert.equals("TimelineSpec", ModulePathScan.moduleNameOf("test/tools/TimelineSpec.hx"));
		Assert.equals("import", ModulePathScan.moduleNameOf("test/tools/import.hx"));
	}

	function test_module_path_joining() {
		// // issue #70 原文定义：包声明 + 文件名；根包无点前缀
		Assert.equals("tools.TimelineSpec", ModulePathScan.modulePathOf("tools", "test/tools/TimelineSpec.hx"));
		Assert.equals("t3.TimelineSpec", ModulePathScan.modulePathOf("t3", "test/t3/TimelineSpec.hx"));
		Assert.equals("TestMain", ModulePathScan.modulePathOf("", "test/TestMain.hx"));
		Assert.equals("FS_02_1_2", ModulePathScan.modulePathOf("", "src/FS_02_1_2.hx"));
		Assert.equals("tools.import", ModulePathScan.modulePathOf("tools", "test/tools/import.hx"));
		Assert.equals("import", ModulePathScan.modulePathOf("", "test/import.hx"));
	}

	// ---- issue 原文钉死的同名模块路径对（两棵树都能产出 tools.xx） ----

	function test_issue_example_pair_same_module_path() {
		// // issue #70 原文举例：「package tools; 的 tools/xx.hx → tools.xx；
		// tools/tools/xx.hx → tools.xx」——目录不同、模块路径相同
		var a = synthetic("tools/xx.hx", "tools");
		var b = synthetic("tools/tools/xx.hx", "tools");
		Assert.equals(ModulePathScan.modulePathOf("tools", "tools/xx.hx"),
			ModulePathScan.modulePathOf("tools", "tools/tools/xx.hx"));
		var conflicts = ModulePathScan.findConflicts([a, b]);
		Assert.equals(1, conflicts.length);
		Assert.equals("tools.xx", conflicts[0].modulePath);
		Assert.same(["tools/tools/xx.hx", "tools/xx.hx"], conflicts[0].files); // 字典序
	}

	// ---- findConflicts：冲突枚举 ----

	function test_no_conflict_when_all_unique() {
		// 干净基线形状：模块路径全异 → 零冲突
		var entries = [
			synthetic("test/tools/TimelineSpec.hx", "tools"),
			synthetic("test/t3/TimelineSpec.hx", "t3"),
			synthetic("tools/tools/CppTyperPlan.hx", "tools"),
			synthetic("src/FS_02_1_2.hx", ""),
		];
		Assert.equals(0, ModulePathScan.findConflicts(entries).length);
	}

	function test_t3_zombie_pair_is_not_a_conflict() {
		// issue 原文先例钉死：t3.TimelineSpec（实现）与 tools.TimelineSpec
		// （僵尸 stub）模块路径不同，import 遮蔽是**两个模块**的协作，不在
		// 命中面——「两者模块路径不重复，不豁免也通过」
		var entries = [
			entry("test/t3/TimelineSpec.hx", fixtureLines("test/t3/TimelineSpec.hx")),
			entry("test/tools/TimelineSpec.hx", fixtureLines("test/tools/TimelineSpec.hx")),
		];
		Assert.equals(0, ModulePathScan.findConflicts(entries).length);
	}

	function test_two_import_hx_precedent_is_not_a_conflict() {
		// 2026-11-25 在库实测先例对：test/import.hx（根包 → import）与
		// test/tools/import.hx（包 tools → tools.import）不撞（干净基线
		// 的组成部分）
		var entries = [
			entry("test/import.hx", fixtureLines("test/import.hx")),
			entry("test/tools/import.hx", fixtureLines("test/tools/import.hx")),
		];
		Assert.equals(0, ModulePathScan.findConflicts(entries).length);
	}

	function test_conflict_detected_cross_tree() {
		// issue 验收「人为复制一个同名模块 → 报」的形状：tools/tools/ 与
		// test/tools/ 各有一个 TimelineTypes.hx（包都是 tools）→ 撞
		var entries = [
			synthetic("tools/tools/TimelineTypes.hx", "tools"),
			synthetic("test/tools/TimelineTypes.hx", "tools"),
		];
		var conflicts = ModulePathScan.findConflicts(entries);
		Assert.equals(1, conflicts.length);
		Assert.equals("tools.TimelineTypes", conflicts[0].modulePath);
		Assert.same(["test/tools/TimelineTypes.hx", "tools/tools/TimelineTypes.hx"], conflicts[0].files);
	}

	function test_conflict_detected_within_single_tree() {
		// 树内重复同样是冲突（同一 classpath 内 Haxe 也按搜索序静默取先
		// 者——issue「重复（同一模块路径出现在 >1 文件）」不区分树内树间）
		var entries = [
			synthetic("src/a/Dup.hx", "shim"),
			synthetic("src/b/Dup.hx", "shim"),
		];
		var conflicts = ModulePathScan.findConflicts(entries);
		Assert.equals(1, conflicts.length);
		Assert.equals("shim.Dup", conflicts[0].modulePath);
		Assert.same(["src/a/Dup.hx", "src/b/Dup.hx"], conflicts[0].files);
	}

	function test_conflict_detected_in_root_package() {
		// 根包同名文件也撞（src/ 一层符号类形态：FS_x 一族模块路径即文件名）
		var entries = [
			synthetic("src/Foo.hx", ""),
			synthetic("test/Foo.hx", ""),
		];
		var conflicts = ModulePathScan.findConflicts(entries);
		Assert.equals(1, conflicts.length);
		Assert.equals("Foo", conflicts[0].modulePath);
		Assert.same(["src/Foo.hx", "test/Foo.hx"], conflicts[0].files);
	}

	function test_same_filename_different_packages_no_conflict() {
		// 文件名同、包不同 → 模块路径不同 → 不撞（t3/tools 先例的合成推广）
		var entries = [
			synthetic("a/TimelineTypes.hx", "t3"),
			synthetic("b/TimelineTypes.hx", "tools"),
		];
		Assert.equals(0, ModulePathScan.findConflicts(entries).length);
	}

	function test_three_way_conflict_single_group() {
		// 三方撞车归一组（同一模块路径 >1 文件——不按对拆组）
		var entries = [
			synthetic("src/x/Dup.hx", "dup"),
			synthetic("test/x/Dup.hx", "dup"),
			synthetic("tools/x/Dup.hx", "dup"),
		];
		var conflicts = ModulePathScan.findConflicts(entries);
		Assert.equals(1, conflicts.length);
		Assert.equals(3, conflicts[0].files.length);
		Assert.same(["src/x/Dup.hx", "test/x/Dup.hx", "tools/x/Dup.hx"], conflicts[0].files);
	}

	function test_multiple_conflicts_sorted_by_module_path() {
		// 组间按模块路径字典序、组内文件字典序（报告可 diff 对拍）
		var entries = [
			synthetic("src/b/Zed.hx", "zed"),
			synthetic("src/a/Zed.hx", "zed"),
			synthetic("src/a/Aaa.hx", "aaa"),
			synthetic("src/b/Aaa.hx", "aaa"),
		];
		var conflicts = ModulePathScan.findConflicts(entries);
		Assert.equals(2, conflicts.length);
		Assert.equals("aaa.Aaa", conflicts[0].modulePath);
		Assert.equals("zed.Zed", conflicts[1].modulePath);
		Assert.same(["src/a/Aaa.hx", "src/b/Aaa.hx"], conflicts[0].files);
		Assert.same(["src/a/Zed.hx", "src/b/Zed.hx"], conflicts[1].files);
	}

	function test_empty_input_no_conflicts() {
		Assert.equals(0, ModulePathScan.findConflicts([]).length);
	}

	function test_find_conflicts_real_repo_trees_baseline() {
		// issue 验收「当前 main 三棵树运行 → 0 冲突（干净基线）」的测试面
		// 锚点：真实在库文件的抽样枚举（全量枚举归脚本侧；这里把**最可能
		// 撞的几对先例**一起过——tools 树与 test 树的 tools 包文件、根包
		// import 对、t3/tools zombie 对、src 根包符号类抽样）
		var entries = [
			entry("tools/tools/CppTyperPlan.hx", fixtureLines("tools/tools/CppTyperPlan.hx")),
			entry("tools/tools/TimelineExtract.hx", fixtureLines("tools/tools/TimelineExtract.hx")),
			entry("tools/tools/BaselineFile.hx", fixtureLines("tools/tools/BaselineFile.hx")),
			entry("test/tools/TimelineTypes.hx", fixtureLines("test/tools/TimelineTypes.hx")),
			entry("test/tools/TimelineSpec.hx", fixtureLines("test/tools/TimelineSpec.hx")),
			entry("test/tools/TimelineDiff.hx", fixtureLines("test/tools/TimelineDiff.hx")),
			entry("test/t3/TimelineSpec.hx", fixtureLines("test/t3/TimelineSpec.hx")),
			entry("test/t3/TimelineDiff.hx", fixtureLines("test/t3/TimelineDiff.hx")),
			entry("test/import.hx", fixtureLines("test/import.hx")),
			entry("test/tools/import.hx", fixtureLines("test/tools/import.hx")),
			entry("src/FS_02_1_2.hx", fixtureLines("src/FS_02_1_2.hx")),
			entry("tools/StepAnimate.hx", fixtureLines("tools/StepAnimate.hx")),
		];
		var conflicts = ModulePathScan.findConflicts(entries);
		Assert.equals(0, conflicts.length,
			"在库抽样须零冲突（干净基线锚点），实中 " + [for (c in conflicts) c.modulePath].join(","));
	}

	// ---- renderConflict：人读报告形状 ----

	function test_render_conflict_shape() {
		// 每组首行模块路径、随后每文件一行缩进列出——脚本侧逐行打出
		var lines = ModulePathScan.renderConflict({
			modulePath: "tools.TimelineTypes",
			files: ["test/tools/TimelineTypes.hx", "tools/tools/TimelineTypes.hx"]
		});
		Assert.equals(3, lines.length);
		Assert.isTrue(lines[0].indexOf("tools.TimelineTypes") >= 0, "首行含模块路径");
		Assert.isTrue(lines[1].indexOf("test/tools/TimelineTypes.hx") >= 0, "次行含首文件");
		Assert.isTrue(lines[2].indexOf("tools/tools/TimelineTypes.hx") >= 0, "三行含次文件");
		// 文件行有缩进（与首行层级可辨）
		Assert.isTrue(StringTools.startsWith(lines[1], " ") || StringTools.startsWith(lines[1], "\t"),
			"文件行须缩进");
	}
}
