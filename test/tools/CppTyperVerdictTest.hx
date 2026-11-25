package tools;

import sys.io.File;
import utest.Assert;

/**
 * issue #61 cpp typer 全量扫描——haxe 输出判据的纯逻辑（write-tests 阶段
 * 对 stub 失败）。被测 tools.CppTyperVerdict 只判文本，不接进程/退出码
 * （调 haxe、捕获合并输出归 tools/scan_cpp_typer.sh，implement 阶段交付）。
 * stub 在 tools/tools/CppTyperVerdict.hx（「stub 归树」规矩，implement
 * 原地填充）。
 *
 * 期望值出处：
 * - 判据文本（「输出末尾只剩 Error: Library hxcpp is not installed
 *   （Build failed）＝ typer 已过；出现在它之前的任何 error 都是命中」）：
 *   // issue #61，shape 记录在 lessons #18/#44。
 * - 四份输出 fixture 都是 2026-11-25 容器实测捕获（main 当时全绿、
 *   WaterModel:310 已由 #60 修复）：
 *   - cpp-typer-pass-output.txt：判据绿面（hxcpp 未装 → 尾巴两行；首行
 *     是 haxe 落 Build.xml 前回显的 haxelib 命令行，走 stdout——不是错，
 *     不计命中）。
 *   - cpp-typer-hits-output.txt：注入面——src/FS_02_1_2.hx:14 植入
 *     `var i:Int = 0; if (i == null)`（issue #61 完成标准 2 同款）后实跑
 *     捕获；haxe 同一错误打两遍是实测形态，typer 挂了就到不了后端（尾巴
 *     不在）。
 *   - cpp-typer-config-error-output.txt：变换漏删 html5 专属 -D（实测
 *     留 -D html5 + lime-canvas）的形状——js 包 import 进 cpp 目标，
 *     错误定位行与「... referenced here」引用链行同形态，共 27 行。
 *   - cpp-typer-exclude-error-output.txt：lessons #29 的 exclude 表写
 *     短名形状（include ignore 传 'mx_internal'）——haxe 只报一行裸
 *     模块名错误直接退，不带定位不带 Error: 前缀。
 * - 无尾巴即红的安全网（0 错 0 输出的 no-compilation 形态）：lessons #29
 *   原文（「留着则 0 错 0 输出退出 0，同样过 typer 但和文档判据对不上」）
 *   ——判据要求尾巴在场，// issue #61。
 */
class CppTyperVerdictTest {
	public function new() {}

	static final PASS_FIXTURE:String = "test/fixtures/cpp-typer-pass-output.txt";
	static final HITS_FIXTURE:String = "test/fixtures/cpp-typer-hits-output.txt";
	static final CONFIG_ERR_FIXTURE:String = "test/fixtures/cpp-typer-config-error-output.txt";
	static final EXCLUDE_ERR_FIXTURE:String = "test/fixtures/cpp-typer-exclude-error-output.txt";

	static function fixtureLines(path:String):Array<String> {
		var lines = File.getContent(path).split("\n");
		if (lines.length > 0 && lines[lines.length - 1] == "") lines.pop(); // 尾换行
		return lines;
	}

	// ---- 绿面：判据尾巴 ----

	function test_judge_pass_shape_real_capture() {
		var v = CppTyperVerdict.judge(File.getContent(PASS_FIXTURE));
		Assert.isTrue(v.pass, "实测绿面（尾巴在、无命中）须 pass");
		Assert.isTrue(v.tailFound);
		Assert.equals(0, v.hits.length);
	}

	function test_judge_minimal_tail_passes() {
		// 最小尾巴形态（脚本侧若只捕获 stderr，绿面就是这两行）
		var v = CppTyperVerdict.judge("Error: Library hxcpp is not installed\nError: Build failed\n");
		Assert.isTrue(v.pass);
		Assert.isTrue(v.tailFound);
		Assert.equals(0, v.hits.length);
	}

	function test_judge_tail_tolerates_trailing_blank_lines() {
		// 判据「末尾只剩」按末两个非空行取：尾随空行不算内容
		var v = CppTyperVerdict.judge("Error: Library hxcpp is not installed\nError: Build failed\n\n\n");
		Assert.isTrue(v.pass);
		Assert.isTrue(v.tailFound);
	}

	// ---- 红面：命中（typer 错误） ----

	function test_judge_injected_typer_error_real_capture() {
		var v = CppTyperVerdict.judge(File.getContent(HITS_FIXTURE));
		Assert.isFalse(v.pass, "注入面须红");
		Assert.isFalse(v.tailFound, "typer 挂了到不了后端，尾巴不在（实测）");
		// 同错两遍原样保留（haxe 实测形态），file:line 全文不截断
		var expected = [
			"src/FS_02_1_2.hx:14: characters 12-16 : On static platforms, null can't be used as basic type Int",
			"src/FS_02_1_2.hx:14: characters 12-16 : On static platforms, null can't be used as basic type Int",
		];
		Assert.same(expected, v.hits);
	}

	function test_judge_errors_before_tail_are_hits() {
		// issue #61 判据原文：「出现在它之前的任何 error 都是命中」——
		// 尾巴在场也不救命中行
		var errLine = "src/Bad.hx:14: characters 12-16 : On static platforms, null can't be used as basic type Int";
		var v = CppTyperVerdict.judge(errLine + "\nError: Library hxcpp is not installed\nError: Build failed\n");
		Assert.isFalse(v.pass);
		Assert.isTrue(v.tailFound, "尾巴两行在场");
		Assert.equals(1, v.hits.length);
		Assert.equals(errLine, v.hits[0]);
	}

	function test_judge_lib_side_errors_and_chains_are_hits() {
		// 配置漂移（漏删 html5 专属 -D）实测形状：lib 侧定位行 + 26 行
		// 「... referenced here」引用链，同一形态全计命中——配置错也是红，
		// 不静默过
		var v = CppTyperVerdict.judge(File.getContent(CONFIG_ERR_FIXTURE));
		Assert.isFalse(v.pass);
		Assert.isFalse(v.tailFound);
		Assert.same(fixtureLines(CONFIG_ERR_FIXTURE), v.hits); // 27 行逐行相等
		Assert.isTrue(v.hits[0].indexOf("You cannot access the js package while targeting cpp") >= 0,
			"首行是根错（js 包进 cpp）");
		Assert.equals("src/FS_02_1_2.hx:3: characters 8-32 : ... referenced here", v.hits[v.hits.length - 1]);
	}

	function test_judge_unknown_error_prefixed_line_is_hit() {
		// Error: 前缀但非尾巴两常量＝命中（如 include 宏自身的报错形态）
		var v = CppTyperVerdict.judge("Error: Invalid macro call\n");
		Assert.isFalse(v.pass);
		Assert.isFalse(v.tailFound);
		Assert.same(["Error: Invalid macro call"], v.hits);
	}

	// ---- 红面：安全网（无尾巴即不绿） ----

	function test_judge_empty_output_is_not_pass() {
		// lessons #29：-D no-compilation 留着 → 0 错 0 输出退出 0——typer
		// 可能过了但判据形态对不上（无尾巴），不许静默绿
		var v = CppTyperVerdict.judge("");
		Assert.isFalse(v.pass);
		Assert.isFalse(v.tailFound);
		Assert.equals(0, v.hits.length);
	}

	function test_judge_module_name_error_shape_reds() {
		// lessons #29：exclude 表传短名 'mx_internal' → 只报一行裸模块名
		// 错误直接退（实测捕获）。不带定位不带 Error: 前缀，不进 hits；
		// 无尾巴 → 不 pass
		var v = CppTyperVerdict.judge(File.getContent(EXCLUDE_ERR_FIXTURE));
		Assert.isFalse(v.pass);
		Assert.isFalse(v.tailFound);
		Assert.equals(0, v.hits.length);
	}

	function test_judge_content_after_tail_breaks_shape() {
		// 判据「输出末尾只剩」：尾巴之后还有内容＝形状不对（hxcpp 真装上
		// 后走到别的失败一类的未知形态）→ 不算尾巴、不 pass
		var v = CppTyperVerdict.judge("Error: Library hxcpp is not installed\nError: Build failed\nError: something else\n");
		Assert.isFalse(v.pass);
		Assert.isFalse(v.tailFound);
	}

	function test_judge_build_failed_alone_is_not_tail() {
		// 尾巴两行成对（hxcpp 未装 → Build failed）；孤零零 Build failed
		// （别的失败路径收尾行）不算尾巴——也不计命中（常量行非定位）
		var v = CppTyperVerdict.judge("Error: Build failed\n");
		Assert.isFalse(v.pass);
		Assert.isFalse(v.tailFound);
		Assert.equals(0, v.hits.length);
	}
}
