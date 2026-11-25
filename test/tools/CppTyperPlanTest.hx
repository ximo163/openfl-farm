package tools;

import sys.io.File;
import utest.Assert;

/**
 * issue #61 cpp typer 全量扫描——临时 hxml 变换的纯逻辑（write-tests
 * 阶段对 stub 失败）。被测 tools.CppTyperPlan 只做行集变换，不碰文件
 * （debug.hxml 的读/生成、mktemp、调 haxe 归 tools/scan_cpp_typer.sh，
 * implement 阶段交付）。stub 在 tools/tools/CppTyperPlan.hx（「stub 归树」
 * 规矩，implement 原地填充）。
 *
 * 期望值出处：
 * - recipe 本身：// issue #61（lessons #18/#29/#44 的固化，逐条坑的出处
 *   见被测类头）。
 * - golden 两侧 fixture 都是 2026-11-25 容器实测捕获：输入 = export/
 *   html5/haxe/debug.hxml 原样快照（openfl 9.5.2 html5 模板产出，尾随
 *   空格的 -main 行也在）；期望输出 = 该输入按 recipe 变换出的扫描
 *   hxml——正是实跑后判据绿的那一份（cpp-typer-pass-output.txt 是它的
 *   haxe 输出）。-cpp 取当时实跑的目录 /tmp/cppscan-c。两侧都以「行
 *   文本数组」喂给被测（29 行 − 删 13 行（-main、-js 与 11 条 html5 专属 -D，其中 -D html5 出现两次）+ 追加 2 行 = 18 行，
 *   差集已逐行核对＝恰 recipe 删改集，见下方各断言）。
 * - 注入式自检红面（在 src/FS_02_1_2.hx:14 植入 var i:Int = 0; if
 *   (i == null)，issue #61 完成标准 2 同款）：实跑输出捕获在
 *   cpp-typer-hits-output.txt，由 CppTyperVerdictTest 消费——证明这份
 *   golden hxml 的 include 真把无引用的 src 散类拉进了类型化（FS_02_1_2
 *   无任何引用者，只有 include 扫得到它）。
 * - html5 专属 -D 名单的「等」（html5×2/web/openfl-html5/lime-howlerjs/
 *   lime-canvas）：2026-11-25 容器实测，被测类头引 lime 源行；非专属
 *   -D 保留名单（版本号/lime-threads/disable_preloader_assets）同实测
 *   （golden 里同款行）。
 */
class CppTyperPlanTest {
	public function new() {}

	static final DEBUG_HXML_FIXTURE:String = "test/fixtures/cpp-typer-debug-hxml.txt";
	static final SCAN_HXML_FIXTURE:String = "test/fixtures/cpp-typer-scan-hxml.txt";
	/** golden 期望里 -cpp 的实跑目录（fixture 两侧行行相等，含这一行）。 */
	static final CPP_OUT:String = "/tmp/cppscan-c";

	static function fixtureLines(path:String):Array<String> {
		// 行文本数组约定（与脚本侧行切法一致）：按 \n 切后去掉尾换行切出的
		// 空行——被测的输入输出都是「行文本」，文件的尾换行处理归脚本侧
		// （读时同款 pop、写时 join + 换行）。中间的空行是合法行文本，
		// 透传不清洗（golden 两侧均无中间空行，透传断言见
		// test_transform_passes_unmatched_lines_through_verbatim）。
		var lines = File.getContent(path).split("\n");
		if (lines.length > 0 && lines[lines.length - 1] == "") lines.pop();
		return lines;
	}

	// ---- golden：真实 debug.hxml → 实跑判据绿的扫描 hxml ----

	function test_transform_real_debug_hxml_golden() {
		var got = CppTyperPlan.transform(fixtureLines(DEBUG_HXML_FIXTURE), CPP_OUT);
		Assert.same(fixtureLines(SCAN_HXML_FIXTURE), got);
	}

	function test_transform_golden_drops_entry_and_keeps_bootstraps() {
		// golden 的可读化断言（行行相等之外把关键不变式钉出来）：
		// -main/-js/html5 专属 -D 不在；三个 bootstrap --macro、全部
		// classpath、--remap、-debug、版本 -D 都在；恰一条 -cpp。
		var got = CppTyperPlan.transform(fixtureLines(DEBUG_HXML_FIXTURE), CPP_OUT);
		Assert.isFalse(Lambda.exists(got, l -> StringTools.startsWith(l, "-main")), "入口行须删");
		Assert.isFalse(Lambda.exists(got, l -> StringTools.startsWith(l, "-js ")), "-js 输出旗标须删");
		Assert.isFalse(Lambda.exists(got, l -> StringTools.startsWith(l, "-D html5")), "-D html5 须删");
		Assert.isFalse(Lambda.exists(got, l -> l == "-D no-compilation"), "-D no-compilation 须删（#29）");
		Assert.equals(1, got.filter(l -> StringTools.startsWith(l, "-cpp ")).length, "恰一条 -cpp");
		Assert.equals(5, got.filter(l -> StringTools.startsWith(l, "-cp ")).length, "debug.hxml 的 5 条 classpath 全保留");
		Assert.isTrue(Lambda.exists(got, l -> l == "--macro openfl.utils._internal.ExtraParamsMacro.include()"));
		Assert.isTrue(Lambda.exists(got, l -> l == "--macro lime._internal.macros.DefineMacro.run()"));
		Assert.isTrue(Lambda.exists(got, l -> StringTools.startsWith(l, "--macro haxe.macro.Compiler.addMetadata(")), "第三个 bootstrap --macro（AssetsMacro）保留");
		Assert.isTrue(Lambda.exists(got, l -> l == "--remap flash:openfl"));
		Assert.isTrue(Lambda.exists(got, l -> l == "-debug"));
		Assert.isTrue(Lambda.exists(got, l -> l == "-D openfl=9.5.2"));
		Assert.isTrue(Lambda.exists(got, l -> l == "-D lime-threads"));
		Assert.isTrue(Lambda.exists(got, l -> l == "-D disable_preloader_assets=1"));
	}

	// ---- 规则面：表驱动 ----

	function test_transform_drops_main_entry_line() {
		// recipe 去 -main ApplicationMain；规则按「入口行一律去」——include
		// 是扫描唯一入口（// issue #61）
		var rows:Array<{src:String, why:String}> = [
			{src: "-main ApplicationMain", why: "recipe 原名"},
			{src: "-main ApplicationMain ", why: "带尾随空格的实跑形态"},
			{src: "-main Something", why: "任何入口都不该留"},
		];
		for (row in rows) {
			var got = CppTyperPlan.transform([row.src, "-cp src"], "/tmp/o");
			Assert.isFalse(Lambda.exists(got, l -> StringTools.startsWith(l, "-main")),
				"-main 行须删：" + row.why);
		}
	}

	function test_transform_drops_html5_only_defines() {
		// issue #61 点名 5 个 + #18「等」实测补齐 5 个（出处见类头）
		var dropped = [
			"lime-webgl", "lime-dom", "howlerjs", "lime-html5", "no-compilation",
			"html5", "web", "openfl-html5", "lime-howlerjs", "lime-canvas",
		];
		for (d in dropped) {
			var got = CppTyperPlan.transform(["-D " + d, "-cp src"], "/tmp/o");
			Assert.isFalse(Lambda.exists(got, l -> l == "-D " + d), "html5 专属 -D 须删：" + d);
		}
		// 目标无关 -D 保留（golden 里同款行；= 值形态也在）
		var kept = [
			"-D openfl=9.5.2", "-D lime=8.3.2", "-D swf=3.4.0", "-D tools=8.3.2",
			"-D lime-threads", "-D disable_preloader_assets=1",
		];
		for (d in kept) {
			var got = CppTyperPlan.transform([d, "-cp src"], "/tmp/o");
			Assert.isTrue(Lambda.exists(got, l -> l == d), "目标无关 -D 须保留：" + d);
		}
	}

	function test_transform_define_match_is_on_name_before_equals() {
		// -D 匹配取 = 前的 define 名：带值的专属名同删，带值的版本号保留
		var got = CppTyperPlan.transform(["-D html5=1", "-D openfl=9.5.2"], "/tmp/o");
		Assert.isFalse(Lambda.exists(got, l -> l == "-D html5=1"), "-D html5=1 与 -D html5 同名同删");
		Assert.isTrue(Lambda.exists(got, l -> l == "-D openfl=9.5.2"), "-D openfl=9.5.2 保留");
	}

	function test_transform_replaces_js_backend_with_cpp() {
		// recipe「换 -cpp」：-js 行删；输出恰一条 -cpp 且取参数目录
		var got = CppTyperPlan.transform(
			["-main ApplicationMain", "-js export/html5/bin/OpenflFarm.js", "-cp src"],
			"/tmp/scanout");
		Assert.isFalse(Lambda.exists(got, l -> StringTools.startsWith(l, "-js")), "-js 行须删");
		var cpp = got.filter(l -> StringTools.startsWith(l, "-cpp "));
		Assert.equals(1, cpp.length, "恰一条 -cpp");
		Assert.equals("-cpp /tmp/scanout", cpp[0]);
	}

	function test_transform_appends_cpp_then_include_macro_last() {
		// 追加行固定在末尾且 -cpp 先、include 后；include 的 exclude 全限定、
		// classPaths 限 'src'（#18/#29 钉死，合成输入也必须是这个形状）
		var got = CppTyperPlan.transform(["-cp src"], "/tmp/o");
		Assert.equals(3, got.length, "原行透传 + 恰两行追加");
		Assert.equals("-cpp /tmp/o", got[got.length - 2]);
		Assert.equals("--macro include('', true, ['mx.core.mx_internal'], ['src'])", got[got.length - 1]);
	}

	function test_transform_keeps_first_three_macros_only() {
		// recipe 原文「前三个 --macro（ExtraParams/DefineMacro/AssetsMacro）」：
		// 第 4 个及以后的 --macro 行去掉
		var macros = [
			"--macro openfl.utils._internal.ExtraParamsMacro.include()",
			"--macro lime._internal.macros.DefineMacro.run()",
			"--macro haxe.macro.Compiler.addMetadata(\"...\")",
			"--macro fourth.Bootstrap.run()",
		];
		var got = CppTyperPlan.transform(macros.concat(["-cp src"]), "/tmp/o");
		var keptMacros = got.filter(l -> StringTools.startsWith(l, "--macro"));
		// 保留的三个 + 追加的 include，共 4 条 --macro；第 4 条原始的不在
		Assert.equals(4, keptMacros.length);
		Assert.equals(macros[0], keptMacros[0]);
		Assert.equals(macros[1], keptMacros[1]);
		Assert.equals(macros[2], keptMacros[2]);
		Assert.isFalse(Lambda.exists(keptMacros, l -> l == macros[3]), "第 4 个 --macro 须删");
	}

	function test_transform_passes_unmatched_lines_through_verbatim() {
		// 不匹配任何规则的行逐字透传（含空行——golden 两侧尾部的空行同因）
		var lines = ["-cp src", "", "--remap flash:openfl", "-debug"];
		var got = CppTyperPlan.transform(lines, "/tmp/o");
		Assert.equals(lines[0], got[0]);
		Assert.equals("", got[1], "空行透传不清洗");
		Assert.equals(lines[2], got[2]);
		Assert.equals(lines[3], got[3]);
	}
}
