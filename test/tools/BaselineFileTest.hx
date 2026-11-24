package tools;

import tools.RenderTypes.BaselineDoc;
import tools.RenderTypes.BaselineEntry;
import utest.Assert;

/**
 * T2 基线文件纯逻辑：拍点键格式、JSON 形状、确定性序列化与换源口
 * （issue #57，write-tests 阶段对 stub 失败）。被测 tools.BaselineFile 只做
 * 数据进出，不碰文件（读写在 implement 阶段的 CLI 里）。stub 在
 * tools/tools/BaselineFile.hx（「stub 归树」规矩，implement 原地填充）。
 *
 * 期望值出处：
 * - 基线的角色（「首跑……哈希/基线文件入库或 CI cache」「生成/重建命令 +
 *   基线文件路径约定」）：// issue #57。文件大小/是否入库的方案在 PR 说明
 *   里给（issue 边界），形状契约归这里钉。
 * - 拍点键三段（asset|symbol|shotId）：// issue #57。段取值沿既有先例：
 *   asset 为 assets/legacy-assets.txt 清单原样路径；symbol 为 T3 比对键
 *   （tools/TimelineTypes.ClipSpec 类头：""=主轴/SymbolClass 导出名/
 *   "#<charId>"=无导出名——dump_swf.php 实测数据的键推导见
 *   test/tools/TimelineSpecTest.hx）；shotId 为 RenderPlan 拍点 id
 *   （"f<帧号>"/"s<步号>"）。
 * - source 字段与换源口（「保真对拍模式留接口：基线来源换成
 *   legacy/references/ 同管道直接换源」）：// issue #57——source 只记来源
 *   供人读，比对不按它分支（分支与否的行为面在 RenderDiffTest 钉）。
 * - 序列化确定性（键升序、紧凑、entry 字段序 hash/width/height）：// #57
 *   （重建产物逐字节稳定——二次生成不产生假 diff，基线文件才敢入库）。
 * - 缺省与报错（缺 source 视为 "self"、JSON 坏必须炸）：// issue #57
 *   （自回归起步首跑；基线文件损坏静默当空基线会全量假红/假绿）。
 * - JSON 里的 asset/symbol 取实测路径与符号名（出处同 TimelineSpecTest
 *   类头 dump 实测）：water_v_5 的 WaterLand3、FDog100 的 #90、farmui_full
 *   的 farmui_full_1_fla.lock_mc_46。
 */
class BaselineFileTest {
	static final WATER:String = "source/core/module/ui/water_v_5.swf";
	static final FDOG:String = "source/core/module/ui/dogs/FDog100_v_1.swf";
	static final FARMUI_FULL:String = "source/core/module/mc/main/farmui_full_v_40.swf";

	public function new() {}

	// ---- shotKey：三段拼接 ----

	function test_shotKey_format() {
		var rows:Array<{src:String, asset:String, symbol:String, shotId:String, expected:String}> = [
			{
				// 常规：实测资产路径 + SymbolClass 导出名 + 静态拍点
				src: "导出名符号 + 静态拍点",
				asset: WATER, symbol: "WaterLand3", shotId: "f1",
				expected: "source/core/module/ui/water_v_5.swf|WaterLand3|f1"
			},
			{
				// 主轴空串键（StepAnimate「空串=根」/T3 ClipSpec 键先例）
				src: "主轴空串键 + 播放拍点",
				asset: WATER, symbol: "", shotId: "s4",
				expected: "source/core/module/ui/water_v_5.swf||s4"
			},
			{
				// 无导出名符号（FDog100 char#90，dump 实测）
				src: "#<charId> 键",
				asset: FDOG, symbol: "#90", shotId: "f1",
				expected: "source/core/module/ui/dogs/FDog100_v_1.swf|#90|f1"
			},
			{
				// 带点的嵌套符号名（farmui_full 实测导出名）
				src: "带点符号名",
				asset: FARMUI_FULL, symbol: "farmui_full_1_fla.lock_mc_46", shotId: "s2",
				expected: "source/core/module/mc/main/farmui_full_v_40.swf|farmui_full_1_fla.lock_mc_46|s2"
			}
		];
		for (r in rows) {
			Assert.equals(r.expected, BaselineFile.shotKey(r.asset, r.symbol, r.shotId), r.src);
		}
	}

	// ---- parse：完整形状与缺省 ----

	function test_parse_full_doc() {
		var json = '{"source":"references","entries":{'
			+ '"' + WATER + '|WaterLand3|f1":{"hash":"h1","width":2,"height":2},'
			+ '"' + WATER + '|WaterLand3|s13":{"hash":"h2","width":2,"height":2}}}';
		var doc = BaselineFile.parse(json);
		Assert.equals("references", doc.source);
		Assert.equals(2, keyCount(doc));
		var e:BaselineEntry = doc.entries.get(WATER + "|WaterLand3|f1");
		Assert.equals("h1", e.hash);
		Assert.equals(2, e.width);
		Assert.equals(2, e.height);
		Assert.equals("h2", doc.entries.get(WATER + "|WaterLand3|s13").hash);
	}

	function test_parse_defaults() {
		// 空对象：自回归起步（首跑还没基线）——source 缺省 "self"、entries 空
		var empty = BaselineFile.parse("{}");
		Assert.equals("self", empty.source);
		Assert.equals(0, keyCount(empty));
		// 只给 entries（source 缺省）——重建半份基线时的形态
		var noSource = BaselineFile.parse('{"entries":{"k|k|f1":{"hash":"h","width":1,"height":1}}}');
		Assert.equals("self", noSource.source);
		Assert.equals(1, keyCount(noSource));
		Assert.equals("h", noSource.entries.get("k|k|f1").hash);
	}

	// ---- stringify：确定性规范形 ----

	function test_stringify_canonical_sorted() {
		// 插入序倒着给（c 在前 a 在后）：输出键升序、紧凑、entry 字段序
		// hash/width/height——重建产物逐字节稳定
		var doc:BaselineDoc = {source: "self", entries: new Map()};
		doc.entries.set(WATER + "|WaterLand3|s13", {hash: "h2", width: 2, height: 2});
		doc.entries.set(WATER + "|WaterLand3|f1", {hash: "h1", width: 2, height: 2});
		Assert.equals(
			'{"source":"self","entries":{'
			+ '"' + WATER + '|WaterLand3|f1":{"hash":"h1","width":2,"height":2},'
			+ '"' + WATER + '|WaterLand3|s13":{"hash":"h2","width":2,"height":2}}}',
			BaselineFile.stringify(doc)
		);
		// 空文档与 references 来源的规范形（换源口：同形状不同值）
		Assert.equals('{"source":"self","entries":{}}', BaselineFile.stringify({source: "self", entries: new Map()}));
		Assert.equals('{"source":"references","entries":{}}', BaselineFile.stringify({source: "references", entries: new Map()}));
	}

	function test_roundtrip() {
		var doc:BaselineDoc = {source: "references", entries: new Map()};
		doc.entries.set(WATER + "|WaterLand3|f1", {hash: "h1", width: 2, height: 2});
		doc.entries.set(FDOG + "|#90|f1", {hash: "h3", width: 640, height: 480});
		var back = BaselineFile.parse(BaselineFile.stringify(doc));
		Assert.equals(doc.source, back.source);
		Assert.equals(keyCount(doc), keyCount(back));
		for (k in doc.entries.keys()) {
			var a:BaselineEntry = doc.entries.get(k);
			var b:BaselineEntry = back.entries.get(k);
			Assert.equals(a.hash, b.hash, k);
			Assert.equals(a.width, b.width, k);
			Assert.equals(a.height, b.height, k);
		}
	}

	// ---- 报错：基线文件损坏必须炸 ----

	function test_parse_malformed_throws() {
		var msg:String = null;
		try {
			BaselineFile.parse("不是 JSON");
		} catch (e:haxe.Exception) {
			msg = e.message;
		}
		Assert.isTrue(msg != null && StringTools.contains(msg, "JSON"), "语法坏基线：须抛消息含 JSON 的 haxe.Exception（不许静默当空基线）");
	}

	// ---- 测试自用 ----

	static function keyCount(doc:BaselineDoc):Int {
		return [for (k in doc.entries.keys()) k].length;
	}
}
