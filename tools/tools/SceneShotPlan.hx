package tools;

import tools.SceneShotTypes.ShotSpec;
import tools.SceneShotTypes.StepSpec;

/**
 * T1b 场景视觉对拍——连拍规格判定（issue #59；write-tests 阶段为 stub，
 * 契约由 test/tools/SceneShotPlanTest.hx 钉死，implement 原地填充）。场景
 * 声明 checkpoint 的视觉键（screenshot/burst）→ ShotSpec；场景 → 逐步
 * 拍法。只做数据进出，不碰文件（场景 JSON 的读写归运行器 scenario.mjs）。
 *
 * 契约（// issue #59；verification.md「场景连拍与运动能量曲线」节的
 * 转述，docs 仓库容器外不可达同 #56）：
 * - checkpoint 未声明视觉键（含 checkpoint 为 null）＝ screenshot 单张
 *   （「未声明的默认单张」）——既有场景不加视觉键也在视觉门里，加
 *   burst 键算加严（issue #59 边界：场景只能加检查点不能删改既有判定）。
 * - "screenshot" == true → 单张；值非 true（false/字符串/数字等错值
 *   形态）抛 haxe.Exception 且消息含 "screenshot"——显式声明必须可用，
 *   错值静默落回默认会让「想要连拍写成错键」悄悄丢判定（门禁缺拍）。
 * - "burst" = { "intervalMs": ≥1, "count": ≥2 } → 连拍。count < 2 抛
 *   （能量曲线至少一个相邻对；单张语义走 screenshot）；intervalMs < 1
 *   抛（同频率连拍的间隔必须为正）；burst 非对象、两键缺一、值非整数
 *   （字符串/浮点）都抛，消息含 "连拍"。
 * - screenshot 与 burst 同时出现抛（二义声明，归一条判定路径的声明不
 *   该有两读），消息含 "连拍"。
 * - 场景级 specsOfScenario：按 steps 顺序逐步出 StepSpec（步的
 *   checkpoint 缺失＝未声明默认单张）；scenario 为 null 或无 steps 返回
 *   []；步内声明错误原样上抛（先炸，不静默跳步）。
 */
class SceneShotPlan {
	/** checkpoint（场景声明解析后的对象）的视觉声明 → 拍法（语义见类头）。 */
	static public function specOfCheckpoint(checkpoint:Dynamic):ShotSpec {
		throw new haxe.Exception("not implemented");
	}

	/** 场景（tools/scenarios/<name>.json 的解析结果）→ 逐步拍法，按步序。 */
	static public function specsOfScenario(scenario:Dynamic):Array<StepSpec> {
		throw new haxe.Exception("not implemented");
	}
}
