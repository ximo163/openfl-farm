package tools;

import format.abc.Data.ABCData;
import format.abc.Data.IName;
import format.abc.Reader as AbcReader;
import format.swf.Data.SWFTag;
import format.swf.Reader as SwfReader;
import format.tools.Inflate;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import tools.TimelineTypes.LabelEntry;

/**
 * T3 时间轴行为对拍——期望侧提取器（issue #56）：swf 字节 → 结构 JSON
 * （tools.TimelineSpec.parseAssetStructure 的输入形状，键名契约同
 * test/tools/TimelineTypes.hx 类头）。
 *
 * 两条读法，产出同构中间数据（模块级 typedef RawClip/RawSwf，文件尾）：
 *  1. format 3.7.0 Reader（主路）——69 个清单资产里 68 个能整读；
 *  2. 自带标签走查（fallback）——a6291_1.swf 在 format Reader 上抛 Eof
 *     （PlaceObject3 className，Reader.hx:961），改用 dump_swf.php 同款的
 *     长度走查 + format.tools.Inflate 解 CWS；只解门禁要的标签
 *     （ShowFrame/FrameLabel/DefineSprite/SymbolClass/DoABC/86），其余按长度
 *     跳过——这正是走查能活过坏 PlaceObject3 的原因。
 *
 * scriptFrames（帧事件盲区标注的输入）两路并收：
 *  · 本层 DoAction(12)/DoABC(72/82) 出现帧（1 基；dump_swf.php 69 资产实测：
 *    sprite 层全清单无、主轴有则恒在帧 1，farm/diy/1-4 与 diy/board/1 五件无）；
 *  · SymbolClass(76) 绑定名的 ABC 类 frameN 方法帧位——镜像运行侧 haxelib swf
 *    3.4.0 的真实行为：SWFTimelineContainer.processAS3Tag 每枚 DoABC 都覆盖
 *    abcData（最后一枚生效），SWFLiteExporter 只对 symbolsByTagID
 *    （SymbolClass）绑定的符号跑 FrameScriptParser.convertToJS（AVM2
 *    FRAME_SCRIPT_METHOD_NAME ~/frame(\d+)/，1 基；findClassByName 拆最后一段
 *    为类名、其余为包名）。故本提取器只扫最后一枚根级 DoABC(82)、只认
 *    SymbolClass 名——ExportAssets(56) 名 exporter 不采（全清单实测 0 枚 tag56），
 *    采了反而与探针侧键对不上（运行侧 symbolsByClassName 只来自 SymbolClass）。
 *
 * 帧数一律取 ShowFrame 计数（与运行侧 exporter 从标签建帧一致），DefineSprite
 * 声明的 frameCount 只作参照不采信；clips 顺序 = 主时间轴 + DefineSprite 先序
 * （嵌套 sprite 规范上不存在，防御性收容）。
 */
class TimelineExtract {
	/** 镜像 swf 3.4.0 FrameScriptParser.AVM2.FRAME_SCRIPT_METHOD_NAME。 */
	static final FRAME_SCRIPT_METHOD_NAME = ~/frame(\d+)/;

	/** swf 字节 → 结构 JSON；via = "format"（Reader 主路）|"raw"（走查 fallback）。 */
	static public function extractStructure(asset:String, bytes:Bytes):{json:String, via:String} {
		var data:RawSwf;
		var via = "format";
		try {
			data = readWithFormatLib(bytes);
		} catch (e:Dynamic) {
			// format Reader 读不动的件（a6291_1）单点容错降级到走查，不整单跳过
			via = "raw";
			data = readRawWalk(bytes);
		}
		return {json: buildStructureJson(asset, data), via: via};
	}

	// ---- 读法 1：format Reader ----

	private static function readWithFormatLib(bytes:Bytes):RawSwf {
		var swf = new SwfReader(new BytesInput(bytes)).read();
		var data:RawSwf = {
			main: {id: null, symbol: null, isMain: true, frames: 0, labels: [], scriptFrames: []},
			sprites: [],
			bindings: new Map(),
			lastRootAbc: null
		};

		var frame = 0;
		var labels:Array<LabelEntry> = [];
		var scripts:Array<Int> = [];
		for (tag in swf.tags) {
			switch (tag) {
				case TShowFrame:
					frame++;
				case TFrameLabel(label, _):
					labels.push({frame: frame + 1, name: label});
				case TDoActions(_):
					scripts.push(frame + 1);
				case TActionScript3(body, context):
					scripts.push(frame + 1);
					// context 非空 = DoABC(82)（RawABC(72) 是 null）——运行侧
					// processAS3Tag 只对 82 建 abcData，72 不进
					if (context != null) data.lastRootAbc = body;
				case TSymbolClass(symbols):
					for (sym in symbols) data.bindings.set(sym.cid, sym.className);
				case TClip(id, _, tags):
					var sub = walkFormatClip(data, tags);
					data.sprites.push({id: id, symbol: null, isMain: false, frames: sub.frames, labels: sub.labels, scriptFrames: sub.scripts});
				case TUnknown(86, body):
					// format Reader 不解 DefineSceneAndFrameLabelData——手工解
					// 帧标签段（变长 u32 + \0 名；全清单实测为空，场景名不进比对）
					parseScenesTag(body, labels);
				default:
			}
		}
		data.main.frames = frame;
		data.main.labels = labels;
		data.main.scriptFrames = scripts;
		return data;
	}

	/** DefineSprite 的标签流：帧数/标签/脚本帧。嵌套 DefineSprite 防御性收容。 */
	private static function walkFormatClip(data:RawSwf, tags:Array<SWFTag>):{frames:Int, labels:Array<LabelEntry>, scripts:Array<Int>} {
		var frame = 0;
		var labels:Array<LabelEntry> = [];
		var scripts:Array<Int> = [];
		for (tag in tags) {
			switch (tag) {
				case TShowFrame:
					frame++;
				case TFrameLabel(label, _):
					labels.push({frame: frame + 1, name: label});
				case TDoActions(_) | TActionScript3(_):
					scripts.push(frame + 1);
				case TClip(id, _, subTags):
					var sub = walkFormatClip(data, subTags);
					data.sprites.push({id: id, symbol: null, isMain: false, frames: sub.frames, labels: sub.labels, scriptFrames: sub.scripts});
				case TUnknown(86, body):
					parseScenesTag(body, labels);
				default:
			}
		}
		return {frames: frame, labels: labels, scripts: scripts};
	}

	// ---- 读法 2：自带标签走查（a6291_1 等 Reader 读不动的件） ----

	private static function readRawWalk(bytes:Bytes):RawSwf {
		// CWS 解压（format Reader 在 readHeader 里做，走查这里手动；FWS 原样）
		var b = bytes;
		if (b.get(0) == 'C'.code && b.get(1) == 'W'.code && b.get(2) == 'S'.code) {
			var head = b.sub(0, 8);
			var body = Inflate.run(b.sub(8, b.length - 8));
			var all = Bytes.alloc(8 + body.length);
			all.blit(0, head, 0, 8);
			all.blit(8, body, 0, body.length);
			b = all;
		}
		// 跳过 RECT（首字节高 5 位 = 边界位宽 nbits，总位 5+4nbits）+ fps(2) + 帧数(2)
		var p = 8;
		var nbits = b.get(p) >> 3;
		p += 1 + Math.ceil(nbits / 2);
		p += 4;
		var data:RawSwf = {
			main: {id: null, symbol: null, isMain: true, frames: 0, labels: [], scriptFrames: []},
			sprites: [],
			bindings: new Map(),
			lastRootAbc: null
		};
		var root = walkRawTags(b, p, b.length, data, true);
		data.main.frames = root.frames;
		data.main.labels = root.labels;
		data.main.scriptFrames = root.scripts;
		return data;
	}

	/** 一条时间轴的标签走查；DefineSprite 递归（子标签流在 tag 体内）。 */
	private static function walkRawTags(b:Bytes, start:Int, end:Int, data:RawSwf, isRoot:Bool):{frames:Int, labels:Array<LabelEntry>, scripts:Array<Int>} {
		var frame = 0;
		var labels:Array<LabelEntry> = [];
		var scripts:Array<Int> = [];
		var p = start;
		while (p < end - 1) {
			var h = readU16(b, p);
			var code = h >> 6;
			var len = h & 63;
			p += 2;
			if (len == 63) {
				len = readU32(b, p);
				p += 4;
			}
			if (code == 0) break; // End
			if (p + len > b.length) break; // 烂尾防御：宁缺勿炸
			switch (code) {
				case 1: // ShowFrame
					frame++;
				case 43: // FrameLabel：\0 结尾名（+可选 anchor 字节）
					labels.push({frame: frame + 1, name: readCString(b, p)});
				case 12 | 72: // DoAction / RawABC
					scripts.push(frame + 1);
				case 82: // DoABC：flags u32 + \0 名 + ABC 体
					scripts.push(frame + 1);
					if (isRoot) {
						var nameLen = cstringLen(b, p + 4);
						var abcStart = p + 4 + nameLen + 1;
						if (abcStart <= p + len) {
							data.lastRootAbc = b.sub(abcStart, p + len - abcStart);
						}
					}
				case 39: // DefineSprite：u16 id + u16 声明帧数 + 子标签流
					var cid = readU16(b, p);
					var sub = walkRawTags(b, p + 4, p + len, data, false);
					data.sprites.push({id: cid, symbol: null, isMain: false, frames: sub.frames, labels: sub.labels, scriptFrames: sub.scripts});
				case 76: // SymbolClass：u16 计数 +（u16 cid + \0 名）×n
					var n = readU16(b, p);
					var q = p + 2;
					for (_ in 0...n) {
						var cid = readU16(b, q);
						q += 2;
						var nameLen = cstringLen(b, q);
						data.bindings.set(cid, b.getString(q, nameLen));
						q += nameLen + 1;
					}
				case 86: // DefineSceneAndFrameLabelData
					parseScenesTag(b.sub(p, len), labels);
				default:
			}
			p += len;
		}
		return {frames: frame, labels: labels, scripts: scripts};
	}

	/** tag 86：场景数/帧标签数变长 u32 + \0 名（dump_swf.php 同款）。帧号 +1 统一 1 基。 */
	private static function parseScenesTag(body:Bytes, labels:Array<LabelEntry>):Void {
		var q = 0;
		var sceneCount = readVarU32(body, q);
		q = sceneCount.next;
		for (_ in 0...sceneCount.v) {
			if (q >= body.length) return;
			q = readVarU32(body, q).next; // 场景 offset（不进比对）
			q += cstringLen(body, q) + 1; // 场景名
		}
		var labelCount = readVarU32(body, q);
		q = labelCount.next;
		for (_ in 0...labelCount.v) {
			if (q >= body.length) return;
			var r = readVarU32(body, q);
			q = r.next;
			var nameLen = cstringLen(body, q);
			labels.push({frame: r.v + 1, name: body.getString(q, nameLen)});
			q += nameLen + 1;
		}
	}

	// ---- 中间数据 → 结构 JSON（含 ABC frameN 扫描） ----

	private static function buildStructureJson(asset:String, data:RawSwf):String {
		var abc:ABCData = null;
		if (data.lastRootAbc != null) {
			try {
				abc = new AbcReader(new BytesInput(data.lastRootAbc)).read();
			} catch (e:Dynamic) {
				abc = null; // 解不动 = 运行侧同样拿不到 frameN（单点容错）
			}
		}
		var rootName = data.bindings.get(0);
		data.main.symbol = rootName;
		var clips:Array<Dynamic> = [clipJson(data.main, rootName != null ? abcScriptFrames(abc, rootName) : null)];
		for (s in data.sprites) {
			if (s.symbol == null) s.symbol = data.bindings.get(s.id);
			clips.push(clipJson(s, s.symbol != null ? abcScriptFrames(abc, s.symbol) : null));
		}
		return haxe.Json.stringify({asset: asset, clips: clips});
	}

	/** 一条剪辑 → 结构 JSON 条目；ABC frameN 帧位并入 scriptFrames（去重排序）。 */
	private static function clipJson(c:RawClip, abcFrames:Null<Array<Int>>):Dynamic {
		var scriptFrames = c.scriptFrames.copy();
		if (abcFrames != null) {
			for (f in abcFrames) {
				if (scriptFrames.indexOf(f) < 0) scriptFrames.push(f);
			}
		}
		scriptFrames.sort(Reflect.compare);
		return {
			id: c.id,
			symbol: c.symbol,
			isMain: c.isMain,
			frames: c.frames,
			labels: c.labels,
			scriptFrames: scriptFrames
		};
	}

	/**
	 * 绑定名的 ABC 类 frameN 方法帧位（1 基）。镜像
	 * FrameScriptParser.AVM2.findClassByName：拆最后一段为类名、其余为包名，
	 * 对 classes 顺序找首个匹配；找不到返回 null（= 运行侧无帧脚本）。
	 */
	private static function abcScriptFrames(abc:ABCData, className:String):Null<Array<Int>> {
		if (abc == null) return null;
		var x = className.lastIndexOf(".");
		var pkgName = x == -1 ? "" : className.substr(0, x);
		var clsName = x == -1 ? className : className.substr(x + 1);
		for (cls in abc.classes) {
			if (cls.isInterface) continue;
			var n = resolveName(abc, cls.name);
			if (n != null && n.name == clsName && n.nsName == pkgName) {
				var frames:Array<Int> = [];
				for (field in cls.fields) {
					switch (field.kind) {
						case FMethod(_, _, _, _):
							var m = resolveName(abc, field.name);
							if (m != null && FRAME_SCRIPT_METHOD_NAME.match(m.name)) {
								frames.push(Std.parseInt(FRAME_SCRIPT_METHOD_NAME.matched(1)));
							}
						default:
					}
				}
				return frames;
			}
		}
		return null;
	}

	/**
	 * NName 解析成 {name, nsName}。包名段仅 NPublic/NInternal/NPrivate/
	 * NProtected 出值（镜像 AVM2.resolveMultiNameByIndex 的 default 分支——
	 * 其余 namespace 该处返回 null、findClassByName 不会匹配）。
	 */
	private static function resolveName(abc:ABCData, idx:IName):{name:String, nsName:String} {
		switch (abc.get(abc.names, idx)) {
			case NName(nameIndex, nsIndex):
				var name = abc.get(abc.strings, nameIndex);
				var nsName = null;
				switch (abc.get(abc.namespaces, nsIndex)) {
					case NPublic(i) | NInternal(i) | NPrivate(i) | NProtected(i):
						nsName = abc.get(abc.strings, i);
					default:
				}
				if (nsName == null) return null;
				return {name: name, nsName: nsName};
			default:
				return null;
		}
	}

	// ---- 走查的底层字节读取（小端） ----

	private static inline function readU16(b:Bytes, p:Int):Int {
		return b.get(p) | (b.get(p + 1) << 8);
	}

	private static inline function readU32(b:Bytes, p:Int):Int {
		return b.get(p) | (b.get(p + 1) << 8) | (b.get(p + 2) << 16) | (b.get(p + 3) << 24);
	}

	private static function readVarU32(b:Bytes, p:Int):{v:Int, next:Int} {
		var v = 0;
		var shift = 0;
		var q = p;
		while (q < b.length) {
			var byte = b.get(q++);
			v += (byte & 0x7F) << shift;
			if ((byte & 0x80) == 0) return {v: v, next: q};
			shift += 7;
			if (shift > 35) return {v: v, next: q}; // 烂数据防御
		}
		return {v: v, next: q};
	}

	private static function cstringLen(b:Bytes, p:Int):Int {
		var q = p;
		while (q < b.length && b.get(q) != 0) q++;
		return q - p;
	}

	private static function readCString(b:Bytes, p:Int):String {
		return b.getString(p, cstringLen(b, p));
	}
}

// ---- 中间数据（两条读法共用；Haxe 4 类体内不放 typedef，置模块级） ----

typedef RawClip = {
	id:Null<Int>,
	symbol:Null<String>,
	isMain:Bool,
	frames:Int,
	labels:Array<LabelEntry>,
	scriptFrames:Array<Int>,
};

typedef RawSwf = {
	main:RawClip,
	sprites:Array<RawClip>,
	/** SymbolClass(76) cid→name（cid 0 = 主时间轴文档类绑定） */
	bindings:Map<Int, String>,
	/** 最后一枚根级 DoABC(82) 的 ABC 体（镜像 processAS3Tag 覆盖语义） */
	lastRootAbc:Null<Bytes>,
};
