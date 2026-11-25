package tools;

import sys.io.File;
import sys.FileSystem;

/**
 * issue #63 基类 Dynamic 字段盲区——脚本侧胶水：scan_dyn_writes 的基类扩展
 * 通道接线（issue 修法方向之二「已知基类字段名单」＝ collect 真实基类 +
 * 内置家族名单兜底）。纯逻辑（行级判式）在 DynWriteScan，契约由
 * test/tools/BaseFieldScanTest.hx 钉死；本类只做「走目录 → 收基类字段 →
 * 逐文件扫 → 打报告」。
 *
 * 与 python 半边（tools/scan_dyn_writes.py）的关系：python 版保持原样，管
 * 局部变量/本文件声明的 Dynamic 生产者写通道（53 行基线清单形状不变——
 * 本通道与它在 `var x:Dynamic` 声明的写上重叠，**输出按行去重**，合跑不
 * 翻倍）；本通道补它看不见的基类继承面（写 Invalid field 炸、读静默 null，
 * 出处 issue #63 机制节）。
 *
 * extends 链选型（issue 允许二选一）：不解析跨文件继承图——基类字段的
 * 判定与接收者是不是「真子类实例」无关（基类家族名 m_view/m_model 的字段
 * 接触在所有文件里都按命中报，triage 由人/agent 按行上下文分诊，与
 * python 版「启发式、误报供分诊」的既定口径一致）。collect 真实基类
 * （src/framework/base/Controller.hx）保证名单跟随源码漂移，内置家族名单
 * 保证基类声明形态变化时不静默失守。
 *
 * 用法（仓库根）：
 *
 *     haxe -cp tools --run tools.DynWriteScanRun [src 目录，默认 ./src]
 *
 * 输出：file:line <TAB> 变量 <TAB> .属性 <TAB> kind <TAB> 代码行（python 版
 * 输出形状 + kind 列）。退出码恒 0（与 python 版同为报告式启发式，不作硬
 * 门禁——CLAUDE.md「收工自检」的分诊在人）。
 */
class DynWriteScanRun {
	/** 内置基类家族名单（issue #63「更省事」方向的兜底）：collect 之外
	 * 恒在。m_view/m_model 是 framework/base/Controller 的 Dynamic 字段族。 */
	static final KNOWN_BASE_FIELDS = ["m_view", "m_model"];

	static function main() {
		var args = Sys.args();
		var src = args.length > 0 ? args[0] : "src";
		if (!FileSystem.exists(src) || !FileSystem.isDirectory(src)) {
			Sys.stderr().writeString("DynWriteScanRun: 找不到 src 目录 " + src + "\n");
			Sys.exit(2);
		}

		// 1) 收全库 .hx（排序确定——遍历序即输出序）
		var files:Array<String> = [];
		walk(src, files);
		files.sort(Reflect.compare);

		// 2) 基类字段名单 = 内置家族 ∪ m_ 前缀形态的基类字段——collect 只收
		//    framework/base/Controller.hx 一族**真正 declare-and-inherit 的基
		//    类**（m_view/m_model 家族出处）。试过两条更宽的并集，全是噪声炸
		//    弹（2026-11-25 实测，教训已进 handbook/lessons）：
		//    - 全库 collect：`var t:Dynamic` 这类局部声明常用名进名单，无关文
		//      件的 typed 文本字段全染命中（9000+ 行）；
		//    - extends 链全量：Window 一族基类的 `_data/_item/effect` 字段名
		//      与全库局部变量常用名碰撞（500+ 行），且 `_locN` 反编译临时名
		//      同染（已在 collect 侧排除 `_locN`）。
		//    收束口径：**m_ 前缀是 Controller 家族的命名约定**（m_view/m_model
		//    /m_module），只有它同时满足「基类继承字段」与「不会和局部变量
		//    撞名」——非 m_ 前缀的 Dynamic 类字段（Window 一族）不在本通道
		//    登记面（python 通道的文件内 DECL_DYN 已覆盖同文件写）。
		var extended = new Map<String, Bool>();
		var extendsRe = ~/\bextends\s+([A-Za-z_][A-Za-z0-9_]*)/;
		for (path in files) {
			for (line in readLines(path)) {
				if (extendsRe.match(line)) extended.set(extendsRe.matched(1), true);
			}
		}
		var baseFields = new Map<String, Bool>();
		for (name in KNOWN_BASE_FIELDS) baseFields.set(name, true);
		var mPrefix = ~/^m_[A-Za-z]/;
		for (path in files) {
			var className = path.split("/").pop().substr(0, -3); // 去 .hx
			if (!extended.exists(className)) continue;
			for (name in DynWriteScan.collect(readLines(path)).keys()) {
				if (mPrefix.match(name)) baseFields.set(name, true);
			}
		}

		// 3) 逐文件扫描，(path, line, variable, prop) 去重（与 python 通道/写读
		//    两形态的同行重叠合并——写优先：同位 write 是更强信号，read 不另报）
		var seen = new Map<String, Bool>();
		var total = 0;
		for (path in files) {
			for (hit in DynWriteScan.scanLines(readLines(path), baseFields, path)) {
				var key = hit.path + ":" + hit.line + ":" + hit.variable + "." + hit.prop;
				if (seen.exists(key)) continue;
				seen.set(key, true);
				Sys.println(hit.path + ":" + hit.line + "\t" + hit.variable + "\t." + hit.prop + "\t" + hit.kind + "\t" + hit.code);
				total++;
			}
		}
		Sys.println("-- " + total + " dynamic field reads/writes (base-field channel)");
	}

	static function walk(dir:String, out:Array<String>):Void {
		for (name in FileSystem.readDirectory(dir)) {
			var path = dir + "/" + name;
			if (FileSystem.isDirectory(path)) {
				walk(path, out);
			} else if (StringTools.endsWith(name, ".hx")) {
				out.push(path);
			}
		}
	}

	static function readLines(path:String):Array<String> {
		var lines = File.getContent(path).split("\n");
		if (lines.length > 0 && lines[lines.length - 1] == "") lines.pop(); // 尾换行
		return lines;
	}
}
