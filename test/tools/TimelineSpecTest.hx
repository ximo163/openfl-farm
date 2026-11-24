package tools;

import haxe.Json;
import sys.io.File;
import tools.TimelineTypes.ClipSpec;
import tools.TimelineTypes.LabelHit;
import utest.Assert;

/**
 * T3 期望侧纯逻辑：swf 结构 → 期望序列（issue #56，write-tests 阶段对 stub
 * 失败）。被测 tools.TimelineSpec 只做数据推导，不碰显示对象/文件。
 *
 * 期望值出处：
 * - 序列项四件与「期望序列从 swf 结构静态提取」：verification.md「动画与
 *   特效怎么验」第 1 节（时间轴行为比对）——docs 仓库在容器外不可达
 *   （github.com/ximo163/openfl-farm-docs 实测 404），引文以 issue #56 转述
 *   为准（// issue #56）。
 * - 推进契约（每步 +1 带回绕、步后记录、先冻结第 1 帧、单帧剪辑跳过）：
 *   tools/StepAnimate.hx:79（gotoAndStop((currentFrame % totalFrames) + 1)）、
 *   :107-113（stopTree）、:116-129（stepTree，:122 的 totalFrames>1 门）。
 * - swf 结构样例（php tools/dump_swf.php 容器内实测输出，对
 *   assets/legacy-assets.txt 全 69 项跑过一遍；帧数另与
 *   spec/swf-inventory.json frames 字段交叉核对）：
 *   · fish_01.swf：主轴 1 帧、8 个 DefineSprite 全多帧——FJ_01_2_2=char#7
 *     6 帧、FJ_01_2_0=char#14 6 帧、FS_01_0_2=char#23 8 帧、FS_01_1_2=
 *     char#32 8 帧、FS_01_2_2=char#41 8 帧、FS_01_0_0=char#49 8 帧、
 *     FS_01_1_0=char#57 8 帧、FS_01_2_0=char#66 8 帧（SymbolClass 导出名）；
 *     根脚本帧 1（主轴 DoABC）；sprite 层无脚本帧；无任何 FrameLabel 行、
 *     DefineSceneAndFrameLabelData 帧标签 0。
 *   · water_v_5.swf：WaterLand3=char#27 26 帧、StoneFrame1=char#30 单帧、
 *     主轴 1 帧、根脚本帧 1、多帧的只有 WaterLand3、无 FrameLabel 行。
 *   · redUpBanner_v_2.swf：redUpBanner=char#18 3 帧（库帧率 12）。
 *   · FDog100_v_1.swf：主轴 695 帧（spec/swf-inventory.json frames:695，
 *     inventory 里 6290 个 swf 中主轴多帧的恰 90 个，与 issue 转述一致）、
 *     FDog100=char#91 151 帧、char#90 23 帧（无导出名）、根脚本帧 1。
 *   · 帧标签（dump_swf.php 的 FrameLabel/DefineSceneAndFrameLabelData 行，
 *     69 项全量实测）：**12/69 资产含 FrameLabel(43)**——9 个只在主轴
 *     frame1（包装类名：main3_v_221 "module_Main"、shop_v_7
 *     "module_shop_ShopWrapper" 等；这些 swf 主轴均 1 帧，不构成比对单元）；
 *     3 个含多帧带标签 sprite：farmui_full_v_40（char#680 FarmLoading 48 帧
 *     f23"loop"、char#536 SellLockIcon 2 帧 f1"lock"/f2"unlock"、char#588
 *     farmui_full_1_fla.lock_mc_46 2 帧 f1"unlock"/f2"lock"、char#76 GiftIcon
 *     42 帧 f3"GiftMove"）、farmui1_v_42（char#136 GiftIcon 42 帧 f3
 *     "GiftMove"、char#60 SellLockIcon 2 帧 f1"lock"/f2"unlock"）、
 *     lite_ui_v_0（char#9 FarmLoading_Lite 48 帧 f23"loop"）。
 *     DefineSceneAndFrameLabelData(86) 只出现在主轴（56/69 个资产），帧标签
 *     段全清单为 0（只有场景名，如 fish_01 的「场景 1」）——比对会用到的
 *     标签全部来自 tag43。前一轮（write-tests attempt 1）曾断言「69 资产
 *     （含 sprite 内）FrameLabel 均为空」被驳回：标签用例一律取上述实测
 *     数据，不造合成标签。
 * - 键名/键空串=根/"#<id>" 无导出名：// issue #56（StepAnimate.hx:17 用法
 *   行「空串=根」先例）。
 */
class TimelineSpecTest {
	static final STRUCTURE_FIXTURE:String = "test/fixtures/timeline-fish01-structure.json";

	public function new() {}

	// ---- parseAssetStructure：键推导与缺省 ----

	function test_parseStructure_keys_and_defaults() {
		var spec = TimelineSpec.parseAssetStructure(File.getContent(STRUCTURE_FIXTURE));
		// fish_01 实测 9 条（主轴 + 8 sprite），顺序保持 swf 出现顺序
		Assert.equals(9, spec.clips.length);
		Assert.equals("source/core/module/ui/farm/fish/fish_01.swf", spec.asset);
		// 主时间轴：键 ""（StepAnimate「空串=根」先例）
		Assert.isTrue(spec.clips[0].isMain);
		Assert.equals("", spec.clips[0].key);
		// SymbolClass 导出名作键：char#7 → FJ_01_2_2（dump_swf.php 实测）
		Assert.equals("FJ_01_2_2", spec.clips[1].key);
		Assert.isFalse(spec.clips[1].isMain);
		Assert.equals(6, spec.clips[1].frames);
		// 无导出名的 sprite：键 "#<charId>"（FDog100 的 char#90 同款规则）
		var fdog = TimelineSpec.parseAssetStructure(Json.stringify({
			asset: "source/core/module/ui/dogs/FDog100_v_1.swf",
			clips: [
				{id: null, symbol: null, isMain: true, frames: 695, labels: [], scriptFrames: [1]},
				{id: 90, symbol: null, isMain: false, frames: 23, labels: [], scriptFrames: []},
				{id: 91, symbol: "FDog100", isMain: false, frames: 151, labels: [], scriptFrames: []}
			]
		}));
		Assert.equals("", fdog.clips[0].key);
		Assert.equals("#90", fdog.clips[1].key);
		Assert.equals("FDog100", fdog.clips[2].key);
		// labels/scriptFrames 可缺省 = []（fixture 里 FS_01_1_2/FS_01_2_2/FS_01_2_0 整体省略）
		var noDefaults = [for (c in spec.clips) if (c.key == "FS_01_1_2") c][0];
		Assert.same([], noDefaults.labels);
		Assert.same([], noDefaults.scriptFrames);
		// 主轴 scriptFrames=[1]（根脚本帧 1，dump 实测）——盲区标注的输入
		Assert.same([1], spec.clips[0].scriptFrames);
	}

	// ---- multiFrameClips：单帧剪辑不产生比对单元 ----

	function test_multiFrameClips_filters_single_frame() {
		var spec = TimelineSpec.parseAssetStructure(File.getContent(STRUCTURE_FIXTURE));
		// fish_01：主轴 1 帧被滤掉，8 个多帧 sprite 全保留、顺序不变
		var multi = TimelineSpec.multiFrameClips(spec);
		Assert.equals(8, multi.length);
		Assert.equals("FJ_01_2_2", multi[0].key);
		Assert.equals("FS_01_2_0", multi[7].key);
		// water_v_5：StoneFrame1 单帧被滤掉，只剩 WaterLand3（26 帧）
		var water = TimelineSpec.multiFrameClips(TimelineSpec.parseAssetStructure(Json.stringify({
			asset: "source/core/module/ui/water_v_5.swf",
			clips: [
				{id: null, symbol: null, isMain: true, frames: 1, labels: [], scriptFrames: [1]},
				{id: 27, symbol: "WaterLand3", isMain: false, frames: 26, labels: [], scriptFrames: []},
				{id: 30, symbol: "StoneFrame1", isMain: false, frames: 1, labels: [], scriptFrames: []}
			]
		})));
		Assert.equals(1, water.length);
		Assert.equals("WaterLand3", water[0].key);
		// 主轴多帧的资产（FDog100 695 帧）主轴条目保留（是否主轴只是标注，不滤）
		var fdogMulti = TimelineSpec.multiFrameClips(TimelineSpec.parseAssetStructure(Json.stringify({
			asset: "source/core/module/ui/dogs/FDog100_v_1.swf",
			clips: [
				{id: null, symbol: null, isMain: true, frames: 695, labels: [], scriptFrames: [1]},
				{id: 90, symbol: null, isMain: false, frames: 23, labels: [], scriptFrames: []},
				{id: 91, symbol: "FDog100", isMain: false, frames: 151, labels: [], scriptFrames: []}
			]
		})));
		Assert.equals(3, fdogMulti.length);
		Assert.isTrue(fdogMulti[0].isMain);
	}

	// ---- stepsFor：最大帧数，每个剪辑至少走满一圈 ----

	function test_stepsFor_is_max_frame_count() {
		// fish_01：max(6,6,8,8,8,8,8,8) = 8
		Assert.equals(8, TimelineSpec.stepsFor(TimelineSpec.parseAssetStructure(File.getContent(STRUCTURE_FIXTURE))));
		// water_v_5：26（StoneFrame1 单帧不参与）
		Assert.equals(26, TimelineSpec.stepsFor(TimelineSpec.parseAssetStructure(Json.stringify({
			asset: "source/core/module/ui/water_v_5.swf",
			clips: [
				{id: 27, symbol: "WaterLand3", isMain: false, frames: 26, labels: [], scriptFrames: []},
				{id: 30, symbol: "StoneFrame1", isMain: false, frames: 1, labels: [], scriptFrames: []}
			]
		}))));
		// FDog100：主轴 695 最大（151/23 让位）
		Assert.equals(695, TimelineSpec.stepsFor(TimelineSpec.parseAssetStructure(Json.stringify({
			asset: "source/core/module/ui/dogs/FDog100_v_1.swf",
			clips: [
				{id: null, symbol: null, isMain: true, frames: 695, labels: [], scriptFrames: [1]},
				{id: 90, symbol: null, isMain: false, frames: 23, labels: [], scriptFrames: []},
				{id: 91, symbol: "FDog100", isMain: false, frames: 151, labels: [], scriptFrames: []}
			]
		}))));
		// 全单帧资产：0（探针/比对无事可做）
		Assert.equals(0, TimelineSpec.stepsFor(TimelineSpec.parseAssetStructure(Json.stringify({
			asset: "source/core/module/ui/allcrops/Crop_2_1.swf",
			clips: [{id: null, symbol: null, isMain: true, frames: 1, labels: [], scriptFrames: [1]}]
		}))));
	}

	// ---- frameSequence：推进契约 ----

	function test_frameSequence_step_contract() {
		var rows:Array<{src:String, frames:Int, steps:Int, head:Array<Int>, tail:Array<Int>, len:Int}> = [
			{
				src: "water_v_5 WaterLand3 26 帧（dump 实测），K=26：2..26 然后 1（整一圈回绕）",
				frames: 26, steps: 26,
				head: [2, 3, 4, 5], tail: [26, 1], len: 26
			},
			{
				src: "fish_01 FS_* 8 帧（dump 实测），K=8：2..8 然后 1",
				frames: 8, steps: 8,
				head: [2, 3, 4, 5, 6, 7, 8], tail: [1], len: 8
			},
			{
				src: "fish_01 FJ_* 6 帧（dump 实测），K=8（stepsFor 由 8 帧兄弟决定）：第二圈走到 3",
				frames: 6, steps: 8,
				head: [2, 3, 4, 5, 6, 1, 2], tail: [3], len: 8
			},
			{
				src: "redUpBanner_v_2 redUpBanner 3 帧（dump 实测；12fps 库与帧率无关），K=5",
				frames: 3, steps: 5,
				head: [2, 3, 1, 2], tail: [3], len: 5
			},
			{
				src: "最小多帧 N=2，K=4：每步翻转（farmui SellLockIcon 同形）",
				frames: 2, steps: 4,
				head: [2, 1, 2], tail: [1], len: 4
			}
		];
		for (r in rows) {
			var seq = TimelineSpec.frameSequence(clip(r.frames), r.steps);
			Assert.equals(r.len, seq.length, r.src);
			var head = seq.slice(0, r.head.length);
			Assert.same(r.head, head, r.src);
			var tail = seq.slice(seq.length - r.tail.length);
			Assert.same(r.tail, tail, r.src);
		}
	}

	function test_frameSequence_main_timeline_long() {
		// FDog100 主轴 695 帧、K=695（dump 实测 + swf-inventory frames:695）：
		// 首步 2、末步恰回 1、倒数第二 695
		var seq = TimelineSpec.frameSequence(clip(695), 695);
		Assert.equals(695, seq.length);
		Assert.equals(2, seq[0]);
		Assert.equals(695, seq[693]);
		Assert.equals(1, seq[694]);
	}

	function test_frameSequence_empty_when_no_steps() {
		// stepsFor=0 的资产：期望序列为空，不产生比对单元
		Assert.same([], TimelineSpec.frameSequence(clip(26), 0));
	}

	// ---- labelHits：帧标签命中序列（用例全部取清单内真实带标签 sprite） ----

	function test_labelHits_real_labeled_clips() {
		// 结构数据出处（类头「帧标签」条，dump_swf.php 实测）；期望值按推进
		// 契约独立推导：第 s 步后落帧 (s%N)+1，该帧带标签即命中，按步序排列
		var rows:Array<{src:String, c:ClipSpec, steps:Int, hits:Array<LabelHit>}> = [
			{
				// farmui1_v_42 SellLockIcon（char#60）2 帧 f1"lock"/f2"unlock"
				// （farmui_full_v_40 的 char#536 同名同帧数、标签同组）。K=2 恰一
				// 圈：步 1 落 f2"unlock"、步 2 落 f1"lock"——命中按步序，与
				// 标签表序（f1 在前）相反
				src: "SellLockIcon 2 帧 K=2：命中步序与表序相反",
				c: {key: "SellLockIcon", isMain: false, frames: 2, labels: [{frame: 1, name: "lock"}, {frame: 2, name: "unlock"}], scriptFrames: []},
				steps: 2,
				hits: [{step: 1, frame: 2, name: "unlock"}, {step: 2, frame: 1, name: "lock"}]
			},
			{
				// 同一剪辑 K=6：三圈，lock/unlock 交替成对
				src: "SellLockIcon 2 帧 K=6：三圈交替",
				c: {key: "SellLockIcon", isMain: false, frames: 2, labels: [{frame: 1, name: "lock"}, {frame: 2, name: "unlock"}], scriptFrames: []},
				steps: 6,
				hits: [
					{step: 1, frame: 2, name: "unlock"},
					{step: 2, frame: 1, name: "lock"},
					{step: 3, frame: 2, name: "unlock"},
					{step: 4, frame: 1, name: "lock"},
					{step: 5, frame: 2, name: "unlock"},
					{step: 6, frame: 1, name: "lock"}
				]
			},
			{
				// farmui1_v_42 GiftIcon（char#136）42 帧 f3"GiftMove"（farmui_full
				// _v_40 的 char#76 同名同构）。K=42：f3 只在步 2 出现（(2%42)+1=3），
				// 一圈内恰一次
				src: "GiftIcon 42 帧 K=42：圈内单次命中",
				c: {key: "GiftIcon", isMain: false, frames: 42, labels: [{frame: 3, name: "GiftMove"}], scriptFrames: []},
				steps: 42,
				hits: [{step: 2, frame: 3, name: "GiftMove"}]
			},
			{
				// farmui_full_v_40 FarmLoading（char#680，与 lite_ui_v_0 的
				// FarmLoading_Lite char#9 同构）48 帧 f23"loop"。K=10：步 1..10
				// 落帧 2..11，到不了 f23——不命中（标签在步数之外）
				src: "FarmLoading 48 帧 K=10：loop 帧未及",
				c: {key: "FarmLoading", isMain: false, frames: 48, labels: [{frame: 23, name: "loop"}], scriptFrames: []},
				steps: 10,
				hits: []
			},
			{
				// 同上 K=70（一圈 48 步再走 22 步）：f23 在步 22 与步 70
				// （70%48=22）各命中一次
				src: "FarmLoading 48 帧 K=70：两圈中两次 loop",
				c: {key: "FarmLoading", isMain: false, frames: 48, labels: [{frame: 23, name: "loop"}], scriptFrames: []},
				steps: 70,
				hits: [{step: 22, frame: 23, name: "loop"}, {step: 70, frame: 23, name: "loop"}]
			},
			{
				// farmui_full_v_40 lock_mc_46（char#588）2 帧 f1"unlock"/f2"lock"
				// （与 SellLockIcon 同帧数、名字互换）。K=4：两圈
				src: "lock_mc_46 2 帧 K=4",
				c: {key: "farmui_full_1_fla.lock_mc_46", isMain: false, frames: 2, labels: [{frame: 1, name: "unlock"}, {frame: 2, name: "lock"}], scriptFrames: []},
				steps: 4,
				hits: [
					{step: 1, frame: 2, name: "lock"},
					{step: 2, frame: 1, name: "unlock"},
					{step: 3, frame: 2, name: "lock"},
					{step: 4, frame: 1, name: "unlock"}
				]
			}
		];
		for (r in rows) {
			Assert.same(r.hits, TimelineSpec.labelHits(r.c, r.steps), r.src);
		}
	}

	function test_labelHits_empty_for_unlabeled_fish_01() {
		// fish_01 的 8 个多帧剪辑无帧标签（dump_swf.php 实测：fish_01 无任何
		// FrameLabel 行、DefineSceneAndFrameLabelData 帧标签 0）——期望命中为
		// 空。这只是 fish_01 的性质，不是全清单的（12/69 资产有标签，类头）
		var spec = TimelineSpec.parseAssetStructure(File.getContent(STRUCTURE_FIXTURE));
		for (c in TimelineSpec.multiFrameClips(spec)) {
			Assert.same([], TimelineSpec.labelHits(c, TimelineSpec.stepsFor(spec)), c.key);
		}
	}

	// ---- loopEnd：循环次数与终点 ----

	function test_loopEnd_table() {
		var rows:Array<{src:String, frames:Int, steps:Int, loops:Int, endFrame:Int}> = [
			{src: "water_v_5 WaterLand3 26 帧 K=26：恰一圈，末步回 1", frames: 26, steps: 26, loops: 1, endFrame: 1},
			{src: "fish_01 FS_* 8 帧 K=8：恰一圈", frames: 8, steps: 8, loops: 1, endFrame: 1},
			{src: "fish_01 FJ_* 6 帧 K=8：一圈余 2 步 → 终点 3", frames: 6, steps: 8, loops: 1, endFrame: 3},
			{src: "redUpBanner 3 帧 K=5：一圈余 2 → 终点 3", frames: 3, steps: 5, loops: 1, endFrame: 3},
			{src: "farmui SellLockIcon 2 帧 K=6：三圈回 1", frames: 2, steps: 6, loops: 3, endFrame: 1},
			{src: "FDog100 #90 23 帧 K=695：695=23*30+5 → 30 圈终点 6", frames: 23, steps: 695, loops: 30, endFrame: 6},
			{src: "FDog100 FDog100 151 帧 K=695：695=151*4+91 → 4 圈终点 92", frames: 151, steps: 695, loops: 4, endFrame: 92},
			{src: "FDog100 主轴 695 帧 K=695：恰一圈", frames: 695, steps: 695, loops: 1, endFrame: 1},
			{src: "FDog100 主轴 695 帧 K=1390（两圈）：2 圈终点 1", frames: 695, steps: 1390, loops: 2, endFrame: 1},
			{src: "不足一圈：water_v_5 26 帧 K=8 → 0 圈终点 9", frames: 26, steps: 8, loops: 0, endFrame: 9}
		];
		for (r in rows) {
			var le = TimelineSpec.loopEnd(clip(r.frames), r.steps);
			Assert.equals(r.loops, le.loops, r.src);
			Assert.equals(r.endFrame, le.endFrame, r.src);
		}
	}

	// 测试自用：无标签、无脚本的多帧剪辑（帧数即全部变量）
	static function clip(frames:Int):ClipSpec {
		return {key: "c" + frames, isMain: false, frames: frames, labels: [], scriptFrames: []};
	}
}
