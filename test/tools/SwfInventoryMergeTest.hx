package tools;

import sys.io.File;
import utest.Assert;

/**
 * issue #83：swf-inventory 生成器手写增补保留逻辑（决策点 a）的纯逻辑契
 * 约门。被测 tools.SwfInventoryMerge 只做 JSON 文本进 → JSON 文本出的纯
 * 逻辑（stub 在 tools/tools/SwfInventoryMerge.hx，「stub 归树」规矩，
 * implement 原地填充）；读旧文件/写回/exit 码归脚本侧（scripts/
 * swf-inventory.py 人管——脚本侧如何调用本逻辑由 implement 与人裁决的
 * 修复方向落地，本门只钉判式）。
 *
 * 需求出处（原版没有的工具，全部 // issue #83）：
 * - 病灶：issue「动机」节——scripts/swf-inventory.py:115-117 从零全量
 *   重写 spec/swf-inventory.json、无合并/保留逻辑；.github/workflows/
 *   legacy-decompile.yml:11-12 由 legacy/deploy/recompile-trigger 的
 *   push 触发再生成（至今已改 6 次）。
 * - 死亡证据：#30 的手写 code 块（84c203bb 交付形态，五键 decompiled/
 *   symbol_class/classes/module_spec/note）被 399a5faa（2026-11-24 CI
 *   再生成）整体抹掉；#83 时「无一带 code 块」是事故现状，#85（2026-11-26
 *   合并）正当写入三条后此现状过期——在库锁已改为钉「在册手写块存活」
 *   （test_main_inventory_handwritten_code_blocks_survive）。
 * - 修复方向：issue 决策点 a（推荐）原文「重写前读旧文件，同 path 条
 *   目保留手写键（如 code），新生成条目无手写键则照常输出」「基线出
 *   账（baseline）等机器生成部分不受影响」。
 * - 84c203bb 形态：`git show 84c203bb -- spec/swf-inventory.json`（#
 *   30 给四件各加 "code": {decompiled, symbol_class, classes,
 *   module_spec, note}，位置在 stage 之后——机器键在前、手写键缀后的
 *   键序出处）。
 * - 机器键闭集：scripts/swf-inventory.py:97-105 的产出键枚举（path/
 *   bytes/category + 头部解开时的 fps/frames/stage 或解不开时的
 *   unparsed）。
 * - 排序/缩进形态：scripts/swf-inventory.py:111（按 path 排序）与
 *   :116（json.dump indent=1 ensure_ascii=False）。
 */
class SwfInventoryMergeTest {
	public function new() {}

	// ------------------------------------------------------------------
	// 语料拼装（表驱动的零件：机器条目与手写块的最小 JSON 形态）

	/** 生成器产出形态的单条目（键序 = scripts/swf-inventory.py:97-105
	 * 的插入序：path/bytes/category/fps/frames/stage）。 */
	static function machineEntry(path:String, ?bytes:Int = 1000):String {
		return '{"path": "' + path + '", "bytes": ' + bytes + ', "category": "ui", "fps": 24, "frames": 1, "stage": [500, 375]}';
	}

	/** 带手写键的旧条目：机器键 + code 块（84c203bb 五键形态）。 */
	static function codedEntry(path:String):String {
		return '{"path": "' + path + '", "bytes": 1000, "category": "ui", "fps": 24, "frames": 1, "stage": [500, 375], '
			+ '"code": {"decompiled": "legacy/decompiled/shop_v_7/", "symbol_class": "module.shop.ShopWrapper", '
			+ '"classes": 25, "module_spec": "spec/modules/farm-shop-ui.json", "note": "功能 UI 代码 swf"}}';
	}

	static function inventoryDoc(entries:Array<String>):String {
		return '{"version": 1, "source": "legacy/deploy/QFarmFlash/source/core/module", "count": '
			+ entries.length + ', "swfs": [' + entries.join(", ") + ']}';
	}

	static function parseEntries(text:String):Array<Dynamic> {
		var doc:Dynamic = haxe.Json.parse(text);
		return cast Reflect.field(doc, "swfs");
	}

	static function entryByPath(entries:Array<Dynamic>, path:String):Dynamic {
		for (e in entries) {
			if (Std.string(Reflect.field(e, "path")) == path) return e;
		}
		return null;
	}

	// ------------------------------------------------------------------
	// isHandwrittenKey / handwrittenKeysOf：手写键判定

	function test_machine_keys_are_not_handwritten() {
		// // issue #83 决策点 a「机器生成部分不受影响」的键面出处：
		// scripts/swf-inventory.py:97-105 枚举的全部产出键。逐键表驱动
		// （单键循环断言红了只剩第一行命——逐行展开后哪个键失守一眼定位）
		Assert.isFalse(SwfInventoryMerge.isHandwrittenKey("path"), "path 是机器键（swf-inventory.py:98），不得判手写");
		Assert.isFalse(SwfInventoryMerge.isHandwrittenKey("bytes"), "bytes 是机器键（swf-inventory.py:99），不得判手写");
		Assert.isFalse(SwfInventoryMerge.isHandwrittenKey("category"), "category 是机器键（swf-inventory.py:100），不得判手写");
		Assert.isFalse(SwfInventoryMerge.isHandwrittenKey("fps"), "fps 是机器键（swf-inventory.py:103 头部解开时），不得判手写");
		Assert.isFalse(SwfInventoryMerge.isHandwrittenKey("frames"), "frames 是机器键（swf-inventory.py:103），不得判手写");
		Assert.isFalse(SwfInventoryMerge.isHandwrittenKey("stage"), "stage 是机器键（swf-inventory.py:103），不得判手写");
		Assert.isFalse(SwfInventoryMerge.isHandwrittenKey("unparsed"), "unparsed 是机器键（swf-inventory.py:105 头部解不开时），不得判手写");
	}

	function test_code_and_unknown_keys_are_handwritten() {
		// // issue #83：手写增补的判式——code 是 84c203bb 的手写键；
		// 闭集外的任何键（未来的手写增补形态）同样算手写（判式是按闭集
		// 减，不是按 code 白名单加——新形态手写键不需要改判式）
		Assert.isTrue(SwfInventoryMerge.isHandwrittenKey("code"));
		Assert.isTrue(SwfInventoryMerge.isHandwrittenKey("triage"));
		Assert.isTrue(SwfInventoryMerge.isHandwrittenKey("x_custom"));
	}

	function test_handwritten_key_match_is_case_sensitive() {
		// 逐字匹配、大小写不折叠：Code/CODE 不是机器键的字形变体，
		// 闭集里没有它们——按手写键处理（判式不折叠是有意的：机器键
		// 全小写产出，大写键只可能是手写）
		Assert.isTrue(SwfInventoryMerge.isHandwrittenKey("Code"));
		Assert.isTrue(SwfInventoryMerge.isHandwrittenKey("PATH"));
	}

	function test_handwritten_keys_of_entry_sorted() {
		// 单条目手写键集：机器键剥掉、余集字典序（报告/断言可 diff）
		var entry = haxe.Json.parse('{"path": "module/ui/x.swf", "bytes": 1, "category": "ui", "fps": 24, "frames": 1, "stage": [500, 375], "code": {}, "triage": {}}');
		Assert.same(["code", "triage"], SwfInventoryMerge.handwrittenKeysOf(entry));
	}

	function test_handwritten_keys_of_pure_machine_entry_is_empty() {
		var entry = haxe.Json.parse(machineEntry("module/ui/x.swf"));
		Assert.same([], SwfInventoryMerge.handwrittenKeysOf(entry));
	}

	// ------------------------------------------------------------------
	// merge：保留面（issue #83 决策点 a 的核心语义）

	function test_merge_preserves_code_block_when_entry_survives() {
		// // issue #83 完成标准：「修复后触发一次再生成，#30 四条 +
		// #66 三条 code 块全部存活」的单条形态——同 path 旧条目的
		// code 块逐字搬进新条目
		var oldText = inventoryDoc([codedEntry("module/ui/shop_v_7.swf")]);
		var genText = inventoryDoc([machineEntry("module/ui/shop_v_7.swf")]);
		var out = parseEntries(SwfInventoryMerge.merge(oldText, genText));
		var row = entryByPath(out, "module/ui/shop_v_7.swf");
		Assert.notNull(row);
		var code:Dynamic = Reflect.field(row, "code");
		Assert.notNull(code, "再生成后 code 块必须存活（issue #83 完成标准；84c203bb 形态出处）");
		Assert.equals("legacy/decompiled/shop_v_7/", Std.string(Reflect.field(code, "decompiled")));
		Assert.equals("module.shop.ShopWrapper", Std.string(Reflect.field(code, "symbol_class")));
		Assert.equals(25, Reflect.field(code, "classes"));
		Assert.equals("spec/modules/farm-shop-ui.json", Std.string(Reflect.field(code, "module_spec")));
	}

	function test_merge_machine_fields_come_from_new_generation() {
		// 机器面以新生成为准（// issue #83「基线出账等机器生成部分
		// 不受影响」）：bytes 变了以新值为准，手写键照搬
		var oldText = inventoryDoc([codedEntry("module/ui/shop_v_7.swf")]);
		var genText = inventoryDoc([machineEntry("module/ui/shop_v_7.swf", 2222)]);
		var out = parseEntries(SwfInventoryMerge.merge(oldText, genText));
		var row = entryByPath(out, "module/ui/shop_v_7.swf");
		Assert.equals(2222, Reflect.field(row, "bytes"), "机器键以新生成为准（swf 重打包后 bytes 漂移由生成器说了算）");
		Assert.notNull(Reflect.field(row, "code"), "手写键不受机器键漂移影响");
	}

	function test_merge_new_entries_without_handwritten_keys_pass_through() {
		// // issue #83 决策点 a 原文「新生成条目无手写键则照常输出」：
		// 旧文件没有同 path 手写面时，新条目原样透传（无 code 键增生）
		var oldText = inventoryDoc([codedEntry("module/ui/shop_v_7.swf")]);
		var genText = inventoryDoc([machineEntry("module/ui/shop_v_7.swf"), machineEntry("module/ui/new_asset_v_1.swf")]);
		var out = parseEntries(SwfInventoryMerge.merge(oldText, genText));
		var added = entryByPath(out, "module/ui/new_asset_v_1.swf");
		Assert.notNull(added);
		Assert.isFalse(Reflect.hasField(added, "code"), "旧文件无手写面的新条目不得增生 code 键（照常输出）");
	}

	function test_merge_drops_handwritten_block_when_entry_disappears() {
		// 配对键是 path：新清单里没有同 path 条目（swf 被删/改名），
		// 手写块随条目消失、不搬到别的条目上（path 配对是逐字不是模糊；
		// 84c203bb 的四条 path 是 module/ui/<名>.swf 形态）
		var oldText = inventoryDoc([codedEntry("module/ui/shop_v_7.swf")]);
		var genText = inventoryDoc([machineEntry("module/ui/decorate_v_0.swf")]);
		var out = parseEntries(SwfInventoryMerge.merge(oldText, genText));
		var row = entryByPath(out, "module/ui/decorate_v_0.swf");
		Assert.notNull(row);
		Assert.isFalse(Reflect.hasField(row, "code"), "手写块不得跨 path 搬迁（配对键逐字）");
		Assert.equals(1, out.length, "被删条目不留尸（新清单是权威基座）");
	}

	function test_merge_entry_count_follows_new_generation() {
		// 顶层 count/swfs 数组以新生成为准：旧文件多出/少出的条目不进
		// 结果（条目增删是机器面——6290 条清单的增删只随 legacy/deploy
		// 变化，不是手写面）
		var oldText = inventoryDoc([codedEntry("module/ui/shop_v_7.swf"), machineEntry("module/ui/dead_v_0.swf")]);
		var genText = inventoryDoc([machineEntry("module/ui/shop_v_7.swf")]);
		var outText = SwfInventoryMerge.merge(oldText, genText);
		var doc:Dynamic = haxe.Json.parse(outText);
		Assert.equals(1, Reflect.field(doc, "count"), "顶层 count 以新生成为准（机器面）");
		var out = parseEntries(outText);
		Assert.equals(1, out.length);
		Assert.isNull(entryByPath(out, "module/ui/dead_v_0.swf"), "新清单已删的条目整体出局（含其机器面）");
	}

	function test_merge_multiple_coded_entries_all_survive() {
		// // issue #83 完成标准的批量形态：「#30 四条 + #66 三条全部存
		// 活」——多条手写块各自按 path 配对，互不串扰
		var paths = [
			"module/ui/shop_v_7.swf", "module/ui/warehouse_v_23.swf",
			"module/ui/pool_v_13.swf", "module/ui/decorate_v_0.swf",
			"module/ui/cards_v_1.swf", "module/ui/quickshoot_v_0.swf",
			"module/mc/farm/wild/WildShellNc_v_5.swf"
		];
		var oldText = inventoryDoc([for (p in paths) codedEntry(p)]);
		var genText = inventoryDoc([for (p in paths) machineEntry(p)].concat([machineEntry("module/ui/unrelated_v_0.swf")]));
		var out = parseEntries(SwfInventoryMerge.merge(oldText, genText));
		for (p in paths) {
			var row = entryByPath(out, p);
			Assert.notNull(row, p + " 条目在");
			Assert.notNull(Reflect.field(row, "code"), p + " 的 code 块存活（issue #83 完成标准：七条全部存活）");
		}
		Assert.isFalse(Reflect.hasField(entryByPath(out, "module/ui/unrelated_v_0.swf"), "code"));
	}

	function test_merge_handwritten_keys_beyond_code_also_preserved() {
		// 判式按闭集减、不按 code 白名单加（test_code_and_unknown_keys
		// 同族）：未来的手写增补键（triage/note2 等）同规则存活——
		// issue #66 的教训是「同族普查」，判式不为 code 刻特例
		var oldText = inventoryDoc(['{"path": "module/ui/x_v_0.swf", "bytes": 1, "category": "ui", "fps": 24, "frames": 1, "stage": [500, 375], "triage": {"verdict": "material"}}']);
		var genText = inventoryDoc([machineEntry("module/ui/x_v_0.swf")]);
		var out = parseEntries(SwfInventoryMerge.merge(oldText, genText));
		var row = entryByPath(out, "module/ui/x_v_0.swf");
		Assert.notNull(Reflect.field(row, "triage"), "code 之外的手写键同规则保留（判式是减闭集，不是加白名单）");
	}

	// ------------------------------------------------------------------
	// merge：输出文本形状（再生成回路的 diff 干净面）

	function test_merge_output_is_valid_json_with_indent_one() {
		// 输出形态对齐生成器（scripts/swf-inventory.py:116 json.dump
		// indent=1）：缩进 1 空格——两次连续 merge 幂等、diff 干净
		var oldText = inventoryDoc([codedEntry("module/ui/shop_v_7.swf")]);
		var genText = inventoryDoc([machineEntry("module/ui/shop_v_7.swf")]);
		var outText = SwfInventoryMerge.merge(oldText, genText);
		var reparsed:Dynamic = haxe.Json.parse(outText);
		Assert.notNull(reparsed, "输出必须是合法 JSON");
		var lines = outText.split("\n");
		var indented = [for (l in lines) if (StringTools.startsWith(l, " ") && !StringTools.startsWith(l, "  ")) l];
		Assert.isTrue(indented.length > 0, "输出有 1 空格缩进行（json.dump indent=1 形态）");
	}

	function test_merge_output_entries_sorted_by_path() {
		// scripts/swf-inventory.py:111 的排序语义进输出：输入乱序不影响
		// 输出序（确定性基线——同样输入同样输出）
		var genText = inventoryDoc([machineEntry("module/ui/z_v_0.swf"), machineEntry("module/ui/a_v_0.swf"), machineEntry("module/ui/m_v_0.swf")]);
		var out = parseEntries(SwfInventoryMerge.merge(inventoryDoc([]), genText));
		var paths = [for (e in out) Std.string(Reflect.field(e, "path"))];
		Assert.same(["module/ui/a_v_0.swf", "module/ui/m_v_0.swf", "module/ui/z_v_0.swf"], paths);
	}

	function test_merge_is_idempotent() {
		// 幂等：merge 输出再喂回 merge（同样旧文件）产出逐字相同——再
		// 生成回路里重复跑不出 diff churn（清单是 6290 条的大文件，
		// 非幂等的话每次 CI 重跑都整文件翻烧饼）
		var oldText = inventoryDoc([codedEntry("module/ui/shop_v_7.swf")]);
		var genText = inventoryDoc([machineEntry("module/ui/shop_v_7.swf")]);
		var once = SwfInventoryMerge.merge(oldText, genText);
		var twice = SwfInventoryMerge.merge(oldText, once);
		Assert.equals(once, twice, "两次连续 merge 输出逐字相同（幂等）");
	}

	function test_merge_handwritten_keys_appear_after_machine_keys() {
		// 键序：机器键在前、手写键缀后（84c203bb 的 diff 形态——code
		// 块出现在 stage 之后）。拼出的条目文本里 "code" 的字面值位置
		// 在 "stage" 之后
		var oldText = inventoryDoc([codedEntry("module/ui/shop_v_7.swf")]);
		var genText = inventoryDoc([machineEntry("module/ui/shop_v_7.swf")]);
		var outText = SwfInventoryMerge.merge(oldText, genText);
		var stagePos = outText.indexOf('"stage"');
		var codePos = outText.indexOf('"code"');
		Assert.isTrue(stagePos >= 0 && codePos > stagePos, '手写键 "code" 出现在机器键 "stage" 之后（84c203bb diff 形态同构的键序）');
	}

	// ------------------------------------------------------------------
	// merge：异常输入语义（类头契约）

	function test_merge_malformed_old_text_treated_as_no_handwritten() {
		// 旧文件不是合法 JSON（首次生成/损坏）→ 手写面视为空、输出即
		// 新生成整形——再生成不阻塞（类头契约）
		var genText = inventoryDoc([machineEntry("module/ui/shop_v_7.swf")]);
		var out = parseEntries(SwfInventoryMerge.merge("{not json", genText));
		Assert.equals(1, out.length);
		Assert.isFalse(Reflect.hasField(entryByPath(out, "module/ui/shop_v_7.swf"), "code"));
	}

	function test_merge_old_text_without_swfs_array_treated_as_empty() {
		var genText = inventoryDoc([machineEntry("module/ui/shop_v_7.swf")]);
		var out = parseEntries(SwfInventoryMerge.merge('{"version": 1}', genText));
		Assert.equals(1, out.length);
	}

	function test_merge_malformed_generated_text_throws() {
		// 生成器产出坏了是生成器自身的事故——抛出（调用方脚本侧退非
		// 零），不静默产出空清单（类头契约：「防生成器坏了还写出绿
		// 文件」）。抛出的只能是判式侧的拒绝，不是 stub 的待填惯用语——
		// 后者撞上了说明实现根本没写（扫描语料在字符串内，机器门零误伤）
		var raised = false;
		var caughtStub = false;
		try {
			SwfInventoryMerge.merge(inventoryDoc([]), "{not json");
		} catch (e:Dynamic) {
			raised = true;
			if (Std.string(e).indexOf("not implemented") >= 0) caughtStub = true;
		}
		Assert.isTrue(raised, "generatedText 形状不符必须抛出（生成器坏了不得静默产出）");
		Assert.isFalse(caughtStub, "抛出的须是判式侧的形状拒绝，不是待填惯用语");
	}

	function test_merge_generated_without_swfs_array_throws() {
		var raised = false;
		var caughtStub = false;
		try {
			SwfInventoryMerge.merge(inventoryDoc([]), '{"version": 1}');
		} catch (e:Dynamic) {
			raised = true;
			if (Std.string(e).indexOf("not implemented") >= 0) caughtStub = true;
		}
		Assert.isTrue(raised, "generatedText 顶层无 swfs 数组必须抛出");
		Assert.isFalse(caughtStub, "抛出的须是判式侧的形状拒绝，不是待填惯用语");
	}

	// ------------------------------------------------------------------
	// reportLine：脚本侧机读报告形态

	function test_report_line_shape() {
		// 报告行 `keep <path> <键集>`：分拣面（机读回归）
		var line = SwfInventoryMerge.reportLine("module/ui/shop_v_7.swf", ["code"]);
		Assert.equals("keep module/ui/shop_v_7.swf code", line);
	}

	// ------------------------------------------------------------------
	// 在库事实锁（issue #83 动机节的证据钉死在测试里）

	function test_main_inventory_handwritten_code_blocks_survive() {
		// // issue #83 锁的「changed for #83」维护点（2026-11-26 触发）：
		// 原断言「无一带 code 块」钉的是再生成事故后的过渡现状，原锁注释
		// 自己写了「修复后手写块恢复时本断言需要更新」——#85（#66 规格提取）
		// 正当写入三条手写 code 块，过渡现状过期、preflight 被锁死（#86 开跑
		// 43 秒即死）。新锁钉活体事实：在册手写块必须存活——被再生成抹掉
		// （399a5faa 同型事故）时本测试红，这是 #83「死了无人察觉」的门在
		// test 层的落点；再生成回路的完整对账归 #95。
		if (!sys.FileSystem.exists("spec/swf-inventory.json")) {
			Assert.fail("spec/swf-inventory.json 不在仓（清单缺失，存活锁无法核对）");
			return;
		}
		var doc:Dynamic = haxe.Json.parse(File.getContent("spec/swf-inventory.json"));
		var entries:Array<Dynamic> = cast Reflect.field(doc, "swfs");
		Assert.notNull(entries);
		if (entries == null) return;
		var byPath = new Map<String, Dynamic>();
		for (e in entries) {
			var p:Dynamic = Reflect.field(e, "path");
			if (Std.isOfType(p, String)) byPath.set(cast p, e);
		}
		// // issue #85 在册三条（2026-11-26 合并，出处 spec/modules/
		// {cards-game-ui,quickshoot-ui,wild-shell-ui}.json 的 code 块交付）；
		// #30 四条 2026-11-26 按 #95 恢复（84c203bb 形态逐字搬运）后追加。
		var known = [
			"module/ui/cards_v_1.swf",
			"module/ui/quickshoot_v_0.swf",
			"module/mc/farm/wild/WildShellNc_v_5.swf",
			"module/ui/shop_v_7.swf",
			"module/ui/warehouse_v_23.swf",
			"module/ui/pool_v_13.swf",
			"module/ui/decorate_v_0.swf"
		];
		for (p in known) {
			var e = byPath.get(p);
			Assert.notNull(e, "在册手写块宿主 " + p + " 缺失（再生成把条目删了？）");
			if (e == null) continue;
			Assert.isTrue(Reflect.hasField(e, "code"), p + " 的手写 code 块被抹掉——399a5faa 同型事故，#95 接线未落地前再生成必踩");
		}
	}

	function test_main_inventory_entries_have_machine_keys_and_consistent_count() {
		// // issue #83 锁的姊妹维护点（2026-11-26 与存活锁同改）：原断言
		// 「键集 ⊆ 机器键闭集 + 硬编码 6290 条」把两个过渡事实当不变量——
		// 手写键回归（#85 三块）与清单扩容（下一次 main_swfs 扩名单）都会
		// 正当打破它。新锁钉耐久不变量：每条目带全机器键、顶层 count 与
		// 条目数自洽。生成器键面漂移的提醒不再走本测试（preflight 红会锁死
		// 所有任务，不是通知通道）——归 #95 的再生成对账门。
		if (!sys.FileSystem.exists("spec/swf-inventory.json")) {
			Assert.fail("spec/swf-inventory.json 不在仓");
			return;
		}
		var doc:Dynamic = haxe.Json.parse(File.getContent("spec/swf-inventory.json"));
		var entries:Array<Dynamic> = cast Reflect.field(doc, "swfs");
		Assert.notNull(entries);
		if (entries == null) return;
		Assert.equals(entries.length, Reflect.field(doc, "count"), "顶层 count 与 swfs 条目数自洽");
		for (e in entries) {
			Assert.isTrue(Reflect.hasField(e, "path"), "条目缺 path（机器键）");
			Assert.isTrue(Reflect.hasField(e, "bytes"), "条目缺 bytes（机器键）");
			Assert.isTrue(Reflect.hasField(e, "category"), "条目缺 category（机器键）");
			var fpsGroup = Reflect.hasField(e, "fps") && Reflect.hasField(e, "frames") && Reflect.hasField(e, "stage");
			Assert.isTrue(fpsGroup || Reflect.hasField(e, "unparsed"), "条目既无 fps/frames/stage 也无 unparsed（swf-inventory.py:97-105 两种产出形态）");
		}
	}
}
