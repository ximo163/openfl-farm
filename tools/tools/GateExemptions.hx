package tools;

import tools.CiGatesVerdict.GateExemption;
import tools.CiGatesVerdict.GateKind;

/**
 * issue #94 T2/T3 门禁接线——已裁决登记的偏差候选表（write-tests 阶段
 * stub：空表，farmui1_v_42 首条由 implement 原地登记，契约由
 * test/tools/GateExemptionsTest.hx 钉死）。消费方是 tools.CiGatesVerdict
 * 的豁免匹配；wrapper（implement 交付）把本表喂给 judge。
 *
 * 为什么存在（// issue #94 要什么 3「红≠一律修的裁决流」+ 完成标准
 * 「farmui1_v_42 的已知偏差候选按裁决流登记豁免」）：T3 全量对拍的
 * farmui1_v_42 红不是移植跑偏，是「期望侧推不出脚本行为」盲区暴露的
 * 诚实红——处置归人裁决（deviations 候选）。接线后 CI 必须全量出绿，
 * 已裁决的候选从「照实红」转为「照打进步日志、带理由、不判 CI 红」；
 * 豁免不是静默放行：条目带裁决记录（根因 + 状态），step 日志原样带出。
 *
 * 登记规程（谁能进表）：
 *   - 比对偏差候选（真红但裁决为「原版差异/工具误差」等非回归项）——
 *     真回归不进表（开修复 issue）；T2 侧原版差异走换源口
 *     --update-baseline 重采（基线 source 字段登记），重采后条目即删。
 *   - 执行错误（`资产 …：错误——…`）不进表：错误是闸的执行失败，没有
 *     豁免一档（judge 侧判式已钉死）。
 *   - 裁决记录追加进 handbook/architecture/render-gate 页（// issue #94
 *     要什么 3），本表是它的机器面。
 */
class GateExemptions {
	/** 已裁决登记的偏差候选（implement 登记 farmui1_v_42 首条；后续按
	 * 裁决流增删——每条都要能追到 handbook 页的裁决记录）。 */
	static public final registered:Array<GateExemption> = [];
}
