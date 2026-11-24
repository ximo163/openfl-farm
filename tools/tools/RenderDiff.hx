package tools;

import tools.RenderTypes.BaselineDoc;
import tools.RenderTypes.CurrentShot;
import tools.RenderTypes.RenderReport;
import tools.RenderTypes.ShotOutcome;

/**
 * T2 资产渲染对拍——自回归基线比对与聚合报告（issue #57）。本次实拍逐拍点
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
		var outcomes:Array<ShotOutcome> = [];
		var failed = 0;
		var missing = 0;
		var extra = 0;
		var seen = new Map<String, Bool>();
		for (shot in shots) {
			var currentHash = RenderHash.imageHash(shot.image);
			var entry = baseline.entries.get(shot.key);
			if (entry == null) {
				// 基线缺该拍点：新冒出的渲染面（红）
				missing++;
				outcomes.push({
					key: shot.key,
					pass: false,
					missing: true,
					extra: false,
					baselineHash: "",
					currentHash: currentHash
				});
			} else {
				// entry 尺寸字段与哈希都验：基线被手改坏尺寸也红
				var ok = entry.hash == currentHash && entry.width == shot.image.width && entry.height == shot.image.height;
				if (!ok) failed++;
				outcomes.push({
					key: shot.key,
					pass: ok,
					missing: false,
					extra: false,
					baselineHash: entry.hash,
					currentHash: currentHash
				});
			}
			seen.set(shot.key, true);
		}
		for (key in baseline.entries.keys()) {
			if (seen.exists(key)) continue;
			// 基线有而本次没拍到：渲染面消失/拍点漂移（红）
			extra++;
			var entry = baseline.entries.get(key);
			outcomes.push({
				key: key,
				pass: false,
				missing: false,
				extra: true,
				baselineHash: entry.hash,
				currentHash: ""
			});
		}
		// 报告序确定（键升序）：输入序不定，两次跑的报告才可比对
		outcomes.sort(function(a, b) return Reflect.compare(a.key, b.key));
		return {
			pass: failed == 0 && missing == 0 && extra == 0,
			failed: failed,
			missing: missing,
			extra: extra,
			shots: outcomes
		};
	}

	/** 总报告 → 人读文本（定位语义见类头；供 stdout / report.txt）。 */
	static public function render(report:RenderReport):String {
		var lines = [];
		if (report.pass) {
			lines.push('自回归比对通过：${report.shots.length} 个拍点全绿（红 ${report.failed}、缺基线 ${report.missing}、基线多余 ${report.extra}）');
			return lines.join("\n");
		}
		lines.push('自回归比对红：红 ${report.failed}、缺基线 ${report.missing}、基线多余 ${report.extra}（共 ${report.shots.length} 拍点）');
		for (o in report.shots) {
			if (o.pass) continue;
			if (o.missing) {
				lines.push('红 ${o.key}：缺基线（本次实拍有、基线没有；新冒出的渲染面）');
			} else if (o.extra) {
				lines.push('红 ${o.key}：基线多余（基线有、本次没拍到；渲染面消失或拍点漂移）');
			} else {
				lines.push('红 ${o.key}：哈希不符（基线 ${o.baselineHash} 实拍 ${o.currentHash}）');
			}
		}
		return lines.join("\n");
	}
}
