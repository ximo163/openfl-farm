package tools;

import sys.io.File;
import sys.FileSystem;

/**
 * issue #61 cpp typer 全量扫描——脚本侧胶水：tools/scan_cpp_typer.sh 的
 * Haxe 半边（文件读写与收尾报告）。bash 半边管进程编排：debug.hxml 缺失时
 * 先 openfl build html5、mktemp 临时件、以 `2>&1` 合并捕获 haxe 输出——
 * 行变换与判据本体在 CppTyperPlan/CppTyperVerdict（契约由
 * test/tools/CppTyperPlanTest.hx / CppTyperVerdictTest.hx 钉死），本类只做
 * 「读文件 → 调被测类 → 写文件/打报告」。
 *
 * 纯 std（不 import openfl/lime），bash 侧零依赖拉起：
 *
 *     haxe -cp tools --run tools.CppTyperScan plan <debug.hxml> <cppOutDir> <scan.hxml>
 *     haxe -cp tools --run tools.CppTyperScan judge <out.txt>
 *
 * plan：读 debug.hxml，行尾换行切出的空行 pop 掉再喂 CppTyperPlan（其输入
 * 输出都是「行文本数组」），返回行 join("\n") 补尾换行写扫描 hxml。
 * judge：读 bash 侧合并捕获的 haxe 输出，按判据收尾——绿打一行 PASS 退 0；
 * 有命中行打全（file:line 不截断，issue #61 完成标准）退 1；无尾巴且无命中
 * 是形状外失败（#29 的 no-compilation / exclude 短名形态一类），打全量输出
 * 同样退 1。报告正文走 stdout，用法错走 stderr 退 2。
 */
class CppTyperScan {
	static function main() {
		var args = Sys.args();
		if (args.length < 1) usage();
		switch (args[0]) {
			case "plan":
				if (args.length != 4) usage();
				plan(args[1], args[2], args[3]);
			case "judge":
				if (args.length != 2) usage();
				judge(args[1]);
			default:
				usage();
		}
	}

	static function usage():Void {
		Sys.stderr().writeString(
			"用法: haxe -cp tools --run tools.CppTyperScan plan <debug.hxml> <cppOutDir> <scan.hxml>\n"
			+ "      haxe -cp tools --run tools.CppTyperScan judge <out.txt>\n");
		Sys.exit(2);
	}

	static function plan(debugHxml:String, cppOutDir:String, scanHxml:String):Void {
		if (!FileSystem.exists(debugHxml)) {
			Sys.stderr().writeString("CppTyperScan: 找不到 " + debugHxml + "\n");
			Sys.exit(2);
		}
		var lines = File.getContent(debugHxml).split("\n");
		if (lines.length > 0 && lines[lines.length - 1] == "") lines.pop(); // 尾换行
		var out = CppTyperPlan.transform(lines, cppOutDir);
		File.saveContent(scanHxml, out.join("\n") + "\n");
	}

	static function judge(outFile:String):Void {
		var output = FileSystem.exists(outFile) ? File.getContent(outFile) : "";
		var v = CppTyperVerdict.judge(output);
		if (v.pass) {
			Sys.println("scan_cpp_typer: PASS —— cpp typer 全量 include 扫描通过，类型层干净"
				+ "（hxcpp 未装、只到 Build failed＝判据绿，lessons #18）");
			Sys.exit(0);
		}
		if (v.hits.length > 0) {
			Sys.println("scan_cpp_typer: FAIL —— cpp typer 命中 " + v.hits.length
				+ " 行（static 目标类型错；先 stash 对比分清本片新引入还是 main 既有——lessons #44；"
				+ "main 既有只报告并当场开 issue，别顺手修，CLAUDE.md「收工与审查的机械自检」）：");
			for (hit in v.hits) Sys.println(hit);
		} else {
			Sys.println("scan_cpp_typer: FAIL —— 判据尾巴不在（hxcpp 未装形态以外的失败，"
				+ "配置漂移线索见 lessons #18/#29），全量输出：");
			for (line in output.split("\n")) Sys.println(line);
		}
		Sys.exit(1);
	}
}
