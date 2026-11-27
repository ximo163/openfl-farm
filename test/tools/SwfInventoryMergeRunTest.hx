package tools;

import sys.io.File;
import sys.FileSystem;
import utest.Assert;

/**
 * issue #95：swf-inventory 生成器保留接线 runner 的契约门（write-tests
 * 阶段对 stub 失败）。被测 tools.SwfInventoryMergeRun 是脚本侧胶水：读
 * 旧清单/生成产物两份文件 → 调 SwfInventoryMerge.merge → 写回 spec 路径
 * → 每保留一条手写块打一行 `keep <path> <键>` 进 stdout。判式（merge
 * 本体）在 tools.SwfInventoryMerge，契约由 SwfInventoryMergeTest 钉死；
 * 本测试钉的是 runner 的**接线面**——#95 原文「判式类无静态 main：接
 * 线需要一个 runner（#70 的 tools/tools/TestStubScanRun.hx 同款形态，
 * tools/ 可写）」「runner 随接线同做，不拆」。stub 在 tools/tools/
 * SwfInventoryMergeRun.hx（main 立刻抛，「stub 归树」规矩，implement
 * 原地填充）。
 *
 * 为什么必须钉 runner 面而不是只钉判式：#83 的教训就是「判式交付、接
 * 线悬空」——merge 判式与 21 个契约用例全绿、在 main 躺了两天，CI 里
 * 零调用（// issue #95 背景「全仓引用 SwfInventoryMerge 的只有判式本
 * 体、测试、handbook 页」）。判式逻辑再对，没有 runner 它就是死代码。
 * 本测试锁的是 runner 的四个不可让渡面：
 *
 * 1. 入口存在：haxe -cp tools --run tools.SwfInventoryMergeRun 调得起来
 *    （TestStubScanRun 先例同款形态）；命令行模块名写法以仓库 runner 先
 *    例为准（tools/scan_test_stubs.py 调 tools.TestStubScanRun——包
 *    tools 单层，「tools.tools」是文件系统路径不是模块路径）。
 * 2. 三文件位参契约：<旧清单路径> <生成产物路径> <写回路径>——与 #95
 *    行动项 1 的接线描述同构（「生成产物先写临时文件 → 调判式 merge
 *    （旧文件, 生成产物) → 写回 spec/swf-inventory.json」）。
 * 3. keep 报告行：每保留一条手写块一行 `keep <path> <键,逗号连接>`进
 *    stdout（// issue #95 原文「保留行打 keep <path> <键> 进 CI 日志
 *    （判式的 reportLine 已备）」——reportLine 形状本身由
 *    SwfInventoryMergeTest.test_report_line_shape 钉死，这里钉 runner
 *    真的把它打出来）。
 * 4. 退出码三态：0 = merge 成功；1 = 判式抛出生成器形状异常（生成器坏
 *    了不得静默绿，SwfInventoryMerge 类头契约的脚本侧落点）；2 = 用法/
 *    环境错（TestStubScanRun 先例「门跑不起来＝不放行」）。
 *
 * runner 是进程面（起 haxe 子进程），单测不 sleep、不联网——拉起方式
 * 与 scan_test_stubs.py/scan_module_paths.py 的 python 壳同款
 * （Sys.command 调 haxe，秒级；--run 是解释执行不编 cpp）。文件读写用
 * 临时目录，不进 test/ 树（test/ 是定稿区，语料文件归 fixtures——但
 * runner 测试的语料是**运行时**拼装的最小清单文本，与
 * SwfInventoryMergeTest 内联语料同族，不值得入库 fixture）。
 */
class SwfInventoryMergeRunTest {
	public function new() {}

	static final RUNNER_CMD_ARGS = "-cp tools --run tools.SwfInventoryMergeRun";

	/** 生成器产出形态的单条目（与 SwfInventoryMergeTest 同族语料）。 */
	static function machineEntry(path:String):String {
		return '{"path": "' + path + '", "bytes": 1000, "category": "ui", "fps": 24, "frames": 1, "stage": [500, 375]}';
	}

	/** 带手写 code 块的条目（84c203bb 五键形态，`git show 84c203bb` 出处）。 */
	static function codedEntry(path:String):String {
		return '{"path": "' + path + '", "bytes": 1000, "category": "ui", "fps": 24, "frames": 1, "stage": [500, 375], '
			+ '"code": {"decompiled": "legacy/decompiled/shop_v_7/", "symbol_class": "module.shop.ShopWrapper", '
			+ '"classes": 25, "module_spec": "spec/modules/farm-shop-ui.json", "note": "功能 UI 代码 swf"}}';
	}

	static function inventoryDoc(entries:Array<String>):String {
		return '{"version": 1, "source": "legacy/deploy/QFarmFlash/source/core/module", "count": '
			+ entries.length + ', "swfs": [' + entries.join(", ") + ']}';
	}

	/** 临时三文件面：旧清单/生成产物/写回路径。目录名带测试语义（出事
	 * 时一眼看出是谁留下的）；用完即清（teardown 是进程面测试的基本卫
	 * 生——仓库里不留运行残骸）。 */
	static function makeSandbox(name:String):String {
		var dir = "export/tmp-swfmerge-" + name;
		if (FileSystem.exists(dir)) wipe(dir);
		FileSystem.createDirectory(dir);
		return dir;
	}

	static function wipe(dir:String):Void {
		for (n in FileSystem.readDirectory(dir)) {
			var p = dir + "/" + n;
			if (FileSystem.isDirectory(p)) wipe(p); else FileSystem.deleteFile(p);
		}
		FileSystem.deleteDirectory(dir);
	}

	static function writeFile(path:String, content:String):Void {
		File.saveContent(path, content);
	}

	/** 拉起 runner（进程面）。返回 (exitCode, stdout)。stderr 与 stdout
	 * 合并——判式抛出/usage 错都走 stderr，断言面只需要「出口文本里有
	 * 没有证据」，不分两路（TestStubScanRun 先例的 python 壳同样透传合
	 * 并输出）。 */
	static function runRunner(args:Array<String>):{code:Int, out:String} {
		var cmd = "haxe " + RUNNER_CMD_ARGS + " " + args.join(" ") + " 2>&1";
		var p = new sys.io.Process(cmd);
		var out = p.stdout.readAll().toString();
		var code = p.exitCode(true);
		return {code: code, out: out};
	}

	// ------------------------------------------------------------------
	// 接线面一：三文件 merge 全回路（#95 行动项 1 的 runner 落点）

	function test_runner_merges_and_writes_back() {
		// // issue #95 行动项 1 原文回路「生成产物先写临时文件 → 调判式
		// merge(旧文件, 生成产物) → 写回 spec/swf-inventory.json」的进程面
		// 重演：旧文件带 code 块、生成产物纯机器面 → 写回文件里 code 块存
		// 活且机器键以新为准。判式细节（逐字搬运/键序/幂等）归
		// SwfInventoryMergeTest，这里只锁「runner 真的把 merge 接上了」
		var dir = makeSandbox("roundtrip");
		try {
			writeFile(dir + "/old.json", inventoryDoc([codedEntry("module/ui/shop_v_7.swf")]));
			writeFile(dir + "/gen.json", inventoryDoc(['{"path": "module/ui/shop_v_7.swf", "bytes": 2222, "category": "ui", "fps": 24, "frames": 1, "stage": [500, 375]}']));
			var r = runRunner([dir + "/old.json", dir + "/gen.json", dir + "/out.json"]);
			Assert.equals(0, r.code, "merge 成功退出码必须 0；输出： " + r.out);
			Assert.isTrue(FileSystem.exists(dir + "/out.json"), "写回路径必须有产物");
			var doc:Dynamic = haxe.Json.parse(File.getContent(dir + "/out.json"));
			var entries:Array<Dynamic> = cast Reflect.field(doc, "swfs");
			Assert.equals(1, entries.length);
			Assert.equals(2222, Reflect.field(entries[0], "bytes"), "机器面以生成产物为准（runner 不掺和 merge 语义）");
			Assert.notNull(Reflect.field(entries[0], "code"), "手写 code 块经 runner 存活——这是 #95 接线存在的意义本身");
		} catch (e:Dynamic) {
			wipe(dir);
			throw e;
		}
		wipe(dir);
	}

	function test_runner_prints_keep_lines_for_preserved_blocks() {
		// // issue #95 原文「保留行打 keep <path> <键> 进 CI 日志（判式的
		// reportLine 已备）」：runner 的 stdout 里必须出现 reportLine 形态
		// 的行——CI 日志是人/机读分拣面，「merge 跑没跑、保住了什么」要
		// 一眼可查（#83 零调用事故里根本没有这个面，出了事只能事后 grep）
		var dir = makeSandbox("keepline");
		try {
			writeFile(dir + "/old.json", inventoryDoc([codedEntry("module/ui/shop_v_7.swf")]));
			writeFile(dir + "/gen.json", inventoryDoc([machineEntry("module/ui/shop_v_7.swf")]));
			var r = runRunner([dir + "/old.json", dir + "/gen.json", dir + "/out.json"]);
			Assert.equals(0, r.code, "merge 成功退出码必须 0；输出： " + r.out);
			Assert.stringContains("keep module/ui/shop_v_7.swf code", r.out,
				"stdout 必须有 keep 行（#95：保留行进 CI 日志——分拣面不是可选项）");
		} catch (e:Dynamic) {
			wipe(dir);
			throw e;
		}
		wipe(dir);
	}

	function test_runner_no_keep_line_when_nothing_preserved() {
		// 旧文件无手写面（纯机器清单——首次生成形态）→ 零 keep 行但退出
		// 码 0：「没有可保留的」不是错，照常输出（// issue #83 决策点 a
		// 原文「新生成条目无手写键则照常输出」的 runner 侧镜像）
		var dir = makeSandbox("nokeep");
		try {
			writeFile(dir + "/old.json", inventoryDoc([machineEntry("module/ui/shop_v_7.swf")]));
			writeFile(dir + "/gen.json", inventoryDoc([machineEntry("module/ui/shop_v_7.swf")]));
			var r = runRunner([dir + "/old.json", dir + "/gen.json", dir + "/out.json"]);
			Assert.equals(0, r.code);
			Assert.isTrue(r.out.indexOf("keep module/ui/") < 0, "无手写面不得增生 keep 行（照常输出的分拣面是安静）");
		} catch (e:Dynamic) {
			wipe(dir);
			throw e;
		}
		wipe(dir);
	}

	// ------------------------------------------------------------------
	// 接线面二：退出码三态（TestStubScanRun 先例的失败方向——门跑不起
	// 来＝不放行）

	function test_runner_exit_1_when_generated_text_malformed() {
		// 生成器产出坏了 → 判式抛出（SwfInventoryMerge 类头契约）→ runner
		// 退 1 且**不得写出产物**（// issue #83「防生成器坏了还写出绿文
		// 件」的脚本侧落点：写回路径上有文件 = 再生成回路把它当新基线提
		// 交，坏清单就此入库）
		var dir = makeSandbox("badgen");
		try {
			writeFile(dir + "/old.json", inventoryDoc([codedEntry("module/ui/shop_v_7.swf")]));
			writeFile(dir + "/gen.json", "{not json");
			var r = runRunner([dir + "/old.json", dir + "/gen.json", dir + "/out.json"]);
			Assert.equals(1, r.code, "生成产物形状不符必须退 1（生成器坏了不是用法错也不是成功）");
			Assert.isFalse(FileSystem.exists(dir + "/out.json"), "判式拒绝时写回路径必须无产物（坏清单不得入库）");
			Assert.isTrue(r.out.indexOf("not implemented") < 0,
				"退 1 的证据行不得是待填惯用语——撞上说明 runner 根本没实现（扫描语料在字符串内，机器门零误伤）");
		} catch (e:Dynamic) {
			wipe(dir);
			throw e;
		}
		wipe(dir);
	}

	function test_runner_exit_2_on_usage_error() {
		// 用法错（参数不足三个路径）→ 退 2（TestStubScanRun/ModulePathScanRun
		// 先例同款三态：0 净 / 1 有缺口 / 2 用法环境错——「门跑不起来＝不
		// 放行，失败方向一致」）
		var r = runRunner(["only-one-arg"]);
		Assert.equals(2, r.code, "参数不足必须退 2（用法错与环境错同档，先例 TestStubScanRun）");
	}

	function test_runner_exit_2_when_input_file_missing() {
		// 输入文件读不到（生成产物路径写错/临时文件没落盘）→ 退 2：这是
		// 环境错不是生成器产出坏——判式都没机会跑，runner 侧的环境面
		var dir = makeSandbox("missing");
		try {
			writeFile(dir + "/old.json", inventoryDoc([machineEntry("module/ui/x.swf")]));
			var r = runRunner([dir + "/old.json", dir + "/no-such-gen.json", dir + "/out.json"]);
			Assert.equals(2, r.code, "输入文件不在必须退 2（环境错——判式没跑起来，不是判式拒绝）");
			Assert.isFalse(FileSystem.exists(dir + "/out.json"));
		} catch (e:Dynamic) {
			wipe(dir);
			throw e;
		}
		wipe(dir);
	}

	// ------------------------------------------------------------------
	// 接线面三：写回产物形状（再生成回路 diff 干净面的 runner 落点）

	function test_runner_output_roundtrips_through_python_json_dump_shape() {
		// 写回文件必须是 json.dump(indent=1, ensure_ascii=False) 同形态
		// （缩进 1 空格、UTF-8 非 ASCII 不转义）——再生成回路的下一次
		// merge 以它为 oldText，形态漂移会让 6290 条大文件整文件翻烧饼
		// （判式的幂等契约在 SwfInventoryMergeTest 钉死；这里锁 runner 写
		// 盘不掺水分：原样落盘判式输出，不再 serialize 一遍）
		var dir = makeSandbox("shape");
		try {
			writeFile(dir + "/old.json", inventoryDoc([codedEntry("module/ui/shop_v_7.swf")]));
			writeFile(dir + "/gen.json", inventoryDoc([machineEntry("module/ui/shop_v_7.swf")]));
			var r = runRunner([dir + "/old.json", dir + "/gen.json", dir + "/out.json"]);
			Assert.equals(0, r.code);
			var outText = File.getContent(dir + "/out.json");
			var lines = outText.split("\n");
			var oneSpaceIndent = [for (l in lines) if (StringTools.startsWith(l, " ") && !StringTools.startsWith(l, "  ")) l];
			Assert.isTrue(oneSpaceIndent.length > 0, "写回文件有 1 空格缩进行（json.dump indent=1 形态，6290 条实文件零 diff 验证过的判式输出）");
			// note 里的中文必须原样（ensure_ascii=False——写回文本里找得到
			// 汉字字面，不是 \uXXXX 转义）
			Assert.stringContains("功能", outText, "非 ASCII 不转义（ensure_ascii=False 形态）");
		} catch (e:Dynamic) {
			wipe(dir);
			throw e;
		}
		wipe(dir);
	}
}
