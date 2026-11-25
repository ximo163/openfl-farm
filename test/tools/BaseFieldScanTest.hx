package tools;

import sys.io.File;
import tools.DynWriteScan.DynHit;
import utest.Assert;

/**
 * issue #63 基类 Dynamic 字段盲区补扫——scan_dyn_writes 基类扩展的纯逻辑
 * （write-tests 阶段对 stub 失败）。被测 tools.DynWriteScan 只做行集→命中
 * 的纯逻辑（extends 链跨文件装配/已知名单兜底/脚本侧接线按 issue 走
 * implement 阶段）。stub 在 tools/tools/DynWriteScan.hx（「stub 归树」
 * 规矩，implement 原地填充）。
 *
 * 期望值出处：
 * - 机制（cpp 上 openfl get/set 属性的 Dynamic 写必抛 Invalid field、读
 *   静默 null；编译与 cpp typer 都抓不到、唯一现形场是真机）：
 *   // issue #63 机制节（2026-11-24 debug 真机栈钉死，PR #62 修复时记录）。
 * - 盲区成因（scan_dyn_writes 只追局部变量与本文件声明的 Dynamic 生产者，
 *   不追基类继承的 Dynamic 字段）与修法方向（extends 链解析或已知名单，
 *   implement 自行取舍）：// issue #63「机械盲区」节。
 * - 回归样例验收（「以 WaterController.hx:366 修复前的代码为样例，扫描
 *   必须命中 m_view.x；修后不再命中」）：// issue #63——fixture 取
 *   527fdc0a^/527fdc0a 两版 src/module/water/WaterController.hx 的 git
 *   原样快照（test/fixtures/water-controller-pre-fix.hx /
 *   water-controller-post-fix.hx）；修复写法出处 WaterController.as:378-398
 *   （值不变，经类型化局部写——scan_dyn_writes 文件头「正确写法三选一
 *   之 1」）。
 * - 命中/不命中的形态表（写 `=<非=>`、null 判与对字段本身赋值不命中、
 *   方法调用不命中、cast 不命中）：// issue #63（读/写两族登记）+
 *   tools/scan_dyn_writes.py:47-49 现有 FIELD_WRITE 判式同构（`=[^=>]`
 *   排除 ==/>=）；方法调用/cast 不在 issue 登记的失效面（cpp 失效的是
 *   字段读/写，不是方法派发——方法经 Dynamic 调用在 cpp 上走
 *   hx::Object 的 __Call 派发，与字段表查找是两路）。
 * - collect 的基准出处：src/framework/base/Controller.hx:12-14
 *   `private var m_view:Dynamic` / `private var m_model:Dynamic`（m_module
 *   是 IModule 非 Dynamic，作「不收」对照位）。
 */
class BaseFieldScanTest {
	public function new() {}

	static final PRE_FIXTURE:String = "test/fixtures/water-controller-pre-fix.hx";
	static final POST_FIXTURE:String = "test/fixtures/water-controller-post-fix.hx";
	static final MINI_BASE:String = "test/fixtures/base-fields-controller.hx";
	static final MINI_PRE:String = "test/fixtures/base-fields-subclass-pre-fix.hx";
	static final MINI_POST:String = "test/fixtures/base-fields-subclass-post-fix.hx";

	static final BASE_FIELDS:Array<String> = ["m_view", "m_model"];

	static function fixtureLines(path:String):Array<String> {
		var lines = File.getContent(path).split("\n");
		if (lines.length > 0 && lines[lines.length - 1] == "") lines.pop(); // 尾换行
		return lines;
	}

	static function baseFieldMap():Map<String, Bool> {
		// 「已知基类字段名单」路线（issue 修法方向之二）的输入形态——
		// 测试喂名单只钉 scanLines 行级判定面，extends 链装配是 implement 选型
		var m = new Map<String, Bool>();
		for (f in BASE_FIELDS) m.set(f, true);
		return m;
	}

	static function hitsFor(path:String, lines:Array<String>):Array<DynHit> {
		return DynWriteScan.scanLines(lines, baseFieldMap(), path);
	}

	static function baseHits(hits:Array<DynHit>):Array<DynHit> {
		return hits.filter(h -> BASE_FIELDS.indexOf(h.variable) >= 0);
	}

	static function hitAt(hits:Array<DynHit>, line:Int, variable:String, prop:String):DynHit {
		for (h in hits) {
			if (h.line == line && h.variable == variable && h.prop == prop) return h;
		}
		return null;
	}

	// ---- collect：基类字段收集（src/framework/base/Controller.hx 实测） ----

	function test_collect_real_base_controller() {
		// 出处 src/framework/base/Controller.hx:12-14——m_view/m_model 是
		// Dynamic 收进名单，m_module 是 IModule 不收
		var got = DynWriteScan.collect(fixtureLines("src/framework/base/Controller.hx"));
		Assert.isTrue(got.exists("m_view"), "m_view 须在名单");
		Assert.isTrue(got.exists("m_model"), "m_model 须在名单");
		Assert.isFalse(got.exists("m_module"), "m_module 是 IModule 非 Dynamic，不收");
	}

	function test_collect_mini_fixture() {
		// 迷你基类同形（fixture 与原件逐字同形的字段声明段）
		var got = DynWriteScan.collect(fixtureLines(MINI_BASE));
		Assert.isTrue(got.exists("m_view"));
		Assert.isTrue(got.exists("m_model"));
		Assert.isFalse(got.exists("m_module"));
	}

	function test_collect_public_modifier_also_collected() {
		// 前缀修饰不扣 private 一格：public 的 Dynamic 字段同样是基类继承
		// 盲区（issue 的 m_view/m_model 家族按「基类 Dynamic 字段」族定义）
		var got = DynWriteScan.collect(["class A {", "\tpublic var m_view:Dynamic;", "}"]);
		Assert.isTrue(got.exists("m_view"));
	}

	// ---- 回归锚点：#62 修复前 WaterController 必须命中 m_view.x（issue 验收原文） ----

	function test_pre_fix_water_controller_hits_m_view_x_y() {
		// 出处 // issue #63 验收节：修复前样例必须命中 m_view.x——fixture 是
		// 527fdc0a^ 的原样快照，:366/:367 即真机栈实锤行（2026-11-24 debug）
		var hits = baseHits(hitsFor(PRE_FIXTURE, fixtureLines(PRE_FIXTURE)));
		var x = hitAt(hits, 366, "m_view", "x");
		Assert.notNull(x, "修复前 :366 m_view.x 必须命中（issue 验收原文）");
		Assert.equals("write", x.kind);
		var y = hitAt(hits, 367, "m_view", "y");
		Assert.notNull(y, "修复前 :367 m_view.y 必须命中");
		Assert.equals("write", y.kind);
	}

	function test_pre_fix_base_hit_count_exactly_two() {
		// 出处 // issue #63 验收节「扫描必须命中 m_view.x」——全文件基类命中
		// 恰两条（:366/:367），不多不少：漏报即盲区未补、误报即修复后清零
		// 面失守（修复前 WaterController 里 m_view/m_model 的其余接触全部是
		// null 判/对字段本身赋值/传参/cast 形态，见 non_field_touch 用例）
		var hits = baseHits(hitsFor(PRE_FIXTURE, fixtureLines(PRE_FIXTURE)));
		Assert.equals(2, hits.length, "修复前全文件基类命中恰 2 条，实中 " + hits.length);
	}

	function test_pre_fix_hit_report_shape() {
		// 命中四元组形状与 scan_dyn_writes 输出对齐（file:line var prop 行文本）
		var hits = baseHits(hitsFor(PRE_FIXTURE, fixtureLines(PRE_FIXTURE)));
		var x = hitAt(hits, 366, "m_view", "x");
		Assert.equals(PRE_FIXTURE, x.path);
		Assert.equals("m_view.x = 46 + 6 * ITEM_WIDTH / 2;", x.code);
	}

	function test_pre_fix_non_field_touch_forms_not_hit() {
		// 修复前残余形态全在不命中面（出处 // issue #63 + scan_dyn_writes.py
		// FIELD_WRITE 判式同构）：
		// :362 null 判、:364 对 m_view 本身赋值（`m_view = _loc1_`，不是
		// m_view 上的字段写——行尾无 `.prop` 段）、:368 传参位、:436 cast
		var hits = baseHits(hitsFor(PRE_FIXTURE, fixtureLines(PRE_FIXTURE)));
		for (line in [362, 364, 368, 436]) {
			var bad = hits.filter(h -> h.line == line);
			Assert.equals(0, bad.length, '修复前 :' + line + " 不命中（裸字段/null判/赋值/cast 形态），实中 " + bad.length);
		}
	}

	// ---- 回归锚点：修复后零基类命中（issue 验收原文「修后不再命中」） ----

	function test_post_fix_water_controller_zero_base_hits() {
		// 出处 // issue #63：修后不再命中——fixture 是 527fdc0a 快照
		// （x/y 改经类型化局部 _loc1_:WaterPool 写，值不变，
		// WaterController.as:378-398）；残余 m_view 形态（:362 null 判、
		// :364 赋值、:371 传参、:439 cast）全在不命中面
		var hits = baseHits(hitsFor(POST_FIXTURE, fixtureLines(POST_FIXTURE)));
		Assert.equals(0, hits.length, "修复后基类 Dynamic 字段读/写命中须清零，实中 " + hits.length);
	}

	// ---- 形态矩阵：迷你 fixture（读写两族 + this. 前缀 + 字面量值位） ----

	function test_mini_pre_write_hits() {
		var hits = baseHits(hitsFor(MINI_PRE, fixtureLines(MINI_PRE)));
		var rows:Array<{line:Int, variable:String, prop:String}> = [
			{line: 11, variable: "m_view", prop: "x"},
			{line: 12, variable: "m_view", prop: "y"},
			{line: 20, variable: "m_model", prop: "dirty"},
			{line: 23, variable: "m_view", prop: "alpha"}, // this. 前缀形态
		];
		for (r in rows) {
			var h = hitAt(hits, r.line, r.variable, r.prop);
			Assert.notNull(h, '迷你 pre :' + r.line + " " + r.variable + "." + r.prop + " 写命中");
			if (h != null) Assert.equals("write", h.kind);
		}
	}

	function test_mini_pre_read_hits() {
		// 读族（cpp 静默 null 偏差——issue 登记的 MyBagController.hx:86
		// visible 读与 FarmLandController.hx:552 stage 读的同形态面）：
		// :14 条件位、:17 var 初始化右端、:18 对象字面量值位（FarmLandController
		// :552 `"parent": m_view.stage` 同形）、:22、:24 this. 前缀
		var hits = baseHits(hitsFor(MINI_PRE, fixtureLines(MINI_PRE)));
		var rows:Array<{line:Int, variable:String, prop:String}> = [
			{line: 14, variable: "m_view", prop: "visible"},
			{line: 17, variable: "m_view", prop: "stage"},
			{line: 18, variable: "m_view", prop: "stage"},
			{line: 22, variable: "m_model", prop: "total"},
			{line: 24, variable: "m_view", prop: "width"},
		];
		for (r in rows) {
			var h = hitAt(hits, r.line, r.variable, r.prop);
			Assert.notNull(h, '迷你 pre :' + r.line + " " + r.variable + "." + r.prop + " 读命中");
			if (h != null) Assert.equals("read", h.kind);
		}
	}

	function test_mini_pre_non_hits() {
		// 不命中面（行号按 fixture）：
		// :10 m_view == null、:15 m_view.show(false) 方法调用、:19 m_model != null
		var hits = baseHits(hitsFor(MINI_PRE, fixtureLines(MINI_PRE)));
		for (line in [10, 15, 19]) {
			var bad = hits.filter(h -> h.line == line);
			Assert.equals(0, bad.length, '迷你 pre :' + line + " 不命中，实中 " + bad.length);
		}
		// :14 内 m_view != null 段不产生额外命中——该行唯一命中是 visible 的 read
		var line14 = hits.filter(h -> h.line == 14);
		Assert.equals(1, line14.length, ":14 恰一条命中（visible 的 read；!= null 段不产命中）");
	}

	function test_mini_post_zero_base_hits() {
		// 修复形态（typed getter + 类型化局部）零基类命中——含 getter 体内
		// cast(m_view, MiniView) 不命中、`m_view = typed` 对字段本身赋值不命中
		var hits = baseHits(hitsFor(MINI_POST, fixtureLines(MINI_POST)));
		Assert.equals(0, hits.length, "迷你 post 基类命中须清零，实中 " + hits.length);
	}

	// ---- 名单外名字不受影响 + 既有写检测保留 ----

	function test_unlisted_dynamic_local_still_detected_by_write_channel() {
		// 既有写检测原样保留（main 命中清单的形状不能因扩展丢失）：
		// 局部 var x:Dynamic 的字段写仍命中 write（scan_dyn_writes.py 基线行为）
		var lines = [
			"class A {",
			"\tfunction f() {",
			"\t\tvar clip:Dynamic = {};",
			"\t\tclip.tipText = \"x\";",
			"\t}",
			"}",
		];
		var hits = DynWriteScan.scanLines(lines, baseFieldMap(), "inline");
		var h = hitAt(hits, 4, "clip", "tipText");
		Assert.notNull(h, "局部 Dynamic 变量字段写仍按既有通道命中");
		if (h != null) Assert.equals("write", h.kind);
	}

	function test_base_field_read_write_matrix_inline() {
		// 行级判式内联表驱动（不依赖 fixture 的面）：
		// 写 `=<非=>`、读其余字段接触；==/>= 判式不命中（scan_dyn_writes.py
		// FIELD_WRITE `=[^=>]` 同构）
		var lines = [
			"class A {",
			"\tfunction f() {",
			"\t\tm_view.x = 1;", // 3 write
			"\t\tvar a = m_view.x;", // 4 read
			"\t\tif (m_view.x >= 1) {}", // 5 read（>= 不是写）
			"\t\tm_view.x == 1;", // 6 read（== 不是写；字段接触仍是 read）
			"\t\tm_view = null;", // 7 不命中（对字段本身赋值）
			"\t}",
			"}",
		];
		var hits = baseHits(DynWriteScan.scanLines(lines, baseFieldMap(), "inline"));
		Assert.equals("write", hitAt(hits, 3, "m_view", "x").kind);
		Assert.equals("read", hitAt(hits, 4, "m_view", "x").kind);
		Assert.equals("read", hitAt(hits, 5, "m_view", "x").kind);
		Assert.equals("read", hitAt(hits, 6, "m_view", "x").kind);
		Assert.isNull(hitAt(hits, 7, "m_view", null), ":7 对 m_view 本身赋值不命中");
		Assert.equals(0, hits.filter(h -> h.line == 7).length);
	}

	function test_no_base_fields_no_base_hits() {
		// 名单为空时基类面全静默（只有既有写检测面在）——证明基类命中由
		// baseFields 驱动而非硬编码名字（implement 选型自由度的护栏）
		var lines = ["\t\tm_view.x = 1;"];
		var hits = DynWriteScan.scanLines(lines, new Map<String, Bool>(), "inline");
		Assert.equals(0, hits.filter(h -> h.variable == "m_view").length);
	}

	function test_comment_lines_never_hit() {
		// 出处 tools/scan_dyn_writes.py:62-64（trim 后行首 `//`/`*` 的整行
		// 跳过）——修复后 WaterController.hx:366 的修复注释内提到 m_view，
		// 不跳注释即假命中；本用例行内钉死
		var lines = [
			"\t\t// m_view.x = 1; 注释内的写字面",
			"\t\t* m_view.visible 星号注释行",
			"\t\t// \"parent\": m_view.stage",
			"\t\tm_view.x = 1;", // 对照：代码行命中
		];
		var hits = baseHits(DynWriteScan.scanLines(lines, baseFieldMap(), "inline"));
		Assert.equals(1, hits.length, "注释行不产命中，恰剩代码行一条，实中 " + hits.length);
		if (hits.length == 1) Assert.equals(4, hits[0].line);
	}

	// ---- 两处 cpp 读偏差修复的扫描侧回归网（issue 验收第一件事的机械面） ----

	function test_mybag_controller_real_file_zero_base_hits() {
		// 出处 // issue #63 待修清单 1：MyBagController.hx:86
		// `As3.truthy(this.m_view.visible)` 的 visible 读在 cpp 上恒 null
		// （typed getter 修复后该处走 view.visible——warehouse_v_23/scripts/
		// module/warehouse/bag/MyBagController.as:76-84 onBagDirty 的
		// `Boolean(m_view) && Boolean(m_view.visible)` 原值不变）。修复后全
		// 文件基类字段读/写命中须清零（本文件其余 m_view/m_model 接触全部是
		// 方法调用/null 判/cast/对字段本身赋值，本就不在命中面）
		var path = "src/module/warehouse/bag/MyBagController.hx";
		var hits = baseHits(hitsFor(path, fixtureLines(path)));
		Assert.equals(0, hits.length, "MyBagController 修复后基类命中须清零（:86 visible 读须已改走 typed view），实中 "
			+ hits.length + (hits.length > 0 ? "，首条 " + hits[0].line + " 行 " + hits[0].code : ""));
	}

	function test_farmland_controller_real_file_zero_base_hits() {
		// 出处 // issue #63 待修清单 2：FarmLandController.hx:552
		// `"parent": m_view.stage`（红土升级 swf 加载失败兜底飘字）的 stage
		// 读在 cpp 上落 null——main3_v_221/scripts/module/mainScene/
		// farmLand/FarmLandController.as:613 原文同形，修复按 typed getter
		// 或局部 cast（issue 原文要求先核对 m_view 在该函数上下文的实际
		// 类型——m_view 由 :862 `new FarmLandsView(this)` 装配）。修复后全
		// 文件基类命中须清零（理由同上）
		var path = "src/module/mainScene/farmLand/FarmLandController.hx";
		var hits = baseHits(hitsFor(path, fixtureLines(path)));
		Assert.equals(0, hits.length, "FarmLandController 修复后基类命中须清零（:552 stage 读须已改走类型化通道），实中 "
			+ hits.length + (hits.length > 0 ? "，首条 " + hits[0].line + " 行 " + hits[0].code : ""));
	}

	function test_water_controller_real_file_zero_base_hits() {
		// #62 已修件的持绿网：527fdc0a 修复落地后的现行
		// src/module/water/WaterController.hx 扫描须零基类命中（防后续改动
		// 把 m_view/m_model 字段接触再带回来）
		var path = "src/module/water/WaterController.hx";
		var hits = baseHits(hitsFor(path, fixtureLines(path)));
		Assert.equals(0, hits.length, "WaterController 基类命中持绿清零，实中 "
			+ hits.length + (hits.length > 0 ? "，首条 " + hits[0].line + " 行 " + hits[0].code : ""));
	}

	// ---- 两处读偏差的直接形态钉（不依赖扫描器选型：源码文本层断言） ----

	function test_mybag_controller_visible_read_shape_removed() {
		// 出处 // issue #63 待修清单 1：MyBagController.hx:86 的
		// `As3.truthy(this.m_view.visible)` 在 cpp 上恒 null 静默偏差——修复
		// 要求改走 typed view getter（warehouse_v_23/scripts/module/
		// warehouse/bag/MyBagController.as:76-84 onBagDirty 原值不变）。
		// 本断言钉修复的机械面：基类 Dynamic 字段上的 visible 读形态
		// （m_view.visible）在代码行中消失——保留即未修（注释行先行剥离，
		// 修复说明注释里提到该形态不算未修）
		var text = stripCommentLines(File.getContent("src/module/warehouse/bag/MyBagController.hx"));
		var re = ~/m_view\s*\.\s*visible/;
		Assert.isFalse(re.match(text), "MyBagController 仍有 m_view.visible 读形态（cpp 静默偏差未修，issue #63 清单 1）");
	}

	function test_farmland_controller_stage_read_shape_removed() {
		// 出处 // issue #63 待修清单 2：FarmLandController.hx:552 的
		// `"parent": m_view.stage`（红土升级 swf 加载失败兜底，main3_v_221/
		// scripts/module/mainScene/farmLand/FarmLandController.as:613 原文
		// 同形）——修复要求 typed getter 或局部 cast（issue 原文：先核对
		// m_view 在该函数上下文的实际类型——由 :862 new FarmLandsView(this)
		// 装配）。机械面同钉：m_view.stage 读形态在代码行中消失（注释行
		// 先行剥离，理由同上）
		var text = stripCommentLines(File.getContent("src/module/mainScene/farmLand/FarmLandController.hx"));
		var re = ~/m_view\s*\.\s*stage/;
		Assert.isFalse(re.match(text), "FarmLandController 仍有 m_view.stage 读形态（cpp 静默偏差未修，issue #63 清单 2）");
	}

	/** 剥离整行注释（trim 后行首 `//` 或 `*`——与 scan_dyn_writes.py:62-64
	 *  跳行同构）：修复说明注释里提到被修形态不算未修。 */
	static function stripCommentLines(text:String):String {
		return text.split("\n").filter(function(l) {
			var t = StringTools.trim(l);
			return !StringTools.startsWith(t, "//") && !StringTools.startsWith(t, "*");
		}).join("\n");
	}
}
