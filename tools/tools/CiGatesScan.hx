package tools;

import sys.FileSystem;
import sys.io.File;

/**
 * issue #94 T2/T3 门禁接线——脚本侧胶水：tools/ci-gates.sh 的 Haxe 半边
 * （报告文件读取 + 机读输出）。bash 半边管进程编排：跑两闸的 --self-check
 * 与全量对拍、采退出码——判定本体在 CiGatesVerdict（契约由
 * test/tools/CiGatesVerdictTest.hx 钉死，`haxe test.hxml` 跑）、豁免登记在
 * GateExemptions，本类只做「读报告文件 → 调被测类 → 打机读键值行」。
 * 与 BootSmokeScan 同款分层（纯 std，不 import openfl/lime，bash 侧零依赖
 * 拉起）。
 *
 * 用法：
 *
 *     haxe -cp tools --run tools.CiGatesScan judge <timelineExit> <timelineReportFile> <renderExit> <renderReportFile>
 *
 * judge：退出码是 bash 半边采的两闸 `$?`；报告路径是两闸 --out 缺省
 * （export/timeline-gate/report.txt、export/render-gate/report.txt）。基建
 * 坏的闸 exit(2) 位点在落盘之前（见 CiGatesVerdict 类头 2），文件不在按
 * 空串喂——judge 对 Infra 闸本来就不读报告，对空报告的 exit 1 照红。
 *
 * 机读行（bash 侧 sed 解析；人读文案归 bash——报告原文不进机读通道）：
 *
 *     pass=true|false
 *     exitCode=0|1
 *     line=<step 日志行，按原序一行一条，整行不截断>
 *
 * 机读行走 stdout，用法错走 stderr 退 2。
 */
class CiGatesScan {
	static function main() {
		var args = Sys.args();
		if (args.length != 5 || args[0] != "judge") {
			usage();
		}
		judge(args[1], args[2], args[3], args[4]);
	}

	static function usage():Void {
		Sys.stderr().writeString(
			"用法: haxe -cp tools --run tools.CiGatesScan judge <timelineExit> <timelineReportFile> <renderExit> <renderReportFile>\n");
		Sys.exit(2);
	}

	static function judge(timelineExitArg:String, timelineReportFile:String, renderExitArg:String, renderReportFile:String):Void {
		var timelineExit = parseIntArg(timelineExitArg, "timelineExit");
		var renderExit = parseIntArg(renderExitArg, "renderExit");
		var v = CiGatesVerdict.judge(timelineExit, readOrEmpty(timelineReportFile), renderExit, readOrEmpty(renderReportFile),
			GateExemptions.registered);
		Sys.println("pass=" + v.pass);
		Sys.println("exitCode=" + v.exitCode);
		for (line in v.lines) {
			Sys.println("line=" + line);
		}
	}

	/** 报告文件不在（基建坏没落新报告/还没跑过）按空串喂。 */
	static function readOrEmpty(file:String):String {
		return FileSystem.exists(file) ? File.getContent(file) : "";
	}

	/** bash $? 原样转数字；解析不了是接线错，退 2 而不是猜（门跑不起来＝
	 * 不放行，失败方向与 #64 同款）。 */
	static function parseIntArg(arg:String, what:String):Int {
		var v = Std.parseInt(arg);
		if (v == null || ("" + v) != arg) {
			Sys.stderr().writeString("CiGatesScan: " + what + " 要整数（bash $? 形态），收到 " + arg + "\n");
			Sys.exit(2);
		}
		return v;
	}
}
