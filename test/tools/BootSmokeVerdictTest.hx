package tools;

import tools.BootSmokeVerdict;
import utest.Assert;

/**
 * issue #64 cpp linux 启动冒烟——断言判定纯逻辑（write-tests 阶段对 stub
 * 失败）。被测 tools.BootSmokeVerdict 只判文本与布尔输入，不碰进程/网络/
 * 真实时间（xvfb 起二进制、kill -0 探活、curl 后端、timeout 兜底、日志
 * 落盘全归 tools/cpp-boot-smoke.sh 的 bash 半边，implement 阶段交付）。
 * stub 在 tools/tools/BootSmokeVerdict.hx（「stub 归树」规矩，implement
 * 原地填充）。
 *
 * 为什么这门存在：m_view.x = …（Dynamic 裸写 openfl get/set 属性）这类错
 * 编译全绿、cpp typer 扫描不报、web/eval 容忍、android CI 编得过——唯一
 * 现形场是真机运行（// issue #64 动机节；2026-11-24 实锤
 * WaterController.hx:366，PR #62 修复）。冒烟的三条断言是 bash 里最难
 * 读对的部分（环境失败 vs app 崩的归账、三标记的逐字识别、tail 80 行
 * 边界），判定本体提到这里用 eval 钉死。
 *
 * 期望值出处（全部 // issue #64，原版没有的运行期机器门，按 issue 授权
 * 钉死）：
 * - 三断言与「全过才绿」：issue「断言（三条全过才绿）」节——a 后端探活
 *   先行（后端没起要输出**明确的**「后端没起」而不是让 app 红背锅）；
 *   b 15 秒后进程仍活着（kill -0 探活）；c 运行日志（stdout+stderr
 *   落盘）无 Invalid field / Uncaught exception / Called from（有栈即红，
 *   这是主断言）。
 * - red 样例形态：issue「验收」节——对 WaterController.hx:366-367 revert
 *   回修复前形态，冒烟必须红且日志带 `Invalid field:x` + `Called from
 *   WaterController::initialze`（PR #62 diff 逆向可得；修复 commit
 *   d421c685 头注同文引用了真机栈的这两个字面量）。
 * - 失败输出 tail 80 行：issue「失败输出」节（「tail 最后 80 行日志进
 *   CI 控制台」）。
 * - 「后端没起」不冒充 app 红：issue「验收」节（「人为不拉后端时输出
 *   『后端没起』且不冒充 app 红」）。
 */
class BootSmokeVerdictTest {
	public function new() {}

	// hxcpp debug 崩溃输出的字面量形态（red 样例出处：issue #64 验收节 +
	// PR #62 修复 commit d421c685 头注——真机栈实锤行正是这两个标记）。
	// 合成日志行：被测的是标记识别与归账语义，不是某次真跑的逐字内容——
	// 标记字面量本身即输入定义（// issue #64）。
	static final INVALID_FIELD_LINE:String = "Invalid field:x";
	static final CALLED_FROM_LINE:String = "Called from module.water.WaterController::initialze (src/module/water/WaterController.hx line 366)";
	static final UNCAUGHT_LINE:String = "Uncaught exception: Invalid field:x";

	static function lines(n:Int, prefix:String):String {
		// 造 n 行无标记日志（行文本不重复——tail 的行序断言要可区分）
		var out = [];
		for (i in 0...n) out.push(prefix + i);
		return out.join("\n");
	}

	// ---- 绿面：三断言全过 ----

	function test_green_when_backend_up_process_alive_log_clean() {
		// // issue #64「三条全过才绿」：后端通 + 15 秒进程在 + 日志无标记
		var v = BootSmokeVerdict.judge(true, true, lines(30, "boot ok "));
		Assert.isTrue(v.pass, "三断言全过须绿");
		Assert.isFalse(v.backendDown);
		Assert.isFalse(v.processDied);
		Assert.equals(0, v.crashedLines.length);
	}

	// ---- 红面 a：后端没起是环境失败，不冒充 app 红 ----

	function test_backend_down_fails_without_blaming_app() {
		// // issue #64 验收节：「人为不拉后端时输出『后端没起』且不冒充
		// app 红」——backendUp=false 即红，但账记 backendDown，不记 app 崩
		var v = BootSmokeVerdict.judge(false, false, "");
		Assert.isFalse(v.pass, "后端没起不许绿");
		Assert.isTrue(v.backendDown, "后端没起须归账 backendDown（报『后端没起』）");
	}

	function test_backend_down_does_not_report_process_death_as_app_crash() {
		// 后端没起时进程多半也活不久（没数据可拉），两行失败同时存在；
		// 归账语义（// issue #64 验收节）：报『后端没起』而不是让 app 红
		// 背锅——processDied/crashedLines 不得冒充主因。pass 必 false，
		// backendDown 必 true（归账的第一断言）
		var v = BootSmokeVerdict.judge(false, false, INVALID_FIELD_LINE + "\n");
		Assert.isFalse(v.pass);
		Assert.isTrue(v.backendDown, "后端没起是第一归账（环境失败），不冒充 app 红");
	}

	// ---- 红面 b：15 秒后进程已死 ----

	function test_process_died_fails() {
		// // issue #64 断言 b：「15 秒后进程仍活着（kill -0 探活）」——
		// 后端正常、进程 15 秒内死掉 = 启动链没走到稳态，红
		var v = BootSmokeVerdict.judge(true, false, lines(10, "boot partial "));
		Assert.isFalse(v.pass, "进程 15 秒内死掉不许绿");
		Assert.isTrue(v.processDied, "进程死须归账 processDied");
		Assert.isFalse(v.backendDown, "后端正常不得误报 backendDown");
	}

	function test_process_alive_is_required_even_with_clean_log() {
		// 日志干净但进程死了同样红——进程死了还谈什么无异常（断言 b 独立
		// 于断言 c，// issue #64「三条全过才绿」）
		var v = BootSmokeVerdict.judge(true, false, "clean\n");
		Assert.isFalse(v.pass);
		Assert.isTrue(v.processDied);
		Assert.equals(0, v.crashedLines.length, "日志干净时 crashedLines 为空（死的是静默死）");
	}

	// ---- 红面 c：日志三标记（主断言，有栈即红） ----

	function test_invalid_field_line_reds() {
		// // issue #64 验收节 red 样例：日志带 `Invalid field:x` 必须红
		var log = lines(5, "boot ") + "\n" + INVALID_FIELD_LINE + "\n" + lines(3, "after ");
		var v = BootSmokeVerdict.judge(true, true, log);
		Assert.isFalse(v.pass, "Invalid field 出现即红（主断言）");
		Assert.isTrue(Lambda.exists(v.crashedLines, l -> l == INVALID_FIELD_LINE),
			"证据行原样保留：" + INVALID_FIELD_LINE);
		Assert.isFalse(v.backendDown);
		Assert.isFalse(v.processDied);
	}

	function test_called_from_line_reds() {
		// // issue #64 验收节 red 样例：`Called from WaterController::
		// initialze`——hxcpp debug 异常栈帧行（HXCPP_STACK_TRACE 族
		// if="debug"），有栈即红
		var log = lines(5, "boot ") + "\n" + CALLED_FROM_LINE + "\n";
		var v = BootSmokeVerdict.judge(true, true, log);
		Assert.isFalse(v.pass, "Called from 出现即红（栈帧行）");
		Assert.isTrue(Lambda.exists(v.crashedLines, l -> l == CALLED_FROM_LINE));
	}

	function test_uncaught_exception_line_reds() {
		// // issue #64 断言 c 三标记之一：Uncaught exception
		var log = lines(5, "boot ") + "\n" + UNCAUGHT_LINE + "\n";
		var v = BootSmokeVerdict.judge(true, true, log);
		Assert.isFalse(v.pass, "Uncaught exception 出现即红");
		Assert.isTrue(Lambda.exists(v.crashedLines, l -> l == UNCAUGHT_LINE));
	}

	function test_red_sample_shape_invalid_field_plus_stack() {
		// // issue #64 验收节 red 样例的完整形态：Invalid field:x +
		// Called from WaterController::initialze 同现——两行都进证据表、
		// 原序保留（单行不截断）
		var log = "prelude\n" + INVALID_FIELD_LINE + "\n" + CALLED_FROM_LINE + "\ntail\n";
		var v = BootSmokeVerdict.judge(true, true, log);
		Assert.isFalse(v.pass);
		Assert.same([INVALID_FIELD_LINE, CALLED_FROM_LINE], v.crashedLines,
			"red 样例两行证据原序原样");
	}

	function test_markers_embedded_in_longer_lines_are_caught() {
		// hxcpp 输出里标记未必独占一行（前缀时间戳/模块名等）——逐字**子串**
		// 匹配（// issue #64：日志里「无 Invalid field / Uncaught
		// exception / Called from」，出现即红，不逐字整行）
		var embedded = "2026-11-25T01:02:03 Uncaught exception: boom in module init";
		var v = BootSmokeVerdict.judge(true, true, embedded + "\n");
		Assert.isFalse(v.pass, "行内嵌入的 Uncaught exception 同样红");
		Assert.same([embedded], v.crashedLines, "证据行整行保留（不截断）");
	}

	function test_clean_boot_log_has_no_crashed_lines() {
		// 正常启动日志的常见行不含三标记——openfl/hxcpp 常规输出不误报
		var normal = [
			"Game just started.",
			"Error: Build failed", // 含 "Error:" 但非三标记——不误判（判的是崩溃标记不是泛 error 词）
			"Library hxcpp is not installed" // 同上
		];
		var v = BootSmokeVerdict.judge(true, true, normal.join("\n"));
		Assert.equals(0, v.crashedLines.length, "无三标记的正常输出不产证据行");
		Assert.isTrue(v.pass);
	}

	function test_empty_log_is_clean() {
		// 空日志（进程启动即静默或无输出）不含三标记——不产证据行；
		// 进程活着 + 后端通 = 绿（issue #64 三断言逐条独立）
		var v = BootSmokeVerdict.judge(true, true, "");
		Assert.equals(0, v.crashedLines.length);
		Assert.isTrue(v.pass);
	}

	// ---- 失败输出：tail 末 80 行 ----

	function test_tail_gives_last_80_lines_in_order() {
		// // issue #64 失败输出节：「tail 最后 80 行日志进 CI 控制台」
		var t = BootSmokeVerdict.tail(lines(100, "log line "));
		Assert.equals(80, t.length, "100 行日志 tail 恰取末 80 行");
		Assert.equals("log line 20", t[0], "第 81 行（0 基 20）是 tail 首行");
		Assert.equals("log line 99", t[79], "末行是原日志末行");
	}

	function test_tail_short_log_gives_everything() {
		// 不足 80 行全给（// issue #64 失败输出——小日志没有可截的）
		var t = BootSmokeVerdict.tail(lines(5, "short "));
		Assert.equals(5, t.length);
		Assert.equals("short 0", t[0]);
		Assert.equals("short 4", t[4]);
	}

	function test_tail_exactly_80_lines_is_not_cut() {
		// 边界含：恰 80 行一行不少
		var t = BootSmokeVerdict.tail(lines(80, "exact "));
		Assert.equals(80, t.length);
		Assert.equals("exact 0", t[0]);
	}

	function test_tail_single_lines_not_truncated() {
		// 单行不截断（行截断会把 file:line 栈帧切碎——与 scan_cpp_typer
		// 「file:line 不截断」同族要求，// issue #64 失败输出规格）
		var longLine = CALLED_FROM_LINE + " " + StringTools.lpad("", "x", 500);
		var t = BootSmokeVerdict.tail("head\n" + longLine + "\n");
		Assert.equals(longLine, t[t.length - 1], "长行整行保留不截断");
	}

	function test_tail_trailing_newline_does_not_inflate_count() {
		// 真实落盘日志末行有尾换行——按 unix tail -80 语义，尾换行切出的
		// 空串不是一行（// issue #64「tail 最后 80 行」：bash 侧的对应物
		// 就是 tail -80，行语义对齐）
		var body = lines(100, "nl ") + "\n";
		var t = BootSmokeVerdict.tail(body);
		Assert.equals(80, t.length, "100 行 + 尾换行 tail 仍是末 80 行（空尾串不算行）");
		Assert.equals("nl 20", t[0]);
		Assert.equals("nl 99", t[79]);
	}

	function test_tail_empty_log_is_empty() {
		Assert.same([], BootSmokeVerdict.tail(""), "空日志 tail 为空");
	}
}
