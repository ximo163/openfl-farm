package tools;

import haxe.Json;
import tools.RenderTypes.BaselineDoc;
import tools.RenderTypes.BaselineEntry;

/**
 * T2 资产渲染对拍——基线文件与拍点键（issue #57）。基线文件的 JSON 形状、
 * 拍点键格式与确定性序列化（生成/重建命令的产物；入库或 CI cache 的方案在
 * PR 说明里定，文件形状归这里钉）。
 *
 * 契约（// issue #57）：
 * - 拍点键 = asset + "|" + symbol + "|" + shotId（三段竖线拼接；asset 为
 *   assets/legacy-assets.txt 的清单原样路径、symbol 沿 T3 键（""=主轴/
 *   SymbolClass 导出名/"#<charId>"）、shotId 为 RenderPlan 的拍点 id
 *   （"f<帧号>"/"s<步号>"）。报告定位「哪个符号哪一帧」全靠它。
 * - JSON：{ "source": "self"|"references", "entries": { 键: {hash,width,
 *   height} } }。source 是换源口——只记基线图像来源（self=首跑 openfl
 *   截图；references=legacy/references 真 Flash 采集就位后同管道换源重建），
 *   比对逻辑不按它分支。
 * - parse 缺省：缺 source 视为 "self"（自回归起步）；缺 entries 视为空。
 *   JSON 语法坏抛 haxe.Exception 且消息含 "JSON"（基线文件损坏必须炸，
 *   不许静默当空基线比对）。
 * - stringify 确定性：entries 按键升序、紧凑无空白、entry 内字段序
 *   hash/width/height——重建产物逐字节稳定（diff 友好、二次生成不产生
 *   假 diff）。
 */
class BaselineFile {
	/** 拍点键三段拼接（见类头；段内不再含 "|"）。 */
	static public function shotKey(asset:String, symbol:String, shotId:String):String {
		return asset + "|" + symbol + "|" + shotId;
	}

	/** 基线文件 JSON → BaselineDoc（缺省/报错语义见类头）。 */
	static public function parse(json:String):BaselineDoc {
		var parsed:Dynamic = null;
		try {
			parsed = Json.parse(json);
		} catch (e:Dynamic) {
			// 语法坏必须炸：静默当空基线比对会全量假红/假绿
			throw new haxe.Exception("基线文件 JSON 损坏: " + Std.string(e));
		}
		if (parsed == null || !Reflect.isObject(parsed) || Std.isOfType(parsed, Array)) {
			throw new haxe.Exception("基线文件 JSON 形状不对：顶层须是对象 {source,entries}");
		}
		var source:String = Reflect.field(parsed, "source");
		if (source == null) source = "self"; // 缺省：自回归起步（首跑还没基线）
		var entries = new Map<String, BaselineEntry>();
		var rawEntries:Dynamic = Reflect.field(parsed, "entries");
		if (rawEntries != null) {
			if (!Reflect.isObject(rawEntries) || Std.isOfType(rawEntries, Array)) {
				throw new haxe.Exception("基线文件 JSON 形状不对：entries 须是对象");
			}
			for (key in Reflect.fields(rawEntries)) {
				var raw:Dynamic = Reflect.field(rawEntries, key);
				if (raw == null || !Reflect.isObject(raw)) {
					throw new haxe.Exception('基线文件 JSON 形状不对：条目 ${key} 须是对象');
				}
				var hash:Dynamic = Reflect.field(raw, "hash");
				var width:Dynamic = Reflect.field(raw, "width");
				var height:Dynamic = Reflect.field(raw, "height");
				if (hash == null || width == null || height == null) {
					throw new haxe.Exception('基线文件 JSON 形状不对：条目 ${key} 缺 hash/width/height');
				}
				entries.set(key, {hash: Std.string(hash), width: width, height: height});
			}
		}
		return {source: source, entries: entries};
	}

	/** BaselineDoc → 确定性紧凑 JSON（键升序，见类头；round-trip：
	 * parse(stringify(d)) 与 d 同内容）。 */
	static public function stringify(doc:BaselineDoc):String {
		var keys = [for (key in doc.entries.keys()) key];
		// 键升序：重建产物逐字节稳定，git diff 里只出真变化（ASCII 键，跨目标
		// 排序一致）
		keys.sort(Reflect.compare);
		var parts = [];
		for (key in keys) {
			var entry = doc.entries.get(key);
			// entry 字段序 hash/width/height 钉死；字符串经 Json.stringify 转义
			parts.push(Json.stringify(key) + ':{' + '"hash":' + Json.stringify(entry.hash) + ',"width":' + entry.width
				+ ',"height":' + entry.height + '}');
		}
		return '{"source":' + Json.stringify(doc.source) + ',"entries":{' + parts.join(",") + '}}';
	}
}
