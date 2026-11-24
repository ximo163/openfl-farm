package tools;

import tools.RenderTypes.BaselineDoc;
import tools.RenderTypes.CurrentShot;
import tools.RenderTypes.RenderReport;
import tools.RenderTypes.ShotOutcome;

/**
 * T2 资产渲染对拍——自回归基线比对与聚合报告（issue #57；write-tests
 * 阶段为 stub，契约由 test/tools/RenderDiffTest.hx 钉死）。本次实拍逐拍点
 * 对基线（哈希路径），产出「哪些符号哪些帧超容差/缺/多」的总报告与人读
 * 文本——不证明「和原版一致」，只证明「没变」（自回归立场，issue #57
 * 现状节）；保真对拍换源后走同一条比对（类头 source 不分支）。
 *
 * 判定语义（// issue #57）：
 * - 每拍点：currentHash = RenderHash.imageHash(本次截图)；基线有条目才
 *   可比，pass = 哈希相等 && width 相等 && height 相等（entry 的尺寸字段
 *   与哈希都验——基线被手改坏尺寸时也红）。基线缺条目 = missing（红，
 *   新冒出的渲染面）；基线有而本次没拍到 = extra（红，渲染面消失/拍点
 *   漂移）。缺的一侧哈希 ""。
 * - 聚合：failed/missing/extra 三计数，pass = 全 0；shots 按拍点键升序
 *   （输入序不定，报告序必须确定）。
 * - render 文本：每个非 pass 拍点一行，含完整拍点键与原因词（哈希不符/
 *   缺基线/基线多余）——issue #57「对不上时指明哪个符号哪一帧超容差」。
 */
class RenderDiff {
	/** 实拍集合 vs 基线 → 总报告（语义见类头）。 */
	static public function compareShots(shots:Array<CurrentShot>, baseline:BaselineDoc):RenderReport {
		throw new haxe.Exception("not implemented");
	}

	/** 总报告 → 人读文本（定位语义见类头；供 stdout / report.txt）。 */
	static public function render(report:RenderReport):String {
		throw new haxe.Exception("not implemented");
	}
}
