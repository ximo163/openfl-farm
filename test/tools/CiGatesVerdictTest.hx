package tools;

import tools.CiGatesVerdict.GateExemption;
import tools.CiGatesVerdict.GateKind;
import tools.CiGatesVerdict.GateRunVerdict;
import tools.CiGatesVerdict.GateStatus;
import utest.Assert;

/**
 * issue #94：T2/T3 门禁接线——CI wrapper 判定纯逻辑（write-tests 阶段对
 * stub 失败）。被测 tools.CiGatesVerdict 只判两闸退出码与报告文本，不起
 * 进程、不读文件、不碰真实时间（跑双闸、读报告、两闸 --self-check 的
 * CI 同跑或省略理由、wrapper 脚本、.github/ 人管线全归 implement + 人，
 * // issue #94「执行模式与路由」节）。stub 在 tools/tools/CiGatesVerdict.hx
 * （「stub 归树」规矩，implement 原地填充）。
 *
 * 为什么这门存在：两闸的机器件已并入 main 但零调用——渲染/时间轴跑偏的
 * PR 照常自动合并（// issue #94 背景）。接线把判定语义钉在纯逻辑层：
 * 退出码分流（1/2 都失败、2 标注「基建坏非渲染回归」）、两闸独立不拖累、
 * 报告红行进 step 日志、红≠一律修的豁免面——这四件是 bash 里最难读对的
 * 部分（#64 的 BootSmokeVerdict 同款分层：脚本只剩进程编排）。
 *
 * 期望值出处（原版没有的运行期机器门，全部 // issue #94 + 被接线机器件
 * 的既有契约）：
 * - 退出码三态：tools/RenderGate.mjs:29-30、tools/TimelineGate.mjs:23
 *   （「0 全通过；1 有红或有错；2 基建坏」），同文
 *   handbook/architecture/render-gate.md:37-38。1/2 都判 CI 红、2 标注
 *   「gate 基建问题非渲染回归」：// issue #94 要什么 2 原文。
 * - 两闸独立不拖累：// issue #94 要什么 1 尾（「一个闸的基建错不该把
 *   另一个闸的结果埋掉」）。
 * - 红项进 step 日志：// issue #94 要什么 1（「红时把『哪笔拍点键/哪步
 *   哪项 diff』打进 step 日志（聚合报告在 export/timeline-gate/ 与
 *   export/render-gate/ 的 report.txt）」）。报告路径 = 两闸 --out 缺省
 *   （tools/RenderGate.mjs:48、tools/TimelineGate.mjs:37）；闸名取报告
 *   标题（tools/RenderGate.mjs:254「T2 资产渲染对拍报告」、
 *   tools/TimelineGate.mjs:148「T3 时间轴行为对拍报告」）。
 * - T2 拍点键红行行形：tools/tools/RenderDiff.hx:98/:100/:102（`红
 *   <asset>|<symbol>|<shotId>：缺基线/基线多余/哈希不符`），由
 *   test/tools/RenderDiffTest.hx:179-184 钉死；拍点键 `<asset>|<symbol>|
 *   <shotId>` 形态 handbook/architecture/render-gate.md「比对单元」节。
 * - T3 跑偏行行形：test/t3/TimelineDiff.hx:221/:225（`跑偏 asset=<asset>
 *   [clip=<key>] item=<item> [第N步] <期望/实测>`），由
 *   test/tools/TimelineDiffTest.hx 钉死。
 * - 资产错误行行形：`资产 <asset>：错误——<detail>`——
 *   tools/RenderGate.mjs:266、tools/TimelineGate.mjs:156。降级行
 *   （t3.TimelineDiff.hx:235）是盲区诚实标注不是红：
 *   handbook/architecture/timeline-gate.md「判定语义」节（「降级只护
 *   frameEvents 一项……不判红不假绿」）。
 * - 豁免面：// issue #94 要什么 3（红≠一律修的裁决流）+ 完成标准
 *   （「farmui1_v_42 的已知偏差候选按裁决流登记豁免」）；farmui1 红的
 *   定性：handbook/architecture/timeline-gate.md:76-81「全清单现状」节
 *   （GiftIcon/farmui1_fla.Timeline_39/farmui1_fla.a_151 三剪辑的帧脚本
 *   是 gotoAndPlay 族、脚本驱动播放头的诚实红，处置归人裁决）。
 * - exit 2 的闸没写新报告（陈旧报告守卫）：两闸的 exit(2) 位点都在
 *   报告落盘之前——tools/RenderGate.mjs:52/:69/:87/:166/:205/:211/:233
 *   vs 落盘 :280-281；tools/TimelineGate.mjs:53/:72 vs :167-168。
 * - 资产键形态：assets/legacy-assets.txt 的清单路径整串（探针 JSON 的
 *   asset 即此形态，test/fixtures/timeline-fish01-probe.json；
 *   farmui1_v_42 = assets/legacy-assets.txt:82，fish_01 = :110）。
 */
class CiGatesVerdictTest {
	public function new() {}

	// ------------------------------------------------------------------
	// 语料（行形出处见类头；红行的数值是合成输入——被测的是行形识别与
	// 判定语义，不是某次真跑的逐字内容）

	static final FARMUI1_ASSET:String = "source/core/module/mc/main/farmui1_v_42.swf"; // assets/legacy-assets.txt:82
	static final FISH01_ASSET:String = "source/core/module/ui/farm/fish/fish_01.swf"; // assets/legacy-assets.txt:110

	// t3.TimelineDiff.hx:225 剪辑级跑偏行（clip= + 第N步 + 期望/实测）
	static final FARMUI1_RED_1:String = "跑偏 asset=" + FARMUI1_ASSET + " clip=GiftIcon item=currentFrame 第2步 期望 3，实测 4";
	static final FARMUI1_RED_2:String = "跑偏 asset=" + FARMUI1_ASSET + " clip=farmui1_fla.Timeline_39 item=currentFrame 第3步 期望 4，实测 5";
	// t3.TimelineDiff.hx:221 资产级跑偏行（无 clip=；steps 是资产级项）
	static final FARMUI1_RED_STEPS:String = "跑偏 asset=" + FARMUI1_ASSET + " item=steps 期望 10 步，实测 9 步";

	// RenderDiff.hx:102/:98/:100 三种拍点键红行（哈希不符/缺基线/基线多余）
	static final FARMUI1_HASH_RED:String = "红 " + FARMUI1_ASSET
		+ "|GiftIcon|f1：哈希不符（基线 0cc175b9c0f1b6a831c399e269772661 实拍 4a43ec2847b1ce1d0e1a1c4d6e5e0e1e）";
	static final FARMUI1_MISSING_RED:String = "红 " + FARMUI1_ASSET
		+ "|farmui1_fla.Timeline_39|s26：缺基线（本次实拍有、基线没有；新冒出的渲染面）";
	static final FARMUI1_EXTRA_RED:String = "红 " + FARMUI1_ASSET
		+ "|farmui1_fla.a_151|s13：基线多余（基线有、本次没拍到；渲染面消失或拍点漂移）";

	// t3.TimelineDiff.hx:235 降级行（盲区诚实标注，不是红）
	static final DOWNGRADE_LINE:String = "降级 asset=" + FISH01_ASSET
		+ " clip=FS_01_0_2 item=frameEvents scriptFrames=[1]（无原版 AS3 帧脚本可执行，issue #56 盲区）"
		+ "——openfl 侧行为只能照录；实测帧事件照录：第2步 frame2 ";

	// 两闸报告的统计头（tools/TimelineGate.mjs:148-152、tools/RenderGate.mjs:
	// 254-262 的拼装形态——这些行是提取器的噪声面，必须被滤掉）
	static function t3Report(sections:Array<String>, red:Bool):String {
		var lines = [
			"# T3 时间轴行为对拍报告（issue #56，期望=swf 结构静态提取 vs 实跑=探针固定步长）",
			"覆盖 69/69 个清单资产（2026-11-26T00:00:00.000Z）",
			red ? "通过 68，红 1，错误 0；降级剪辑 43 个（盲区不判红，分布在 8 个资产）；走查 fallback（via=raw）1 个"
				: "通过 69，红 0，错误 0；降级剪辑 43 个（盲区不判红，分布在 8 个资产）；走查 fallback（via=raw）1 个",
		];
		if (red) lines.push("红资产：farmui1_v_42.swf");
		lines.push("");
		return lines.concat(sections).concat([""]).join("\n");
	}

	static function t2Report(sections:Array<String>, red:Bool):String {
		var lines = [
			"# T2 资产渲染对拍报告（issue #57，自回归基线：基线=首跑 openfl 截图，证明「没变」）",
			"基线来源 source=self（真 Flash 参考采集是人 TODO；就位后 --update-baseline --source references 换源重建）",
			"覆盖 69/69 个清单资产（k=10，2026-11-26T00:00:00.000Z）",
			red ? "通过 68，红 1，错误 1；拍点 6251（符号目标 200）"
				: "通过 69，红 0，错误 0；拍点 6251（符号目标 200）",
			"覆盖数：PNG 解码 112、JPEG（黑兜底，format 无解码器）104、动态文本字形盒 fillText 877、位图兜底采样 0、实例化失败符号 0",
		];
		if (red) {
			lines.push("红资产：farmui1_v_42.swf");
			lines.push("错误资产：fish_01.swf");
		}
		lines.push("");
		return lines.concat(sections).concat([""]).join("\n");
	}

	/** 全绿的 T3 报告（通过资产 + 降级行 + 库侧日志行——提取面全噪声）。 */
	static function greenT3():String {
		return t3Report([
			"资产 " + FISH01_ASSET + "：通过（steps=8，剪辑 9 个，降级 1 个）",
			DOWNGRADE_LINE,
			"  （库侧日志 3 条进探针 JSON 的 scriptLog，此处不展开）", // tools/TimelineGate.mjs:161
		], false);
	}

	/** farmui1 红的 T3 报告（通过/降级/红资产段混排，reds 逐字拼进红段）。 */
	static function redT3(reds:Array<String>):String {
		return t3Report([
			"资产 " + FISH01_ASSET + "：通过（steps=8，剪辑 9 个，降级 1 个）",
			DOWNGRADE_LINE,
			"  （库侧日志 3 条进探针 JSON 的 scriptLog，此处不展开）",
			"资产 " + FARMUI1_ASSET + "：红（steps=10，剪辑 5 个，降级 0 个）",
		].concat(reds), true);
	}

	/** 全绿的 T2 报告（通过资产的 RenderDiff.render 行裸拼，无 `资产 X：` 头）。 */
	static function greenT2():String {
		return t2Report(["自回归比对通过：91 个拍点全绿（红 0、缺基线 0、基线多余 0）"], false);
	}

	/** farmui1 红的 T2 报告（红段 + 通过资产段混排）。 */
	static function redT2(reds:Array<String>):String {
		return t2Report([
			"自回归比对红：红 1、缺基线 1、基线多余 1（共 12 拍点）",
		].concat(reds).concat([
			"自回归比对通过：91 个拍点全绿（红 0、缺基线 0、基线多余 0）",
		]), true);
	}

	static function joined(v:GateRunVerdict):String {
		return v.lines.join("\n");
	}

	/** lines 里有一行同时含 parts 全部片段（状态行/定位行的行级钉法——
	 * 片段同行才钉得住归属，如「T3 …」「exit 1」「report.txt」）。 */
	static function hasLine(v:GateRunVerdict, parts:Array<String>):Bool {
		return Lambda.exists(v.lines, l -> {
			for (p in parts) {
				if (!StringTools.contains(l, p)) return false;
			}
			return true;
		});
	}

	/** 登记表里找 farmui1@T3 的条目（不存在返回 null——测试自行 notNull）。 */
	static function farmui1Entry():GateExemption {
		return Lambda.find(GateExemptions.registered, e -> e.asset == FARMUI1_ASSET && e.gate == Timeline);
	}

	// ------------------------------------------------------------------
	// classifyExit：退出码分流（// issue #94 要什么 2）

	function test_classify_exit_declared_codes_table() {
		// 两闸退出码契约的三个声明码（tools/RenderGate.mjs:29-30、
		// tools/TimelineGate.mjs:23）：0 全过 / 1 有红或有错 / 2 基建坏
		Assert.equals(GateStatus.Green, CiGatesVerdict.classifyExit(0), "exit 0 = 全通过");
		Assert.equals(GateStatus.Red, CiGatesVerdict.classifyExit(1), "exit 1 = 有红或有错");
		Assert.equals(GateStatus.Infra, CiGatesVerdict.classifyExit(2), "exit 2 = 基建坏");
	}

	function test_classify_exit_undeclared_nonzero_is_infra() {
		// 未声明码不在闸的 0/1/2 契约里（node 崩溃/被信号杀，bash $? 呈
		// 137/139 形态）：闸没按契约说话＝闸自己坏了——归「基建问题」侧
		// 而不是「渲染回归」侧（2 的标注语义「gate 基建问题非渲染回归」
		// 对闸失灵同样成立，// issue #94 要什么 2）
		Assert.equals(GateStatus.Infra, CiGatesVerdict.classifyExit(3));
		Assert.equals(GateStatus.Infra, CiGatesVerdict.classifyExit(137));
	}

	// ------------------------------------------------------------------
	// renderRedLines：T2 报告 → 判红定位行

	function test_render_red_lines_pick_shot_key_lines_and_errors() {
		// T2 定位行两类：拍点键红行（RenderDiff.hx:98/:100/:102 三种原因
		// 词，行形 test/tools/RenderDiffTest.hx:179-184 钉死——「哪笔拍点
		// 键」）与资产错误行（tools/RenderGate.mjs:266——「错在哪个资产」）。
		// 统计头/红资产行/错误资产行/通过资产段都不是定位行。
		var errLine = "资产 " + FISH01_ASSET + "：错误——stdout 末行不是 JSON（exit=1）… {boom}"; // RenderGate.mjs:141 的 detail 形态
		var report = t2Report([
			"自回归比对红：红 1、缺基线 1、基线多余 1（共 12 拍点）",
			FARMUI1_HASH_RED,
			FARMUI1_MISSING_RED,
			FARMUI1_EXTRA_RED,
			"自回归比对通过：91 个拍点全绿（红 0、缺基线 0、基线多余 0）",
			errLine,
		], true);
		Assert.same([FARMUI1_HASH_RED, FARMUI1_MISSING_RED, FARMUI1_EXTRA_RED, errLine],
			CiGatesVerdict.renderRedLines(report), "拍点键红行 + 错误行按报告原序原样");
	}

	function test_render_red_lines_green_report_has_no_locator_lines() {
		// 全绿报告（`红 0、缺基线 0、基线多余 0` 的统计字样与通过行共存，
		// 但没有一行是拍点键红行）→ 定位行为空
		Assert.same([], CiGatesVerdict.renderRedLines(greenT2()));
	}

	// ------------------------------------------------------------------
	// timelineRedLines：T3 报告 → 判红定位行

	function test_timeline_red_lines_pick_paopian_and_errors_excluding_downgrade() {
		// T3 定位行两类：跑偏行（t3.TimelineDiff.hx:221 资产级 / :225 剪辑
		// 级——「哪步哪项」）与资产错误行（tools/TimelineGate.mjs:156）。
		// 降级行（t3.TimelineDiff.hx:235）是盲区诚实标注不是红
		// （handbook/architecture/timeline-gate.md「判定语义」节「降级
		// 只护 frameEvents 一项……不判红不假绿」）；资产头行（:218-219）、
		// 库侧日志行、统计头同理不进。
		var errLine = "资产 " + FISH01_ASSET + "：错误——探针进程失败: spawn ENOENT"; // TimelineGate.mjs:93 的 detail 形态
		var report = t3Report([
			"资产 " + FISH01_ASSET + "：通过（steps=8，剪辑 9 个，降级 1 个）",
			DOWNGRADE_LINE,
			"  （库侧日志 3 条进探针 JSON 的 scriptLog，此处不展开）",
			"资产 " + FARMUI1_ASSET + "：红（steps=10，剪辑 5 个，降级 0 个）",
			FARMUI1_RED_1,
			FARMUI1_RED_STEPS,
			errLine,
		], true);
		Assert.same([FARMUI1_RED_1, FARMUI1_RED_STEPS, errLine],
			CiGatesVerdict.timelineRedLines(report), "跑偏行 + 错误行按报告原序原样，降级行/头行滤掉");
	}

	function test_timeline_red_lines_green_report_has_no_locator_lines() {
		// 全绿报告（降级行在、跑偏行没有——降级不判红）→ 定位行为空
		Assert.same([], CiGatesVerdict.timelineRedLines(greenT3()));
	}

	// ------------------------------------------------------------------
	// judge：双闸 → CI 判定 + step 日志块

	function test_judge_green_when_both_gates_green_with_both_status_lines() {
		// 全绿形态（// issue #94 完成标准「CI 实跑两闸全量对拍出绿」的
		// 机器面）：两闸 exit 0 + 报告无定位行 → pass + exitCode 0；
		// lines 恒两闸在场，状态行带闸名、退出码、聚合报告路径
		// （「聚合报告在 export/timeline-gate/ 与 export/render-gate/
		// 的 report.txt」——两闸 --out 缺省 tools/TimelineGate.mjs:37、
		// tools/RenderGate.mjs:48；闸名取报告标题 TimelineGate.mjs:148 /
		// RenderGate.mjs:254）
		var v = CiGatesVerdict.judge(0, greenT3(), 0, greenT2(), []);
		Assert.isTrue(v.pass);
		Assert.equals(0, v.exitCode);
		Assert.isTrue(hasLine(v, ["T3 时间轴行为对拍", "exit 0", "export/timeline-gate/report.txt"]), "T3 状态行：闸名 + 退出码 + 报告路径");
		Assert.isTrue(hasLine(v, ["T2 资产渲染对拍", "exit 0", "export/render-gate/report.txt"]), "T2 状态行：闸名 + 退出码 + 报告路径");
	}

	function test_judge_unregistered_red_fails_ci_with_reds_in_step_log() {
		// exit 1＝有红或有错（闸契约）→ CI 红（// issue #94 要什么 2）。
		// 红行逐字进 step 日志（「红时把『哪笔拍点键/哪步哪项 diff』打进
		// step 日志」——T3 的哪步哪项）；豁免表为空 → 照红。报告里有
		// 降级行但 step 日志不进（定位面不是大报告转储，聚合报告在
		// export/ 下）
		var v = CiGatesVerdict.judge(1, redT3([FARMUI1_RED_1]), 0, greenT2(), []);
		Assert.isFalse(v.pass, "未登记的红照红");
		Assert.equals(1, v.exitCode);
		Assert.isTrue(hasLine(v, [FARMUI1_RED_1]), "红行逐字进 step 日志");
		Assert.isTrue(hasLine(v, ["T3 时间轴行为对拍", "export/timeline-gate/report.txt"]));
		Assert.isFalse(StringTools.contains(joined(v), "降级 asset="), "降级行不进 step 日志");
	}

	function test_judge_registered_candidate_is_exempted_but_visible() {
		// // issue #94 完成标准：「farmui1_v_42 的已知偏差候选按裁决流
		// 登记豁免」——已登记的红不判 CI 红（全量对拍照绿的唯一活路）；
		// 但照打进步日志带登记理由：豁免不是静默放行，复审的人从 step
		// 日志看得见「哪步哪项被以什么理由豁免」（// issue #94 要什么 3）
		var entry = farmui1Entry();
		Assert.notNull(entry, "farmui1_v_42 的候选已在 GateExemptions 登记（本测试对空表 stub 失败）");
		var v = CiGatesVerdict.judge(1, redT3([FARMUI1_RED_1, FARMUI1_RED_2]), 0, greenT2(), GateExemptions.registered);
		Assert.isTrue(v.pass, "farmui1 的红已按裁决流登记，不判 CI 红");
		Assert.equals(0, v.exitCode);
		Assert.isTrue(hasLine(v, [FARMUI1_RED_1]), "豁免的红行照进步日志（不静默）");
		Assert.isTrue(StringTools.contains(joined(v), entry.reason), "登记理由带进步日志（裁决记录可追）");
	}

	function test_judge_exemption_is_gate_scoped() {
		// 登记条目按闸生效：farmui1@T3 的豁免不盖 T2 的红——T2 侧
		// farmui1 的拍点哈希不符仍是回归红（裁决流按闸按红裁决，「真回归
		// →开修复 issue」不能被别闸的登记条目顺带吞掉）
		var v = CiGatesVerdict.judge(0, greenT3(), 1, redT2([FARMUI1_HASH_RED]), GateExemptions.registered);
		Assert.isFalse(v.pass, "T3 的登记不豁免 T2 的红");
		Assert.equals(1, v.exitCode);
		Assert.isTrue(hasLine(v, [FARMUI1_HASH_RED]));
	}

	function test_judge_exemption_matches_asset_key_exactly() {
		// 豁免匹配按登记的清单路径**整串**：basename 同形、目录不同的
		// 资产不豁免（合成资产——清单外路径，只测匹配判式；basename /
		// 子串匹配会把「登记了 fish_01」放大成「豁免一切同名文件」）
		var syntheticAsset = "source/core/module/ui/fish/fish_01.swf";
		var syntheticRed = "跑偏 asset=" + syntheticAsset + " clip=FS_01_0_2 item=currentFrame 第2步 期望 3，实测 4";
		var exemptions:Array<GateExemption> = [
			{gate: Timeline, asset: FISH01_ASSET, reason: "合成条目：只测登记键整串匹配判式"},
		];
		var v = CiGatesVerdict.judge(1, redT3([syntheticRed]), 0, greenT2(), exemptions);
		Assert.isFalse(v.pass, "别目录同名资产的红不受 fish_01 登记条目豁免");
	}

	function test_judge_error_line_fails_even_when_asset_registered() {
		// 错误行不可豁免：`资产 …：错误——…` 是闸的执行失败（探针没跑
		// 成），不是比对偏差候选——登记了 farmui1@T3 也盖不住 farmui1 的
		// 执行错误（裁决流只收比对偏差，执行错要么修基建要么修资产，
		// // issue #94 要什么 3）
		var errLine = "资产 " + FARMUI1_ASSET + "：错误——探针进程失败: spawn ENOENT";
		var v = CiGatesVerdict.judge(1, redT3([FARMUI1_RED_1, errLine]), 0, greenT2(), GateExemptions.registered);
		Assert.isFalse(v.pass, "豁免盖得住比对红行，盖不住执行错误行");
		Assert.equals(1, v.exitCode);
		Assert.isTrue(hasLine(v, [errLine]), "错误行进 step 日志（错误同样要定位到资产）");
	}

	function test_judge_exit1_without_locator_lines_stays_red() {
		// 闸说红（exit 1）而报告里提取不出任何定位行（闸中途崩、报告
		// 没落或形态对不上）：照红不猜绿——豁免只对「看得见、对得上
		// 登记」的红生效，看不见的红当绿等于给报告丢失开静默后门
		var v = CiGatesVerdict.judge(1, greenT3(), 0, greenT2(), GateExemptions.registered);
		Assert.isFalse(v.pass, "exit 1 但看不见红在哪，照红");
		Assert.equals(1, v.exitCode);
	}

	function test_judge_infra_exit2_fails_ci_with_annotation() {
		// // issue #94 要什么 2：「2（基建坏：探针编译失败/缺基线）也
		// 失败但日志标注『gate 基建问题非渲染回归』」——CI 一样红（不
		// 静默放行），标注行把「先修基建」和「查渲染回归」分流
		var v = CiGatesVerdict.judge(2, "", 0, greenT2(), []);
		Assert.isFalse(v.pass, "基建坏也判 CI 红");
		Assert.equals(1, v.exitCode, "不透传 2——CI 只认红绿，基建坏靠行内标注说清");
		Assert.isTrue(hasLine(v, ["T3 时间轴行为对拍", "gate 基建问题非渲染回归"]), "标注挂在 T3 的状态行上");
	}

	function test_judge_infra_does_not_leak_stale_report_reds() {
		// exit 2 的闸没写新报告（两闸的 exit(2) 位点都在落盘之前：
		// tools/RenderGate.mjs:52/:69/:87/:166/:205/:211/:233 vs :280-281、
		// tools/TimelineGate.mjs:53/:72 vs :167-168）——盘上只可能是上一
		// 轮的陈旧报告，吐出来就是把旧红冒充本轮结果。基建坏的闸不提取
		// 红行，step 日志只有标注。
		var v = CiGatesVerdict.judge(2, redT3([FARMUI1_RED_1]), 0, greenT2(), []);
		Assert.isFalse(v.pass);
		Assert.isFalse(StringTools.contains(joined(v), FARMUI1_RED_1), "基建坏的闸不吐陈旧报告红行");
		Assert.isTrue(hasLine(v, ["gate 基建问题非渲染回归"]));
	}

	function test_judge_infra_gate_does_not_bury_other_gate() {
		// // issue #94 要什么 1 尾：「两闸探针编译线各自独立，失败互不
		// 拖累（一个闸的基建错不该把另一个闸的结果埋掉）」——bash `&&`
		// 短路就埋掉了，judge 侧的对应物是两个方向都验：一闸基建坏时
		// 另一闸的红行照进 step 日志、基建坏的那闸带着标注在场
		var a = CiGatesVerdict.judge(1, redT3([FARMUI1_RED_1]), 2, "", []);
		Assert.isFalse(a.pass);
		Assert.isTrue(hasLine(a, [FARMUI1_RED_1]), "T2 基建坏不埋 T3 的红行");
		Assert.isTrue(hasLine(a, ["T2 资产渲染对拍", "gate 基建问题非渲染回归"]), "基建坏的 T2 带标注在场");
		Assert.isTrue(hasLine(a, ["T3 时间轴行为对拍"]), "T3 结果在场");

		var b = CiGatesVerdict.judge(2, "", 1, redT2([FARMUI1_HASH_RED]), []);
		Assert.isFalse(b.pass);
		Assert.isTrue(hasLine(b, [FARMUI1_HASH_RED]), "T3 基建坏不埋 T2 的红行");
		Assert.isTrue(hasLine(b, ["T3 时间轴行为对拍", "gate 基建问题非渲染回归"]), "基建坏的 T3 带标注在场");
		Assert.isTrue(hasLine(b, ["T2 资产渲染对拍"]), "T2 结果在场");
	}

	function test_judge_report_reds_trump_green_exit_code() {
		// 报告说红就红：退出码 0 但报告里有未登记的定位行（闸内不一致）
		// ——退出码的绿不遮报告的红；farmui1 的登记条目按资产键匹配，
		// 不盖 fish_01 的红（豁免不扩面）
		var fishRed = "跑偏 asset=" + FISH01_ASSET + " clip=FS_01_0_2 item=currentFrame 第2步 期望 3，实测 4";
		var v = CiGatesVerdict.judge(0, redT3([fishRed]), 0, greenT2(), GateExemptions.registered);
		Assert.isFalse(v.pass, "退出码 0 不遮报告里的红行");
		Assert.equals(1, v.exitCode);
	}

	function test_judge_both_gates_red_both_present() {
		// 两闸都红：各自的红行都进 step 日志、状态行各自带报告路径
		// （「哪笔拍点键」+「哪步哪项」同场可读）；通过资产行不进
		// （redT2 语料里就有通过行——噪声负钉）
		var v = CiGatesVerdict.judge(1, redT3([FARMUI1_RED_1]), 1, redT2([FARMUI1_HASH_RED]), []);
		Assert.isFalse(v.pass);
		Assert.equals(1, v.exitCode);
		Assert.isTrue(hasLine(v, [FARMUI1_RED_1]));
		Assert.isTrue(hasLine(v, [FARMUI1_HASH_RED]));
		Assert.isTrue(hasLine(v, ["T2 资产渲染对拍", "export/render-gate/report.txt"]));
		Assert.isTrue(hasLine(v, ["T3 时间轴行为对拍", "export/timeline-gate/report.txt"]));
		Assert.isFalse(StringTools.contains(joined(v), "自回归比对通过："), "通过资产行不进 step 日志");
	}
}
