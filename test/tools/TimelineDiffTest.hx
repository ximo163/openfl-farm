package tools;

import sys.io.File;
import tools.TimelineTypes.AssetSpec;
import utest.Assert;

/**
 * T3 比对器纯逻辑：期望序列（tools.TimelineSpec 从 swf 结构派生）vs 实跑
 * 探针记录 JSON 的逐项 diff 与报告（issue #56，write-tests 阶段对 stub
 * 失败）。被测 tools.TimelineDiff 只做数据进出，不碰显示对象/文件/真实时间。
 *
 * 期望值出处：
 * - 判定语义（序列项四件逐项独立判红、报告指明「哪个符号哪一步哪一项
 *   跑偏」、序列先于截图）：verification.md「动画与特效怎么验」第 1 节，
 *   引文以 issue #56 转述为准（docs 仓库容器外不可达，// issue #56）。
 * - 故障注入四形（抓不动/跳帧/倒放/提前 stop）：verification.md 序列项一
 *   括注（issue #56 转述）；完成标准 2 的「注入式自检：人为改坏一处（例如
 *   推进时跳一帧）能红」即 test_injected_skip_frame_reds_at_that_step。
 * - 帧事件盲区（scriptFrames 非空 → 降级标注不判红、实测照录、非假绿）：
 *   issue #56「已知盲区要写清」；swf 侧事实——FrameScriptParser.convertToJS
 *   只对有类绑定的符号做 AVM2 frameN→JS（haxelib swf 3.4.0）、
 *   AnimateTimeline.hx:102-130 非 js 目标丢弃 scriptSource；脚本帧分布
 *   （dump_swf.php 69 资产实测）：sprite 层全清单无帧脚本，主轴帧脚本有则
 *   恒在帧 1（62 资产单个、lite_ui_v_0 十个、farmui_full_v_40 二百零七个
 *   （207，根标签普查 DoABC2×207）都在帧 1；farm/diy/1-4 与 diy/board/1 五件
 *   无脚本）——fish_01/FS_* 与
 *   water_v_5/WaterLand3 的 scriptFrames 为空（可严格判红），FDog100 主轴
 *   scriptFrames=[1]（盲区）。
 * - 帧标签：12/69 资产含 FrameLabel(43)、3 个含多帧带标签 sprite
 *   （farmui_full_v_40/farmui1_v_42/lite_ui_v_0 的 SellLockIcon/GiftIcon/
 *   FarmLoading 等）——详单见 TimelineSpecTest 类头「帧标签」条（dump_swf.php
 *   实测）。前一轮曾误断「全清单无帧标签」并被驳回，凭空标签判红的用例
 *   只对实测无标签的剪辑（water_v_5/WaterLand3）做。
 * - swf 结构数值（帧数/键）：见 TimelineSpecTest 类头（dump_swf.php 容器
 *   内实测 + spec/swf-inventory.json frames 字段）。
 * - 记录 JSON 键名与「labels/frameEvents 可缺省 = 空」：// issue #56
 *   （探针按此产出；fixture test/fixtures/timeline-fish01-probe.json 同构，
 *   其中的 frames 数组是手写字面量——不经过被测代码，保证忠实记录的定义
 *   独立于实现）。
 */
class TimelineDiffTest {
	static final STRUCTURE_FIXTURE:String = "test/fixtures/timeline-fish01-structure.json";
	static final PROBE_FIXTURE:String = "test/fixtures/timeline-fish01-probe.json";
	static final FISH_ASSET:String = "source/core/module/ui/farm/fish/fish_01.swf";

	public function new() {}

	// ---- 忠实记录全绿（防门禁无差别红） ----

	function test_faithful_probe_record_passes() {
		var expected = TimelineSpec.parseAssetStructure(File.getContent(STRUCTURE_FIXTURE));
		var report = TimelineDiff.compare(expected, File.getContent(PROBE_FIXTURE));
		// 8 个多帧剪辑（主轴单帧被滤）、stepsFor=8、全绿、无降级（sprite 层无脚本帧）
		Assert.isTrue(report.pass);
		Assert.equals(FISH_ASSET, report.asset);
		Assert.equals(8, report.steps);
		Assert.equals(0, report.downgraded);
		Assert.equals(0, report.mismatches.length);
		Assert.equals(8, report.clips.length);
		for (c in report.clips) {
			Assert.isTrue(c.pass, c.key);
			Assert.isFalse(c.downgraded, c.key);
		}
	}

	// ---- 完成标准 2：注入式自检（推进时跳一帧）能红且定位准确 ----

	function test_injected_skip_frame_reds_at_that_step() {
		var expected = TimelineSpec.parseAssetStructure(File.getContent(STRUCTURE_FIXTURE));
		// 只改坏一处：FS_01_2_2 第 4 步从 5 跳到 6（跳帧），其余 7 个剪辑忠实
		var bad = faithful(8, 8);
		bad[3] = 6;
		var json = record(FISH_ASSET, 8, [
			clipRec("FJ_01_2_2", faithful(6, 8), 1, 3),
			clipRec("FJ_01_2_0", faithful(6, 8), 1, 3),
			clipRec("FS_01_0_2", faithful(8, 8), 1, 1),
			clipRec("FS_01_1_2", faithful(8, 8), 1, 1),
			clipRec("FS_01_2_2", bad, 1, 1),
			clipRec("FS_01_0_0", faithful(8, 8), 1, 1),
			clipRec("FS_01_1_0", faithful(8, 8), 1, 1),
			clipRec("FS_01_2_0", faithful(8, 8), 1, 1)
		]);
		var report = TimelineDiff.compare(expected, json);
		Assert.isFalse(report.pass);
		var guilty = [for (c in report.clips) if (c.key == "FS_01_2_2") c][0];
		// 恰一项跑偏：currentFrame @ 第 4 步（期望 5 实测 6），其余项不受牵连
		Assert.isFalse(guilty.pass);
		Assert.equals(1, guilty.mismatches.length);
		Assert.equals("currentFrame", guilty.mismatches[0].item);
		Assert.equals(4, guilty.mismatches[0].step);
		for (c in report.clips) {
			if (c.key != "FS_01_2_2") Assert.isTrue(c.pass, c.key);
		}
	}

	// ---- 序列项一 currentFrame：四形故障逐个红、首偏差步号准确 ----

	function test_currentFrame_fault_table() {
		// water_v_5 WaterLand3 26 帧、K=26（dump 实测；期望序列 2..26,1）
		var rows:Array<{src:String, frames:Array<Int>, firstStep:Int}> = [
			{
				// verification.md 序列项一「抓不动」：第 1 步后播放头不再前进
				src: "抓不动：恒 2",
				frames: [for (_ in 0...26) 2],
				firstStep: 2
			},
			{
				// 「跳帧」：每步双倍推进，第 1 步就到 3
				src: "跳帧：双倍推进",
				frames: [for (s in 1...27) ((s * 2) % 26) + 1],
				firstStep: 1
			},
			{
				// 「倒放」：2,1,26,25,…（第 2 步退回 1）
				src: "倒放",
				frames: [2, 1].concat([for (i in 0...24) 26 - i]),
				firstStep: 2
			},
			{
				// 「提前 stop」：走 5 步冻在 6（第 6 步期望 7）
				src: "提前 stop",
				frames: [2, 3, 4, 5, 6].concat([for (_ in 0...21) 6]),
				firstStep: 6
			}
		];
		for (r in rows) {
			var report = TimelineDiff.compare(waterSpec(), record("source/core/module/ui/water_v_5.swf", 26, [clipRec("WaterLand3", r.frames, 1, 1)]));
			Assert.isFalse(report.pass, r.src);
			Assert.equals(1, report.clips.length, r.src);
			Assert.isFalse(report.clips[0].pass, r.src);
			Assert.equals(1, report.clips[0].mismatches.length, r.src);
			Assert.equals("currentFrame", report.clips[0].mismatches[0].item, r.src);
			Assert.equals(r.firstStep, report.clips[0].mismatches[0].step, r.src);
		}
	}

	// ---- 序列项二 labelHits ----

	function test_labelHits_mismatch_reds() {
		// 真实带标签剪辑（farmui1_v_42 SellLockIcon=char#60，dump_swf.php 实测：
		// 2 帧、f1"lock"/f2"unlock"；结构详单见 TimelineSpecTest 类头）。单剪辑
		// 资产 stepsFor=2，期望命中：步 1"unlock"、步 2"lock"
		var labeled:AssetSpec = {
			asset: "source/core/module/mc/main/farmui1_v_42.swf",
			clips: [{key: "SellLockIcon", isMain: false, frames: 2, labels: [{frame: 1, name: "lock"}, {frame: 2, name: "unlock"}], scriptFrames: []}]
		};
		// 忠实（含真实标签命中序列，帧序 2,1 即 (s%2)+1）：全绿
		var ok = TimelineDiff.compare(labeled, record("source/core/module/mc/main/farmui1_v_42.swf", 2, [
			clipRec("SellLockIcon", [2, 1], 1, 1, '[{"step":1,"name":"unlock"},{"step":2,"name":"lock"}]')
		]));
		Assert.isTrue(ok.pass);
		// 漏命中：期望首个命中在第 1 步
		var missed = TimelineDiff.compare(labeled, record("source/core/module/mc/main/farmui1_v_42.swf", 2, [
			clipRec("SellLockIcon", [2, 1], 1, 1)
		]));
		Assert.isFalse(missed.pass);
		Assert.equals("labelHits", missed.clips[0].mismatches[0].item);
		Assert.equals(1, missed.clips[0].mismatches[0].step);
		// 多出命中：第 2 步的 "lock" 后面又冒出 "zz"
		var spurious = TimelineDiff.compare(labeled, record("source/core/module/mc/main/farmui1_v_42.swf", 2, [
			clipRec("SellLockIcon", [2, 1], 1, 1, '[{"step":1,"name":"unlock"},{"step":2,"name":"lock"},{"step":2,"name":"zz"}]')
		]));
		Assert.isFalse(spurious.pass);
		Assert.equals("labelHits", spurious.clips[0].mismatches[0].item);
		Assert.equals(2, spurious.clips[0].mismatches[0].step);
		// 实测无标签的剪辑（water_v_5 WaterLand3，dump 实测无 FrameLabel 行）：
		// 探针凭空记标签 = 红（清单 12/69 资产有标签，此处用例挑的是真没有的）
		var invented = TimelineDiff.compare(waterSpec(), record("source/core/module/ui/water_v_5.swf", 26, [
			clipRec("WaterLand3", faithful(26, 26), 1, 1, '[{"step":4,"name":"surprise"}]')
		]));
		Assert.isFalse(invented.pass);
		Assert.equals("labelHits", invented.clips[0].mismatches[0].item);
		Assert.equals(4, invented.clips[0].mismatches[0].step);
	}

	// ---- 序列项三 loops / endFrame：独立判红 ----

	function test_loops_and_endFrame_red_independently() {
		var ok = TimelineDiff.compare(waterSpec(), record("source/core/module/ui/water_v_5.swf", 26, [clipRec("WaterLand3", faithful(26, 26), 1, 1)]));
		Assert.isTrue(ok.pass);
		// 少记一圈：只有 loops 项红
		var wrongLoops = TimelineDiff.compare(waterSpec(), record("source/core/module/ui/water_v_5.swf", 26, [clipRec("WaterLand3", faithful(26, 26), 0, 1)]));
		Assert.isFalse(wrongLoops.pass);
		Assert.equals(1, wrongLoops.clips[0].mismatches.length);
		Assert.equals("loops", wrongLoops.clips[0].mismatches[0].item);
		Assert.equals(0, wrongLoops.clips[0].mismatches[0].step);
		// 终点跑偏：只有 endFrame 项红
		var wrongEnd = TimelineDiff.compare(waterSpec(), record("source/core/module/ui/water_v_5.swf", 26, [clipRec("WaterLand3", faithful(26, 26), 1, 5)]));
		Assert.isFalse(wrongEnd.pass);
		Assert.equals(1, wrongEnd.clips[0].mismatches.length);
		Assert.equals("endFrame", wrongEnd.clips[0].mismatches[0].item);
	}

	// ---- 序列项四 frameEvents：盲区降级（不判红、非假绿），无脚本凭空触发判红 ----

	function test_frameEvents_blind_spot_downgrades_not_fakes_green() {
		// FDog100 主轴 scriptFrames=[1]（根脚本帧 1，dump 实测）→ 帧事件项盲区；
		// 实测照录 + 降级标注，pass 不翻红（「降级标注而不是假绿」＝报告可见）
		var report = TimelineDiff.compare(fdogSpec(), record("source/core/module/ui/dogs/FDog100_v_1.swf", 695, [
			clipRec("", faithful(695, 695), 1, 1, null, '[{"step":1,"frame":1}]'),
			clipRec("#90", faithful(23, 695), 30, 6),
			clipRec("FDog100", faithful(151, 695), 4, 92)
		]));
		Assert.isTrue(report.pass);
		Assert.equals(1, report.downgraded);
		var main = [for (c in report.clips) if (c.key == "") c][0];
		Assert.isTrue(main.downgraded);
		Assert.isTrue(main.pass);
		// openfl 侧行为照录（issue #56「只能记 openfl 侧行为」）
		Assert.equals(1, main.frameEvents.length);
		Assert.equals(1, main.frameEvents[0].step);
		// 无脚本的剪辑不降级
		for (c in report.clips) {
			if (c.key != "") Assert.isFalse(c.downgraded, c.key);
		}
		// 报告里可见降级标注（非假绿）
		Assert.isTrue(StringTools.contains(TimelineDiff.render(report), "降级"));
	}

	function test_blind_spot_does_not_shield_other_faults() {
		// 降级不是免死金牌：主轴盲区 + #90 少一圈 → 照样红，且两项各归各
		var report = TimelineDiff.compare(fdogSpec(), record("source/core/module/ui/dogs/FDog100_v_1.swf", 695, [
			clipRec("", faithful(695, 695), 1, 1, null, '[{"step":1,"frame":1}]'),
			clipRec("#90", faithful(23, 695), 29, 6),
			clipRec("FDog100", faithful(151, 695), 4, 92)
		]));
		Assert.isFalse(report.pass);
		Assert.equals(1, report.downgraded);
		var dog90 = [for (c in report.clips) if (c.key == "#90") c][0];
		Assert.isFalse(dog90.pass);
		Assert.equals("loops", dog90.mismatches[0].item);
	}

	function test_frameEvents_spurious_reds_when_unscripted() {
		// fish_01 的 FS_* sprite 层无脚本帧（dump 实测）：期望帧事件为空，
		// 探针记出帧事件 = 红
		var spec:AssetSpec = {asset: FISH_ASSET, clips: [{key: "FS_01_0_2", isMain: false, frames: 8, labels: [], scriptFrames: []}]};
		var report = TimelineDiff.compare(spec, record(FISH_ASSET, 8, [
			clipRec("FS_01_0_2", faithful(8, 8), 1, 1, null, '[{"step":2,"frame":2}]')
		]));
		Assert.isFalse(report.pass);
		Assert.isFalse(report.clips[0].downgraded);
		Assert.equals(1, report.clips[0].mismatches.length);
		Assert.equals("frameEvents", report.clips[0].mismatches[0].item);
		Assert.equals(2, report.clips[0].mismatches[0].step);
	}

	// ---- 剪辑对齐与资产级项 ----

	function test_clip_presence_missing_and_extra_red() {
		// 期望有、记录无 → clipMissing
		var missing = TimelineDiff.compare(waterSpec(), record("source/core/module/ui/water_v_5.swf", 26, []));
		Assert.isFalse(missing.pass);
		var wl = [for (c in missing.clips) if (c.key == "WaterLand3") c][0];
		Assert.isFalse(wl.pass);
		Assert.equals("clipMissing", wl.mismatches[0].item);
		// 记录有、期望无 → clipExtra（单帧剪辑 StoneFrame1 被探针记录也算多报）
		var extra = TimelineDiff.compare(waterSpec(), record("source/core/module/ui/water_v_5.swf", 26, [
			clipRec("WaterLand3", faithful(26, 26), 1, 1),
			clipRec("StoneFrame1", [for (_ in 0...26) 1], 0, 1)
		]));
		Assert.isFalse(extra.pass);
		var stone = [for (c in extra.clips) if (c.key == "StoneFrame1") c][0];
		Assert.isFalse(stone.pass);
		Assert.equals("clipExtra", stone.mismatches[0].item);
	}

	function test_steps_count_mismatch_reds() {
		// 探针步数 != 期望侧派生步数（fish_01 stepsFor=8，记录只有 7）→ 资产级红
		var expected = TimelineSpec.parseAssetStructure(File.getContent(STRUCTURE_FIXTURE));
		var report = TimelineDiff.compare(expected, record(FISH_ASSET, 7, [
			clipRec("FJ_01_2_2", faithful(6, 7), 1, 2),
			clipRec("FJ_01_2_0", faithful(6, 7), 1, 2),
			clipRec("FS_01_0_2", faithful(8, 7), 0, 8),
			clipRec("FS_01_1_2", faithful(8, 7), 0, 8),
			clipRec("FS_01_2_2", faithful(8, 7), 0, 8),
			clipRec("FS_01_0_0", faithful(8, 7), 0, 8),
			clipRec("FS_01_1_0", faithful(8, 7), 0, 8),
			clipRec("FS_01_2_0", faithful(8, 7), 0, 8)
		]));
		Assert.isFalse(report.pass);
		Assert.equals(1, report.mismatches.length);
		Assert.equals("steps", report.mismatches[0].item);
		Assert.equals(0, report.mismatches[0].step);
	}

	function test_asset_without_multiframe_clips_is_vacuous_pass() {
		// 主轴单帧、无多帧 sprite（6290 资产的大多数形态，swf-inventory）：
		// 无比对单元，空记录空跑全绿
		var spec:AssetSpec = {asset: "source/core/module/ui/allcrops/Crop_2_1.swf", clips: [{key: "", isMain: true, frames: 1, labels: [], scriptFrames: [1]}]};
		var report = TimelineDiff.compare(spec, record("source/core/module/ui/allcrops/Crop_2_1.swf", 0, []));
		Assert.isTrue(report.pass);
		Assert.equals(0, report.clips.length);
		Assert.equals(0, report.downgraded);
	}

	// ---- render：定位到资产/符号/步/项 ----

	function test_render_names_asset_symbol_step_item() {
		var expected = TimelineSpec.parseAssetStructure(File.getContent(STRUCTURE_FIXTURE));
		var bad = faithful(8, 8);
		bad[3] = 6;
		var json = record(FISH_ASSET, 8, [
			clipRec("FJ_01_2_2", faithful(6, 8), 1, 3),
			clipRec("FJ_01_2_0", faithful(6, 8), 1, 3),
			clipRec("FS_01_0_2", faithful(8, 8), 1, 1),
			clipRec("FS_01_1_2", faithful(8, 8), 1, 1),
			clipRec("FS_01_2_2", bad, 1, 1),
			clipRec("FS_01_0_0", faithful(8, 8), 1, 1),
			clipRec("FS_01_1_0", faithful(8, 8), 1, 1),
			clipRec("FS_01_2_0", faithful(8, 8), 1, 1)
		]);
		var text = TimelineDiff.render(TimelineDiff.compare(expected, json));
		// issue #56「对不上时指明哪个符号哪一步哪一项跑偏」
		Assert.isTrue(StringTools.contains(text, "fish_01.swf"));
		Assert.isTrue(StringTools.contains(text, "FS_01_2_2"));
		Assert.isTrue(StringTools.contains(text, "第4步"));
		Assert.isTrue(StringTools.contains(text, "currentFrame"));
	}

	// ---- parseRecord：缺省补空 ----

	function test_parse_record_defaults() {
		var rec = TimelineDiff.parseRecord('{"asset":"a.swf","steps":3,"clips":[{"key":"k","frames":[2,3,4],"loops":1,"endFrame":4}]}');
		Assert.equals("a.swf", rec.asset);
		Assert.equals(3, rec.steps);
		Assert.equals(1, rec.clips.length);
		Assert.equals("k", rec.clips[0].key);
		Assert.same([2, 3, 4], rec.clips[0].frames);
		// labels/frameEvents 缺省 = []
		Assert.same([], rec.clips[0].labels);
		Assert.same([], rec.clips[0].frameEvents);
	}

	// ---- 测试自用：期望结构与记录 JSON 的构造（不经被测代码产生） ----

	/** water_v_5 实测结构：主轴 1 帧（根脚本帧 1）、WaterLand3=char#27 26 帧、
	 * StoneFrame1=char#30 单帧（多帧门滤掉，只当 clipExtra 用例的诱饵）。 */
	static function waterSpec():AssetSpec {
		return {
			asset: "source/core/module/ui/water_v_5.swf",
			clips: [
				{key: "", isMain: true, frames: 1, labels: [], scriptFrames: [1]},
				{key: "WaterLand3", isMain: false, frames: 26, labels: [], scriptFrames: []},
				{key: "StoneFrame1", isMain: false, frames: 1, labels: [], scriptFrames: []}
			]
		};
	}

	/** FDog100_v_1 实测结构：主轴 695 帧（scriptFrames=[1] 盲区）、#90 23 帧
	 * （无导出名）、FDog100=char#91 151 帧。 */
	static function fdogSpec():AssetSpec {
		return {
			asset: "source/core/module/ui/dogs/FDog100_v_1.swf",
			clips: [
				{key: "", isMain: true, frames: 695, labels: [], scriptFrames: [1]},
				{key: "#90", isMain: false, frames: 23, labels: [], scriptFrames: []},
				{key: "FDog100", isMain: false, frames: 151, labels: [], scriptFrames: []}
			]
		};
	}

	/** 推进契约的测试侧独立推导（第 s 步后 (s%N)+1；与实现无共享代码）。 */
	static function faithful(n:Int, steps:Int):Array<Int> {
		return [for (s in 1...steps + 1) (s % n) + 1];
	}

	static function record(asset:String, steps:Int, clips:Array<String>):String {
		return '{"asset":"' + asset + '","steps":' + steps + ',"clips":[' + clips.join(",") + ']}';
	}

	/** labels/events 为 JSON 字面量（null = 整体缺省，验缺省路径）。 */
	static function clipRec(key:String, frames:Array<Int>, loops:Int, endFrame:Int, ?labels:String, ?events:String):String {
		var s = '{"key":"' + key + '","frames":[' + frames.join(",") + '],"loops":' + loops + ',"endFrame":' + endFrame;
		if (labels != null) s += ',"labels":' + labels;
		if (events != null) s += ',"frameEvents":' + events;
		return s + "}";
	}
}
