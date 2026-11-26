package tools;

/**
 * issue #83：swf-inventory 生成器手写增补保留逻辑的纯逻辑（write-tests 阶
 * 段为 stub，契约由 test/tools/SwfInventoryMergeTest.hx 钉死，implement
 * 原地填充）。
 *
 * 为什么这门存在：scripts/swf-inventory.py:115-117 用 json.dump 从零全量
 * 重写 spec/swf-inventory.json，无任何合并/保留逻辑；legacy-decompile.yml
 * 由 legacy/deploy/recompile-trigger 的 push 触发再生成（该文件至今已改
 * 6 次、每改必重生成）。#30 给 shop_v_7/warehouse_v_23/pool_v_13/decorate_v_0
 * 四条手写的 code 块（五键形态，出处 commit 84c203bb）被 399a5faa 的 CI
 * 再生成整体抹掉、因无测试钉住而无人察觉。#66（cards_v_1/quickshoot_v_0/
 * WildShellNc_v_5）按同形态交付也会落地即死。issue #83 决策点 a（推荐方
 * 向，issue 原文）：「生成器加保留逻辑：重写前读旧文件，同 path 条目保
 * 留手写键（如 code），新生成条目无手写键则照常输出」。
 *
 * 职责边界：本类只做**JSON 文本进 → JSON 文本出**的纯逻辑（动态值操作，
 * 不读文件、不走目录、不读真实时间）。归并形状：
 *
 *   merge(oldText, generatedText) → 合成后的清单 JSON 文本
 *
 *   输入两份 spec/swf-inventory.json 形态的 JSON 文本：oldText 是再生成
 *   前的工作区现文件（含手写增补），generatedText 是生成器本次从零产出
 *   （每条目只有机器键）。输出以 generatedText 为基座——机器生成面（
 *   bytes/category/fps/frames/stage/unparsed、条目增删、path 排序、顶
 *   层 version/source/count）全部以新生成为准（「基线出账等机器生成部
 *   分不受影响」，issue #83 决策点 a 原文）；手写键按 path 配对从
 *   oldText 搬入。
 *
 * 手写键判定：条目键集减去机器键闭集 {path, bytes, category, fps,
 * frames, stage, unparsed}（scripts/swf-inventory.py:97-105 的全部产出
 * 键，unparsed 仅头部解不开时出现）后余下的键。闭集写死在本类，不做参
 * 数化——机器键集变了是生成器契约变了，那时该改的是这个类（#63 判式
 * 单源教训：判式只在这里有一份）。逐字匹配，大小写不折叠。
 *
 * 保留规则（// issue #83 决策点 a）：
 *   1. 配对键是 path（path 在清单里唯一——6290 条实测零重复）；
 *   2. 旧条目带手写键、新清单同 path 条目仍在 → 手写键值**逐字覆盖**到
 *      新条目上（84c203bb 五键 code 块原样存活）；
 *   3. 新条目本不带手写键（生成器从零产出）——若同名键两边都有，旧值
 *      赢（手写优先级高于机器再产出，人审过的增补不被覆盖）；
 *   4. 新清单里没有同 path 条目（swf 被删/改名）→ 手写键随条目消失，
 *      不搬——孤块留在清单里是腐化（对账门禁另有职责，见
 *      test/tools/SwfInventoryMergeTest.hx 类头的门禁面）；
 *   5. 顶层三键 version/source/count 永远以 generatedText 为准（count 与
 *      新 swfs 数组长度一致——手写键只进条目，不进顶层）。
 *
 * 输出文本形状：缩进 1 空格、UTF-8 非 ASCII 不转义、条目按 path 字典
 * 序——与 scripts/swf-inventory.py:116 的 json.dump(indent=1,
 * ensure_ascii=False) 同形态，再生成回路里两次连续 merge 幂等（同样输
 * 入同样输出，diff 干净）。键序：机器键在前（按 json.dump 的插入序：
 * path/bytes/category/fps/frames/stage[/unparsed]），手写键按名字典序
 * 缀后——84c203bb 的 diff 形态（code 块出现在 stage 之后）同构。
 *
 * 实现要点（为什么不能直接用 haxe.Json.stringify 搭）：输出形态必须逐
 * 字节对齐 python 的 json.dump(indent=1, ensure_ascii=False)，且手写键
 * 值要按旧文件原文逐字搬运——haxe.Json.parse 会丢掉 Float/Int 的区分
 * （eval 上 25.0 与 25 都进 TFloat/TInt 的归一坑，parse 后 stringify 无
 * 法还原 25.0 的字面形态），机器面以新生成为准可以只靠 re-serialize，
 * 但手写面一旦经过 parse 就不再逐字。所以手写键的值子串直接从 oldText
 * 原文里按位置截取（parse 只用来找键和配对，不用来重排值），机器面键
 * 与顶层三键从 generatedText 截值同理——全部值子串都来自原文，缩进/
 * 分隔/键序由本类拼，数字/字符串/嵌套对象的字面形态逐字保留。
 *
 * 输入解析失败的语义：oldText 不是合法 JSON 或形状不符（顶层无 swfs 数
 * 组）→ 手写面整体视为空，输出即 generatedText 原样整形——首次生成/
 * 旧文件损坏不阻塞再生成；generatedText 形状不符是生成器自身坏了，抛
 * 出（调用方脚本侧退非零）而不是静默产出空清单（防「生成器坏了还写
 * 出绿文件」）。条目级形状异常（非对象条目、无 path 键）在旧文件侧忽
 * 略该条、在新文件侧原样保留（新文件是权威基座，生成器的产出原样透
 * 传，裁决归对账门禁）。
 */
class SwfInventoryMerge {
	/** 机器键闭集（scripts/swf-inventory.py:97-105 的全部产出键；写死，
	 * 不做参数化——生成器契约变了就该改这里）。 */
	static public final MACHINE_KEYS:Array<String> = [
		"path", "bytes", "category", "fps", "frames", "stage", "unparsed"
	];

	/** 手写键判定：键不在机器键闭集内（逐字，大小写不折叠）。 */
	static public function isHandwrittenKey(key:String):Bool {
		return MACHINE_KEYS.indexOf(key) < 0;
	}

	/** 单条目手写键集：条目的键减去机器键后的余集（字典序）。非对象/无
	 * 键条目入参按空调用方契约不出现，这里对 null 返回空数组。 */
	static public function handwrittenKeysOf(entry:Dynamic):Array<String> {
		if (entry == null) return [];
		var keys = [for (k in Reflect.fields(entry)) if (isHandwrittenKey(k)) k];
		keys.sort(Reflect.compare);
		return keys;
	}

	/** 归并本体（契约见类头）：oldText/generatedText 两份清单 JSON 文本
	 * → 合成清单 JSON 文本。generatedText 形状不符（顶层非对象或无 swfs
	 * 数组）抛异常；oldText 形状不符按空手写面处理。 */
	static public function merge(oldText:String, generatedText:String):String {
		var gen = parseInventory(generatedText, true);
		var old = parseInventory(oldText, false);
		// 手写面索引：path → (键 → 原文值子串)。旧文件里带手写键的条目才进
		// 索引；同 path 重复（清单约定不出现）以先见为准——配对键逐字、不模
		// 糊，后来者视为腐化忽略（裁决归对账门禁，merge 不发明去重规则）。
		var handIndex = new Map<String, Map<String, String>>();
		if (old != null) {
			for (e in old.entries) {
				var p = e.path;
				if (p == null) continue;
				if (handIndex.exists(p)) continue;
				var hand = new Map<String, String>();
				for (k in e.keys) {
					if (!isHandwrittenKey(k)) continue;
					hand.set(k, e.values.get(k));
				}
				if (Lambda.count(hand) > 0) handIndex.set(p, hand);
			}
		}
		// 新条目按 path 排序（scripts/swf-inventory.py:111 语义进输出——输入
		// 乱序不影响输出序，幂等的前提）。path 缺位/非字符串的条目排最后、
		// 保持原相对序（新文件是权威基座，生成器的产出原样透传）。
		var order = new Array<Int>();
		for (i in 0...gen.entries.length) order.push(i);
		var keyed = [for (i in order) {i: i, path: gen.entries[i].path}];
		var sortable = [for (k in keyed) if (k.path != null) k];
		var unsortable = [for (k in keyed) if (k.path == null) k];
		sortable.sort(function(a, b) {
			var c = Reflect.compare(a.path, b.path);
			if (c != 0) return c;
			return a.i - b.i;
		});
		order = [for (k in sortable) k.i].concat([for (k in unsortable) k.i]);
		// 逐条目拼：机器键在前（按 generatedText 原文的插入序），手写键按名
		// 字典序缀后（84c203bb diff 形态——code 在 stage 之后）。值子串全部
		// 取自原文：机器键值取 generatedText，手写键值取 oldText（逐字搬运，
		// 见类头实现要点）。
		var buf = new StringBuf();
		buf.add("{\n");
		buf.add(' "version": ' + gen.topValues.get("version") + ",\n");
		buf.add(' "source": ' + gen.topValues.get("source") + ",\n");
		buf.add(' "count": ' + gen.topValues.get("count") + ",\n");
		buf.add(' "swfs": [');
		for (pos in 0...order.length) {
			var e = gen.entries[order[pos]];
			buf.add(if (pos == 0) "\n" else ",\n");
			if (e.raw != null) {
				// 非对象条目（生成器产出腐化面）：原文逐字透传，不进键拼流程
				// ——新文件是权威基座，merge 不裁决它的形状（类头契约）
				buf.add("  " + e.raw);
				continue;
			}
			buf.add("  {\n");
			var parts = new Array<String>();
			for (k in e.keys) {
				parts.push('   ' + haxe.Json.stringify(k) + ': ' + e.values.get(k));
			}
			var hand = (e.path != null) ? handIndex.get(e.path) : null;
			if (hand != null) {
				var handKeys = [for (k in hand.keys()) k];
				handKeys.sort(Reflect.compare);
				for (k in handKeys) {
					// 同名键两边都有时旧值赢（类头保留规则 3）——生成器从零产
					// 出本不带手写键，真撞名说明机器面长出了同名词，人手审过的
					// 增补不被覆盖；机器键闭集是写死的，手写键与机器键不可能
					// 同名，所以这里只需防 generatedText 里手写键位置的重复插
					// 入。
					if (e.values.exists(k)) {
						// 替换掉已按 generatedText 拼出的那一份
						parts = [for (p in parts) if (!keyMatches(p, k)) p];
					}
					parts.push('   ' + haxe.Json.stringify(k) + ': ' + hand.get(k));
				}
			}
			buf.add(parts.join(",\n"));
			buf.add("\n  }");
		}
		// 顶层余键：除 version/source/count/swfs 外 generatedText 顶层还有什
		// 么原样透传（生成器契约里的顶层键面漂移不静默吞掉——写死三键 + swfs
		// 之外的键按原插入序缀在 swfs 后，值子串取 generatedText 原文）。
		var extraTop = new Array<String>();
		for (k in gen.topKeys) {
			if (k == "version" || k == "source" || k == "count" || k == "swfs") continue;
			extraTop.push(' ' + haxe.Json.stringify(k) + ': ' + gen.topValues.get(k));
		}
		buf.add(if (order.length == 0) "]" else "\n ]");
		if (extraTop.length > 0) {
			buf.add(",\n");
			buf.add(extraTop.join(",\n"));
			buf.add("\n}");
		} else {
			buf.add("\n}");
		}
		return buf.toString();
	}

	/** 报告行（机读回归分拣用，test/tools/SwfInventoryMergeTest.hx 的断
	 * 言消息形态）：保留一条手写块时脚本侧打印的单行
	 * `keep <path> <键名,逗号连接>`。 */
	static public function reportLine(path:String, keys:Array<String>):String {
		return "keep " + path + " " + keys.join(",");
	}

	// ------------------------------------------------------------------
	// 以下为内部实现：按原文位置截取值子串的迷你 JSON 扫描器。
	//
	// 为什么不用 haxe.Json.parse 的值：parse 后数字的字面形态丢失（25.0 →
	// 25），手写块的「逐字搬运」契约无法兑现；parse 只承担形状校验（合法
	// JSON 与否、顶层形状），值一律从原文截。

	/** 解析清单文本。strict=true（generatedText）时形状不符抛异常；
	 * strict=false（oldText）时形状不符返回 null（手写面视为空）。形状不
	 * 符 = 不是合法 JSON / 顶层非对象 / 顶层无 swfs 数组。swfs 数组内非对
	 * 象条目在旧文件侧忽略、在新文件侧以空对象条目透传（见类头）。 */
	static function parseInventory(text:String, strict:Bool):Null<DocScan> {
		if (text == null) {
			if (strict) throw new haxe.Exception("swf-inventory merge: generatedText 为空");
			return null;
		}
		// 形状校验用 haxe.Json.parse——它对字面量/结构的判定是权威的，扫描
		// 器只负责位置。parse 失败 = 不是合法 JSON。
		var parsed:Dynamic = try haxe.Json.parse(text) catch (e:Dynamic) {
			if (strict) throw new haxe.Exception("swf-inventory merge: generatedText 不是合法 JSON");
			return null;
		};
		if (parsed == null || !Reflect.isObject(parsed) || Std.isOfType(parsed, Array)) {
			if (strict) throw new haxe.Exception("swf-inventory merge: generatedText 顶层非对象");
			return null;
		}
		var swfsDyn = Reflect.field(parsed, "swfs");
		if (!Std.isOfType(swfsDyn, Array)) {
			if (strict) throw new haxe.Exception("swf-inventory merge: generatedText 顶层无 swfs 数组");
			return null;
		}
		// 位置扫描：只在顶层对象与 swfs 数组两级做键/值截取（清单形状固定，
		// 不需要通用 JSON 定位器）。扫描前先过一遍 haxe.Json.parse 保证整体
		// 合法，扫描器内部不再处理畸形输入的恢复。
		var scan = new PosScanner(text);
		scan.skipWs();
		if (scan.peek() != "{".code) {
			if (strict) throw new haxe.Exception("swf-inventory merge: generatedText 顶层非对象");
			return null;
		}
		var topKeys = new Array<String>();
		var topValues = new Map<String, String>();
		var entries = new Array<EntryScan>();
		scan.pos++; // {
		while (true) {
			scan.skipWs();
			if (scan.peek() == "}".code) { scan.pos++; break; }
			var key = scan.readString();
			if (key == null) {
				if (strict) throw new haxe.Exception("swf-inventory merge: generatedText 顶层键扫描失败");
				return null;
			}
			scan.skipWs();
			if (scan.peek() != ":".code) {
				if (strict) throw new haxe.Exception("swf-inventory merge: generatedText 顶层键后无冒号");
				return null;
			}
			scan.pos++; // :
			scan.skipWs();
			var vstart = scan.pos;
			if (key == "swfs" && scan.peek() == "[".code) {
				// swfs 数组：逐条扫描对象条目，同时记录整条数组的原文值子串
				scan.pos++; // [
				var idx = 0;
				while (true) {
					scan.skipWs();
					if (scan.peek() == "]".code) { scan.pos++; break; }
					var estart = scan.pos;
					if (scan.peek() == "{".code) {
						var escan = scanEntry(scan);
						if (escan == null) {
							if (strict) throw new haxe.Exception("swf-inventory merge: swfs 条目扫描失败");
							return null;
						}
						entries.push(escan);
					} else {
						// 非对象条目（新文件侧原样透传，契约见类头）：跳过整个
						// 值，记为空键条目——path 必为 null，排到最末
						skipValue(scan);
						entries.push({keys: [], values: new Map(), path: null, raw: text.substring(estart, scan.pos)});
					}
					scan.skipWs();
					if (scan.peek() == ",".code) { scan.pos++; }
					idx++;
				}
			} else {
				skipValue(scan);
			}
			var vend = scan.pos;
			topKeys.push(key);
			topValues.set(key, text.substring(vstart, vend));
			scan.skipWs();
			if (scan.peek() == ",".code) { scan.pos++; }
		}
		return {topKeys: topKeys, topValues: topValues, entries: entries};
	}

	/** 扫描单个对象条目：读取键/值位置，返回键插入序、值原文子串、path
	 * 提取。scan.pos 进入时在 `{`、出来时在 `}` 之后。条目非法（parse 已
	 * 保证整体合法，这里防的是对象内形状出格）返回 null。 */
	static function scanEntry(scan:PosScanner):Null<EntryScan> {
		var estart = scan.pos;
		scan.pos++; // {
		var keys = new Array<String>();
		var values = new Map<String, String>();
		var path:Null<String> = null;
		while (true) {
			scan.skipWs();
			if (scan.peek() == "}".code) { scan.pos++; break; }
			var key = scan.readString();
			if (key == null) return null;
			scan.skipWs();
			if (scan.peek() != ":".code) return null;
			scan.pos++; // :
			scan.skipWs();
			var vstart = scan.pos;
			skipValue(scan);
			var vend = scan.pos;
			var raw = scan.text.substring(vstart, vend);
			keys.push(key);
			values.set(key, raw);
			if (key == "path") {
				// path 取字符串值（非字符串按缺键处理——配对键是字符串逐字，
				// 生成器产出的 path 必为字符串）
				var pv:Dynamic = try haxe.Json.parse(raw) catch (e:Dynamic) null;
				if (Std.isOfType(pv, String)) path = cast pv;
			}
			scan.skipWs();
			if (scan.peek() == ",".code) { scan.pos++; }
		}
		return {keys: keys, values: values, path: path, raw: null};
	}

	/** 跳过任意 JSON 值（对象/数组/字符串/数字/true/false/null），scan.pos
	 * 落在值结束之后。调用前文本已过 haxe.Json.parse 整体校验，这里不做
	 * 恢复性容错。 */
	static function skipValue(scan:PosScanner):Void {
		scan.skipWs();
		var c = scan.peek();
		if (c == "\"".code) {
			scan.readString();
			return;
		}
		if (c == "{".code || c == "[".code) {
			var open = c;
			var close = (open == "{".code) ? "}".code : "]".code;
			scan.pos++;
			var depth = 1;
			while (depth > 0 && scan.pos < scan.text.length) {
				var ch = scan.peek();
				if (ch == "\"".code) {
					scan.readString();
					continue;
				}
				if (ch == "{".code || ch == "[".code) depth++;
				if (ch == "}".code || ch == "]".code) depth--;
				scan.pos++;
			}
			return;
		}
		// 字面量：数字/true/false/null——读到分隔符为止
		while (scan.pos < scan.text.length) {
			var ch = scan.peek();
			if (ch == ",".code || ch == "}".code || ch == "]".code || ch == " ".code
				|| ch == "\t".code || ch == "\n".code || ch == "\r".code) break;
			scan.pos++;
		}
	}

	/** 判断一行已拼出的 `   "key": value` 片段是否属于键 k（同名键两边都
	 * 有时的旧值赢替换用）。parts 元素形态固定（本类拼出），前缀比对即够。 */
	static function keyMatches(part:String, key:String):Bool {
		var prefix = "   " + haxe.Json.stringify(key) + ": ";
		return StringTools.startsWith(part, prefix);
	}
}

/** 单条目的拆解结果：keys 为插入序键名，values 为键 → 原文值子串，
 * path 为 path 键的字符串值（非字符串/缺键为 null）。 */
private typedef EntryScan = {
	keys:Array<String>,
	values:Map<String, String>,
	path:Null<String>,
	raw:Null<String>
};

/** 清单文档的拆解结果：顶层键插入序与原文值子串（version/source/
 * count/swfs 之外的顶层键也在，透传用），entries 为 swfs 数组逐条。 */
private typedef DocScan = {
	topKeys:Array<String>,
	topValues:Map<String, String>,
	entries:Array<EntryScan>
};

/** 逐字符位置扫描器：只在 parseInventory/scanEntry/skipValue 内部用。持
 * 有原文与游标，readString 返回 JSON 字符串字面量的解码值（haxe.Json.parse
 * 解码——转义形态的正确性交给标准库，扫描器只找边界）。 */
private class PosScanner {
	public var text:String;
	public var pos:Int = 0;

	public function new(text:String) {
		this.text = text;
	}

	public inline function peek():Int {
		return (pos < text.length) ? text.charCodeAt(pos) : -1;
	}

	public inline function skipWs():Void {
		while (pos < text.length) {
			var c = text.charCodeAt(pos);
			if (c == " ".code || c == "\t".code || c == "\n".code || c == "\r".code) pos++; else break;
		}
	}

	/** 读字符串字面量：游标在开头引号时前进到结尾引号之后并返回解码值；
	 * 否则返回 null（游标不动——调用方按形状失败处理）。解码借助
	 * haxe.Json.parse（转义序列的正确性不归扫描器）。 */
	public function readString():Null<String> {
		if (peek() != "\"".code) return null;
		var start = pos;
		pos++; // 开引号
		while (pos < text.length) {
			var c = text.charCodeAt(pos);
			if (c == "\\".code) {
				pos += 2;
				continue;
			}
			if (c == "\"".code) {
				pos++;
				var raw = text.substring(start, pos);
				var v:Dynamic = try haxe.Json.parse(raw) catch (e:Dynamic) null;
				return Std.isOfType(v, String) ? cast v : null;
			}
			pos++;
		}
		return null;
	}
}
