package tools;

import tools.RenderTypes.BaselineDoc;
import tools.RenderTypes.BaselineEntry;
import tools.RenderTypes.CurrentShot;
import tools.RenderTypes.ShotImage;
import tools.RenderTypes.ShotOutcome;
import utest.Assert;

/**
 * T2 自回归基线比对纯逻辑：逐拍点哈希比对、missing/extra 对齐红与聚合
 * 报告（issue #57，write-tests 阶段对 stub 失败）。被测 tools.RenderDiff
 * 只做数据进出，不碰文件/显示对象。stub 在 tools/tools/RenderDiff.hx
 * （「stub 归树」规矩，implement 原地填充）。
 *
 * 期望值出处：
 * - 自回归立场（「不证明和原版一致，只证明没变」——首跑建基线、后续跑
 *   比对抓移植侧渲染回归）与「聚合报告（哪些符号哪些帧超容差）」：// #57
 *   （verification.md 截图部分的 issue 转述，docs 仓库容器外不可达同 #56）。
 * - 注入用例对应完成标准 2「人为改坏一处渲染（如改一个符号的缩放）能
 *   红」的纯逻辑面：改坏单拍点 → 恰该拍点红、其余不受牵连（端到端注入
 *   [--self-check] 走 implement 阶段的 CLI，按 issue）。
 * - 对齐项语义（基线缺 = missing 红 / 基线多余 = extra 红）与报告序键
 *   升序：// issue #57（T3 clipMissing/clipExtra 同思想——门禁须能暴露
 *   渲染面增删，报告序确定才可比对两次跑）。
 * - 换源口（source 不进比对分支）：// issue #57「保真对拍模式留接口：
 *   基线来源换成 legacy/references/，同管道直接换源」——保真对拍换源后
 *   比对逻辑零改动，行为面就是本文件 test_source_field_does_not_branch。
 * - 基线 fixture 的哈希走测试侧独立推导（钉死的布局规范文本 +
 *   haxe.crypto.Md5——与被测实现无共享代码；实现正确性另由
 *   RenderHashTest 的 python 交叉核对已知值钉死）。asset/symbol 键取
 *   实测数据（water_v_5 WaterLand3=char#27 26 帧，dump 实测详单见
 *   TimelineSpecTest 类头）。像素为合成小图：被测的是比对语义。
 */
class RenderDiffTest {
	static final WATER:String = "source/core/module/ui/water_v_5.swf";
	static final KEY_F1:String = WATER + "|WaterLand3|f1";
	static final KEY_S13:String = WATER + "|WaterLand3|s13";
	static final KEY_S26:String = WATER + "|WaterLand3|s26";

	public function new() {}

	// ---- 忠实记录全绿（防门禁无差别红） ----

	function test_faithful_shots_pass_sorted() {
		// 输入序乱给（探针产出序不定）：报告序必须键升序确定
		var r = RenderDiff.compareShots(
			[{key: KEY_S26, image: water2x2()}, {key: KEY_F1, image: red1x1()}],
			baseline([KEY_F1 => redEntry(), KEY_S26 => waterEntry()])
		);
		Assert.isTrue(r.pass);
		Assert.equals(0, r.failed);
		Assert.equals(0, r.missing);
		Assert.equals(0, r.extra);
		Assert.equals(2, r.shots.length);
		Assert.equals(KEY_F1, r.shots[0].key);
		Assert.equals(KEY_S26, r.shots[1].key);
		for (o in r.shots) {
			Assert.isTrue(o.pass, o.key);
			Assert.isFalse(o.missing, o.key);
			Assert.isFalse(o.extra, o.key);
			Assert.equals(o.baselineHash, o.currentHash, o.key);
		}
	}

	// ---- 完成标准 2（纯逻辑面）：改坏一处恰红一处 ----

	function test_injected_pixel_change_reds_only_that_shot() {
		// 只改坏一处：s26 拍点的 alpha 差 1（其余拍点忠实）——恰该拍点红，
		// f1 不受牵连（对应「改一个符号的缩放/渲染」在哈希路径的暴露形态）
		var bumped:ShotImage = {width: 1, height: 1, pixels: [254, 0, 0, 255]};
		var r = RenderDiff.compareShots(
			[{key: KEY_F1, image: red1x1()}, {key: KEY_S26, image: bumped}],
			baseline([KEY_F1 => redEntry(), KEY_S26 => redEntry()])
		);
		Assert.isFalse(r.pass);
		Assert.equals(1, r.failed);
		Assert.equals(0, r.missing);
		Assert.equals(0, r.extra);
		var guilty:ShotOutcome = find(r, KEY_S26);
		Assert.isFalse(guilty.pass);
		Assert.isFalse(guilty.missing);
		Assert.isFalse(guilty.extra);
		Assert.equals(redEntry().hash, guilty.baselineHash);
		Assert.equals(hashOf(bumped), guilty.currentHash);
		Assert.isFalse(guilty.currentHash == guilty.baselineHash);
		Assert.isTrue(find(r, KEY_F1).pass, "未改坏的拍点不牵连");
	}

	function test_injected_size_change_reds() {
		// 尺寸变化（「改一个符号的缩放」的形态）：同字节像素横竖互换，
		// 哈希（宽高参与布局）与 entry 尺寸字段任一不符即红
		var r = RenderDiff.compareShots(
			[{key: KEY_F1, image: {width: 1, height: 2, pixels: red1x1().pixels}}],
			baseline([KEY_F1 => redEntry()])
		);
		Assert.isFalse(r.pass);
		Assert.equals(1, r.failed);
		Assert.isFalse(find(r, KEY_F1).pass);
	}

	// ---- 对齐项：基线缺 / 基线多余（渲染面增删） ----

	function test_missing_and_extra_red() {
		// 基线缺该拍点（新冒出的渲染面）：missing 红、缺侧哈希 ""
		var missing = RenderDiff.compareShots(
			[{key: KEY_F1, image: red1x1()}, {key: KEY_S26, image: water2x2()}],
			baseline([KEY_F1 => redEntry()])
		);
		Assert.isFalse(missing.pass);
		Assert.equals(0, missing.failed);
		Assert.equals(1, missing.missing);
		Assert.equals(0, missing.extra);
		var mo:ShotOutcome = find(missing, KEY_S26);
		Assert.isFalse(mo.pass);
		Assert.isTrue(mo.missing);
		Assert.isFalse(mo.extra);
		Assert.equals("", mo.baselineHash);
		Assert.equals(hashOf(water2x2()), mo.currentHash);
		// 基线有而本次没拍到（渲染面消失/拍点漂移）：extra 红、缺侧哈希 ""
		var extra = RenderDiff.compareShots(
			[{key: KEY_F1, image: red1x1()}],
			baseline([KEY_F1 => redEntry(), KEY_S13 => waterEntry()])
		);
		Assert.isFalse(extra.pass);
		Assert.equals(0, extra.failed);
		Assert.equals(0, extra.missing);
		Assert.equals(1, extra.extra);
		var eo:ShotOutcome = find(extra, KEY_S13);
		Assert.isFalse(eo.pass);
		Assert.isTrue(eo.extra);
		Assert.isFalse(eo.missing);
		Assert.equals("", eo.currentHash);
		Assert.equals(waterEntry().hash, eo.baselineHash);
	}

	// ---- 换源口：source 只记来源，比对不按它分支 ----

	function test_source_field_does_not_branch() {
		// 同批实拍（含一处不符）对 self / references 两份同条目基线：
		// 结果逐字段一致——保真对拍换源重建基线后走同一条比对
		var shots:Array<CurrentShot> = [
			{key: KEY_F1, image: red1x1()},
			{key: KEY_S26, image: red1x1()} // 与 waterEntry 不符 → 红
		];
		var selfR = RenderDiff.compareShots(shots, baseline2("self", [KEY_F1 => redEntry(), KEY_S26 => waterEntry()]));
		var refR = RenderDiff.compareShots(shots, baseline2("references", [KEY_F1 => redEntry(), KEY_S26 => waterEntry()]));
		Assert.equals(selfR.pass, refR.pass);
		Assert.equals(selfR.failed, refR.failed);
		Assert.equals(selfR.missing, refR.missing);
		Assert.equals(selfR.extra, refR.extra);
		Assert.equals(selfR.shots.length, refR.shots.length);
		for (i in 0...selfR.shots.length) {
			Assert.equals(selfR.shots[i].key, refR.shots[i].key);
			Assert.equals(selfR.shots[i].pass, refR.shots[i].pass);
			Assert.equals(selfR.shots[i].missing, refR.shots[i].missing);
			Assert.equals(selfR.shots[i].extra, refR.shots[i].extra);
			Assert.equals(selfR.shots[i].baselineHash, refR.shots[i].baselineHash);
			Assert.equals(selfR.shots[i].currentHash, refR.shots[i].currentHash);
		}
		Assert.isFalse(selfR.pass, "用例前提：本批实拍确有一处不符");
	}

	// ---- render：定位到拍点键（哪个符号哪一帧） ----

	function test_render_locates_keys_and_reasons() {
		// 一红三形齐全：f1 哈希不符、s26 缺基线、s13 基线多余
		var r = RenderDiff.compareShots(
			[{key: KEY_F1, image: water2x2()}, {key: KEY_S26, image: water2x2()}],
			baseline([KEY_F1 => redEntry(), KEY_S13 => waterEntry()])
		);
		Assert.isFalse(r.pass);
		Assert.equals(1, r.failed);
		Assert.equals(1, r.missing);
		Assert.equals(1, r.extra);
		var text = RenderDiff.render(r);
		// issue #57「对不上时指明哪个符号哪一帧超容差」：完整拍点键 + 原因词
		Assert.isTrue(StringTools.contains(text, KEY_F1), "哈希不符行含拍点键");
		Assert.isTrue(StringTools.contains(text, KEY_S26), "缺基线行含拍点键");
		Assert.isTrue(StringTools.contains(text, KEY_S13), "基线多余行含拍点键");
		Assert.isTrue(StringTools.contains(text, "哈希"), "不符原因词：哈希");
		Assert.isTrue(StringTools.contains(text, "缺基线"), "missing 原因词");
		Assert.isTrue(StringTools.contains(text, "基线多余"), "extra 原因词");
	}

	// ---- 测试自用 ----

	/** 测试侧独立哈希（钉死的布局规范文本 + haxe.crypto.Md5；与被测
	 * RenderHash 无共享代码——类头出处说明）。 */
	static function hashOf(image:ShotImage):String {
		return haxe.crypto.Md5.encode(image.width + "x" + image.height + ":" + image.pixels.join(","));
	}

	static function water2x2():ShotImage {
		return {width: 2, height: 2, pixels: [10, 20, 30, 255, 40, 50, 60, 255, 70, 80, 90, 255, 100, 110, 120, 255]};
	}

	static function red1x1():ShotImage {
		return {width: 1, height: 1, pixels: [255, 0, 0, 255]};
	}

	static function waterEntry():BaselineEntry {
		return {hash: hashOf(water2x2()), width: 2, height: 2};
	}

	static function redEntry():BaselineEntry {
		return {hash: hashOf(red1x1()), width: 1, height: 1};
	}

	static function baseline(entries:Map<String, BaselineEntry>):BaselineDoc {
		return {source: "self", entries: entries};
	}

	static function baseline2(source:String, entries:Map<String, BaselineEntry>):BaselineDoc {
		return {source: source, entries: entries};
	}

	static function find(r:tools.RenderTypes.RenderReport, key:String):ShotOutcome {
		return [for (o in r.shots) if (o.key == key) o][0];
	}
}
