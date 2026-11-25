package tools;

import tools.SceneShotTypes.ShotSpec;
import tools.SceneShotTypes.StepSpec;
import utest.Assert;

/**
 * T1b 场景视觉对拍——连拍规格判定纯逻辑（issue #59，write-tests 阶段对
 * stub 失败）。被测 tools.SceneShotPlan 只做数据进出，不碰文件/显示对象
 * （场景 JSON 的解析归运行器，这里喂解析后的 Dynamic 形状）。stub 在
 * tools/tools/SceneShotPlan.hx（「stub 归树」规矩，implement 原地填充）。
 *
 * 期望值出处：
 * - 检查点视觉声明的两类形态（screenshot 单张 / burst {intervalMs,
 *   count} 连拍）与「未声明的默认单张」：verification.md「场景连拍与
 *   运动能量曲线」节——引文以 issue #59 转述为准（docs 仓库容器外不可
 *   达，github.com/ximo163/openfl-farm-docs 实测 404，#56/#57 同因）——
 *   // issue #59。
 * - 连拍规格数值（intervalMs=200、count=25）：verification.md 节内例
 *   「每 200ms 一张持续 5s」（5s/200ms = 25 张），同以 issue #59 转述
 *   为准——// issue #59。
 * - 校验细节（count ≥ 2、intervalMs ≥ 1、缺键/非整数/非对象/二义声明
 *   抛错且消息含 连拍、screenshot 值必须为 true）：原版没有的工具行为，
 *   // issue #59（契约钉死：count < 2 时能量曲线无相邻对，单张语义走
 *   screenshot；显式声明的错值必须炸，不静默落回默认——错字丢判定
 *   等于门禁缺拍）。
 * - 无视觉键的 checkpoint 形状：沿用 tools/scenarios/plant.json 既有
 *   checkpoint（requests/state，见 test/ScenarioRunnerContractTest.hx 契
 *   约）；加视觉键算加严、不删既有判定（issue #59 边界），合成场景不
 *   读真场景文件——implement 会给既有场景补视觉检查点，钉死现状会把
 *   加严改动打红。
 */
class SceneShotPlanTest {
	public function new() {}

	// ---- 未声明的默认单张（既有场景不加键也在视觉门里） ----

	function test_undeclared_checkpoint_defaults_to_single() {
		var rows:Array<{src:String, cp:Dynamic}> = [
			{src: "checkpoint 为 null（步没有 checkpoint）", cp: null},
			{src: "空 checkpoint", cp: {}},
			{
				// plant.json 既有形态：只有 requests/state，无视觉键
				src: "requests/state 检查点（无视觉键）",
				cp: {requests: [{mod: "user", act: "run", params: {}}], state: {}}
			}
		];
		for (r in rows) {
			var spec:ShotSpec = SceneShotPlan.specOfCheckpoint(r.cp);
			Assert.equals("screenshot", spec.kind, r.src);
			Assert.equals(0, spec.intervalMs, r.src);
			Assert.equals(1, spec.count, r.src);
		}
	}

	// ---- screenshot / burst 两类声明 ----

	function test_screenshot_true_is_single() {
		var spec:ShotSpec = SceneShotPlan.specOfCheckpoint({screenshot: true});
		Assert.equals("screenshot", spec.kind);
		Assert.equals(0, spec.intervalMs);
		Assert.equals(1, spec.count);
	}

	function test_burst_declaration_parses() {
		var rows:Array<{src:String, decl:Dynamic, intervalMs:Int, count:Int}> = [
			{
				// verification.md 节内例：每 200ms 一张持续 5s
				src: "verification.md 例值（200ms × 5s = 25 张）",
				decl: {burst: {intervalMs: 200, count: 25}},
				intervalMs: 200,
				count: 25
			},
			{src: "非整十间隔", decl: {burst: {intervalMs: 333, count: 16}}, intervalMs: 333, count: 16},
			{
				// 最小合法连拍：2 张恰给能量曲线 1 个相邻对
				src: "最小合法连拍（2 张）",
				decl: {burst: {intervalMs: 1, count: 2}},
				intervalMs: 1,
				count: 2
			}
		];
		for (r in rows) {
			var spec:ShotSpec = SceneShotPlan.specOfCheckpoint(r.decl);
			Assert.equals("burst", spec.kind, r.src);
			Assert.equals(r.intervalMs, spec.intervalMs, r.src);
			Assert.equals(r.count, spec.count, r.src);
		}
	}

	// ---- burst 校验：错规格必须炸（消息含 连拍），不静默改判 ----

	function test_burst_validation_throws() {
		var rows:Array<{src:String, decl:Dynamic}> = [
			{src: "count=1（能量曲线无相邻对；单张走 screenshot）", decl: {burst: {intervalMs: 200, count: 1}}},
			{src: "count=0", decl: {burst: {intervalMs: 200, count: 0}}},
			{src: "count 为负", decl: {burst: {intervalMs: 200, count: -3}}},
			{src: "intervalMs=0（间隔须为正）", decl: {burst: {intervalMs: 0, count: 25}}},
			{src: "intervalMs 为负", decl: {burst: {intervalMs: -200, count: 25}}},
			{src: "缺 intervalMs", decl: {burst: {count: 25}}},
			{src: "缺 count", decl: {burst: {intervalMs: 200}}},
			{src: "intervalMs 是字符串", decl: {burst: {intervalMs: "200", count: 25}}},
			{src: "count 是浮点", decl: {burst: {intervalMs: 200, count: 2.5}}},
			{src: "burst 不是对象", decl: {burst: true}}
		];
		for (r in rows) {
			var msg:String = null;
			try {
				SceneShotPlan.specOfCheckpoint(r.decl);
			} catch (e:haxe.Exception) {
				msg = e.message;
			}
			Assert.isTrue(msg != null && StringTools.contains(msg, "连拍"),
				r.src + "：须抛消息含 连拍 的 haxe.Exception");
		}
	}

	// ---- screenshot 值非 true：显式声明错值必须炸 ----

	function test_screenshot_bad_value_throws() {
		var rows:Array<{src:String, v:Dynamic}> = [
			{src: "screenshot=false", v: false},
			{src: "screenshot 是字符串", v: "yes"},
			{src: "screenshot 是数字", v: 1}
		];
		for (r in rows) {
			var msg:String = null;
			try {
				SceneShotPlan.specOfCheckpoint({screenshot: r.v});
			} catch (e:haxe.Exception) {
				msg = e.message;
			}
			Assert.isTrue(msg != null && StringTools.contains(msg, "screenshot"),
				r.src + "：须抛消息含 screenshot 的 haxe.Exception");
		}
	}

	function test_screenshot_and_burst_together_throws() {
		// 二义声明：同时给 screenshot 与 burst 必须炸——归一条判定路径的
		// 声明不该有两读
		var msg:String = null;
		try {
			SceneShotPlan.specOfCheckpoint({screenshot: true, burst: {intervalMs: 200, count: 25}});
		} catch (e:haxe.Exception) {
			msg = e.message;
		}
		Assert.isTrue(msg != null && StringTools.contains(msg, "连拍"),
			"二义声明须抛消息含 连拍 的 haxe.Exception");
	}

	// ---- 场景级：按步序逐步拍法 ----

	function test_specs_of_scenario_walks_steps_in_order() {
		// 合成场景（形状沿 plant.json：steps[].name/action/checkpoint）：
		// enter 未声明（默认单张）、plant screenshot、water 缺 checkpoint、
		// harvest burst（收获爆金币是 verification.md 点名的连拍交互瞬间）
		var enter:Dynamic = {name: "enter", action: {type: "waitForReady"}, checkpoint: {requests: [], state: {}}};
		var plant:Dynamic = {name: "plant", action: {type: "clickLand"}, checkpoint: {requests: [], screenshot: true}};
		var water:Dynamic = {name: "water", action: {type: "clickLand"}, checkpoint: null};
		var harvest:Dynamic = {name: "harvest", action: {type: "clickLand"},
			checkpoint: {requests: [], burst: {intervalMs: 200, count: 25}}};
		var scenario:Dynamic = {name: "syn", steps: [enter, plant, water, harvest]};
		var specs:Array<StepSpec> = SceneShotPlan.specsOfScenario(scenario);
		Assert.equals(4, specs.length, "每步一个拍法（未声明的默认单张）");
		Assert.equals("enter", specs[0].step);
		Assert.equals("screenshot", specs[0].spec.kind);
		Assert.equals("plant", specs[1].step);
		Assert.equals("screenshot", specs[1].spec.kind);
		Assert.equals("water", specs[2].step);
		Assert.equals("screenshot", specs[2].spec.kind, "checkpoint 缺失＝未声明默认单张");
		Assert.equals("harvest", specs[3].step);
		Assert.equals("burst", specs[3].spec.kind);
		Assert.equals(200, specs[3].spec.intervalMs);
		Assert.equals(25, specs[3].spec.count);
	}

	function test_specs_of_scenario_null_or_empty() {
		Assert.equals(0, SceneShotPlan.specsOfScenario(null).length, "scenario 为 null → []");
		Assert.equals(0, SceneShotPlan.specsOfScenario({name: "x"}).length, "无 steps → []");
		Assert.equals(0, SceneShotPlan.specsOfScenario({steps: []}).length, "空 steps → []");
	}

	function test_specs_of_scenario_propagates_bad_burst() {
		// 步内的声明错误原样上抛（先炸，不静默跳步——跳步丢的是判定）
		var step:Dynamic = {name: "boom", action: {type: "clickLand"},
			checkpoint: {burst: {intervalMs: 0, count: 25}}};
		var scenario:Dynamic = {name: "bad", steps: [step]};
		var msg:String = null;
		try {
			SceneShotPlan.specsOfScenario(scenario);
		} catch (e:haxe.Exception) {
			msg = e.message;
		}
		Assert.isTrue(msg != null && StringTools.contains(msg, "连拍"),
			"场景级解析须上抛步内连拍声明错误（消息含 连拍）");
	}
}
