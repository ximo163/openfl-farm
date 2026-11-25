package tools;

/**
 * issue #64 cpp linux 启动冒烟——断言判定的纯逻辑（write-tests 阶段 stub，
 * 契约由 test/tools/BootSmokeVerdictTest.hx 钉死，implement 原地填充）。
 * 被测类只判文本与布尔输入，不碰进程/网络/真实时间（xvfb 起二进制、
 * kill -0 探活、curl 后端、timeout 兜底全归 tools/cpp-boot-smoke.sh 的
 * bash 半边，implement 阶段交付）。
 *
 * 为什么存在：m_view.x = …（Dynamic 裸写 openfl get/set 属性）这类错
 * 编译全绿、cpp typer 扫描不报、web/eval 容忍、android CI 编得过——唯一
 * 现形场是真机运行（2026-11-24 实锤 WaterController.hx:366，PR #62）。
 * 冒烟的三条断言（issue 原文「三条全过才绿」）是 bash 里最难读对的部分，
 * 把判定本体提到这里用 eval 单测钉死，bash 只剩进程编排。
 *
 * 契约（// issue #64「断言（三条全过才绿）」节与「失败输出」节）：
 *
 * judge(backendUp, processAlive, log) 输入三件（bash 侧采集后以纯数据喂入）：
 *   - backendUp：后端探活结果（curl 旧后端健康口是否 200）；
 *   - processAlive：15 秒后 kill -0 探活结果（进程是否仍在）；
 *   - log：运行日志全文（stdout+stderr 合并落盘的文本）。
 *
 * 判定规则（// issue #64）：
 *   a. 后端探活先行：backendUp == false → pass = false、backendDown = true；
 *      后端没起是环境失败不是 app 红——crashedLines/processDied 的归账
 *      不冒充（backendDown 时调用方报「后端没起」而非 app 崩）。
 *   b. 15 秒后进程仍活着：processAlive == false → processDied = true、
 *      pass = false（backendUp 正常的前提下）。
 *   c. 运行日志无 Invalid field / Uncaught exception / Called from：
 *      log 里任一标记出现即红（主断言——有栈即红）。三标记**逐字子串**
 *      匹配（hxcpp debug 输出原样含这些字面量；issue 验收的 red 样例形态
 *      Invalid field:x + Called from WaterController::initialze 即此）。
 *   pass = backendUp && processAlive && crashedLines 为空。
 *
 * tail(log)（失败输出规格，// issue #64「tail 最后 80 行进 CI 控制台」）：
 *   log 末 80 行按原序返回；不足 80 行全给；单行不截断。
 *
 * 实现选型（implement 自行取舍）：judge 的输入三件按签名拆参即可，测试
 * 只调静态入口判纯逻辑；返回 BootVerdict typedef（键名见下，测试按键断言）。
 */
class BootSmokeVerdict {
	// issue #64 断言 c 的三标记，逐字子串匹配（hxcpp debug 输出原样含这些
	// 字面量，行内嵌入也算——「出现即红，不逐字整行」）：Invalid field
	// 是 cpp 的 Reflect/裸字段写崩消息头；Uncaught exception 是 hxcpp 未
	// 捕获异常头；Called from 是 HXCPP_STACK_TRACE（debug 配置编入）的
	// 栈帧行——有栈即红（主断言）
	private static final MARKERS:Array<String> = ["Invalid field", "Uncaught exception", "Called from"];

	private static final TAIL_LINES:Int = 80; // issue #64 失败输出节：「tail 最后 80 行日志进 CI 控制台」

	/** 判冒烟三断言（契约见类头）。 */
	static public function judge(backendUp:Bool, processAlive:Bool, log:String):BootVerdict {
		var crashedLines:Array<String> = [];
		if (log != null) {
			for (line in log.split("\n")) {
				for (marker in MARKERS) {
					if (line.indexOf(marker) != -1) {
						crashedLines.push(line); // 证据行整行原样保留，不截断
						break; // 一行含多个标记只记一次
					}
				}
			}
		}
		// 归账顺序（// issue #64 验收节）：后端没起是环境失败，账记
		// backendDown——processDied/crashedLines 的采集照实填（都是事实），
		// 但报文案时 backendDown 优先（「报『后端没起』而不是让 app 红背锅」
		// 由 bash 侧按 backendDown 择文案）
		var backendDown:Bool = !backendUp;
		var processDied:Bool = !processAlive;
		return {
			pass: backendUp && processAlive && crashedLines.length == 0,
			backendDown: backendDown,
			processDied: processDied,
			crashedLines: crashedLines
		};
	}

	/** log 末 80 行（失败输出规格；契约见类头）。 */
	static public function tail(log:String):Array<String> {
		if (log == null || log == "") {
			return [];
		}
		var lines:Array<String> = log.split("\n");
		// unix tail 行语义：末行尾换行切出的空串不是一行（真实落盘日志末行
		// 都有尾换行——// issue #64「tail 最后 80 行」的 bash 对应物就是
		// tail -80，行语义对齐）
		if (lines.length > 0 && lines[lines.length - 1] == "") {
			lines.pop();
		}
		if (lines.length > TAIL_LINES) {
			lines = lines.slice(lines.length - TAIL_LINES);
		}
		return lines;
	}
}

/** judge 的判定结果。 */
typedef BootVerdict = {
	/** 三断言全过（脚本据此 exit 0）。 */
	var pass:Bool;

	/** 后端没起（环境失败——报告文案是明确的「后端没起」，不冒充 app 红）。 */
	var backendDown:Bool;

	/** 15 秒后进程已死（kill -0 探活失败）。 */
	var processDied:Bool;

	/** log 里的崩溃证据行（含 Invalid field / Uncaught exception /
	 *  Called from 三标记之一的行，按原序原样保留、单行不截断）。
	 *  主断言：非空即红。 */
	var crashedLines:Array<String>;
};
