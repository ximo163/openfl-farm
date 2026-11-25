package tools;

import sys.io.File;
import sys.FileSystem;

/**
 * issue #64 cpp linux 启动冒烟——脚本侧胶水：tools/cpp-boot-smoke.sh 的
 * Haxe 半边（日志文件读写与机读报告）。bash 半边管进程编排：起后端、xvfb
 * 起二进制、kill -0 探活、timeout 兜底——判定本体在 BootSmokeVerdict
 * （契约由 test/tools/BootSmokeVerdictTest.hx 钉死，`haxe test.hxml` 跑），
 * 本类只做「读日志文件 → 调被测类 → 打机读键值行」。与 CppTyperScan 同款
 * 分层（纯 std，不 import openfl/lime，bash 侧零依赖拉起）。
 *
 * 用法：
 *
 *     haxe -cp tools --run tools.BootSmokeScan judge <backendUp> <processAlive> <logFile>
 *
 * judge：backendUp/processAlive 是 bash 侧采集的布尔字面量（"true"/"false"），
 * logFile 是 stdout+stderr 合并落盘的日志路径。输出机读行（bash 侧 sed 解析，
 * 报告文案归 bash——人读文案不进机读通道）：
 *
 *     pass=true|false
 *     backendDown=true|false
 *     processDied=true|false
 *     crashedCount=<n>
 *     crash=<证据行，按原序一行一条，整行不截断>
 *
 * 机读行走 stdout，用法错走 stderr 退 2。
 */
class BootSmokeScan {
	static function main() {
		var args = Sys.args();
		if (args.length != 4 || args[0] != "judge") {
			usage();
		}
		judge(args[1], args[2], args[3]);
	}

	static function usage():Void {
		Sys.stderr().writeString(
			"用法: haxe -cp tools --run tools.BootSmokeScan judge <backendUp:true|false> <processAlive:true|false> <logFile>\n");
		Sys.exit(2);
	}

	static function judge(backendUpArg:String, processAliveArg:String, logFile:String):Void {
		if (backendUpArg != "true" && backendUpArg != "false") {
			Sys.stderr().writeString("BootSmokeScan: backendUp 只认 true/false，收到 " + backendUpArg + "\n");
			Sys.exit(2);
		}
		if (processAliveArg != "true" && processAliveArg != "false") {
			Sys.stderr().writeString("BootSmokeScan: processAlive 只认 true/false，收到 " + processAliveArg + "\n");
			Sys.exit(2);
		}
		var log:String = FileSystem.exists(logFile) ? File.getContent(logFile) : "";
		var v = BootSmokeVerdict.judge(backendUpArg == "true", processAliveArg == "true", log);
		// 机读行：键值单行在前（bash sed 解析），证据行按原序跟后（一行一条，
		// 整行不截断——file:line 栈帧切碎就没法定位死点）
		Sys.println("pass=" + v.pass);
		Sys.println("backendDown=" + v.backendDown);
		Sys.println("processDied=" + v.processDied);
		Sys.println("crashedCount=" + v.crashedLines.length);
		for (line in v.crashedLines) {
			Sys.println("crash=" + line);
		}
	}
}
