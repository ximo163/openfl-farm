package tools;

import sys.io.File;

/**
 * issue #95：swf-inventory 生成器手写增补保留的脚本侧胶水 runner（契约
 * 由 test/tools/SwfInventoryMergeRunTest.hx 钉死）。
 *
 * 为什么存在：#83 交付的判式 tools.SwfInventoryMerge 无静态 main，「全
 * 仓引用 SwfInventoryMerge 的只有判式本体、测试、handbook 页」（#95 背
 * 景——零调用是 #83 半件交付的实锤）。#95 行动项 1 原文：「判式类无静
 * 态 main：接线需要一个 runner（#70 的 tools/tools/TestStubScanRun.hx
 * 同款形态，tools/ 可写）」「runner 随接线同做，不拆」。
 *
 * 职责：读旧 spec/swf-inventory.json 与生成器本次产出（临时文件）→ 调
 * SwfInventoryMerge.merge → 写回路径落盘；每保留一条手写块打一行
 * `keep <path> <键,逗号连接>`（SwfInventoryMerge.reportLine 形态）进
 * stdout——#95 原文「保留行打 keep <path> <键> 进 CI 日志（判式的
 * reportLine 已备）」。退出码：0 = merge 成功；1 = 判式抛出生成器形状
 * 异常（生成器坏了不得静默绿）；2 = 用法/环境错（TestStubScanRun 先例
 * 「门跑不起来＝不放行，失败方向一致」）。
 *
 * 用法（仓库根）：
 *
 *     haxe -cp tools --run tools.SwfInventoryMergeRun <旧清单路径> <生成产物路径> <写回路径>
 *
 * 与 scripts/swf-inventory.py 的接线关系（#95 行动项 1）：生成器落盘改
 * 为「生成产物先写临时文件 → 调本 runner merge(旧文件, 生成产物) → 写回
 * spec/swf-inventory.json」；scripts/ 是人管路径，接线 edit 归人，本类只
 * 提供 tools/ 侧的入口——判式单源不破（#63：merge 逻辑只在
 * SwfInventoryMerge 一份，本类零 merge 逻辑拷贝）。
 */
class SwfInventoryMergeRun {
	static function main() {
		var args = Sys.args();
		if (args.length != 3) {
			Sys.stderr().writeString("SwfInventoryMergeRun: 用法： haxe -cp tools --run tools.SwfInventoryMergeRun"
				+ " <旧清单路径> <生成产物路径> <写回路径>\n");
			Sys.exit(2);
		}
		var oldText:String;
		var genText:String;
		try {
			oldText = File.getContent(args[0]);
			genText = File.getContent(args[1]);
		} catch (e:Dynamic) {
			// 读不到输入是环境错（生成产物没落盘/路径写错）——判式都没机会
			// 跑，与判式拒绝（退 1）分档（TestStubScanRun 先例三态）
			Sys.stderr().writeString("SwfInventoryMergeRun: 输入文件读取失败（" + args[0] + " / " + args[1] + "）：" + Std.string(e) + "\n");
			Sys.exit(2);
			return;
		}
		var merged:String;
		try {
			merged = SwfInventoryMerge.merge(oldText, genText);
		} catch (e:Dynamic) {
			// 判式拒绝 = 生成器产出形状不符（生成器坏了不得静默绿）——退出
			// 码 1，且写回路径上不留产物（坏清单不得入库，再生成回路会把写回
			// 路径的文件当新基线提交）
			Sys.stderr().writeString("SwfInventoryMergeRun: merge 判式拒绝——" + Std.string(e) + "\n");
			Sys.exit(1);
			return;
		}
		// keep 行先于落盘：CI 日志的分拣面是「保住了什么」——merge 语义
		// （配对键 path、手写键 = 键集减机器键闭集）这里复算一次只做报告，
		// 不进 merge 逻辑本体（判式单源不破：搬运本身是 SwfInventoryMerge
		// 干的，本类只是用同一规则把结果说出来）
		for (line in keepLines(oldText, genText)) {
			Sys.println(line);
		}
		try {
			// 判式输出原样落盘（不再 serialize 一遍——json.dump(indent=1,
			// ensure_ascii=False) 形态逐字保留，再生成回路的 diff 干净面）
			File.saveContent(args[2], merged);
		} catch (e:Dynamic) {
			Sys.stderr().writeString("SwfInventoryMergeRun: 写回失败（" + args[2] + "）：" + Std.string(e) + "\n");
			Sys.exit(2);
			return;
		}
		Sys.exit(0);
	}

	/** 保留面报告：旧文件里带手写键的条目，凡同 path 出现在新清单里的，
	 * 逐条出一行 SwfInventoryMerge.reportLine（手写键名按字典序——与
	 * merge 输出的键序同规则）。旧文件形状不符/无手写面时零行（「没有可
	 * 保留的」不是错，照常输出的分拣面是安静）。 */
	static function keepLines(oldText:String, genText:String):Array<String> {
		var genPaths = new Map<String, Bool>();
		var genEntries:Array<Dynamic> = tryEntriesOf(genText);
		for (e in genEntries) {
			var p = pathOf(e);
			if (p != null) genPaths.set(p, true);
		}
		var lines = new Array<String>();
		for (e in tryEntriesOf(oldText)) {
			var p = pathOf(e);
			if (p == null || !genPaths.exists(p)) continue;
			var keys = SwfInventoryMerge.handwrittenKeysOf(e);
			if (keys.length == 0) continue;
			lines.push(SwfInventoryMerge.reportLine(p, keys));
		}
		return lines;
	}

	/** 清单文本的 swfs 条目数组（形状不符/非法 JSON 按空面——报告面宽免
	 * 与 merge 对 oldText 的语义同族；genText 形状不符时 merge 早已抛出，
	 * 这里只是防御同形）。 */
	static function tryEntriesOf(text:String):Array<Dynamic> {
		var parsed:Dynamic = try haxe.Json.parse(text) catch (e:Dynamic) return [];
		if (parsed == null || !Reflect.isObject(parsed) || Std.isOfType(parsed, Array)) return [];
		var swfs:Dynamic = Reflect.field(parsed, "swfs");
		if (!Std.isOfType(swfs, Array)) return [];
		return cast swfs;
	}

	static function pathOf(entry:Dynamic):Null<String> {
		if (entry == null || !Reflect.isObject(entry) || Std.isOfType(entry, Array)) return null;
		var p:Dynamic = Reflect.field(entry, "path");
		return Std.isOfType(p, String) ? cast p : null;
	}
}
