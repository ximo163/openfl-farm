package tools;

import sys.io.File;
import utest.Assert;

/**
 * issue #95：swf-inventory 再生成对账门的判式契约（write-tests 阶段对
 * stub 失败）。被测 tools.SwfInventoryReconcile 只做 JSON 文本进 → 对账
 * 结果出的纯逻辑（stub 在 tools/tools/SwfInventoryReconcile.hx，「stub
 * 归树」规矩，implement 原地填充）；读文件/exit 码/进 checks/ 的壳归
 * implement + 人（scripts/、checks/ 人管，#95「执行模式与路由」节），本
 * 门只钉判式。
 *
 * 为什么这门存在：#83 完成标准原文「『死了无人察觉』不再可能」——
 * #30 四条手写块 2026-11-22 交付、399a5faa（2026-11-24 CI 再生成）抹
 * 掉、到 #85 合并（2026-11-26）都无人察觉，暴露周期以天计。#95 行动项
 * 2：「再生成对账门——再生成前后手写键集合对账，任何已登记手写块消失
 * 即红」。本测试把「红什么」钉死：缺口三态（条目消失/键消失/值变）、
 * 单文件自检、工作流接线静态对账、报告行形状。
 *
 * 期望值出处（原版没有的工具，全部 // issue #95 / #83）：
 * - 缺口即红：// issue #95 要什么 2 原文「任何已登记手写块消失即红」。
 * - 手写键判定：与 SwfInventoryMerge 同规则（条目键集减机器键闭集），
 *   出处 // issue #83 决策点 a；机器键闭集出处 scripts/swf-inventory.py
 *   :97-105（path/bytes/category/fps/frames/stage/unparsed）。
 * - 配对键 path 逐字：// issue #83 判式契约（SwfInventoryMerge 类头保
 *   留规则 1：「配对键是 path」），对账门与 merge 共用同一配对语义——
 *   否则 merge 保住的块对账门不认、或反过来。
 * - 工作流接线证据形态：// issue #95 要什么 1 原文「legacy-decompile.
 *   yml 补装 haxe 调 haxe -cp tools --run tools.tools.SwfInventoryMergeRun」
 *   ——命令行里模块名的实际写法以仓库既有 runner 先例为准
 *   （tools/scan_test_stubs.py 调的是 tools.TestStubScanRun，包 tools
 *   单层——「tools.tools」是文件系统路径，模块路径是 tools.XxxRun）。
 * - 报告行形状：`reconcile <kind> <path> <key>`（// issue #95 行动项 2
 *   的对账门机读面，与 SwfInventoryMerge.reportLine 的 `keep <path>
 *   <键>` 互补——#95 原文「保留行打 keep <path> <键> 进 CI 日志」）。
 */
class SwfInventoryReconcileTest {
	public function new() {}

	// ------------------------------------------------------------------
	// 语料拼装（与 SwfInventoryMergeTest 同族的最小 JSON 形态——对账门与
	// merge 共用同一份清单形状，缩进/键序不影响判式，parse 级比对）

	/** 生成器产出形态的单条目（机器键全键：scripts/swf-inventory.py:97-105）。 */
	static function machineEntry(path:String):String {
		return '{"path": "' + path + '", "bytes": 1000, "category": "ui", "fps": 24, "frames": 1, "stage": [500, 375]}';
	}

	/** 带手写 code 块的条目（84c203bb 五键形态，`git show 84c203bb` 出处）。 */
	static function codedEntry(path:String, ?note:String = "功能 UI 代码 swf"):String {
		return '{"path": "' + path + '", "bytes": 1000, "category": "ui", "fps": 24, "frames": 1, "stage": [500, 375], '
			+ '"code": {"decompiled": "legacy/decompiled/x/", "symbol_class": "module.x.XWrapper", '
			+ '"classes": 1, "module_spec": "spec/modules/x.json", "note": "' + note + '"}}';
	}

	static function inventoryDoc(entries:Array<String>):String {
		return '{"version": 1, "source": "legacy/deploy/QFarmFlash/source/core/module", "count": '
			+ entries.length + ', "swfs": [' + entries.join(", ") + ']}';
	}

	static function gapsOf(r:Dynamic):Array<Dynamic> {
		return cast Reflect.field(r, "gaps");
	}

	static function gapKinds(r:Dynamic):Array<String> {
		return [for (g in gapsOf(r)) Std.string(Reflect.field(g, "kind"))];
	}

	// ------------------------------------------------------------------
	// reconcile：再生成前后手写键集合对账（#95 行动项 2 核心面）

	function test_reconcile_passes_when_all_handwritten_keys_survive() {
		// // issue #95 完成标准「#30 四条 + #85 三条全部存活」的判式形态：
		// 前后两份文件手写面一致 → 零缺口、pass
		var oldText = inventoryDoc([codedEntry("module/ui/shop_v_7.swf"), machineEntry("module/ui/plain_v_0.swf")]);
		var newText = inventoryDoc([codedEntry("module/ui/shop_v_7.swf"), machineEntry("module/ui/plain_v_0.swf")]);
		var r = SwfInventoryReconcile.reconcile(oldText, newText);
		Assert.isTrue(Reflect.field(r, "pass"), "手写面一致时对账必须绿（再生成正常走完 merge 的形态）");
		Assert.same([], [for (g in gapsOf(r)) Reflect.field(g, "kind")]);
	}

	function test_reconcile_missing_key_when_block_erased() {
		// 399a5faa 同型事故的判式重演：旧文件带 code 块、新文件同 path
		// 条目只剩机器键——手写块被裸重写抹掉（生成器接线漏跑 merge 的
		// 产出形态）。必须红且 kind 是 missing_key
		// （// issue #95 背景「已被 399a5faa 抹死至今未恢复」）
		var oldText = inventoryDoc([codedEntry("module/ui/shop_v_7.swf")]);
		var newText = inventoryDoc([machineEntry("module/ui/shop_v_7.swf")]);
		var r = SwfInventoryReconcile.reconcile(oldText, newText);
		Assert.isFalse(Reflect.field(r, "pass"), "手写块被抹必须红（#95：任何已登记手写块消失即红）");
		var gaps = gapsOf(r);
		Assert.equals(1, gaps.length);
		Assert.equals("missing_key", Std.string(Reflect.field(gaps[0], "kind")));
		Assert.equals("module/ui/shop_v_7.swf", Std.string(Reflect.field(gaps[0], "path")));
		Assert.equals("code", Std.string(Reflect.field(gaps[0], "key")));
	}

	function test_reconcile_missing_entry_when_swf_disappears() {
		// 条目整体消失（swf 被删/改名）：手写块随条目消失同样是「死了」
		// ——要么真删了该先清手写登记，要么是事故，对账门不替人裁决、照红
		// （// issue #95「任何已登记手写块消失即红」不设例外）
		var oldText = inventoryDoc([codedEntry("module/ui/dead_v_0.swf")]);
		var newText = inventoryDoc([machineEntry("module/ui/other_v_0.swf")]);
		var r = SwfInventoryReconcile.reconcile(oldText, newText);
		Assert.isFalse(Reflect.field(r, "pass"));
		Assert.contains("missing_entry", gapKinds(r));
	}

	function test_reconcile_altered_when_value_changes() {
		// 键还在但值变了：merge 搬运逐字（// issue #83 判式契约），值变
		// 只能是绕开判式的手改或腐化——对账门钉住「手写块的内容也归对账」，
		// 不只是键的存在性
		var oldText = inventoryDoc([codedEntry("module/ui/shop_v_7.swf", "原文 note")]);
		var newText = inventoryDoc([codedEntry("module/ui/shop_v_7.swf", "被改过的 note")]);
		var r = SwfInventoryReconcile.reconcile(oldText, newText);
		Assert.isFalse(Reflect.field(r, "pass"), "手写块值被改必须红（逐字搬运的反面就是对账面）");
		Assert.contains("altered", gapKinds(r));
	}

	function test_reconcile_value_compare_is_json_semantic_not_whitespace() {
		// 值比对按 JSON 语义比（parse 后深比），不比原文子串——手写块在
		// 两份文件里的缩进/空白形态差异（json.dump 重排）不该造成假红；
		// 键序差异同理（JSON 对象无序）。这是「对人手正当重排宽容、对内容
		// 漂移红」的分界
		var oldText = '{"version": 1, "source": "x", "count": 1, "swfs": [{"path": "module/ui/shop_v_7.swf", "bytes": 1, "category": "ui", "fps": 24, "frames": 1, "stage": [500, 375], "code": {"decompiled":"legacy/decompiled/x/","symbol_class":"module.x.XWrapper","classes":1,"module_spec":"spec/modules/x.json","note":"n"}}]}';
		// 同值、不同空白与键序形态
		var newText = inventoryDoc(['{"path": "module/ui/shop_v_7.swf", "bytes": 1, "category": "ui", "fps": 24, "frames": 1, "stage": [500, 375], "code": {"note": "n", "module_spec": "spec/modules/x.json", "classes": 1, "symbol_class": "module.x.XWrapper", "decompiled": "legacy/decompiled/x/"}}']);
		var r = SwfInventoryReconcile.reconcile(oldText, newText);
		Assert.isTrue(Reflect.field(r, "pass"), "同值不同空白/键序不得假红（JSON 语义比对，不是原文子串比对）");
	}

	function test_reconcile_pure_machine_entries_never_gap() {
		// 机器键面的任何漂移（bytes 变了、条目增删）都不是对账对象——
		// 机器面永远以新生成为准（// issue #83 决策点 a「基线出账等机器
		// 生成部分不受影响」），对账门只管手写面
		var oldText = inventoryDoc([machineEntry("module/ui/plain_v_0.swf")]);
		var newText = inventoryDoc(['{"path": "module/ui/plain_v_0.swf", "bytes": 9999, "category": "ui", "fps": 24, "frames": 1, "stage": [500, 375]}', machineEntry("module/ui/added_v_1.swf")]);
		var r = SwfInventoryReconcile.reconcile(oldText, newText);
		Assert.isTrue(Reflect.field(r, "pass"), "纯机器条目的 bytes 漂移与新增条目不是手写面缺口");
	}

	function test_reconcile_machine_keys_are_not_handwritten_surface() {
		// 手写键判定与 merge 同规则（判式单源 // issue #83）：闭集七键
		// （swf-inventory.py:97-105）全缺的极端形态——旧条目连 unparsed
		// 都没有——也不出手写面缺口（闭集键消失是生成器契约事故，归生
		// 成器侧红，不归手写面对账）
		var oldText = inventoryDoc(['{"path": "module/ui/x_v_0.swf", "bytes": 1, "category": "ui", "unparsed": true}']);
		var newText = inventoryDoc(['{"path": "module/ui/x_v_0.swf", "bytes": 1, "category": "ui", "fps": 24, "frames": 1, "stage": [500, 375]}']);
		var r = SwfInventoryReconcile.reconcile(oldText, newText);
		Assert.isTrue(Reflect.field(r, "pass"), "unparsed→fps 形态切换是机器面（生成器头部解出与否），不是手写缺口");
	}

	function test_reconcile_handwritten_keys_beyond_code_also_reconciled() {
		// 判式按闭集减、不按 code 白名单加（// issue #83 同族，#66 教训
		// 「同族普查」）：triage 等未来手写键同规则进对账——键消失即红
		var oldText = inventoryDoc(['{"path": "module/ui/x_v_0.swf", "bytes": 1, "category": "ui", "fps": 24, "frames": 1, "stage": [500, 375], "triage": {"verdict": "material"}}']);
		var newText = inventoryDoc([machineEntry("module/ui/x_v_0.swf")]);
		var r = SwfInventoryReconcile.reconcile(oldText, newText);
		Assert.isFalse(Reflect.field(r, "pass"));
		var gaps = gapsOf(r);
		Assert.equals("triage", Std.string(Reflect.field(gaps[0], "key")), "code 之外的手写键同规则进对账（判式是减闭集）");
	}

	function test_reconcile_multiple_gaps_all_reported() {
		// #95 完成标准的对账形态：「#30 四条 + #85 三条全部存活」的反面
		// ——多块同死时逐块出缺口，不是只报第一块（分拣面要一眼看全）
		var paths = ["module/ui/shop_v_7.swf", "module/ui/warehouse_v_23.swf", "module/ui/pool_v_13.swf"];
		var oldText = inventoryDoc([for (p in paths) codedEntry(p)]);
		var newText = inventoryDoc([for (p in paths) machineEntry(p)]);
		var r = SwfInventoryReconcile.reconcile(oldText, newText);
		Assert.isFalse(Reflect.field(r, "pass"));
		Assert.equals(3, gapsOf(r).length, "三条手写块同死出三条缺口（不是首块即弃）");
	}

	function test_reconcile_gap_ordering_is_deterministic() {
		// gaps 排序确定（path 字典序）——输出是机读分拣面，顺序不稳就没
		// 法 diff（scripts/swf-inventory.py:111 排序语义同族：清单是确定
		// 性基线，对账报告同要求）
		var paths = ["module/ui/z_v_0.swf", "module/ui/a_v_0.swf", "module/ui/m_v_0.swf"];
		var oldText = inventoryDoc([for (p in paths) codedEntry(p)]);
		var newText = inventoryDoc([for (p in paths) machineEntry(p)]);
		var r = SwfInventoryReconcile.reconcile(oldText, newText);
		var got = [for (g in gapsOf(r)) Std.string(Reflect.field(g, "path"))];
		Assert.same(["module/ui/a_v_0.swf", "module/ui/m_v_0.swf", "module/ui/z_v_0.swf"], got);
	}

	// ------------------------------------------------------------------
	// reconcile：异常输入语义（与 SwfInventoryMerge 同族契约——旧宽新严）

	function test_reconcile_malformed_old_text_treated_as_no_handwritten() {
		// 旧文件不是合法 JSON（首次生成/损坏）→ 手写面视为空、对账绿—
		// —与 SwfInventoryMerge 的宽免语义对齐（// issue #83 类头契约：
		// 「首次生成/旧文件损坏不阻塞再生成」）。宽免的是「没有旧手写面
		// 可对」，不是「旧文件坏了」本身——那是 merge/脚本侧的面
		var newText = inventoryDoc([machineEntry("module/ui/shop_v_7.swf")]);
		var r = SwfInventoryReconcile.reconcile("{not json", newText);
		Assert.isTrue(Reflect.field(r, "pass"), "旧文件损坏按空手写面（首次生成不阻塞——与 merge 宽免同语义）");
	}

	function test_reconcile_malformed_new_text_throws() {
		// 新文件是生成器产出——坏了是生成器自身事故，抛出（调用方退非
		// 零），不静默绿（// issue #83 类头「防生成器坏了还写出绿文件」
		// 同款失败方向）。抛出的只能是判式侧的拒绝，不是 stub 的待填惯用
		// 语——后者撞上说明实现根本没写
		var raised = false;
		var caughtStub = false;
		try {
			SwfInventoryReconcile.reconcile(inventoryDoc([]), "{not json");
		} catch (e:Dynamic) {
			raised = true;
			if (Std.string(e).indexOf("not implemented") >= 0) caughtStub = true;
		}
		Assert.isTrue(raised, "newText 形状不符必须抛出（生成器坏了不得静默绿）");
		Assert.isFalse(caughtStub, "抛出的须是判式侧的形状拒绝，不是待填惯用语");
	}

	// ------------------------------------------------------------------
	// reconcileLive：单文件自检形态（#95 行动项 2「或并入」裁决空间——
	// 常规 CI/收工自检只有现文件一份时的对账面）

	function test_reconcile_live_passes_on_current_repo_inventory() {
		// 仓内现文件自检必须绿——这是 #95 完成标准「对一次真实再生成验
		// 过红绿两面」的绿面锚点：现行 spec/swf-inventory.json（a5fecc91
		// 恢复后七条手写块在册）是自洽的
		if (!sys.FileSystem.exists("spec/swf-inventory.json")) {
			Assert.fail("spec/swf-inventory.json 不在仓（自检无对象）");
			return;
		}
		var r = SwfInventoryReconcile.reconcileLive(File.getContent("spec/swf-inventory.json"));
		var gaps = gapsOf(r);
		Assert.isTrue(Reflect.field(r, "pass"),
			"仓内现文件自检必须绿；缺口： " + [for (g in gaps) SwfInventoryReconcile.reportLine(cast g)].join(" | "));
	}

	function test_reconcile_live_duplicate_path_is_gap() {
		// path 重复让 merge 的配对键失锚（// issue #83 判式契约「path 在
		// 清单里唯一——6290 条实测零重复」）——重复出现是文件腐化，自检
		// 必须红。生成器 scripts/swf-inventory.py 按文件遍历产出、正常不
		// 会重复，这条锁的是手写面编辑事故（人手复制条目忘改 path）
		var text = inventoryDoc([codedEntry("module/ui/shop_v_7.swf"), codedEntry("module/ui/shop_v_7.swf")]);
		var r = SwfInventoryReconcile.reconcileLive(text);
		Assert.isFalse(Reflect.field(r, "pass"), "path 重复必须红（配对键失锚是腐化）");
		Assert.contains("selfcheck_duplicate_path", gapKinds(r));
	}

	function test_reconcile_live_null_handwritten_value_is_gap() {
		// 手写键的值必须是合法 JSON 且非 null——`"code": null` 形态是登
		// 记腐化（键在值亡，merge 会逐字搬一个 null 块进清单，比没有更糟）
		var text = inventoryDoc(['{"path": "module/ui/x_v_0.swf", "bytes": 1, "category": "ui", "fps": 24, "frames": 1, "stage": [500, 375], "code": null}']);
		var r = SwfInventoryReconcile.reconcileLive(text);
		Assert.isFalse(Reflect.field(r, "pass"), "手写键 null 值是登记腐化（键在值亡）");
		Assert.contains("selfcheck_invalid_value", gapKinds(r));
	}

	// ------------------------------------------------------------------
	// workflowKeepsHandwritten：生成器接线静态对账（#95 行动项 1 的机
	// 器化——「零调用」不能再靠人肉 grep 发现）

	function test_workflow_wiring_absent_on_current_main() {
		// 本测试是 write-tests 阶段必须红的核心证据锁之一：#95 背景实锤
		// 「CI legacy-decompile.yml:55 仍直接 python3 scripts/swf-inventory.
		// py……全仓引用 SwfInventoryMerge 的只有判式本体、测试、handbook
		// 页」。喂当前仓内真实两份文本，判式必须报 wiring_missing——接线
		// 落地（人管 edit）后本测试翻绿，这正是对账门「接线在不在」的活
		// 体锚点
		if (!sys.FileSystem.exists(".github/workflows/legacy-decompile.yml")
			|| !sys.FileSystem.exists("scripts/swf-inventory.py")) {
			Assert.fail("工作流/生成器脚本不在仓（静态对账无对象）");
			return;
		}
		var r = SwfInventoryReconcile.workflowKeepsHandwritten(
			File.getContent(".github/workflows/legacy-decompile.yml"),
			File.getContent("scripts/swf-inventory.py"));
		var kinds = gapKinds(r);
		Assert.isFalse(Reflect.field(r, "pass"), "当前 main 接线缺位必须红（#95 背景：零调用实锤）——接线落地后本断言翻绿");
		Assert.contains("wiring_missing", kinds);
	}

	function test_workflow_wiring_present_when_merge_step_in_workflow() {
		// 接线完成形态（// issue #95 要什么 1）：legacy-decompile.yml 里
		// 出现 haxe 调 SwfInventoryMergeRun 的运行步 + 脚本侧有 merge 接线
		// 证据 → 判式绿。语料按 95 原文给出的接线形态最小复刻（模块名写
		// 法以仓库 runner 先例 tools.TestStubScanRun 为准）
		var workflow = "steps:\n"
			+ "      - name: 生成资产清单\n"
			+ "        run: python3 scripts/swf-inventory.py\n"
			+ "      - name: 合并手写增补\n"
			+ "        run: haxe -cp tools --run tools.SwfInventoryMergeRun spec/swf-inventory.json.old spec/swf-inventory.json.new spec/swf-inventory.json\n";
		var script = "# 生成产物先写临时文件，merge 后写回（issue #95）\n"
			+ "# haxe -cp tools --run tools.SwfInventoryMergeRun\n"
			+ "import json\n";
		var r = SwfInventoryReconcile.workflowKeepsHandwritten(workflow, script);
		Assert.isTrue(Reflect.field(r, "pass"), "接线两证据齐全必须绿（#95 行动项 1 的完成形态）");
	}

	function test_workflow_wiring_missing_when_only_workflow_side() {
		// 半接线形态一：工作流有 merge 步、脚本侧零证据——生成器还在裸
		// 重写（json.dump 直写 spec 路径），CI 跑 merge 也是拿裸产物合并
		// 空气（// issue #95 行动项 1「生成器接线」是两个文本面的事）
		var workflow = "run: haxe -cp tools --run tools.SwfInventoryMergeRun a b c\n";
		var script = "import json\njson.dump(payload, f, ensure_ascii=False, indent=1)\n";
		var r = SwfInventoryReconcile.workflowKeepsHandwritten(workflow, script);
		Assert.isFalse(Reflect.field(r, "pass"), "脚本侧裸奔（无 merge 接线证据）必须红——半接线等于没接线");
		Assert.contains("wiring_missing", gapKinds(r));
	}

	function test_workflow_wiring_missing_when_only_script_side() {
		// 半接线形态二：脚本侧有 merge 调用痕迹、工作流没装 haxe 步——
		// CI 环境根本没有 haxe（legacy-decompile.yml 只装 java），脚本里
		// 的 haxe 调用在 CI 直接死（// issue #95 原文「legacy-decompile.yml
		// 补装 haxe」——不补装就是裸的）
		var workflow = "steps:\n      - name: 生成资产清单\n        run: python3 scripts/swf-inventory.py\n";
		var script = "subprocess.run([\"haxe\", \"-cp\", \"tools\", \"--run\", \"tools.SwfInventoryMergeRun\", old, new, out])\n";
		var r = SwfInventoryReconcile.workflowKeepsHandwritten(workflow, script);
		Assert.isFalse(Reflect.field(r, "pass"), "工作流侧无 haxe 步必须红——CI 没装 haxe 脚本侧调了也是死");
		Assert.contains("wiring_missing", gapKinds(r));
	}

	function test_workflow_wiring_empty_inputs_all_missing() {
		// 文件读不到 = 接线不可能在（空串/null 宽免不存在——对账门喂的
		// 是仓内文件，读不到本身就是事故面）
		var r = SwfInventoryReconcile.workflowKeepsHandwritten("", "");
		Assert.isFalse(Reflect.field(r, "pass"));
		Assert.contains("wiring_missing", gapKinds(r));
	}

	// ------------------------------------------------------------------
	// reportLine：机读分拣面形状（与 SwfInventoryMerge.reportLine 互补
	// ——keep 行说保住了什么，reconcile 行说没保住什么，#95 行动项 1/2
	// 各出一行进 CI 日志）

	function test_report_line_shape() {
		var line = SwfInventoryReconcile.reportLine({path: "module/ui/shop_v_7.swf", key: "code", kind: "missing_key"});
		Assert.equals("reconcile missing_key module/ui/shop_v_7.swf code", line);
	}
}
