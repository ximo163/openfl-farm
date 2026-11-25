package tools;

/**
 * issue #70 机器门收口之一：test/** 禁 throw-stub 扫描的纯逻辑（write-tests
 * 阶段为 stub，契约由 test/tools/TestStubScanTest.hx 钉死，implement 原地
 * 填充）。
 *
 * 为什么这门存在：test/ 是定稿区（write-tests 交付时已审完，不含待填骨
 * 架——「stub 放它完工后所属的树，不进 test/」规矩出处
 * .orchestrator/prompts/write-tests.md:20-26，#56 教训）。错放的 stub 此前
 * 无机器门：#56 attempt-1 的 stub 混进 test/，implement 被 append-only
 * 驳回、被迫发明 import.hx 遮蔽（$11 教训），烧了 implement 才撞墙。本扫
 * 描让 write-tests 的 verify 当场拦截，而不是事后靠记忆。
 *
 * 职责边界：本类只做**行集 → 命中**的纯逻辑，不读文件、不走目录——逐文件
 * 读行喂进来。走目录收 test/**.hx、拼报告行、按命中有无 exit 0/1 归脚本侧
 * （python 壳 tools/scan_test_stubs.py，或 Haxe 胶水，选型 implement 自定
 * ——对脚本侧的唯一契约是行格式，见 reportLine）。
 *
 * 命中判式（// issue #70 交付物 1 原文：「pattern 收窄到 stub 惯用语一族：
 * `throw new Error("not implemented")`、`throw new haxe.Exception("not
 * implemented")`、`throw "not implemented"`（对照 write-tests.md 的 stub 规
 * 则原文措辞）」）。一行命中**当且仅当**以下全部成立（2026-11-25 容器实测
 * 逐字验证：全 test/ 树只有 #56 两僵尸的 9 行命中——spec:51/56/62/68/77/82
 * + diff:53/59/64，零误报）：
 *
 *   1. 字符串遮罩（先于剔注释）：把行内字符串字面量内容（`'…'`/`"…"`，
 *      反斜杠转义对占两格）逐字符换成空白、只留定界引号——**代码结构**
 *      与**字符串内容**就此分离。先于剔注释做，字符串内的 `//`（URL 字
 *      面量等）就不会被当成注释起点截断后续真代码；
 *   2. 剔注释：在**遮罩后**的文本上取第一个 `//` 之前的部分（行注释整段
 *      不算代码；`///` 文档注释同以 `//` 起手同剔——遮罩后字符串已空，
 *      截断位必然落在真注释上）；
 *   3. 语句位判式：剔注释后的遮罩文本匹配「throw 处于语句位」——throw
 *      前是行首/空白/分号/花括号/括号/等号这类非标识符边界（`thrower`、
 *      `xthrow` 不算；字符串内的 throw 字样已被遮罩抹掉、天然不算），
 *      后随（空白不敏感）`new Error(` 或 `new haxe.Exception(`（issue
 *      原文形态一/二的类名逐字），或直接跟字符串开引号 `"`（issue 原文
 *      形态三裸字符串）；
 *   4. 逐字短语：**未遮罩**的同行文本（同一剔注释截断位之前）含 `not
 *      implemented`（小写、单空格——短语在 throw 的字符串实参里，遮罩
 *      后已不可见，所以这条在遮罩前的文本上判）。
 *
 * 判式刻意收窄，以下都不命中（在库先例与不误伤面，实测锚点见上）：
 *   - 注释提到：test/tools/import.hx:6 的散文（`//` 在 throw 之前，剔除
 *     后残余无内容）；
 *   - 无 throw 语句的散文：test/help0316_fla/MainTimelineTest.hx:51「抛
 *     not implemented」——机器门若拦散文，正常叙事注释反而写不了这个
 *     词，误伤面大于捕获面；
 *   - 字符串/断言里**引用**惯用语字样的行（扫描工具自身的测试语料形态
 *     ——`Assert.equals('throw new Error("not implemented");', …)`：throw
 *     在字符串内，遮罩后消失，判式 3 不过）。**这决定了写测试语料时引
 *     用惯用语无需回避**；
 *   - 大小写变体（`Not implemented`/`NOT IMPLEMENTED`——不是 stub 惯用
 *     语，不折叠）；
 *   - 没有 `not implemented` 字样的 throw（`throw "whatever"`、`throw
 *     new Error("boom")`——正常业务 throw 不是待填骨架）。
 *
 * 输出形状：命中三元组 path（入参原样）/line（1 基）/code（trim 后行文
 * 本）；脚本侧报告行格式 `文件:行 摘录`（`path:line 摘录`——// issue #70
 * 原文，「对齐 scan_dyn_writes.py 的输出形态」按「路径:行号起手、行文本
 * 收尾」对齐；scan_dyn_writes.py 中间的 tab 列是它的变量/属性三元组，
 * 本扫描没有对应物）。
 *
 * 已知存量豁免（迁移期，// issue #70 原文「豁免清单写死在脚本顶部、每
 * 项注明出处，不引入通用白名单机制」）：#56 的两个僵尸 stub 文件
 * test/tools/TimelineSpec.hx 与 test/tools/TimelineDiff.hx——import.hx
 * 遮蔽「已经放进去了的按那条接」。豁免按**文件路径**豁免（不是按行号、
 * 不是按豁免行文本）：清僵尸＝删文件后豁免清单随删（issue 验收「清理
 * 僵尸后豁免清单清空」），按行豁免会留下「豁免已不存在的行」的腐化口。
 * 豁免语义在 exemptHits：把豁免文件的命中从全集里滤掉，同时报告哪些豁
 * 免条目**还在消费**（文件里仍有命中）/已失锚（文件里零命中——腐化检
 * 测面：僵尸被删后豁免行没跟着删，扫出来提醒收口）。
 */
class TestStubScan {
	/** 命中判式字面量（// issue #70；写死在判式里，不做参数化——「收窄到
	 * stub 惯用语一族」就是要它固定）。 */
	static inline final NEEDLE:String = "not implemented";

	/** issue #70 点名的两个豁免文件（写死，出处逐条见 exemptions()）。 */
	static inline final EXEMPT_TIMELINE_SPEC:String = "test/tools/TimelineSpec.hx";
	static inline final EXEMPT_TIMELINE_DIFF:String = "test/tools/TimelineDiff.hx";

	/** 单文件行扫描：lines 是行文本数组（按 \n 切好的），path 原样进命中
	 * 三元组。命中判式四条件见类头（字符串遮罩→剔注释→语句位 throw 惯用
	 * 语族→遮罩前逐字短语；大小写敏感）。行序保持输入序。一行只出一条命
	 * 中（同行多处出现不重复计——行是报告粒度）。 */
	static public function scanLines(lines:Array<String>, path:String):Array<StubHit> {
		var hits:Array<StubHit> = [];
		for (i in 0...lines.length) {
			if (lineIsStub(lines[i])) hits.push({path: path, line: i + 1, code: StringTools.trim(lines[i])});
		}
		return hits;
	}

	/** 当前生效的豁免清单（写死两条，出处逐条注明——// issue #70「豁免清
	 * 单写死在脚本顶部、每项注明出处」）。返回**副本**（调用方改了不影响
	 * 内部状态；就两条、无所谓性能）。 */
	static public function exemptions():Array<Exemption> {
		return [
			{
				path: EXEMPT_TIMELINE_SPEC,
				reason: "#56 僵尸 stub：write-tests attempt-1 留在 test/ 的骨架，implement 被 test/** append-only 驳回后靠 import.hx 遮蔽、不再被任何链加载——issue #70 迁移期豁免（清理该文件时同步删本条并改 TestStubScanTest 的豁免断言）"
			},
			{
				path: EXEMPT_TIMELINE_DIFF,
				reason: "#56 僵尸 stub（与 TimelineSpec 同批，import.hx 遮蔽先例）——issue #70 迁移期豁免"
			}
		];
	}

	/** 报告行拼装：`path:line 摘录` 单行（// issue #70 输出契约）。path
	 * 含空格/行文本为空行之类都不做转义——人读报告不是机读协议。 */
	static public function reportLine(hit:StubHit):String {
		return hit.path + ":" + hit.line + " " + hit.code;
	}

	/** 报告行逆向判读：一行文本是不是本门输出的报告行形态（`路径:行 摘录`
	 * ——行号段是数字、路径段非空、摘录段任意）。机读回归用：测试对拍脚本
	 * 输出时靠它分拣命中行与首尾说明行。 */
	static public function isReportLine(line:String):Bool {
		if (line == null) return false;
		var colon = line.indexOf(":");
		if (colon <= 0) return false; // 无冒号，或路径段为空（":51 …"）
		var rest = line.substring(colon + 1);
		var digits = 0;
		while (digits < rest.length && rest.charCodeAt(digits) >= "0".code && rest.charCodeAt(digits) <= "9".code) digits++;
		if (digits == 0) return false; // 行号段非数字（首尾说明行的 " FAIL …" 形态在此拦下）
		if (digits == rest.length) return true; // 摘录段空（"path:8"）
		return rest.charCodeAt(digits) == " ".code;
	}

	/** 豁免消费：全集命中 → 滤后命中 + 豁免对账。path 与豁免条目**逐字相
	 * 等**才豁免（不做规范化——扫描器与测试喂的是仓库相对路径同一形态；
	 * `./test/tools/…` 或反斜杠形态不匹配、按未豁免报，这是有意的：豁免面
	 * 越窄腐化越早现形）。stale 是失锚豁免条目名单（该文件在全集命中里
	 * 已零命中——僵尸清理后豁免行忘删的检测面）；live 是仍在消费的。豁免
	 * 文件里一条命中都没有时它整文件进 stale（不是逐行粒度）。 */
	static public function exemptHits(allHits:Array<StubHit>, exemptions:Array<Exemption>):ExemptResult {
		var exempt = new Map<String, Bool>();
		for (e in exemptions) exempt.set(e.path, true);
		var hits:Array<StubHit> = [];
		var consumed = new Map<String, Bool>();
		for (h in allHits) {
			if (exempt.exists(h.path)) consumed.set(h.path, true);
			else hits.push(h);
		}
		var live:Array<Exemption> = [];
		var stale:Array<Exemption> = [];
		for (e in exemptions) {
			if (consumed.exists(e.path)) live.push(e);
			else stale.push(e);
		}
		return {hits: hits, live: live, stale: stale};
	}

	// ---- 判式内部（类头四条件的实现件；私有，不进公共 API） ----

	/** 单行判式：四条件全部成立才命中。条件顺序有讲究——字符串遮罩必须
	 * **先于**剔注释（类头条件 1/2）：遮罩与原文**等长**（转义对占两格），
	 * 所以剔注释的截断位可以直接换算回原文用（条件 4 在遮罩前文本上判）。 */
	static function lineIsStub(raw:String):Bool {
		var masked = maskStrings(raw);
		var cut = masked.indexOf("//"); // 遮罩后字符串内的 //（URL 字面量）已抹掉，截断位必在真注释上
		var cutPos = cut < 0 ? raw.length : cut;
		if (raw.substring(0, cutPos).indexOf(NEEDLE) < 0) return false; // 条件 4：遮罩前、截断位之前含逐字短语
		return hasStatementThrow(cut < 0 ? masked : masked.substring(0, cut)); // 条件 3
	}

	/** 字符串遮罩（条件 1）：'…'/"…" 的内容逐字符换空白、只留定界引号，
	 * 反斜杠转义对占两格——**保持与原文等长**（剔注释截断位可互换使用）。
	 * 字符串未闭合（跨行/孤引号）时吃满到行尾，与逐行扫描的粒度一致。 */
	static function maskStrings(s:String):String {
		var buf = new StringBuf();
		var i = 0;
		var quote = -1; // 当前字符串的定界引号码；-1 = 不在字符串里
		while (i < s.length) {
			var c = s.charCodeAt(i);
			if (quote < 0) {
				if (c == '"'.code || c == "'".code) quote = c;
				buf.addChar(c);
				i++;
			} else if (c == "\\".code && i + 1 < s.length) {
				buf.add("  "); // 转义对占两格
				i += 2;
			} else if (c == quote) {
				quote = -1;
				buf.addChar(c);
				i++;
			} else {
				buf.add(" ");
				i++;
			}
		}
		return buf.toString();
	}

	/** 语句位 throw 惯用语族（条件 3）：throw 前是白名单边界（行首/空白/
	 * ;{}()=——反引号**不在**白名单，doc 注释里 ``throw "not implemented"``
	 * 的引用形态靠它排除）、后是非标识符字符，且（空白不敏感）随 `"`（形态
	 * 三）或 `new Error(` / `new haxe.Exception(`（形态一/二）。 */
	static function hasStatementThrow(text:String):Bool {
		var n = text.length;
		var from = 0;
		while (true) {
			var idx = text.indexOf("throw", from);
			if (idx < 0) return false;
			var end = idx + 5; // "throw".length
			if (statementBoundaryBefore(text, idx) && (end >= n || !isIdent(text.charCodeAt(end)))) {
				var j = skipWs(text, end);
				if (j < n && text.charCodeAt(j) == '"'.code) return true;
				if (matchWord(text, j, "new")) {
					var k = skipWs(text, j + 3);
					if (matchWord(text, k, "Error")) {
						var m = skipWs(text, k + 5);
						if (m < n && text.charCodeAt(m) == "(".code) return true;
					} else if (matchWord(text, k, "haxe")) {
						var m = skipWs(text, k + 4);
						if (m < n && text.charCodeAt(m) == ".".code) {
							m = skipWs(text, m + 1);
							if (matchWord(text, m, "Exception")) {
								var e = skipWs(text, m + 9);
								if (e < n && text.charCodeAt(e) == "(".code) return true;
							}
						}
					}
				}
			}
			from = idx + 1; // 同行第二个 throw 也要看（一行仍只出一条命中，见 scanLines）
		}
	}

	/** throw 的左边界白名单：行首/空白/分号/花括号/括号/等号（类头条件 3
	 * 的枚举集）。反引号、方括号等非标识符字符**故意不收**——收了就把
	 * doc 注释/散文里反引号引用的惯用语当真 stub（误伤面大于捕获面）。 */
	static function statementBoundaryBefore(text:String, idx:Int):Bool {
		if (idx == 0) return true;
		var c = text.charCodeAt(idx - 1);
		return isWs(c) || c == ";".code || c == "{".code || c == "}".code || c == "(".code || c == ")".code || c == "=".code;
	}

	static function isWs(c:Int):Bool {
		return c == " ".code || c == "\t".code || c == "\r".code || c == "\n".code;
	}

	static function isIdent(c:Int):Bool {
		return (c >= "a".code && c <= "z".code) || (c >= "A".code && c <= "Z".code)
			|| (c >= "0".code && c <= "9".code) || c == "_".code;
	}

	static function skipWs(text:String, i:Int):Int {
		while (i < text.length && isWs(text.charCodeAt(i))) i++;
		return i;
	}

	/** 词匹配：逐字相等且词尾是非标识符字符（`newError(` 里的 new 不算）。 */
	static function matchWord(text:String, i:Int, word:String):Bool {
		if (text.substr(i, word.length) != word) return false;
		var after = i + word.length;
		return after >= text.length || !isIdent(text.charCodeAt(after));
	}
}

/** 单条命中（契约见类头）。 */
typedef StubHit = {
	/** 入参 path 原样（仓库相对路径形态由扫描器侧决定，本类不规范化）。 */
	var path:String;
	/** 1 基行号。 */
	var line:Int;
	/** trim 后的行文本（「摘录」）。 */
	var code:String;
}

/** 豁免条目（写死清单的元素形状；// issue #70「每项注明出处」）。 */
typedef Exemption = {
	/** 豁免的文件路径（逐字匹配）。 */
	var path:String;
	/** 出处一句话（为什么是合法存量——报告里打出来给人看）。 */
	var reason:String;
}

/** 豁免消费结果（契约见 exemptHits）。 */
typedef ExemptResult = {
	/** 滤掉豁免后的命中（脚本侧据此非空则 exit 1）。 */
	var hits:Array<StubHit>;
	/** 仍在消费的豁免条目（文件里确有命中被滤掉）。 */
	var live:Array<Exemption>;
	/** 失锚的豁免条目（文件里零命中——腐化检测面，提醒删豁免行）。 */
	var stale:Array<Exemption>;
}
