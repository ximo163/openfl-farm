package tools;

import tools.RenderTypes.ShotImage;
import tools.SceneShotTypes.BurstDiff;
import tools.SceneShotTypes.CurveDiff;
import tools.SceneShotTypes.ShotSpec;
import utest.Assert;

/**
 * T1b 场景视觉对拍——两级判定与曲线 diff 纯逻辑（issue #59，write-tests
 * 阶段对 stub 失败）。被测 tools.SceneShotDiff 只做数据进出，不碰文件/
 * 显示对象（连拍驱动与像素来源在 implement 阶段的探针里）。stub 在
 * tools/tools/SceneShotDiff.hx（「stub 归树」规矩，implement 原地填充）。
 *
 * 期望值出处：
 * - 两级判定形态（逐张容差 diff + 运动能量曲线、两份记录的曲线 diff、
 *   「原版在动、移植版冻住」立刻分叉）：verification.md「场景连拍与运动
 *   能量曲线」节，引文以 issue #59 转述为准（docs 仓库容器外不可达，
 *   实测 404 同 #56/#57）——// issue #59。
 * - 完成标准 2 的纯逻辑面（「冻住一处动画让某检查点能量曲线归零能红」）：
 *   test_frozen_animation_injection_reds（端到端注入自检走 implement
 *   阶段的 CLI，按 issue）；diffCurves 的冻住用例是它判定半边的最小复
 *   现基线侧在动 [4,4,4] vs 实测冻住 [0,0,0]，// issue #59。
 * - 容差/哨兵细节（曲线逐点 |Δ| ≤ tol 边界含、缺省 0 严格、长度不齐
 *   哨兵红且容差不救、maxDelta 如实记量级含被容忍、divergedAt 定位首个
 *   超容差点、记录对齐门 recordMatches）：原版没有的工具行为，// #59
 *   （契约钉死，#57 PixelDiff/ShotDiff 的哨兵与边界含先例同思想——门禁
 *   必须能暴露「张数不齐/记录缺拍」且报告可定位）。
 * - 像素数据是合成小图（2×2，#57 PixelDiffTest 同款基准）：被测的是
 *   判定语义，不是某场景的画面；合成像素不构成「凭空期望」——数值本身
 *   即输入定义（// issue #59）。连拍序列 A→B→C 的曲线 [1,4] 与
 *   MotionEnergyTest 的同款合成序列一致。
 */
class SceneShotDiffTest {
	public function new() {}

	// ---- diffCurves：忠实曲线全过 ----

	function test_equal_curves_pass() {
		// 自回归基线的忠实形态：两次跑曲线全同（含全零与在动两种形态）
		var rows:Array<Array<Int>> = [[0, 0, 0], [3, 5, 2], [24]];
		for (base in rows) {
			var d:CurveDiff = SceneShotDiff.diffCurves(base, base.copy());
			Assert.isTrue(d.pass);
			Assert.isFalse(d.lengthMismatch);
			Assert.equals(0, d.maxDelta);
			Assert.equals(-1, d.divergedAt);
		}
	}

	// ---- 完成标准 2 的判定半边：冻住 vs 在动立刻分叉 ----

	function test_frozen_vs_animated_diverges_immediately() {
		// 基线在动（每相邻对 4 个变化像素）vs 实测冻住（全零）：第 0 点
		// 就分叉——「原版在动、移植版冻住」的暴露形态
		var d:CurveDiff = SceneShotDiff.diffCurves([4, 4, 4], [0, 0, 0]);
		Assert.isFalse(d.pass);
		Assert.isFalse(d.lengthMismatch);
		Assert.equals(4, d.maxDelta);
		Assert.equals(0, d.divergedAt);
		// 对称：基线冻住、实测在动同样红（分叉无方向性）
		var rev:CurveDiff = SceneShotDiff.diffCurves([0, 0, 0], [4, 4, 4]);
		Assert.isFalse(rev.pass);
		Assert.equals(0, rev.divergedAt);
		Assert.equals(4, rev.maxDelta);
	}

	// ---- 曲线容差：边界含；量级与判定分离 ----

	function test_curve_tolerance_boundary_inclusive() {
		// |Δ|=3 ≤ tol 3（边界含）→ 过；tol 2 → 红在首点
		var ok:CurveDiff = SceneShotDiff.diffCurves([5, 5], [2, 2], 3);
		Assert.isTrue(ok.pass);
		Assert.equals(3, ok.maxDelta, "被容忍的量级也如实记");
		Assert.equals(-1, ok.divergedAt);
		var red:CurveDiff = SceneShotDiff.diffCurves([5, 5], [2, 2], 2);
		Assert.isFalse(red.pass);
		Assert.equals(3, red.maxDelta);
		Assert.equals(0, red.divergedAt);
	}

	function test_diverged_at_first_exceeding_point() {
		// 曲线中段才分叉：定位到首个超容差点（前两点同、第 3 点差 5、
		// 第 4 点差 6）——报告定位「曲线从第几点分叉」靠它
		var d:CurveDiff = SceneShotDiff.diffCurves([1, 1, 6, 1], [1, 1, 1, 7]);
		Assert.isFalse(d.pass);
		Assert.equals(2, d.divergedAt);
		Assert.equals(6, d.maxDelta, "max |Δ| = max(0,0,5,6)");
	}

	// ---- 长度不齐：哨兵红，容差不救 ----

	function test_curve_length_mismatch_sentinel() {
		var rows:Array<{src:String, a:Array<Int>, b:Array<Int>, tol:Null<Int>}> = [
			{src: "b 多一个点", a: [1, 2], b: [1, 2, 3], tol: null},
			{src: "a 多一个点", a: [1, 2, 3], b: [1, 2], tol: null},
			{src: "空 vs 非空", a: [], b: [0], tol: null},
			{src: "容差不救长度", a: [1, 2], b: [1, 2, 3], tol: 999}
		];
		for (r in rows) {
			var d:CurveDiff = SceneShotDiff.diffCurves(r.a, r.b, r.tol);
			Assert.isFalse(d.pass, r.src);
			Assert.isTrue(d.lengthMismatch, r.src);
			Assert.equals(-1, d.maxDelta, r.src);
			Assert.equals(-1, d.divergedAt, r.src);
		}
	}

	function test_null_treated_as_empty_curve() {
		// 记录缺视觉段时装载侧的缺省（空对空是合法一致）；「记录没录上
		// → 全绿」的假阴由 recordMatches 对齐门挡，不在这里静默红
		var both:CurveDiff = SceneShotDiff.diffCurves(null, null);
		Assert.isTrue(both.pass);
		Assert.isFalse(both.lengthMismatch);
		var one:CurveDiff = SceneShotDiff.diffCurves(null, [1]);
		Assert.isFalse(one.pass);
		Assert.isTrue(one.lengthMismatch);
	}

	// ---- compareBurst：两级全过（自回归忠实形态） ----

	function test_faithful_burst_passes_both_levels() {
		var base = burst3();
		var d:BurstDiff = SceneShotDiff.compareBurst(base, copyFrames(base));
		Assert.isTrue(d.pass);
		Assert.equals(3, d.frames.length);
		Assert.equals(0, d.frameFails);
		for (fd in d.frames) {
			Assert.isTrue(fd.pass, "逐张全过");
		}
		Assert.isTrue(d.curve.pass);
		Assert.equals(-1, d.curve.divergedAt);
		// 曲线两侧如实携带（记录两侧同构的输出形态）：A→B→C = [1,4]
		Assert.same([1, 4], d.curveBaseline);
		Assert.same([1, 4], d.curveCurrent);
	}

	// ---- 完成标准 2：冻住一处动画（能量归零）必红 ----

	function test_frozen_animation_injection_reds() {
		// 实测侧全部帧同图（冻住）：能量归零 → 曲线第 0 点分叉；帧层同
		// 步红（冻住的帧不再逐张等于基线的动画帧）——两级都咬住
		var base = burst3();
		var frozen = [img(2, 2, base2x2()), img(2, 2, base2x2()), img(2, 2, base2x2())];
		var d:BurstDiff = SceneShotDiff.compareBurst(base, frozen);
		Assert.isFalse(d.pass);
		Assert.same([0, 0], d.curveCurrent, "冻住侧能量全零");
		Assert.isFalse(d.curve.pass);
		Assert.equals(0, d.curve.divergedAt, "曲线第 0 点分叉（基线 [1,4] vs 冻住 [0,0]）");
		Assert.isTrue(d.frameFails > 0, "帧层同样红");
		Assert.isFalse(d.frames[1].pass, "B 帧位：冻住的 A ≠ 基线 B");
	}

	// ---- 两级独立：各自判，不互相吞 ----

	function test_frame_level_reds_alone() {
		// 只改坏一张帧（C 帧多挪一个像素）：帧层红；曲线计数差 1 由
		// curveTol=1 吸收（边界含）——两级容差独立，帧红不被曲线吞
		var base = burst3();
		var bumped = copyFrames(base);
		bumped[2] = img(2, 2, shifted2x2([0, 1, 2, 3]));
		var d:BurstDiff = SceneShotDiff.compareBurst(base, bumped, null, 1);
		Assert.isFalse(d.pass, "帧层红 → 总判定红");
		Assert.equals(1, d.frameFails);
		Assert.isFalse(d.frames[2].pass, "C 帧位红（多挪一个像素）");
		Assert.isTrue(d.frames[0].pass, "A 帧位不受牵连");
		Assert.isTrue(d.frames[1].pass, "B 帧位不受牵连");
		Assert.isTrue(d.curve.pass, "曲线计数差 1 由 curveTol 吸收");
		Assert.same([1, 4], d.curveBaseline);
		Assert.same([1, 3], d.curveCurrent);
		Assert.equals(1, d.curve.maxDelta, "曲线量级如实记");
	}

	function test_frame_count_mismatch_reds_via_curve_length() {
		// 张数不齐（实测少一张）：帧比公共前缀全过，曲线长度不齐哨兵红
		// ——总判定红（缺拍不能静默绿）
		var base = burst3();
		var d:BurstDiff = SceneShotDiff.compareBurst(base, copyFrames(base).slice(0, 2));
		Assert.isFalse(d.pass);
		Assert.equals(2, d.frames.length, "帧比公共前缀");
		Assert.equals(0, d.frameFails, "公共前缀两帧各自全同");
		Assert.isTrue(d.curve.lengthMismatch);
		Assert.same([1, 4], d.curveBaseline);
		Assert.same([1], d.curveCurrent);
	}

	function test_compare_burst_propagates_data_errors() {
		// 帧数据错（长度）原样上抛：比对器不吞数据错当判定红（数据错 ≠
		// 判定红，#57 PixelDiff 同款分工）
		var base = [img(2, 2, base2x2()), img(2, 2, base2x2().slice(0, 15))];
		var cur = [img(2, 2, base2x2()), img(2, 2, base2x2())];
		var msg:String = null;
		try {
			SceneShotDiff.compareBurst(base, cur);
		} catch (e:haxe.Exception) {
			msg = e.message;
		}
		Assert.isTrue(msg != null && StringTools.contains(msg, "长度"),
			"须上抛消息含 长度 的 haxe.Exception（PixelDiff 校验不吞）");
	}

	// ---- recordMatches：记录与声明的对齐门 ----

	function test_record_matches_spec_alignment() {
		// 帧数 == spec.count 且曲线点数 == spec.count - 1（screenshot 的
		// 1 帧 0 点是同一条规则）——不齐 = 记录缺拍/多拍，调用方必须判红
		// （空对空在 diffCurves 是合法 pass，靠这扇门挡「记录没录上 →
		// 全绿」的假阴）
		var shot:ShotSpec = {kind: "screenshot", intervalMs: 0, count: 1};
		var burst:ShotSpec = {kind: "burst", intervalMs: 200, count: 25};
		var rows:Array<{src:String, spec:ShotSpec, frames:Int, curve:Int, ok:Bool}> = [
			{src: "screenshot 1 帧 0 点", spec: shot, frames: 1, curve: 0, ok: true},
			{src: "screenshot 0 帧（缺拍）", spec: shot, frames: 0, curve: 0, ok: false},
			{src: "screenshot 2 帧（多拍）", spec: shot, frames: 2, curve: 0, ok: false},
			{src: "screenshot 带曲线点", spec: shot, frames: 1, curve: 1, ok: false},
			{src: "burst 25 帧 24 点", spec: burst, frames: 25, curve: 24, ok: true},
			{src: "burst 24 帧（缺一张）", spec: burst, frames: 24, curve: 23, ok: false},
			{src: "burst 26 帧（多一张）", spec: burst, frames: 26, curve: 25, ok: false},
			{src: "burst 25 帧 25 点（曲线多报）", spec: burst, frames: 25, curve: 25, ok: false},
			{src: "burst 25 帧 23 点（曲线少报）", spec: burst, frames: 25, curve: 23, ok: false}
		];
		for (r in rows) {
			Assert.equals(r.ok, SceneShotDiff.recordMatches(r.spec, r.frames, r.curve), r.src);
		}
	}

	// ---- 测试自用：合成小图（判定语义的输入，见类头） ----

	/** 3 帧连拍 A→B→C（B 挪像素 0、C 挪 1/2/3）：曲线 [1,4]。 */
	static function burst3():Array<ShotImage> {
		return [img(2, 2, base2x2()), img(2, 2, shifted2x2([0])), img(2, 2, shifted2x2([1, 2, 3]))];
	}

	static function copyFrames(frames:Array<ShotImage>):Array<ShotImage> {
		return [for (f in frames) {width: f.width, height: f.height, pixels: f.pixels.copy()}];
	}

	static function img(width:Int, height:Int, pixels:Array<Int>):ShotImage {
		return {width: width, height: height, pixels: pixels};
	}

	/** 2×2 四像素基准（行优先；#57 PixelDiffTest 同款值）。 */
	static function base2x2():Array<Int> {
		return [10, 20, 30, 255, 40, 50, 60, 255, 70, 80, 90, 255, 100, 110, 120, 255];
	}

	/** 基准上把第 idx 像素（0 基）三色通道 +10（alpha 不动 → 像素差 10）。 */
	static function shifted2x2(idxs:Array<Int>):Array<Int> {
		var out = base2x2();
		for (idx in idxs) {
			out[idx * 4] += 10;
			out[idx * 4 + 1] += 10;
			out[idx * 4 + 2] += 10;
		}
		return out;
	}
}
