package tools;

import sys.io.File;
import sys.FileSystem;
import tools.TestStubScan.StubHit;

/**
 * issue #70 机器门之一（test/ 禁 throw-stub）——脚本侧胶水：走目录、拼报
 * 告、exit 码。判式本体与豁免清单在 tools.TestStubScan（契约由
 * test/tools/TestStubScanTest.hx 钉死，`haxe test.hxml` 跑）；本类只做
 * 「收 test/**.hx → 逐文件喂行集 → 豁免消费 → 打报告」（DynWriteScanRun
 * 先例）。python 壳 tools/scan_test_stubs.py 拉起本类——issue 接线命令
 * `python tools/scan_test_stubs.py`，判式单源、python 半边零重复（#63
 * 双实现「改判式必须两侧同步改」的教训不再吃一遍）。
 *
 * 输出形状（机读分拣面，TestStubScan.isReportLine 据此分拣命中行与说明
 * 行）：命中/豁免行 = reportLine 的 `path:line 摘录`；说明行一律
 * `scan_test_stubs: ` 起手（冒号后带空格，isReportLine 不认）；豁免出处
 * 行用全角冒号——别在说明行里引入 `ASCII 冒号+数字+空格` 序列。报告顺
 * 序：豁免面（每个仍在消费的豁免文件报一处起点——issue 验收「对 #56 的
 * 两个僵尸 stub 运行 → 报 2 处（豁免后过）」按文件读）→ 失锚豁免（腐化
 * 检测，退 1）→ 净命中（退 1）→ 全净时一行 OK。
 *
 * 用法（仓库根）：haxe -cp tools --run tools.TestStubScanRun [仓库根，默认 .]
 * 退出码：0 = 净命中 0 且无失锚豁免；1 = 有净命中或有失锚豁免（判式半边
 * 编译失败时 haxe 同样退非零——门跑不起来＝不放行，失败方向一致）；
 * 2 = 用法/环境错。
 */
class TestStubScanRun {
	static function main() {
		var args = Sys.args();
		var root = normalizeRoot(args.length > 0 ? args[0] : ".");
		if (root == ".") root = ""; // 相对形态统一成无前缀（./test/… 会破坏与豁免条目的逐字匹配）
		var testDir = root == "" ? "test" : root + "/test";
		if (!FileSystem.exists(testDir) || !FileSystem.isDirectory(testDir)) {
			Sys.stderr().writeString("TestStubScanRun: 找不到 test 目录 " + testDir
				+ "（用法：haxe -cp tools --run tools.TestStubScanRun [仓库根，默认 .]）\n");
			Sys.exit(2);
		}

		// 1) 收 test/**.hx（排序确定——遍历序即输出序）
		var files:Array<String> = [];
		walk(testDir, files);
		files.sort(Reflect.compare);

		// 2) 逐文件喂行集（path 用仓库相对路径——与豁免条目逐字匹配的同一形态）
		var allHits:Array<StubHit> = [];
		for (f in files) {
			allHits = allHits.concat(TestStubScan.scanLines(readLines(f), relPath(root, f)));
		}

		// 3) 豁免消费 + 报告
		var r = TestStubScan.exemptHits(allHits, TestStubScan.exemptions());
		var bad = r.hits.length > 0 || r.stale.length > 0;

		if (r.live.length > 0) {
			var exemptHitCount = allHits.length - r.hits.length; // 被滤掉的命中数
			Sys.println("scan_test_stubs: 豁免 " + exemptHitCount + " 处（迁移期存量，清单与出处写死在 tools.TestStubScan.exemptions）：");
			for (e in r.live) {
				var first = firstHitOf(allHits, e.path);
				if (first != null) {
					Sys.println(TestStubScan.reportLine(first));
					Sys.println("  豁免出处： " + e.reason);
				}
			}
		}
		if (r.stale.length > 0) {
			Sys.println("scan_test_stubs: FAIL —— 豁免失锚 " + r.stale.length
				+ " 条（该文件已零命中——僵尸清理后把豁免条目一并删掉，exemptions() 与 TestStubScanTest 的豁免断言同步改）：");
			for (e in r.stale) {
				Sys.println("scan_test_stubs: 失锚豁免 " + e.path + " —— " + e.reason);
			}
		}
		if (r.hits.length > 0) {
			Sys.println("scan_test_stubs: FAIL —— test/ 禁 throw-stub 净命中 " + r.hits.length
				+ " 处（stub 骨架放它完工后所属的树：产品类进 src/、验证基建进 tools/tools/；test/ 是定稿区——#56 教训）：");
			for (h in r.hits) {
				Sys.println(TestStubScan.reportLine(h));
			}
		}
		if (!bad) {
			Sys.println("scan_test_stubs: OK —— test/ " + files.length
				+ " 个 .hx 无 throw-stub 净命中（test/ 是定稿区，规矩：stub 放它完工后所属的树）");
		}
		Sys.exit(bad ? 1 : 0);
	}

	/** 去尾斜杠（"…//" 拼接会弄脏相对路径换算；根目录 "/" 除外）。 */
	static function normalizeRoot(root:String):String {
		while (root.length > 1 && StringTools.endsWith(root, "/")) root = root.substring(0, root.length - 1);
		return root;
	}

	static function walk(dir:String, out:Array<String>):Void {
		var names = FileSystem.readDirectory(dir);
		names.sort(Reflect.compare);
		for (n in names) {
			var p = dir + "/" + n;
			if (FileSystem.isDirectory(p)) walk(p, out);
			else if (StringTools.endsWith(n, ".hx")) out.push(p);
		}
	}

	static function readLines(path:String):Array<String> {
		var lines = File.getContent(path).split("\n");
		if (lines.length > 0 && lines[lines.length - 1] == "") lines.pop(); // 尾换行
		return lines;
	}

	/** 仓库根下的路径 → 仓库相对路径（"/" 分隔、无 ./ 前缀——与豁免条目
	 * 逐字匹配的同一形态；root 已在 main 归一成 "" 或绝对/相对根）。 */
	static function relPath(root:String, file:String):String {
		return root == "" ? file : file.substring(root.length + 1);
	}

	static function firstHitOf(hits:Array<StubHit>, path:String):StubHit {
		for (h in hits) {
			if (h.path == path) return h;
		}
		return null;
	}
}
