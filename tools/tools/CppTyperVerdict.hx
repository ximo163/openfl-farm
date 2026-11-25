package tools;

/**
 * issue #61 cpp typer 全量扫描——haxe 输出判据（write-tests 阶段为 stub，
 * 契约由 test/tools/CppTyperVerdictTest.hx 钉死，implement 原地填充）。
 *
 * 输入：脚本侧合并捕获的 haxe stdout+stderr 文本（typer 错误与尾巴两行走
 * stderr、Build.xml 回显行走 stdout——脚本侧 2>&1 合并后喂进来；只判文本
 * 不接 haxe 退出码：判据绿时 haxe 同样退出 1——hxcpp 未装即 Build failed，
 * 退出码区分不了过/不过。#29：留 no-compilation 时 0 错 0 输出退出 0，同样
 * 不是判据形态）。
 *
 * 判据（issue #61；#18/#44 记录，2026-11-25 容器实测形状存
 * test/fixtures/cpp-typer-*-output.txt）：
 * - 尾巴：末两个非空行恰为 `Error: Library hxcpp is not installed`、
 *   `Error: Build failed`（hxcpp 未装没关系——typer 错误在后端生成之前
 *   全量出，尾巴在场＝typer 已过、类型层干净）。
 * - 命中行（hits）：形如 `路径:行: characters a-b : 消息` 的错误定位行
 *   （含消息为 `... referenced here` 的引用链行——同一形态，一并计），
 *   以及 `Error: ` 开头但不是尾巴两常量的行。haxe 同一错误会打两遍
 *   （实测），按输出原序原样保留：打全不截断、不去重。
 * - pass ＝ 尾巴在场 且 无命中行。出现在尾巴之前的任何 error 都是命中
 *   （issue 原文判据）；尾巴之后还有内容＝「末尾只剩」不成立，不算尾巴。
 * - 安全网：无尾巴即不 pass——含 0 错 0 输出的 no-compilation 形态（#29）、
 *   exclude 表写错的裸模块名错误形态（#29 实测：`Module ... does not have
 *   a valid name` 一行、不带 Error: 前缀不带定位——不进 hits 但无尾巴照
 *   样红）。过不过不依赖 hits 的形态枚举全不全：未知失败形态必然无尾巴
 *   必然红；hits 只决定「报告打哪几行」。
 */
class CppTyperVerdict {
	/** 判 haxe 合并输出 → 判定结果（契约见类头）。 */
	static public function judge(output:String):Verdict {
		throw new haxe.Exception("not implemented");
	}
}

/** judge 的判定结果。 */
typedef Verdict = {
	/** 判据全绿：尾巴在场且无命中行（脚本据此 exit 0）。 */
	var pass:Bool;

	/** 末两个非空行是否恰为判据尾巴（hxcpp 未装 → Build failed）。 */
	var tailFound:Bool;

	/** 命中的错误行全文，按输出原序（file:line 不截断；haxe 重复打印的
	 *  同错行原样保留，不去重）。脚本据此打报告并 exit 1；无尾巴且无
	 *  命中＝形状外失败，脚本打全量输出同样 exit 1。 */
	var hits:Array<String>;
};
