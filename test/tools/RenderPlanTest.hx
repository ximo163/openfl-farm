package tools;

import tools.RenderTypes.ShotPlan;
import tools.TimelineTypes.ClipSpec;
import tools.TimelineTypes.LabelEntry;
import utest.Assert;

/**
 * T2 拍点计划纯逻辑：静态关键帧拍点 + 播放抽帧拍点的推导（issue #57，
 * write-tests 阶段对 stub 失败）。被测 tools.RenderPlan 只做数据推导，不碰
 * 显示对象/文件。stub 在 tools/tools/RenderPlan.hx（#56 教训的「stub 归树」
 * 规矩：验证基建的骨架放完工所属的 tools 树，implement 原地填充）。
 *
 * 期望值出处：
 * - 拍点规则本身：verification.md「动画与特效怎么验」截图部分——静态帧
 *   对拍「每符号 gotoAndStop 关键帧（起点帧、各标签帧）」、第 2 节「播放
 *   中的抽帧」play 状态「每隔 K 帧截一帧，起点/中间/循环回绕帧必抽（补间
 *   插值、嵌套错位只在播放中可见）」。docs 仓库容器外不可达（404，#56
 *   同因实测），引文以 issue #57 转述为准（// issue #57）。
 * - 步号语义（第 s 步（0 基）后 currentFrame = (s % frames) + 1、先冻结
 *   第 1 帧、单帧剪辑不推进）：tools/StepAnimate.hx:79（gotoAndStop(
 *   (currentFrame % totalFrames) + 1)）、:107-113（stopTree 整树冻结第
 *   1 帧）、:116-129（stepTree）、:122（totalFrames>1 门）。T2 复用 T3
 *   的子剪辑枚举与固定步长推进（issue #57 依赖说明），拍点在同一个步号
 *   世界里取。steps 取 T3 stepsFor 语义（资产级最大帧数，恒 ≥ 每个剪辑
 *   帧数）；「回绕拍点 = s%frames==0 且 s>0」即 T3 loops 计数回到第 1 帧
 *   的那些时刻。
 * - swf 结构样例（帧数/标签表）：dump_swf.php 容器内实测 + spec/
 *   swf-inventory.json frames 交叉核对，详单见 test/tools/
 *   TimelineSpecTest.hx 类头（#56 全 69 项实测）。用到的剪辑：water_v_5
 *   WaterLand3=char#27 26 帧无标签、StoneFrame1=char#30 单帧；fish_01
 *   FS_01_0_2=char#23 8 帧无标签、FJ_01_2_2=char#7 6 帧、主轴 1 帧根脚本
 *   帧 1；redUpBanner_v_2 redUpBanner=char#18 3 帧；farmui1_v_42
 *   SellLockIcon=char#60 2 帧 f1"lock"/f2"unlock"、GiftIcon=char#136 42 帧
 *   f3"GiftMove"；farmui_full_v_40 FarmLoading=char#680 48 帧 f23"loop"、
 *   farmui_full_1_fla.lock_mc_46=char#588 2 帧 f1"unlock"/f2"lock"；main3
 *   _v_221 主轴 1 帧带 frame1 标签"module_Main"（包装类名，9 资产同形）；
 *   FDog100_v_1 主轴 695 帧、#90 23 帧（无导出名）。
 * - 拍点 id 格式（"f<帧号>"/"s<步号>"）与「单帧符号也拍静态起点」：键名
 *   契约是原版没有的工具行为，// issue #57（逐符号截图覆盖单帧符号——
 *   help 的 pageN 一族就是单帧符号；id 进基线键，格式钉死保基线稳定）。
 */
class RenderPlanTest {
	public function new() {}

	// ---- staticShots：起点帧 + 各标签帧 ----

	function test_staticShots_start_and_label_frames() {
		// 标签帧全部取实测数据（#56 被驳回教训：不造合成标签）；期望值按
		// 「起点 + 标签帧，去重升序」独立列写
		var rows:Array<{src:String, c:ClipSpec, expected:Array<ShotPlan>}> = [
			{
				// fish_01 FS_01_0_2 8 帧无标签（dump 实测）：只有起点
				src: "FS_01_0_2 8 帧无标签：仅起点",
				c: clip("FS_01_0_2", 8),
				expected: [{id: "f1", kind: "f", index: 1}]
			},
			{
				// 单帧符号也拍（issue #57 逐符号截图；help pageN 一族同形）：
				// fish_01 主轴 1 帧（根脚本帧 1，标签无）
				src: "fish_01 主轴单帧：仍拍起点",
				c: {key: "", isMain: true, frames: 1, labels: [], scriptFrames: [1]},
				expected: [{id: "f1", kind: "f", index: 1}]
			},
			{
				// water_v_5 StoneFrame1 单帧（dump 实测）
				src: "StoneFrame1 单帧：仍拍起点",
				c: clip("StoneFrame1", 1),
				expected: [{id: "f1", kind: "f", index: 1}]
			},
			{
				// main3_v_221 主轴 1 帧 frame1 标签"module_Main"（dump 实测）：
				// 标签帧与起点同帧 → 去重
				src: "主轴 frame1 标签与起点同帧去重",
				c: {key: "", isMain: true, frames: 1, labels: [{frame: 1, name: "module_Main"}], scriptFrames: [1]},
				expected: [{id: "f1", kind: "f", index: 1}]
			},
			{
				// farmui1_v_42 SellLockIcon 2 帧 f1"lock"/f2"unlock"（farmui_full
				// _v_40 char#536 同名同标签）：f1 去重后 [f1, f2]
				src: "SellLockIcon 2 帧 f1/f2 标签：起点与 f1 去重",
				c: clip("SellLockIcon", 2, [{frame: 1, name: "lock"}, {frame: 2, name: "unlock"}]),
				expected: [{id: "f1", kind: "f", index: 1}, {id: "f2", kind: "f", index: 2}]
			},
			{
				// farmui_full_v_40 lock_mc_46 2 帧 f1"unlock"/f2"lock"
				src: "lock_mc_46 2 帧 f1/f2 标签",
				c: clip("farmui_full_1_fla.lock_mc_46", 2, [{frame: 1, name: "unlock"}, {frame: 2, name: "lock"}]),
				expected: [{id: "f1", kind: "f", index: 1}, {id: "f2", kind: "f", index: 2}]
			},
			{
				// farmui1_v_42 GiftIcon 42 帧 f3"GiftMove"：[f1, f3]
				src: "GiftIcon 42 帧 f3 标签",
				c: clip("GiftIcon", 42, [{frame: 3, name: "GiftMove"}]),
				expected: [{id: "f1", kind: "f", index: 1}, {id: "f3", kind: "f", index: 3}]
			},
			{
				// farmui_full_v_40 FarmLoading 48 帧 f23"loop"（lite_ui 的
				// FarmLoading_Lite char#9 同构）：[f1, f23]
				src: "FarmLoading 48 帧 f23 标签",
				c: clip("FarmLoading", 48, [{frame: 23, name: "loop"}]),
				expected: [{id: "f1", kind: "f", index: 1}, {id: "f23", kind: "f", index: 23}]
			}
		];
		for (r in rows) {
			Assert.same(r.expected, RenderPlan.staticShots(r.c), r.src);
		}
	}

	function test_staticShots_dedup_and_sorted() {
		// 标签数据同上（实测），输入顺序打乱：基线键稳定要求输出与输入序
		// 无关——升序去重（排序行为本身是工具契约 // issue #57）
		var rows:Array<{src:String, c:ClipSpec, expected:Array<ShotPlan>}> = [
			{
				src: "SellLockIcon 标签倒序输入 → 升序输出",
				c: clip("SellLockIcon", 2, [{frame: 2, name: "unlock"}, {frame: 1, name: "lock"}]),
				expected: [{id: "f1", kind: "f", index: 1}, {id: "f2", kind: "f", index: 2}]
			},
			{
				// farmui_full_v_40 lock_mc_46 2 帧 f1"unlock"/f2"lock"（dump
				// 实测），输入倒序
				src: "lock_mc_46 标签倒序输入 → 升序输出",
				c: clip("farmui_full_1_fla.lock_mc_46", 2, [{frame: 2, name: "lock"}, {frame: 1, name: "unlock"}]),
				expected: [{id: "f1", kind: "f", index: 1}, {id: "f2", kind: "f", index: 2}]
			}
		];
		for (r in rows) {
			Assert.same(r.expected, RenderPlan.staticShots(r.c), r.src);
		}
	}

	// ---- playbackShots：起点/中间/回绕必抽 + 每隔 k 步 ----

	function test_playbackShots_table() {
		// 期望步集按契约独立推导：{0（起点）、floor(frames/2)（中间）、
		// s%frames==0 且 s>0（回绕）} ∪ {k 的非负倍数 ≤ steps}，升序去重；
		// 结构数值（帧数）出处见类头（dump 实测 + swf-inventory）
		var rows:Array<{src:String, frames:Int, steps:Int, k:Int, expected:Array<Int>}> = [
			{
				// water_v_5 WaterLand3 26 帧，stepsFor=26（该资产唯一多帧
				// 剪辑，T3 stepsFor=最大帧数）：中间 13、回绕 26、k=26 网格
				// {0,26}
				src: "WaterLand3 26 帧 K=26：起点/中间/回绕",
				frames: 26, steps: 26, k: 26,
				expected: [0, 13, 26]
			},
			{
				src: "WaterLand3 26 帧 K=10：网格 {0,10,20} ∪ 必抽 {13,26}",
				frames: 26, steps: 26, k: 10,
				expected: [0, 10, 13, 20, 26]
			},
			{
				// fish_01 FS_* 8 帧，stepsFor=8：中间 4（落帧 5，8 帧的正中
				// 双帧之后者）、回绕 8
				src: "FS_01_0_2 8 帧 K=8：中间 4 回绕 8",
				frames: 8, steps: 8, k: 8,
				expected: [0, 4, 8]
			},
			{
				// FJ_* 6 帧（stepsFor 由 8 帧兄弟决定，T3 同款场景）：中间 3、
				// 回绕 6（第 6 步后播放头回 1，T3 loops 计数时刻）、网格 {0,8}
				src: "FJ_01_2_2 6 帧 K=8：圈内回绕 6 与域末 8",
				frames: 6, steps: 8, k: 8,
				expected: [0, 3, 6, 8]
			},
			{
				// redUpBanner 3 帧 K=5：中间 1、回绕 3、网格 {0,5}
				src: "redUpBanner 3 帧 K=5",
				frames: 3, steps: 5, k: 5,
				expected: [0, 1, 3, 5]
			},
			{
				// 最小多帧 N=2 恰一圈（stepsFor=2）：三个必抽点布满全域
				src: "SellLockIcon 2 帧 K=2：必抽布满全域",
				frames: 2, steps: 2, k: 2,
				expected: [0, 1, 2]
			},
			{
				// farmui_full FarmLoading 48 帧 K=10：网格 {0,10,20,30,40} ∪
				// 中间 24 ∪ 回绕 48
				src: "FarmLoading 48 帧 K=10",
				frames: 48, steps: 48, k: 10,
				expected: [0, 10, 20, 24, 30, 40, 48]
			},
			{
				src: "GiftIcon 42 帧 K=42：中间 21 回绕 42",
				frames: 42, steps: 42, k: 42,
				expected: [0, 21, 42]
			},
			{
				// FDog100 主轴 695 帧（swf-inventory frames:695）K=100：网格
				// {0,100..600} ∪ 中间 347 ∪ 回绕 695
				src: "FDog100 主轴 695 帧 K=100",
				frames: 695, steps: 695, k: 100,
				expected: [0, 100, 200, 300, 347, 400, 500, 600, 695]
			},
			{
				// FDog100 #90 23 帧、总步数 46（两圈内）：回绕 23 与 46 两个
				// 都抽（T3 loops 语义：46=23*2 恰两圈）；中间 11；网格 {0,20,40}
				src: "FDog100 #90 23 帧 steps=46 K=20：两圈两回绕",
				frames: 23, steps: 46, k: 20,
				expected: [0, 11, 20, 23, 40, 46]
			}
		];
		for (r in rows) {
			Assert.same(s(r.expected), RenderPlan.playbackShots(clip("c" + r.frames, r.frames), r.steps, r.k), r.src);
		}
		// 头两条以完整字面量复核拍点形状（id/kind/index 的格式钉死不依赖
		// 测试侧格式化函数）
		Assert.same(
			[{id: "s0", kind: "s", index: 0}, {id: "s13", kind: "s", index: 13}, {id: "s26", kind: "s", index: 26}],
			RenderPlan.playbackShots(clip("WaterLand3", 26), 26, 26),
			"WaterLand3 26 帧 K=26 完整字面量"
		);
	}

	function test_playbackShots_k1_shoots_every_step() {
		// k=1（每隔 1 帧）：全域 [0, steps] 每步都抽——期望是恒等列举，
		// 与实现无共享代码
		Assert.same(s([for (i in 0...27) i]), RenderPlan.playbackShots(clip("WaterLand3", 26), 26, 1), "k=1 全步抽");
	}

	function test_playbackShots_gates() {
		// 单帧剪辑不产生播放拍点（StepAnimate.hx:122 的 totalFrames>1 门
		// 同款；静态起点帧由 staticShots 负责）
		Assert.same([], RenderPlan.playbackShots(clip("StoneFrame1", 1), 26, 4), "单帧剪辑无播放拍点");
		Assert.same([], RenderPlan.playbackShots({key: "", isMain: true, frames: 1, labels: [], scriptFrames: [1]}, 8, 4), "fish_01 主轴单帧无播放拍点");
		// 资产无多帧剪辑时 stepsFor=0（T3 语义）：无播放可比
		Assert.same([], RenderPlan.playbackShots(clip("WaterLand3", 26), 0, 4), "steps=0 无播放拍点");
		// 防御性行为（真实管道里 steps=stepsFor ≥ 每个剪辑帧数，此形态只
		// 会出现在直接误用 API）：中间步超出播放域时不虚造拍点（域内必抽、
		// 域外不发明）
		Assert.same(s([0, 4, 8]), RenderPlan.playbackShots(clip("WaterLand3", 26), 8, 4), "steps<frames：域外的中间/回绕不虚造");
	}

	function test_playbackShots_k_below_1_throws() {
		// k 是门禁级配置：配置错必须炸（消息含 "k"），且先于单帧门——不
		// 被数据形状吞掉（stub 契约 // issue #57）
		var rows:Array<{src:String, frames:Int, k:Int}> = [
			{src: "多帧剪辑 k=0", frames: 26, k: 0},
			{src: "多帧剪辑 k=-1", frames: 8, k: -1},
			{src: "单帧剪辑 k=0（k 校验先于单帧门）", frames: 1, k: 0}
		];
		for (r in rows) {
			var msg:String = null;
			try {
				RenderPlan.playbackShots(clip("c" + r.frames, r.frames), 26, r.k);
			} catch (e:haxe.Exception) {
				msg = e.message;
			}
			Assert.isTrue(msg != null && StringTools.contains(msg, "k"), r.src + "：须抛消息含 k 的 haxe.Exception");
		}
	}

	// ---- 测试自用 ----

	/** 无标签、无脚本的多帧剪辑（帧数即全部变量；isMain 与拍点推导无关）。 */
	static function clip(key:String, frames:Int, ?labels:Array<LabelEntry>):ClipSpec {
		return {key: key, isMain: false, frames: frames, labels: labels == null ? [] : labels, scriptFrames: []};
	}

	/** 步集 → 拍点期望（纯格式化：id/kind/index 由字面量复核行钉死形状）。 */
	static function s(steps:Array<Int>):Array<ShotPlan> {
		return [for (i in steps) {id: "s" + i, kind: "s", index: i}];
	}
}
