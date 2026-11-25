package tools;

/**
 * issue #63 基类 Dynamic 字段盲区补扫——scan_dyn_writes 的 Haxe 纯逻辑镜像
 * + 基类扩展（write-tests 阶段 stub，契约由 test/tools/BaseFieldScanTest.hx
 * 钉死，implement 原地填充）。
 *
 * 为什么存在：tools/scan_dyn_writes.py 只追踪**局部变量与本文件声明**的
 * Dynamic 生产者，不追踪基类继承的 Dynamic 字段（m_view/m_model 家族）——
 * #62 的漏网正是这个盲区（WaterController.hx:366 修复前的 `m_view.x =` 从
 * 未出现在扫描输出里）。cpp typer 扫描也抓不到这类错（Dynamic 类型层怎么
 * 编都合法），唯一现形场是 android 真机（写 Invalid field 炸、读静默
 * null 偏差），扫描器是唯一能提前拦的机械层（出处：issue #63 机制节）。
 *
 * 镜像基线：现有命中行（_locN_/_arrow/item 一族的 Dynamic 字段写）全部
 * 保持原检测（main 当前 53 行命中清单的形状不能因本扩展丢失）；以下契约
 * 只覆盖新增的基类字段面。
 *
 * 契约（// issue #63）：
 *
 * 1. collect(lines)——单文件基类字段收集：
 *    从**基类**源码行里收 `private var <名>:Dynamic` 形态的字段名（含
 *    private/public 等前缀修饰——framework/base/Controller.hx:12-14 的
 *    `private var m_view:Dynamic;`/`private var m_model:Dynamic;` 是基准
 *    出处；`private var m_module:IModule` 非 Dynamic 不收）。返回键排序
 *    确定（升序）的 Map 或等价结构（实现选型自定，测试按「含 m_view/
 *    m_model 两键、不含 m_module」断言）。
 *
 * 2. scanLines(lines, baseFields, path)——单文件行扫描：
 *    - 注释行跳过与 scan_dyn_writes.py:62-64 同构：行首（trim 后）`//` 或
 *      `*` 的整行不产生命中（修复后 WaterController.hx:366 的修复注释内
 *      提到 m_view、迷你 fixture 的头注释段亦同——不跳注释即假命中）。
 *    - 现有写检测原样：DECL_DYN/ASSIGN_PRODUCER 追踪的变量上 `x.prop =`
 *      命中（kind "write"，var/prop/line/code 四元组）。
 *    - 新增基类命中：baseFields 名单内名字的 `this.<名>.<字段>` 与
 *      裸 `<名>.<字段>` 形态——写（`=<非 =>` 收尾）kind "write"，读
 *      （其余字段接触）kind "read"。
 *    - 不命中面（按形态，不按名单外推断）：
 *      a. 裸字段 null 判/赋值：`m_view == null`、`m_view = x`（对 m_view
 *         本身赋值，不是 m_view 上的字段写——post-fix 修复形态
 *         WaterController.hx:364 同形，本就不在命中面）；
 *      b. 方法调用 `m_view.show(...)`（原版视角是 view 真类型的方法，
 *         cpp 上 Dynamic 方法调用不在本 issue 登记的失效面——issue 只钉
 *         字段读/写）；
 *      c. `cast(m_view, T)`（对 m_view 本身无字段接触）。
 *    - hit 四元组：path（入参原样）、line（1 基）、var（"m_view" 等名
 *      字）、prop（字段名）、kind（"read"/"write"）、code（trim 后行文本）。
 *
 * 3. 样例锚点（验收以 fixture 行号钉死，见 test/tools/BaseFieldScanTest.hx）：
 *    - test/fixtures/water-controller-pre-fix.hx（527fdc0a^ 的原样快照，
 *      #62 修复前）：:366 `m_view.x =`、:367 `m_view.y =` write 命中；
 *      :364 `m_view = _loc1_`、:368 `addChild(m_view)`、:362 `m_view ==
 *      null` 不命中。
 *    - test/fixtures/water-controller-post-fix.hx（527fdc0a 快照，修复
 *      后）：零基类命中（:371 `addChild(m_view)` 等残余形态全在不命中面）。
 *    - test/fixtures/base-fields-*.hx 迷你族：读写形态矩阵（含 this. 前缀、
 *      对象字面量值位 read、typed getter 降噪）。
 *
 * 实现选型（implement 自行取舍，issue 原文）：跨文件 extends 链解析，或
 * 已知基类字段名单（m_view/m_model）——测试只钉单文件 API 的命中/不命
 * 中面，不钉跨文件装配（扫描器脚本侧的接线按 issue 走 implement）。
 */
class DynWriteScan {
	// —— 判式与 scan_dyn_writes.py 同构（正则文本逐字对齐，Haxe EReg 的
	// lookahead/全局 matchSub 已 probe 实证，2026-11-25）——

	/** 返回 Dynamic 的生产者（接收者上的一切字段写都算动态）。 */
	static final PRODUCER_SRC = "(Utils\\.getMaterial|Reflect\\.field|Reflect\\.getProperty|"
		+ "As3\\.childOf|As3\\.getProperty)\\s*\\(";

	/** var x:Dynamic / private var x:Dynamic（局部与类字段都收）。 */
	static var DECL_DYN:EReg = ~/\bvar\s+([A-Za-z_][A-Za-z0-9_]*)\s*:\s*Dynamic\b/g;

	/** var x:Array<Dynamic>。 */
	static var DECL_ARR_DYN:EReg = ~/\bvar\s+([A-Za-z_][A-Za-z0-9_]*)\s*:\s*Array<Dynamic>/g;

	/** x = <producer>(...)（含 var x = ...）：本行起视为动态。 */
	static var ASSIGN_PRODUCER:EReg = null;

	/** 字段写：x.prop = / x[i].prop = / x["k"].prop =（==、>= 等由 (?![=>]) 排除）。 */
	static var FIELD_WRITE:EReg = ~/([A-Za-z_][A-Za-z0-9_]*)((?:\[[^\]]*\])*)\.([A-Za-z_][A-Za-z0-9_]*)\s*=(?![=>])/g;

	/** collect 用：行首 var 声明（private/public 前缀不扣格）的 Dynamic 类字段。
	 * `_locN` 反编译临时名排除——它们是函数体内局部不是类字段（行首缩进
	 * 更深）， Window 一族基类源码里若混进 `_locN:Dynamic` 收进名单会把全库
	 * 同名局部变量全染成命中（2026-11-25 实测并集污染 2200+ 行，教训已进
	 * handbook/lessons）。 */
	static var BASE_DECL:EReg = ~/^\s*(?:(?:private|public|protected|static|final)\s+)*var\s+([A-Za-z_][A-Za-z0-9_]*)\s*:\s*Dynamic\b/;

	static function assignProducerRe():EReg {
		if (ASSIGN_PRODUCER == null) {
			ASSIGN_PRODUCER = new EReg("\\b(?:var\\s+)?([A-Za-z_][A-Za-z0-9_]*)\\s*=\\s*[^;=\\n]*" + PRODUCER_SRC, "g");
		}
		return ASSIGN_PRODUCER;
	}

	static function foreachMatch(re:EReg, text:String, f:String->Int->Void):Void {
		var pos = 0;
		while (pos <= text.length && re.matchSub(text, pos)) {
			var p = re.matchedPos();
			var end = p.pos + p.len;
			f(re.matched(1), p.pos);
			pos = end > pos ? end : pos + 1; // 零宽命中防死循环
		}
	}

	/** prop 匹配结束后行内余尾分类：第一非空白字符定形态。
	 * 返回 null = 不命中面（方法调用）；否则 "write"/"read"。 */
	static function classifyTail(line:String, from:Int):String {
		var i = from;
		while (i < line.length) {
			var c = line.charAt(i);
			if (c == " " || c == "\t") {
				i++;
				continue;
			}
			if (c == "(") return null; // 方法调用
			if (c == "=") {
				var n = i + 1 < line.length ? line.charAt(i + 1) : "";
				if (n == "=" || n == ">") return "read"; // ==/>= 比较，仍是读
				return "write";
			}
			return "read";
		}
		return "read"; // 行尾收尾（`var s = m_view.stage` 无分号形态同 read）
	}

	/** 单文件基类 Dynamic 字段收集（契约见类头条 1）。 */
	static public function collect(lines:Array<String>):Map<String, Bool> {
		var out = new Map<String, Bool>();
		var locN = ~/^_loc[0-9]+_$/;
		for (line in lines) {
			var stripped = StringTools.trim(line);
			if (StringTools.startsWith(stripped, "//") || StringTools.startsWith(stripped, "*")) continue;
			if (BASE_DECL.match(line)) {
				var name = BASE_DECL.matched(1);
				if (!locN.match(name)) out.set(name, true);
			}
		}
		return out;
	}

	/** 单文件行扫描（契约见类头条 2）。baseFields 为 collect 产出的名单
	 * （键=字段名）；path 原样回填 hit。 */
	static public function scanLines(lines:Array<String>, baseFields:Map<String, Bool>, path:String):Array<DynHit> {
		var hits:Array<DynHit> = [];
		var dynVars = new Map<String, Bool>();
		var assignRe = assignProducerRe();
		for (i in 0...lines.length) {
			var line = lines[i];
			var stripped = StringTools.trim(line);
			var lineNo = i + 1;
			if (StringTools.startsWith(stripped, "//") || StringTools.startsWith(stripped, "*")) continue;

			// —— 既有写检测通道（scan_dyn_writes.py 同构，原样保留）——
			foreachMatch(DECL_DYN, line, function(name, _) dynVars.set(name, true));
			foreachMatch(DECL_ARR_DYN, line, function(name, _) dynVars.set(name, true));
			foreachMatch(assignRe, line, function(name, _) dynVars.set(name, true));
			// EReg matched(n) 在一次 match 内多组取值：FIELD_WRITE 的 prop 是组 3，
			// foreachMatch 只给组 1，这里手开循环
			var pos = 0;
			while (pos <= line.length && FIELD_WRITE.matchSub(line, pos)) {
				var p = FIELD_WRITE.matchedPos();
				var v = FIELD_WRITE.matched(1);
				var prop = FIELD_WRITE.matched(3);
				if (dynVars.exists(v)) {
					hits.push({path: path, line: lineNo, variable: v, prop: prop, kind: "write", code: stripped});
				}
				pos = p.pos + p.len > pos ? p.pos + p.len : pos + 1;
			}

			// —— 基类继承 Dynamic 字段的读/写命中（issue #63 补盲区）——
			// 接收者形态：裸 <名> 或 this.<名>（词边界防 m_viewXxx 类前缀误吞）；
			// 写字段 `prop =`（==/>= 由 (?![=>]) 排除——同 FIELD_WRITE 判式），
			// 其余字段接触一律 read（条件位/var 初始化/对象字面量值位同族，
			// cpp 上全是静默 null 偏差）；方法调用（prop 后紧跟 `(`）与裸字段
			// 接触（无 .prop 段）不在命中面。
			for (name in baseFields.keys()) {
				// 形态判式：prop 完整吃进 ident 后按**行内余尾**分类——eval EReg
				// 的 lookahead 退化成右截断匹配（嵌套 lookahead 更乱，2026-11-25
				// probe 实证），不能靠 lookahead 分流：prop 后第一非空字符
				//   `(`           → 方法调用，不命中（issue 只钉字段读/写）；
				//   `=`+非 `=`/`>` → 写字段（kind "write"；==/>= 是比较 read）；
				//   其余           → 读字段（kind "read"——条件位/var 初始化/对象
				//                    字面量值位同族，cpp 上全是静默 null 偏差）。
				// 裸字段接触（无 .prop 段：`m_view == null`、`m_view = x`、
				// `addChild(m_view)`、`cast(m_view, T)`）形态上根本不进匹配。
				var touchRe = new EReg("(?:this\\.)?" + name + "\\.([A-Za-z_][A-Za-z0-9_]*)", "g");
				var tp = 0;
				while (tp <= line.length && touchRe.matchSub(line, tp)) {
					var p = touchRe.matchedPos();
					var prop = touchRe.matched(1);
					var kind = classifyTail(line, p.pos + p.len);
					if (kind != null) {
						hits.push({path: path, line: lineNo, variable: name, prop: prop, kind: kind, code: stripped});
					}
					tp = p.pos + p.len > tp ? p.pos + p.len : tp + 1;
				}
			}
		}
		// 输出排序确定性：行号升序、行内命中位序（构造顺序即扫描顺序，同
		// python 版的行优先次序）；既有通道与基类通道同行交错时按追加序，
		// 四元组本身不含序依赖——测试按 (line, var, prop) 定位，无形状约束
		return hits;
	}
}

/** 一条命中（scan_dyn_writes 输出四元组 + kind 读/写别）。 */
typedef DynHit = {
	var path:String;
	var line:Int;
	var variable:String; // 接收者名（m_view/_loc2_/…）
	var prop:String; // 字段名（x/visible/stage/…）
	var kind:String; // "read" | "write"
	var code:String; // trim 后行文本
}
