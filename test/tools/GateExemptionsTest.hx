package tools;

import sys.io.File;
import tools.CiGatesVerdict.GateExemption;
import tools.CiGatesVerdict.GateKind;
import utest.Assert;

/**
 * issue #94：T2/T3 门禁接线——豁免登记表（tools.GateExemptions，write-tests
 * 阶段空表 stub，本门对 stub 失败，implement 登记 farmui1_v_42 首条后转绿）。
 * 消费方 tools.CiGatesVerdict 的豁免匹配（判式门在
 * test/tools/CiGatesVerdictTest.hx）；wrapper（implement 交付）把本表喂给
 * judge。
 *
 * 需求出处（原版没有的机器门登记表，全部 // issue #94 + 既有事实）：
 * - 要什么 3「红≠一律修的裁决流」+ 完成标准「farmui1_v_42 的已知偏差
 *   候选按裁决流登记豁免」：T3 全量对拍的 farmui1_v_42 红不是移植跑偏，
 *   是「期望侧推不出脚本行为」盲区暴露的诚实红——接线后 CI 必须全量
 *   出绿，已裁决候选转为「照进步日志带理由、不判 CI 红」。
 * - farmui1 红的定性：handbook/architecture/timeline-gate.md:76-81
 *   「全清单现状」节——GiftIcon、farmui1_fla.Timeline_39、farmui1_fla.a_151
 *   三剪辑的帧脚本是 gotoAndPlay 族（含 gotoAndPlay(Math.floor(
 *   Math.random()*100))），改了播放头，「脚本驱动播放头的诚实红……
 *   处置归人裁决（deviations 候选）」。
 * - 资产键 = 清单路径：assets/legacy-assets.txt:82
 *   （source/core/module/mc/main/farmui1_v_42.swf；探针 JSON 的 asset 即
 *   此形态，test/fixtures/timeline-fish01-probe.json 同构）。
 * - 清单读取口径（跳 # 注释与空行、trim）：两闸同款
 *   （tools/RenderGate.mjs:81-82、tools/TimelineGate.mjs:66-67）。
 */
class GateExemptionsTest {
	public function new() {}

	function test_registered_has_farmui1_timeline_candidate() {
		// farmui1_v_42 的偏差候选必须登记在 timeline 闸名下、资产键 =
		// 清单路径整串（// issue #94 完成标准；资产的出处见类头）——
		// 本条对空表 stub 失败，是 write-tests 阶段的验收行
		var found:GateExemption = null;
		for (e in GateExemptions.registered) {
			if (e.gate == Timeline && e.asset == "source/core/module/mc/main/farmui1_v_42.swf") {
				found = e;
				break;
			}
		}
		Assert.notNull(found, "farmui1_v_42@timeline 的候选条目必须在册");
		// 理由是裁决记录：技术根因（gotoAndPlay 族脚本驱动播放头）+
		// 状态（偏差候选待人裁）——step 日志原样带出，复审可追
		// （handbook/architecture/timeline-gate.md:76-81）
		Assert.notNull(found.reason);
		Assert.isTrue(StringTools.contains(found.reason, "gotoAndPlay"), "理由带技术根因（gotoAndPlay 族帧脚本）");
		Assert.isTrue(StringTools.contains(found.reason, "候选"), "理由带裁决状态（偏差候选待人裁）");
	}

	function test_registered_entries_are_complete_records() {
		// 每条登记三件齐（闸别/资产键/理由）——空理由的豁免等于静默
		// 放行，登记表里不许有（// issue #94 要什么 3「裁决记录」的
		// 机器面；空表 stub 上循环体不转，是给后续增补立的门）
		Assert.notNull(GateExemptions.registered, "登记表本体必须在（wrapper 直接喂给 judge，null 会当场炸）");
		for (e in GateExemptions.registered) {
			Assert.notNull(e.gate, "条目缺闸别：" + e.asset);
			Assert.notNull(e.asset);
			Assert.isTrue(e.asset != "", "条目资产键为空串");
			Assert.notNull(e.reason, "条目缺裁决记录：" + e.asset);
			Assert.isTrue(e.reason != "", "条目裁决记录为空串：" + e.asset);
		}
	}

	function test_registered_assets_are_manifest_lines() {
		// 登记的资产键必须真在 assets/legacy-assets.txt 里（整行匹配）：
		// 键写错/资产改名的当天，豁免匹配静默失效、CI 在「未豁免红」上
		// 当场红出来——本门提前把失效钉成显式失败。清单读取口径与两闸
		// 同款（tools/RenderGate.mjs:81-82：trim、跳空行与 # 注释）
		var lines = [];
		for (l in File.getContent("assets/legacy-assets.txt").split("\n")) {
			var t = StringTools.trim(l);
			if (t != "" && !StringTools.startsWith(t, "#")) lines.push(t);
		}
		Assert.isTrue(lines.length > 0, "清单要读得到（路径/cwd 错了本门就空转）"); // 69 资产清单，handbook/architecture/render-gate.md「全清单现状」节
		for (e in GateExemptions.registered) {
			Assert.isTrue(Lambda.has(lines, e.asset), e.asset + " 不在清单里——豁免键失效（登记要跟清单路径走）");
		}
	}
}
