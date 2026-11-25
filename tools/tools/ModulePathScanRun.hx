package tools;

import sys.io.File;
import sys.FileSystem;
import tools.ModulePathScan.ModuleEntry;

/**
 * issue #70 机器门之二（跨树重复模块路径）——脚本侧胶水：走三棵树、拼报
 * 告、exit 码。判式本体（包声明解析/模块路径拼装/查重/渲染）在
 * tools.ModulePathScan（契约由 test/tools/ModulePathScanTest.hx 钉死，
 * `haxe test.hxml` 跑）；本类只做「收 test/ tools/ src/ 三棵树的 .hx →
 * 喂 (path, lines) 对 → 打报告」（DynWriteScanRun 先例）。python 壳
 * tools/scan_module_paths.py 拉起本类（issue 接线命令
 * `python tools/scan_module_paths.py`，判式单源——#63 双实现漂移教训）。
 *
 * 扫描面：test/、tools/、src/ 三棵树的**全部** .hx（含 test/fixtures/ 的
 * 快照件——它们在 -cp test 的包空间里，同名即真遮蔽，不豁免）。模块路
 * 径 = 包声明 + 文件名（与目录无关），树内树间重复同罪（Haxe 同
 * classpath 内也按搜索序静默取先者）。
 *
 * 用法（仓库根）：haxe -cp tools --run tools.ModulePathScanRun [仓库根，默认 .]
 * 退出码：0 = 零重复；1 = 有冲突组（判式半边编译失败同样退非零——门跑
 * 不起来＝不放行）；2 = 用法/环境错（三棵树缺其一）。
 */
class ModulePathScanRun {
	static function main() {
		var args = Sys.args();
		var root = normalizeRoot(args.length > 0 ? args[0] : ".");
		if (root == ".") root = ""; // 相对形态统一成无前缀（报告路径不带 ./）

		// 1) 收三棵树（顺序固定 test→tools→src；冲突组输出排序归
		//    ModulePathScan.findConflicts，遍历序不影响报告）
		var trees = ["test", "tools", "src"];
		var entries:Array<ModuleEntry> = [];
		var missing:Array<String> = [];
		for (t in trees) {
			var dir = root == "" ? t : root + "/" + t;
			if (!FileSystem.exists(dir) || !FileSystem.isDirectory(dir)) {
				missing.push(t);
				continue;
			}
			var files:Array<String> = [];
			walk(dir, files);
			files.sort(Reflect.compare);
			for (f in files) {
				entries.push({path: relPath(root, f), lines: readLines(f)});
			}
		}
		if (missing.length > 0) {
			Sys.stderr().writeString("ModulePathScanRun: 缺树 " + missing.join("/")
				+ "（用法：haxe -cp tools --run tools.ModulePathScanRun [仓库根，默认 .]）\n");
			Sys.exit(2);
		}

		// 2) 查重 + 报告
		var conflicts = ModulePathScan.findConflicts(entries);
		if (conflicts.length > 0) {
			Sys.println("scan_module_paths: FAIL —— test/tools/src 三棵树模块路径重复 "
				+ conflicts.length + " 组（-cp tools 后共享包空间，Haxe 对同名模块静默按 -cp 顺序取先者、不报错——test/tools/import.hx 遮蔽同机制，谁生效取决于编译的 classpath 顺序）：");
			for (c in conflicts) {
				for (line in ModulePathScan.renderConflict(c)) Sys.println(line);
			}
			Sys.exit(1);
		}
		Sys.println("scan_module_paths: OK —— test/tools/src 三棵树 " + entries.length
			+ " 个 .hx 模块路径零重复");
		Sys.exit(0);
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

	/** 仓库根下的路径 → 仓库相对路径（"/" 分隔、无 ./ 前缀，报告给人看；
	 * root 已在 main 归一成 "" 或绝对/相对根）。 */
	static function relPath(root:String, file:String):String {
		return root == "" ? file : file.substring(root.length + 1);
	}
}
