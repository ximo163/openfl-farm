package;

import haxe.Json;
import sys.FileSystem;
import sys.io.File;
import utest.Assert;

/**
 * 场景运行器（issue #17：tools/scenario.mjs 种植场景对拍）的数据契约门。
 *
 * 本门钉的是运行器**可判定的交付物**，不是运行器进程本身：utest 只测纯逻辑
 * （不碰显示对象/网络/真实时间），执行器在 node 里跑 nodeboot 产物、驱动
 * 「进农场→种→浇→收」、拦截 XHR——那由实现阶段真跑产出证据、CI（人工配套）
 * 兜底；issue #17 自己把「改坏一处被 diff 指出」定性为「测试或 PR 说明演示」，
 * diff 算法演示按 PR 说明走。可以在 eval 里钉死的是三份交付物与其相互一致性：
 *
 *   1. tools/scenario.mjs —— issue 点名的运行器本体（// issue #17）。
 *   2. tools/scenarios/plant.json —— 种植场景（V3 种浇收链路，#9 的
 *      drive-chain9 证据链声明式化）：四步，每步 action + 检查点。
 *   3. tools/scenarios/plant.record.json —— 运行器自录基线（请求序列快照
 *      + 每步判定与检查点时刻的界面状态），即 diff 模式的基线格式
 *      （issue：基线格式按新版自录设计）。
 *
 * 格式契约（实现按此构造，键名与路径一字不差；场景声明是判定的输入、基线是
 * 判定的输出，两侧同构）：
 *
 *   plant.json = { "name": "plant", "steps": [ {
 *       "name": "enter|plant|water|harvest",
 *       // 操作步骤：执行器原语。词表归执行器（点工具/设光标/按键/点地块），
 *       // 门只要求 type 是非空字符串——能驱动出基线即证明原语可用
 *       "action": { "type": "<非空>", ... },
 *       "checkpoint": {
 *         // 期望发出的 mod 请求及参数（issue #17）。params 取 POST body 的
 *         // k=v 字面，值一律字符串；判定语义=期望参数逐键字面相等，body 的
 *         // 公共参数（tName/fName 等额外键）不判红
 *         "requests": [ { "mod": "...", "act": "...",
 *                          "params": { "<k>": "<v>" } } ],
 *         // 期望的界面状态断言：地块号 → 模型字段（数值语义）
 *         "state": { "lands": { "<place>": { "cId|cropStatus|humidity": <数> } } }
 *       } } ] }
 *
 *   plant.record.json = {
 *     "scenario": "plant",
 *     // 拦截到的全部 mync mod 请求按发送顺序（mod/act 取 URL 查询、params 取
 *     // POST body 字面）；启动期 getoutput 等额外请求照录、判定不计红
 *     "requests": [ { "mod": "...", "act": "...", "params": { "<k>": "<v>" } } ],
 *     // 通过/失败清单 + 检查点时刻实测状态
 *     "steps": [ { "name": "...", "pass": true,
 *                  "state": { "lands": { ... } } } ] }
 *
 * 检查点判定语义（运行器 judge 按此实现；本门按此对三份交付物交叉复验）：
 *   - 每步期望请求在基线 requests 里按步序出现（子序列），期望参数逐键相等；
 *   - 三个操作 act（planting/water/harvest）整份基线恰好各一次；
 *   - 每步 pass==true（完成标准 1「全绿退出」），期望状态字段逐个落地。
 *   基线里出现场景没操作的 farmlandstatus 动作 = 运行器多驱动了一步，判红。
 *
 * 期望值出处（断言处随消息再标一次）：
 *   - mod 序列（「请求序列与 mync.php 的 mod 定义一致」）：mync.php $mod_list
 *     'user_run' :94（访问农场）、'farmlandstatus_planting' :41、
 *     'farmlandstatus_water' :46、'farmlandstatus_harvest' :39；dispatch 拼
 *     mod+'_'+act 走白名单 mync.php:175-183。逐 mod 的 dispatch_query 与参数
 *     规格以 spec/protocol.json（issue #14 的 S1 协议清单，人审过；CLAUDE.md
 *     依据优先级 spec 高于反编译）。
 *   - 地块数值（「参数以 legacy/snapshot uid=1 为准」）：legacy/snapshot/
 *     initialized.sql:5718 uid=1 六块地 status——land0 a=2 b=6 m=16（唯一可收：
 *     farmlandstatus_harvest.php:23-26 守卫 b==6 且 m>=1，land1-3 b=1 全被挡）、
 *     land2 a=2 h=0（唯一可浇：farmlandstatus_water.php:23-25 对 h==1 静默
 *     exit，land1/3 h=1、新种地 planting.php:33 h 置 1）、land4/5 a=0（仅有
 *     空地：farmlandstatus_planting.php:12-13 要求 status[place].a==0）。
 *   - 键映射 a→cId、b→cropStatus、h→humidity：entities/FarmLandTest 逐键
 *     断言（FarmLand.as:187-223 importObject；farmlandstatus_getoutput.php:62
 *     "cId":$a 定死 a 是作物号）。
 *   - 状态转移（应答 echo 的客户端落地）：planting echo farmlandstatus_
 *     planting.php:79 cId:2；water echo :65 humidity:1（farmChange 落
 *     _humidity，FarmLandModel.as:963-971）；harvest :50-53 j+1==maturingTime
 *     （白萝卜=1，cropstype.php:5）→ b=7，echo :94-95 status.cropStatus。
 *   - ownerId：FarmLandModel.as:300-326 buildCommonPostParams 恒带
 *     ownerId=当前 uid；快照 uid=1（uid1_user_run.json user.uId=1）。
 *   - 路径/键名/字符串化等格式细节：// issue #17（原版没有的运行器，按
 *     「基线格式按新版自录设计」授权由本门钉死）。
 */
class ScenarioRunnerContractTest {
	// 交付物路径：scenario.mjs 由 issue #17 点名；场景/基线路径是本门契约
	static final RUNNER_PATH:String = "tools/scenario.mjs";
	static final SCENARIO_PATH:String = "tools/scenarios/plant.json";
	static final RECORD_PATH:String = "tools/scenarios/plant.record.json";
	// S1 协议清单（issue #14）：dispatch_query 与参数规格的 spec 侧权威
	static final PROTOCOL_PATH:String = "spec/protocol.json";

	// issue #17「进农场→种→浇→收」四步
	static final STEP_NAMES:Array<String> = ["enter", "plant", "water", "harvest"];

	// record 里允许出现的 farmlandstatus 动作：三个场景操作 + 启动期 getoutput
	// （FarmLandModel.getOutputs 对 step==5 && output==0 的地块在启动窗口发，
	// CropLifecycleLibrariesTest 类头记录的三条 POST；时序不定，不判红）
	static final ALLOWED_FARM_ACTS:Array<String> = ["planting", "water", "harvest", "getoutput"];

	// 四步期望的 mod 请求（每步恰好一条：进农场/种/浇/收各一个主操作）
	static final STEP_REQUESTS:Array<StepReq> = [
		{
			step: "enter",
			mod: "user",
			act: "run",
			params: [],
			src: "mync.php:94 'user_run'（访问自己和别人农场）；spec/protocol.json user_run.dispatch_query mod=user&act=run"
		},
		{
			step: "plant",
			mod: "farmlandstatus",
			act: "planting",
			params: [
				{
					k: "place",
					vs: ["4", "5"],
					src: "farmlandstatus_planting.php:12-13 空地守卫 status[place].a==0；initialized.sql:5718 仅 land4/5 a=0"
				},
				{
					k: "cId",
					vs: ["2"],
					src: "cropstype.php:5 cId=2 白萝卜（#9 V3 链路的种子，drive-chain9 种植步 POST cId=2）"
				}
			],
			src: "mync.php:41 'farmlandstatus_planting'；spec/protocol.json farmlandstatus_planting.dispatch_query mod=farmlandstatus&act=planting"
		},
		{
			step: "water",
			mod: "farmlandstatus",
			act: "water",
			params: [
				{
					k: "place",
					vs: ["2"],
					src: "farmlandstatus_water.php:23-25 h==1 静默 exit → 只剩 land2 a=2 h=0 可浇（initialized.sql:5718）"
				},
				{
					k: "ownerId",
					vs: ["1"],
					src: "spec/protocol.json farmlandstatus_water.params.ownerId required=true；FarmLandModel.as:300-326 恒带 ownerId=当前 uid；快照 uid=1"
				}
			],
			src: "mync.php:46 'farmlandstatus_water'；spec/protocol.json farmlandstatus_water.dispatch_query mod=farmlandstatus&act=water"
		},
		{
			step: "harvest",
			mod: "farmlandstatus",
			act: "harvest",
			params: [
				{
					k: "place",
					vs: ["0"],
					src: "farmlandstatus_harvest.php:23-26 守卫 b==6 且 m>=1；initialized.sql:5718 唯一 land0 b=6 m=16（land1-3 b=1）"
				}
			],
			src: "mync.php:39 'farmlandstatus_harvest'；spec/protocol.json farmlandstatus_harvest.dispatch_query mod=farmlandstatus&act=harvest"
		}
	];

	// 每步检查点的界面状态期望（数值=模型字段语义；plant 的地块读场景声明值）
	static final STEP_STATES:Array<StepState> = [
		{
			step: "enter",
			land: "0",
			field: "cId",
			v: 2,
			src: "initialized.sql:5718 land0 a=2；a→cId（entities/FarmLandTest，FarmLand.as:187-223）"
		},
		{
			step: "enter",
			land: "0",
			field: "cropStatus",
			v: 6,
			src: "initialized.sql:5718 land0 b=6；b→cropStatus（同上映射）"
		},
		{
			step: "enter",
			land: "2",
			field: "cId",
			v: 2,
			src: "initialized.sql:5718 land2 a=2"
		},
		{
			step: "enter",
			land: "2",
			field: "humidity",
			v: 0,
			src: "initialized.sql:5718 land2 h=0；h→humidity（同上映射）"
		},
		{
			step: "plant",
			land: null, // 场景 plant 步声明的 place（仅 land4/5 合法，见 STEP_REQUESTS）
			field: "cId",
			v: 2,
			src: "farmlandstatus_planting.php:79 echo cId:2 → 客户端 _cId=2（drive-chain9 种植步验证）"
		},
		{
			step: "water",
			land: "2",
			field: "humidity",
			v: 1,
			src: "farmlandstatus_water.php:25 h=1 → echo :65 humidity:1 → farmChange 落 _humidity（FarmLandModel.as:963-971）"
		},
		{
			step: "harvest",
			land: "0",
			field: "cropStatus",
			v: 7,
			src: "farmlandstatus_harvest.php:50-53 j+1==maturingTime（白萝卜=1，cropstype.php:5）→ b=7；echo :94-95 status.cropStatus"
		}
	];

	public function new() {}

	// ---------------------------------------------------------------- helpers

	static function loadJson(path:String, what:String):Dynamic {
		if (!FileSystem.exists(path)) {
			// utest 的 Assert 记录后不中断方法：返回 null，由调用方的空值守卫收尾
			Assert.fail('${what}缺失：${path}（issue #17 交付物，由实现阶段生成/自录，格式契约见本类头注释）');
			return null;
		}
		return Json.parse(File.getContent(path));
	}

	static function scenarioJson():Dynamic {
		return loadJson(SCENARIO_PATH, "种植场景");
	}

	static function recordJson():Dynamic {
		return loadJson(RECORD_PATH, "自录基线记录");
	}

	static function stepByName(steps:Array<Dynamic>, name:String):Dynamic {
		for (st in steps) {
			if (Std.string(Reflect.field(st, "name")) == name) {
				return st;
			}
		}
		return null;
	}

	// 地块键 "0"/"2" 以数字开头：Dynamic 下标直取在 eval 报 "String should be
	// Int"（handbook/lessons #8），一律 Reflect.field
	static function landState(state:Dynamic, land:String):Dynamic {
		if (state == null) {
			return null;
		}
		var lands:Dynamic = Reflect.field(state, "lands");
		if (lands == null) {
			return null;
		}
		return Reflect.field(lands, land);
	}

	// 场景 plant 步声明的 place（state 期望里 plant 的地块号用它）
	static function declaredPlantPlace(scenario:Dynamic):String {
		var steps:Array<Dynamic> = cast Reflect.field(scenario, "steps");
		var st = stepByName(steps, "plant");
		if (st == null) {
			return null;
		}
		var cp:Dynamic = Reflect.field(st, "checkpoint");
		if (cp == null) {
			return null;
		}
		var reqs:Array<Dynamic> = cast Reflect.field(cp, "requests");
		if (reqs == null || reqs.length < 1) {
			return null;
		}
		return Std.string(Reflect.field(Reflect.field(reqs[0], "params"), "place"));
	}

	static function countAct(reqs:Array<Dynamic>, mod:String, act:String):Int {
		var n = 0;
		for (r in reqs) {
			if (Std.string(Reflect.field(r, "mod")) == mod && Std.string(Reflect.field(r, "act")) == act) {
				n++;
			}
		}
		return n;
	}

	// 期望请求（mod/act + 期望参数逐键字面相等）是否被 record 条目满足；
	// 额外键是 body 的公共参数（tName/fName 等），不参与判定
	static function matchReq(entry:Dynamic, expMod:String, expAct:String, expParams:Dynamic):Bool {
		if (entry == null) {
			return false;
		}
		if (Std.string(Reflect.field(entry, "mod")) != expMod) {
			return false;
		}
		if (Std.string(Reflect.field(entry, "act")) != expAct) {
			return false;
		}
		var actual:Dynamic = Reflect.field(entry, "params");
		for (k in Reflect.fields(expParams)) {
			var av = Reflect.field(actual, k);
			if (av == null) {
				return false;
			}
			if (Std.string(av) != Std.string(Reflect.field(expParams, k))) {
				return false;
			}
		}
		return true;
	}

	static function checkpointRequest(step:Dynamic):Dynamic {
		var cp:Dynamic = Reflect.field(step, "checkpoint");
		if (cp == null) {
			return null;
		}
		var reqs:Array<Dynamic> = cast Reflect.field(cp, "requests");
		if (reqs == null || reqs.length < 1) {
			return null;
		}
		return reqs[0];
	}

	// ---------------------------------------------------------------- tests

	// issue #17 点名的三份交付物到位（内容契约由下面各测试逐项钉）
	public function test_issue17_deliverables_present() {
		Assert.isTrue(FileSystem.exists(RUNNER_PATH), '${RUNNER_PATH} 缺失：issue #17 点名的场景运行器本体');
		Assert.isTrue(FileSystem.exists(SCENARIO_PATH), '${SCENARIO_PATH} 缺失：种植场景（进农场→种→浇→收）的声明式描述');
		Assert.isTrue(FileSystem.exists(RECORD_PATH), '${RECORD_PATH} 缺失：运行器自录的基线（请求序列快照，diff 模式的基线格式）');
	}

	// 场景四步 enter→plant→water→harvest，每步有操作原语与检查点
	public function test_scenario_steps_are_enter_plant_water_harvest() {
		var scenario = scenarioJson();
		Assert.notNull(scenario, "种植场景可加载（issue #17 交付物，缺失详情见 test_issue17_deliverables_present）");
		if (scenario == null) {
			return;
		}
		Assert.equals("plant", Reflect.field(scenario, "name"), "场景 name == plant（契约 // issue #17）");
		var steps:Array<Dynamic> = cast Reflect.field(scenario, "steps");
		Assert.notNull(steps, "steps 是数组（操作步骤 + 每步检查点，issue #17）");
		if (steps == null) {
			return;
		}
		Assert.equals(STEP_NAMES.length, steps.length, '四步（issue #17「进农场→种→浇→收」），got ${steps.length}');
		for (i in 0...STEP_NAMES.length) {
			Assert.equals(STEP_NAMES[i], Std.string(Reflect.field(steps[i], "name")), '第 ${i} 步 name == ${STEP_NAMES[i]}');
			var action:Dynamic = Reflect.field(steps[i], "action");
			Assert.notNull(action, 'step ${STEP_NAMES[i]} 的 action 是对象（操作步骤）');
			var type:Dynamic = action == null ? null : Reflect.field(action, "type");
			Assert.isTrue(type != null && Std.isOfType(type, String) && StringTools.trim(cast(type, String)).length > 0,
				'step ${STEP_NAMES[i]} 的 action.type 是非空字符串（执行器原语词表归执行器，本门只要求可辨识）');
			var cp:Dynamic = Reflect.field(steps[i], "checkpoint");
			Assert.notNull(cp, 'step ${STEP_NAMES[i]} 有检查点（期望请求 + 界面状态断言，issue #17）');
			if (cp == null) {
				continue;
			}
			var reqs:Array<Dynamic> = cast Reflect.field(cp, "requests");
			Assert.notNull(reqs, 'step ${STEP_NAMES[i]} checkpoint.requests 是数组');
			Assert.notNull(Reflect.field(cp, "state"), 'step ${STEP_NAMES[i]} checkpoint.state 存在（期望的界面状态断言）');
		}
	}

	// 每步的 mod 请求都在 mync.php 白名单（经 spec/protocol.json 核对）且声明
	// 了协议要求的必填参数——「请求序列与 mync.php 的 mod 定义一致」
	public function test_scenario_request_mods_match_mync_whitelist_and_required_params() {
		var protocol = loadJson(PROTOCOL_PATH, "S1 协议清单");
		var mods:Dynamic = Reflect.field(Reflect.field(Reflect.field(protocol, "entries"), "nc"), "mods");
		var scenario = scenarioJson();
		Assert.notNull(scenario, "种植场景可加载（issue #17 交付物）");
		if (scenario == null) {
			return;
		}
		var steps:Array<Dynamic> = cast Reflect.field(scenario, "steps");
		Assert.notNull(steps);
		if (steps == null) {
			return;
		}
		for (row in STEP_REQUESTS) {
			var st = stepByName(steps, row.step);
			Assert.notNull(st, '场景有 ${row.step} 步');
			if (st == null) {
				continue;
			}
			var reqs:Array<Dynamic> = cast Reflect.field(Reflect.field(st, "checkpoint"), "requests");
			Assert.notNull(reqs, 'step ${row.step} checkpoint.requests 是数组');
			if (reqs == null) {
				continue;
			}
			Assert.equals(1, reqs.length, 'step ${row.step} 期望恰好一条 mod 请求（每步一个主操作，// issue #17），got ${reqs.length}');
			var req = reqs[0];
			Assert.equals(row.mod, Std.string(Reflect.field(req, "mod")), 'step ${row.step} mod == ${row.mod}（${row.src}）');
			Assert.equals(row.act, Std.string(Reflect.field(req, "act")), 'step ${row.step} act == ${row.act}（${row.src}）');
			var declared:Dynamic = Reflect.field(req, "params");
			Assert.notNull(declared, 'step ${row.step} checkpoint.params 是对象');
			// 系统核对：mod_act 在协议清单里、已 dispatch、查询串逐字一致
			var key = row.mod + "_" + row.act;
			var entry:Dynamic = Reflect.field(mods, key);
			Assert.notNull(entry, 'spec/protocol.json entries.nc.mods.${key} 存在（mync.php 白名单的 S1 提取）');
			if (entry == null) {
				continue;
			}
			Assert.isTrue(Reflect.field(entry, "dispatched") == true, '${key} dispatched==true（在 mync.php 的 $$mod_list 白名单内，mync.php:175-183）');
			var dq:Array<String> = cast Reflect.field(entry, "dispatch_query");
			Assert.isTrue(dq != null && dq.indexOf("mod=" + row.mod + "&act=" + row.act) >= 0,
				'${key}.dispatch_query 含 mod=${row.mod}&act=${row.act}（客户端拼网关的字面串，ServerServices cmdMap）');
			// 协议里 required=true 的参数必须全部声明进检查点
			var pdef:Dynamic = Reflect.field(entry, "params");
			for (pk in Reflect.fields(pdef)) {
				var pd:Dynamic = Reflect.field(pdef, pk);
				if (Reflect.field(pd, "required") == true) {
					Assert.isTrue(Reflect.hasField(declared, pk), 'step ${row.step} 检查点声明参数 ${pk}（protocol.json ${key}.params.${pk} required=true）');
				}
			}
		}
	}

	// 检查点参数值逐键对上 uid=1 快照推得的合法值——「参数以 legacy/snapshot uid=1 为准」
	public function test_scenario_request_param_values_match_uid1_snapshot() {
		var scenario = scenarioJson();
		Assert.notNull(scenario, "种植场景可加载（issue #17 交付物）");
		if (scenario == null) {
			return;
		}
		var steps:Array<Dynamic> = cast Reflect.field(scenario, "steps");
		Assert.notNull(steps);
		if (steps == null) {
			return;
		}
		for (row in STEP_REQUESTS) {
			var st = stepByName(steps, row.step);
			if (st == null) {
				continue; // 缺步由 shape 测试报错，这里不重复报
			}
			var req = checkpointRequest(st);
			if (req == null) {
				continue;
			}
			var declared:Dynamic = Reflect.field(req, "params");
			for (p in row.params) {
				var v:Dynamic = declared == null ? null : Reflect.field(declared, p.k);
				Assert.isTrue(v != null && Std.isOfType(v, String) && p.vs.indexOf(cast(v, String)) >= 0,
					'step ${row.step} params.${p.k} ∈ {${p.vs.join("|")}}（字符串字面，POST body 真值；${p.src}），got ${v}');
			}
		}
	}

	// 每步检查点的界面状态期望逐字段对上 PHP echo / 快照——「录检查点的请求序列与界面状态」
	public function test_scenario_state_expectations_match_php_echoes() {
		var scenario = scenarioJson();
		Assert.notNull(scenario, "种植场景可加载（issue #17 交付物）");
		if (scenario == null) {
			return;
		}
		var steps:Array<Dynamic> = cast Reflect.field(scenario, "steps");
		Assert.notNull(steps);
		if (steps == null) {
			return;
		}
		var plantPlace = declaredPlantPlace(scenario);
		for (row in STEP_STATES) {
			var land = row.land == null ? plantPlace : row.land;
			Assert.notNull(land, "场景 plant 步声明了 place（state 期望里 plant 的地块号取它）");
			if (land == null) {
				return;
			}
			var st = stepByName(steps, row.step);
			if (st == null) {
				continue;
			}
			var cp:Dynamic = Reflect.field(st, "checkpoint");
			var landObj = landState(cp == null ? null : Reflect.field(cp, "state"), land);
			Assert.notNull(landObj, 'step ${row.step} 期望状态里有 lands.${land}（契约 // issue #17）');
			if (landObj == null) {
				continue;
			}
			Assert.equals(row.v, Reflect.field(landObj, row.field),
				'step ${row.step} 期望 lands.${land}.${row.field} == ${row.v}（${row.src}）');
		}
	}

	// 基线的请求序列：形状合法、四个检查点按步序命中（子序列）、三个操作各恰好
	// 一次、没有场景之外的 farmlandstatus 动作——judge 语义对基线的复验
	public function test_record_request_sequence_matches_checkpoints() {
		var scenario = scenarioJson();
		Assert.notNull(scenario, "种植场景可加载（issue #17 交付物）");
		if (scenario == null) {
			return;
		}
		var record = recordJson();
		Assert.notNull(record, "自录基线可加载（issue #17 交付物）");
		if (record == null) {
			return;
		}
		Assert.equals("plant", Std.string(Reflect.field(record, "scenario")), "基线 scenario == plant（命名场景的自录快照）");
		var reqs:Array<Dynamic> = cast Reflect.field(record, "requests");
		Assert.notNull(reqs, "基线 requests 是数组（拦截记录的全部 mync mod 请求，issue #17）");
		if (reqs == null) {
			return;
		}
		Assert.isTrue(reqs.length >= STEP_REQUESTS.length, '基线至少录到四个检查点请求，got ${reqs.length}');

		// 形状：mod/act 非空字符串；params 值一律字符串（POST body 的 k=v 字面）
		for (r in reqs) {
			var mod = Std.string(Reflect.field(r, "mod"));
			var act = Std.string(Reflect.field(r, "act"));
			Assert.isTrue(mod.length > 0 && act.length > 0, "每条请求有非空 mod/act（mod/act 取 URL 查询）");
			var params:Dynamic = Reflect.field(r, "params");
			Assert.notNull(params, "每条请求有 params 对象（可为空对象）");
			if (params == null) {
				continue;
			}
			for (k in Reflect.fields(params)) {
				Assert.isTrue(Std.isOfType(Reflect.field(params, k), String),
					'请求参数 ${mod}/${act} 的 ${k} 是字符串字面（POST body wire 真值，契约 // issue #17）');
			}
		}

		// 三个操作 act 恰好各一次（每步一次点击）；其余 farmlandstatus 动作只
		// 容启动期 getoutput——出现 scarify 之类即运行器多驱动了一步
		for (act in ["planting", "water", "harvest"]) {
			var n = countAct(reqs, "farmlandstatus", act);
			Assert.equals(1, n, '基线里 farmlandstatus act=${act} 恰好 1 次（每步一个主操作），got ${n}');
		}
		for (r in reqs) {
			if (Std.string(Reflect.field(r, "mod")) == "farmlandstatus") {
				var act = Std.string(Reflect.field(r, "act"));
				Assert.isTrue(ALLOWED_FARM_ACTS.indexOf(act) >= 0,
					'基线的 farmlandstatus act=${act} 在场景操作+启动 getoutput 之外（${ALLOWED_FARM_ACTS.join("/")})——多驱动了场景外的操作');
			}
		}

		// 四个检查点按步序出现（子序列匹配）：期望参数逐键字面相等，额外键是
		// body 公共参数（tName/fName 等）不计红
		var cursor = 0;
		for (row in STEP_REQUESTS) {
			var st = stepByName(cast Reflect.field(scenario, "steps"), row.step);
			var req = st == null ? null : checkpointRequest(st);
			Assert.notNull(req, '场景 ${row.step} 步有期望请求（缺步由 shape 测试报错）');
			if (req == null) {
				return;
			}
			var expMod = Std.string(Reflect.field(req, "mod"));
			var expAct = Std.string(Reflect.field(req, "act"));
			var expParams:Dynamic = Reflect.field(req, "params");
			var found = -1;
			for (i in cursor...reqs.length) {
				if (matchReq(reqs[i], expMod, expAct, expParams)) {
					found = i;
					break;
				}
			}
			Assert.isTrue(found >= 0,
				'基线 requests 从位置 ${cursor} 起出现 step ${row.step} 期望的 ${expMod}/${expAct}（顺序：进农场→种→浇→收，issue #17；期望参数逐键字面相等）');
			if (found < 0) {
				return;
			}
			cursor = found + 1;
		}
	}

	// 基线的判定清单：每步 pass==true（全绿退出）+ 检查点时刻的实测状态逐字段
	// 满足场景期望（期望 ⊆ 实测）
	public function test_record_steps_all_green_with_observed_states() {
		var scenario = scenarioJson();
		Assert.notNull(scenario, "种植场景可加载（issue #17 交付物）");
		if (scenario == null) {
			return;
		}
		var record = recordJson();
		Assert.notNull(record, "自录基线可加载（issue #17 交付物）");
		if (record == null) {
			return;
		}
		var steps:Array<Dynamic> = cast Reflect.field(record, "steps");
		Assert.notNull(steps, "基线 steps 是数组（通过/失败清单 + 每步实测状态，issue #17）");
		if (steps == null) {
			return;
		}
		Assert.equals(STEP_NAMES.length, steps.length, '基线判定清单四步一判，got ${steps.length}');
		for (i in 0...STEP_NAMES.length) {
			Assert.equals(STEP_NAMES[i], Std.string(Reflect.field(steps[i], "name")), '基线第 ${i} 步 name == ${STEP_NAMES[i]}');
			Assert.isTrue(Reflect.field(steps[i], "pass") == true,
				'step ${STEP_NAMES[i]} pass == true（完成标准 1「全绿退出」；失败路径=改坏基线由 diff 演示，见类头）');
		}
		var plantPlace = declaredPlantPlace(scenario);
		for (row in STEP_STATES) {
			var land = row.land == null ? plantPlace : row.land;
			Assert.notNull(land, "场景 plant 步声明了 place");
			if (land == null) {
				return;
			}
			var st = stepByName(steps, row.step);
			Assert.notNull(st, '基线判定清单里有 ${row.step} 步');
			if (st == null) {
				continue;
			}
			var landObj = landState(Reflect.field(st, "state"), land);
			Assert.notNull(landObj, '基线 step ${row.step} 实测状态里有 lands.${land}（检查点时刻的界面状态）');
			if (landObj == null) {
				continue;
			}
			Assert.equals(row.v, Reflect.field(landObj, row.field),
				'基线 step ${row.step} lands.${land}.${row.field} == ${row.v}（${row.src}）');
		}
	}
}

typedef StepReq = {
	step:String,
	mod:String,
	act:String,
	params:Array<{k:String, vs:Array<String>, src:String}>,
	src:String,
};

typedef StepState = {
	step:String,
	land:Null<String>, // null = 取场景 plant 步声明的 place
	field:String,
	v:Int,
	src:String,
};
