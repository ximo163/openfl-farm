package tools;

import format.abc.Data.ABCData;
import format.abc.Data.OpCode;
import format.abc.Reader as AbcReader;
import format.swf.Reader as SwfReader;
import format.swf.Data.SWFTag;
import format.tools.Inflate;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import sys.io.File;
import tools.FrameScriptSurvey.FrameScriptBinding;
import tools.FrameScriptSurvey.FrameScriptOp;

/**
 * issue #58 帧脚本清查器（一次性 CLI，容器内跑）：
 *   haxe -cp tools -lib format -main tools.FrameScriptAudit --interp
 * 扫 assets/legacy-assets.txt 清单内全部 swf 的根级 DoABC（72/82 都收），
 * 逐类解构造器 → tools.FrameScriptSurvey.ctorBindings 得 addFrameScript
 * 登记表，逐登记解 frameN 方法体 → isBodyEmpty 分流「空体 / 实义」，打印
 * 全量报告（stdout，贴 PR 说明 / issue 评论，不提交文件——spec/ 受保护，
 * 报告类产物不入库）。
 *
 * 与 #56（T3 时间轴门禁）的分工：#56 只推得出脚本在哪些帧（scriptFrames，
 * 镜像运行侧），本工具解构造器实参与方法体字节码（DumpAbcMethod 先例：
 * format.abc.Reader + OpReader），是补偿登记表（shim/
 * FrameScriptCompensation）的逐条出处数据。#56 的读法这里复用两条：format
 * Reader 主路 + a6291_1 的长度走查 fallback（PlaceObject3 className 在
 * Reader.hx:961 抛 Eof）；SymbolClass(76) 的 cid 0 = 主时间轴文档类绑定。
 *
 * 只扫根级 ABC——素材 swf 的 DoABC 全在根级（sprite 层 DoAction/DoABC 全
 * 清单实测无，见 tools/tools/TimelineExtract.hx 头注），多枚 DoABC 全收
 * （Flash 执行全部 ABC 的帧脚本；#56 只认最后一枚是「openfl 运行侧看得到
 * 什么」的镜像，清查要的是「原版有什么」）。
 */
class FrameScriptAudit {
	/** 清单行 → legacy/deploy/QFarmFlash/ 下的绝对路径（目录条目展开成
	 *  旗下 *.swf，sync-legacy-assets.sh 的目录整拷同款语义）。 */
	static function main() {
		var manifest:Array<String> = [];
		for (line in File.getContent("assets/legacy-assets.txt").split("\n")) {
			var t = StringTools.trim(line);
			if (t == "" || StringTools.startsWith(t, "#")) {
				continue;
			}
			manifest.push(t);
		}

		var files:Array<String> = [];
		for (rel in manifest) {
			var path = "legacy/deploy/QFarmFlash/" + rel;
			if (!sys.FileSystem.exists(path)) {
				Sys.println('!! 清单路径不存在：$rel');
				continue;
			}
			if (sys.FileSystem.isDirectory(path)) {
				for (f in rcollect(path)) {
					files.push(f);
				}
			} else {
				files.push(path);
			}
		}
		files.sort(Reflect.compare);

		var assetsWithoutAbc:Int = 0;
		var totalBindings:Int = 0;
		var totalEmpty:Int = 0;
		var totalMeaningful:Int = 0;
		var meaningfulAssets:Array<String> = [];
		var anomalies:Array<String> = [];

		for (path in files) {
			var bytes = File.getBytes(path);
			var tags:ParsedSwf;
			try {
				tags = readWithFormatLib(bytes);
			} catch (e:Dynamic) {
				tags = readRawWalk(bytes); // a6291_1 同款 fallback
			}
			var rel = path.substr("legacy/deploy/QFarmFlash/".length);
			if (tags.abcs.length == 0) {
				assetsWithoutAbc++;
				continue;
			}
			Sys.println('');
			Sys.println('== $rel（DoABC ×${tags.abcs.length}${tags.via == "raw" ? "，raw 走查" : ""}）');
			var assetHasMeaningful = false;
			for (abc in tags.abcs) {
				// className → SymbolClass 绑定 cid（cid 0 = 主轴文档类）
				var data:ABCData;
				try {
					data = new AbcReader(new BytesInput(abc)).read();
				} catch (e:Dynamic) {
					Sys.println('   (ABC 解不动：$e)');
					continue;
				}
				var bodies = new Map<Int, format.abc.Data.Function>();
				for (b in data.functions) {
					bodies.set(b.type.asInt(), b);
				}
				for (c in data.classes) {
					var className = fullClassName(data, c.name);
					if (className == "?") {
						continue;
					}
					// 帧脚本登记只在构造器里；有 frameN 方法名而无登记的类
					// （死了的脚本/反射调用）单列为异常
					var ctorIdx = c.constructor.asInt();
					var ctorBody = bodies.get(ctorIdx);
					var bindings:Array<FrameScriptBinding> = [];
					if (ctorBody != null) {
						bindings = FrameScriptSurvey.ctorBindings(mirrorOps(data, decodeOps(ctorBody)));
					}
					var frameMethodBodies = new Map<String, Array<FrameScriptOp>>();
					for (f in c.fields) {
						switch (f.kind) {
							case FMethod(m, _, _, _):
								var mname = nameStr(data, f.name);
								if (mname != null && ~/^frame\d+$/.match(mname)) {
									var body = bodies.get(m.asInt());
									frameMethodBodies.set(mname, body == null ? null : mirrorOps(data, decodeOps(body)));
								}
							default:
						}
					}
					if (bindings.length == 0) {
						// 无 addFrameScript：frameN 方法若存在则记异常（Flash
						// 不执行未被登记的帧脚本）
						for (mname in frameMethodBodies.keys()) {
							anomalies.push('$rel $className 有 $mname 方法但构造器无 addFrameScript 登记');
						}
						continue;
					}
					var binding = describeBinding(data, tags.bindings, className);
					Sys.println('   class $className$binding');
					for (b in bindings) {
						totalBindings++;
						var ops = frameMethodBodies.get(b.method);
						if (ops == null) {
							anomalies.push('$rel $className frame${b.frame} 登记的方法 ${b.method} 无方法体');
							Sys.println('      frame${b.frame} ← ${b.method}：无方法体（异常）');
							continue;
						}
						if (FrameScriptSurvey.isBodyEmpty(ops)) {
							totalEmpty++;
							Sys.println('      frame${b.frame} ← ${b.method}：空体');
						} else {
							totalMeaningful++;
							assetHasMeaningful = true;
							Sys.println('      frame${b.frame} ← ${b.method}：实义（${ops.length} op）');
							Sys.println('        ' + ops.map(opName).join(" "));
						}
					}
				}
			}
			if (assetHasMeaningful) {
				meaningfulAssets.push(rel);
			}
		}

		Sys.println('');
		Sys.println('==== 汇总 ====');
		Sys.println('清单 swf ${files.length} 个：无 ABC（纯素材）$assetsWithoutAbc 个，其余 ${files.length - assetsWithoutAbc} 个含根级 DoABC');
		Sys.println('addFrameScript 登记共 $totalBindings 条：空体 $totalEmpty / 实义 $totalMeaningful');
		Sys.println('实义分布：' + meaningfulAssets.join("、"));
		if (anomalies.length > 0) {
			Sys.println('异常（登记与体不配套，人工核对）：');
			for (a in anomalies) {
				Sys.println('   $a');
			}
		}
	}

	// ---- swf → 根级 DoABC 字节 + SymbolClass 绑定 ----

	static function readWithFormatLib(bytes:Bytes):ParsedSwf {
		var swf = new SwfReader(new BytesInput(bytes)).read();
		var out:ParsedSwf = {abcs: [], bindings: new Map(), via: "format"};
		for (tag in swf.tags) {
			switch (tag) {
				// DoABC(82) 与 RawABC(72) 都收（原版全部 ABC 都可能带帧脚本）
				case TActionScript3(body, _):
					out.abcs.push(body);
				case TSymbolClass(symbols):
					for (sym in symbols) {
						out.bindings.set(sym.className, sym.cid);
					}
				default:
			}
		}
		return out;
	}

	/** a6291_1 的 fallback：只解 SymbolClass/DoABC(82/72)，其余按长度跳过
	 *  （能活过 Reader 读不动的坏 PlaceObject3 的原因，TimelineExtract 同款）。 */
	static function readRawWalk(bytes:Bytes):ParsedSwf {
		var b = bytes;
		if (b.get(0) == 'C'.code && b.get(1) == 'W'.code && b.get(2) == 'S'.code) {
			var head = b.sub(0, 8);
			var body = Inflate.run(b.sub(8, b.length - 8));
			var all = Bytes.alloc(8 + body.length);
			all.blit(0, head, 0, 8);
			all.blit(8, body, 0, body.length);
			b = all;
		}
		// 跳 RECT（首字节高 5 位 = nbits，总位 5+4nbits）+ fps(2) + 帧数(2)
		var p = 8;
		var nbits = b.get(p) >> 3;
		p += 1 + Math.ceil(nbits / 2);
		p += 4;
		var out:ParsedSwf = {abcs: [], bindings: new Map(), via: "raw"};
		while (p < b.length - 1) {
			var h = readU16(b, p);
			var code = h >> 6;
			var len = h & 63;
			p += 2;
			if (len == 63) {
				len = readU32(b, p);
				p += 4;
			}
			if (code == 0) break;
			if (p + len > b.length) break; // 烂尾防御
			switch (code) {
				case 76: // SymbolClass
					var n = readU16(b, p);
					var q = p + 2;
					for (_ in 0...n) {
						var cid = readU16(b, q);
						q += 2;
						var nameLen = cstringLen(b, q);
						out.bindings.set(b.getString(q, nameLen), cid);
						q += nameLen + 1;
					}
				case 82: // DoABC：flags u32 + \0 名 + ABC 体
					var nameLen = cstringLen(b, p + 4);
					var abcStart = p + 4 + nameLen + 1;
					if (abcStart <= p + len) {
						out.abcs.push(b.sub(abcStart, p + len - abcStart));
					}
				case 72: // RawABC：整段是 ABC 体
					out.abcs.push(b.sub(p, len));
				default:
			}
			p += len;
		}
		return out;
	}

	// ---- ABC → 镜像 op 流 ----

	static function decodeOps(body:format.abc.Data.Function):Array<OpCode> {
		var out:Array<OpCode> = [];
		var inp = new BytesInput(body.code);
		var opr = new format.abc.OpReader(inp);
		while (inp.position < body.code.length) {
			var b = inp.readByte();
			out.push(opr.readOp(b));
		}
		return out;
	}

	/** format OpCode → FrameScriptOp 镜像（只映射清查相关形态；其余 →
	 *  OOther，isBodyEmpty 按实义不猜）。常量折叠：OSmallInt/OInt/OIntRef/
	 *  OUIntRef → OInt（值同）。 */
	static function mirrorOps(abc:ABCData, ops:Array<OpCode>):Array<FrameScriptOp> {
		var out:Array<FrameScriptOp> = [];
		for (op in ops) {
			var m:FrameScriptOp = switch (op) {
				case OThis: FrameScriptOp.OThis;
				case OScope: FrameScriptOp.OScope;
				case OPop: FrameScriptOp.OPop;
				case ORetVoid: FrameScriptOp.ORetVoid;
				case OSmallInt(v): FrameScriptOp.OInt(v);
				case OInt(v): FrameScriptOp.OInt(v);
				case OIntRef(v): FrameScriptOp.OInt(abc.get(abc.ints, v));
				case OUIntRef(v): FrameScriptOp.OInt(abc.get(abc.uints, v));
				case OString(v): FrameScriptOp.OStr(abc.get(abc.strings, v));
				case OFindProp(n): FrameScriptOp.OFindProp(nameStr(abc, n));
				case OFindPropStrict(n): FrameScriptOp.OFindPropStrict(nameStr(abc, n));
				case OGetProp(n): FrameScriptOp.OGetProp(nameStr(abc, n));
				case OGetLex(n): FrameScriptOp.OGetLex(nameStr(abc, n));
				case OSetProp(n): FrameScriptOp.OSetProp(nameStr(abc, n));
				case OInitProp(n): FrameScriptOp.OInitProp(nameStr(abc, n));
				case OCallProperty(n, argc): FrameScriptOp.OCallProp(nameStr(abc, n), argc);
				case OCallPropVoid(n, argc): FrameScriptOp.OCallPropVoid(nameStr(abc, n), argc);
				case OConstructProperty(n, argc): FrameScriptOp.OConstructProp(nameStr(abc, n), argc);
				case OConstructSuper(argc): FrameScriptOp.OConstructSuper(argc);
				case ODebugReg(_) | ODebugLine(_) | ODebugFile(_) | OTimestamp:
					FrameScriptOp.ODebug(Std.string(op).split("(")[0]);
				default: FrameScriptOp.OOther(Std.string(op).split("(")[0]);
			}
			out.push(m);
		}
		return out;
	}

	/** 报告用的 op 简名。 */
	static function opName(op:FrameScriptOp):String {
		return switch (op) {
			case OInt(v): 'OInt($v)';
			case OStr(v): 'OStr("$v")';
			case OFindProp(n): 'OFindProp($n)';
			case OFindPropStrict(n): 'OFindPropStrict($n)';
			case OGetProp(n): 'OGetProp($n)';
			case OGetLex(n): 'OGetLex($n)';
			case OSetProp(n): 'OSetProp($n)';
			case OInitProp(n): 'OInitProp($n)';
			case OCallProp(n, a): 'OCallProp($n,$a)';
			case OCallPropVoid(n, a): 'OCallPropVoid($n,$a)';
			case OConstructProp(n, a): 'OConstructProp($n,$a)';
			case OConstructSuper(a): 'OConstructSuper($a)';
			case ODebug(n): 'ODebug($n)';
			case OOther(n): 'OOther($n)';
			default: Std.string(op);
		}
	}

	/** 类名（含包名前缀，与 SymbolClass 绑定名同形）。NName 单命名空间 /
	 *  NMulti 命名空间集（取首个非空段）。 */
	static function fullClassName(abc:ABCData, idx:format.abc.Data.IName):String {
		var n = abc.get(abc.names, idx);
		return switch (n) {
			case NName(s, ns):
				var nsName = nsStr(abc, ns);
				var name = abc.get(abc.strings, s);
				nsName == "" ? name : nsName + "." + name;
			case NMulti(s, nsSet):
				var nsName = nsSetStr(abc, nsSet);
				var name = abc.get(abc.strings, s);
				nsName == "" ? name : nsName + "." + name;
			case NParams(inner, _): fullClassName(abc, inner);
			default: "?";
		}
	}

	/** 命名空间集 → 首个命名空间的字符串段（包名）。 */
	static function nsSetStr(abc:ABCData, idx:format.abc.Data.Index<format.abc.Data.NamespaceSet>):String {
		var set = abc.get(abc.nssets, idx);
		if (set == null) return "";
		for (nsIdx in set) {
			var s = nsStr(abc, nsIdx);
			if (s != "" && s != "?") return s;
		}
		return "";
	}

	static function nsStr(abc:ABCData, idx:format.abc.Data.Index<format.abc.Data.Namespace>):String {
		return switch (abc.get(abc.namespaces, idx)) {
			case NPublic(s): abc.get(abc.strings, s);
			case NInternal(s): abc.get(abc.strings, s);
			case NPrivate(s): abc.get(abc.strings, s);
			case NProtected(s): abc.get(abc.strings, s);
			default: "?";
		}
	}

	/** DumpAbcMethod.nameStr 同款：NName/NMulti → 字符串名（ns 段截掉）。 */
	static function nameStr(abc:ABCData, idx:format.abc.Data.IName):String {
		if (idx == null || idx.asInt() == 0) {
			return null;
		}
		var n = abc.get(abc.names, idx);
		return switch (n) {
			case NName(s, _): abc.get(abc.strings, s);
			case NMulti(s, _): abc.get(abc.strings, s);
			case NParams(inner, _): nameStr(abc, inner);
			default: null;
		}
	}

	/** 类的符号绑定描述（报告定位用）。 */
	static function describeBinding(data:ABCData, bindings:Map<String, Int>, className:String):String {
		if (!bindings.exists(className)) {
			return "（无 SymbolClass 绑定——未导出的辅助类）";
		}
		var cid = bindings.get(className);
		return cid == 0 ? "（SymbolClass cid 0 = 主时间轴文档类）" : '（SymbolClass → char#$cid）';
	}

	// ---- 走查的底层字节读取（小端，TimelineExtract 同款） ----

	static inline function readU16(b:Bytes, p:Int):Int {
		return b.get(p) | (b.get(p + 1) << 8);
	}

	static inline function readU32(b:Bytes, p:Int):Int {
		return b.get(p) | (b.get(p + 1) << 8) | (b.get(p + 2) << 16) | (b.get(p + 3) << 24);
	}

	static function cstringLen(b:Bytes, p:Int):Int {
		var q = p;
		while (q < b.length && b.get(q) != 0) q++;
		return q - p;
	}

	static function rcollect(dir:String):Array<String> {
		var out:Array<String> = [];
		for (name in sys.FileSystem.readDirectory(dir)) {
			var p = dir + "/" + name;
			if (sys.FileSystem.isDirectory(p)) {
				out = out.concat(rcollect(p));
			} else if (StringTools.endsWith(p, ".swf")) {
				out.push(p);
			}
		}
		return out;
	}
}

// 模块级（Haxe 4 类体内不放 typedef，TimelineExtract 同款）
typedef ParsedSwf = {
	/** 根级 DoABC(72/82) 的 ABC 体（全部收，见类头注） */
	abcs:Array<Bytes>,
	/** SymbolClass(76) className → cid（cid 0 = 主时间轴文档类绑定） */
	bindings:Map<String, Int>,
	via:String
};
