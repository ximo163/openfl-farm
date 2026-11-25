package tools;

/**
 * issue #70 机器门收口之二：跨树重复模块路径扫描的纯逻辑（write-tests 阶
 * 段为 stub，契约由 test/tools/ModulePathScanTest.hx 钉死，implement 原
 * 地填充）。
 *
 * 为什么这门存在：-cp tools 之后（test.hxml:23 起）test/、tools/、src/
 * 三棵树共享包空间，Haxe 对跨 classpath 的**同名模块静默按 -cp 顺序取先
 * 者**——不报错（// issue #70 交付物 2）。import.hx 事件证明这种遮蔽能
 * 同时骗过 agent、review 和 verify；69 资产门禁的 test/tools/import.hx
 * 就是靠这个机制活着的（防御性地利用——`import t3.TimelineSpec` 把包内
 * 未限定名解析到 t3 实现、绕过占死类路径的僵尸 stub），反过来同一个机
 * 制也能吞掉真正的同名冲突：哪天有人在 tools/tools/ 建一个
 * TimelineTypes.hx，它就和 test/tools/TimelineTypes.hx 撞模块路径
 * tools.TimelineTypes，谁生效取决于 -cp 顺序，编译照样绿。模块路径重复
 * 是这个机制的触发条件，必须枚举报警——不能靠记忆。
 *
 * 职责边界：本类只做**枚举/解析/查重的纯逻辑**，不走目录——输入是
 * (文件路径, 行集) 对。走三棵树收 .hx、拼报告、exit 0/1 归脚本侧
 * （tools/scan_module_paths.py 或 Haxe 胶水，选型 implement 自定）。
 *
 * 模块路径定义（// issue #70 原文）：**包声明 + 文件名**。
 * `package tools;` 的 tools/xx.hx → tools.xx；tools/tools/xx.hx →
 * tools.xx——**与文件在哪个目录无关，只看包声明与文件名**：三棵树的目
 * 录布局本来就是「包路径 ≠ 文件路径」（tools/ 树的包 tools 文件放在
 * tools/tools/ 下、test/ 树的包 tools 文件放在 test/tools/ 下），所以
 * 冲突检测必须以包声明为准而不是以目录结构为准（issue 原文举例钉死）。
 * 无 package 声明（或 `package;`）→ 根包，模块路径即文件名（src/ 一层的
 * FS_01_0_0.hx → FS_01_0_0；test/TestMain.hx → TestMain）。文件名大小写
 * 逐字（Haxe 类型名大小写敏感），包声明逐字（大小写不折叠）。
 *
 * 冲突判定：同一模块路径出现在 >1 文件即冲突（// issue #70）——不问在
 * 哪棵树：**树内**重复同样是冲突（Haxe 在同一 classpath 内也按搜索序
 * 静默取先者，ModulePathScanTest 有树内用例钉死）。输出冲突组：每组的
 * 文件名单按**字典序**排序（报告可 diff 对拍，不随遍历序漂移）；组间按
 * 模块路径字典序。import.hx 自身不豁免——它就是 `import.hx`（根包模块
 * import），两个 import.hx（test/import.hx 与 test/tools/import.hx）不
 * 同包？不：import.hx 没有 package 声明……**注意**：test/import.hx 与
 * test/tools/import.hx 都是根包无声明文件吗——test/tools/import.hx 首
 * 行是 `package tools;`（默认导入机制要求它在对应包的 classpath 根
 * 位），模块路径是 tools.import；test/import.hx 无 package 声明，模块
 * 路径是 import。两者不同、不构成冲突（2026-11-25 全库实测零冲突基线
 * 含此对）。
 *
 * 已确认的**非冲突**先例（issue 原文）：test/t3/TimelineSpec.hx（包 t3
 * → t3.TimelineSpec）与 test/tools/TimelineSpec.hx（包 tools →
 * tools.TimelineSpec）模块路径不同，靠 import 遮蔽同包名是**两个模块**
 * 的协作，不在本扫描的命中面——当前 main 三棵树 0 冲突（干净基线，
 * issue 验收钉死，本扫描对 main 运行必须通过）。
 *
 * package 解析：取文件里第一个 `package` 语句——形态 `package a.b.c;`
 * （允许行前空白、行内注释在分号后）。没有 package 语句按根包。**注释里
 * 的 "package" 字样不算**（`// package foo;` 是注释——扫描器按行剔除
 * `//` 之后的部分再判，块注释不在防面：仓里 .hx 的 package 声明全在文
 * 件头、先于一切块注释，2026-11-25 实测枚举成立）。
 */
class ModulePathScan {
	/** 从行集解析包声明：第一个 package 语句的包名（逐字，去尾分号与空
	 * 白）；无 package 语句或 `package;`（空包）→ ""（根包）。`//` 行注
	 * 释剔除后判（见类头）。 */
	static public function parsePackage(lines:Array<String>):String {
		for (line in lines) {
			var cut = line.indexOf("//");
			var text = cut < 0 ? line : line.substring(0, cut);
			if (PACKAGE_RE.match(text)) return PACKAGE_RE.matched(1);
		}
		return "";
	}

	/** 文件名 → 模块名：去 `.hx` 后缀（逐字；`.hx` 以外的后缀原样保留—
	 * —扫描器侧只收 .hx，这里不防御）。传入的是 basename 还是全路径都行：
	 * 只取最后一个 `/` 之后的段再剥后缀（目录名不进模块路径）。 */
	static public function moduleNameOf(fileName:String):String {
		var base = fileName;
		var slash = base.lastIndexOf("/");
		if (slash >= 0) base = base.substring(slash + 1);
		if (StringTools.endsWith(base, ".hx")) return base.substring(0, base.length - 3);
		return base;
	}

	/** 模块路径拼装：包声明 + 文件名（根包时即文件名，无点前缀）。 */
	static public function modulePathOf(pack:String, fileName:String):String {
		var name = moduleNameOf(fileName);
		if (pack == null || pack == "") return name;
		return pack + "." + name;
	}

	/** 全库查重：输入 entries 是 (path, lines) 对（path 是仓库相对路径
	 * 原样进报告）。输出冲突组名单：只含文件数 >1 的模块路径；组内文件
	 * 字典序、组间模块路径字典序（报告可 diff）。输入空/全零冲突 → []。 */
	static public function findConflicts(entries:Array<ModuleEntry>):Array<ModuleConflict> {
		var byPath = new Map<String, Array<String>>();
		for (e in entries) {
			var mp = modulePathOf(parsePackage(e.lines), e.path);
			if (!byPath.exists(mp)) byPath.set(mp, []);
			byPath.get(mp).push(e.path);
		}
		var conflicts:Array<ModuleConflict> = [];
		for (mp => files in byPath) {
			if (files.length > 1) {
				files.sort(Reflect.compare);
				conflicts.push({modulePath: mp, files: files});
			}
		}
		conflicts.sort(function(a:ModuleConflict, b:ModuleConflict):Int {
			return Reflect.compare(a.modulePath, b.modulePath);
		});
		return conflicts;
	}

	/** 冲突组 → 人读报告行集（每组首行模块路径、随后每文件一行缩进列
	 * 出——脚本侧拼报告时逐行打出；形状由测试钉死）。 */
	static public function renderConflict(c:ModuleConflict):Array<String> {
		var lines = [c.modulePath + " —— " + c.files.length + " 个文件同模块路径："];
		for (f in c.files) lines.push("  " + f);
		return lines;
	}

	/** package 语句形态（类头）：行前空白 + package + 包名（可空，即
	 * `package;`）+ 尾分号；分号后的行内注释已被剔除。EReg 刻意不用
	 * 前瞻（eval 的 lookahead 退化坑，handbook/lessons #63），纯顺序匹配。 */
	static final PACKAGE_RE = ~/^[ \t]*package[ \t]*([A-Za-z0-9_.]*)[ \t]*;/;
}

/** 扫描输入项：一个 .hx 文件的路径与行集。 */
typedef ModuleEntry = {
	/** 仓库相对路径原样（报告里给人看，本类不规范化）。 */
	var path:String;
	/** 文件行集（按 \n 切好；扫描器侧读文件切行）。 */
	var lines:Array<String>;
}

/** 一组模块路径冲突。 */
typedef ModuleConflict = {
	/** 冲突的模块路径（如 tools.TimelineTypes）。 */
	var modulePath:String;
	/** 撞车的文件名单（字典序）。 */
	var files:Array<String>;
}
