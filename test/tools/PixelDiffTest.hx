package tools;

import tools.RenderTypes.ShotDiff;
import tools.RenderTypes.ShotImage;
import tools.RenderTypes.Tolerance;
import utest.Assert;

/**
 * T2 单张容差像素 diff 纯逻辑：判定语义与差异统计（issue #57，write-tests
 * 阶段对 stub 失败）。被测 tools.PixelDiff 只做数据进出，不碰显示对象/文件
 * /真实时间。stub 在 tools/tools/PixelDiff.hx（「stub 归树」规矩，implement
 * 原地填充）。
 *
 * 期望值出处：
 * - 比对形态（容差像素 diff 逐张、聚合报告「哪些符号哪些帧超容差」）：
 *   verification.md 截图部分，引文以 issue #57 转述为准（docs 仓库容器外
 *   不可达，404 实测同 #56）——// issue #57。
 * - 容差语义细节（四通道等权取最大、边界含、缺省 0/0 逐字节严格、尺寸
 *   不等哨兵红、容差不救尺寸）：原版没有的工具行为，// issue #57（契约
 *   钉死；抗锯齿/预乘噪声走 perPixel 容差吸收，不搞透明像素特例——那是
 *   通道特例，容差语义会跟着实现漂）。
 * - 像素数据是合成小图（1×1/2×2）：被测的是判定语义，不是某资产的画面；
 *   合成像素不构成「凭空期望」——数值本身即输入定义（// issue #57）。
 *   注入用例对应完成标准 2「人为改坏一处渲染能红」的纯逻辑面（探针/截图
 *   通道的端到端自检在 implement 阶段按 issue 走 --self-check）。
 */
class PixelDiffTest {
	public function new() {}

	// ---- 忠实记录全绿（防门禁无差别红） ----

	function test_identical_passes_strict() {
		// 同图（结构相等、不同实例）：缺省容差 0/0 逐字节全绿
		var d = PixelDiff.compare(img(2, 2, base2x2()), img(2, 2, base2x2()));
		Assert.isTrue(d.pass);
		Assert.isFalse(d.sizeMismatch);
		Assert.equals(0, d.differing);
		Assert.equals(4, d.total);
		Assert.floatEquals(0.0, d.ratio);
		Assert.equals(0, d.maxDelta);
	}

	// ---- perPixel 容差：边界含（≤ 容忍、> 记差异），四通道等权 ----

	function test_perPixel_boundary_table() {
		// 1×1 图（total=1）：像素差 d、容差 p → 计差异与否；maxDelta 恒记
		// 实际量级（含被容忍的——报告量级与判定分离）
		var rows:Array<{src:String, a:Array<Int>, b:Array<Int>, tol:Tolerance, differing:Int, maxDelta:Int, pass:Bool}> = [
			{
				// R 通道差 1，perPixel=1：恰在容忍边界（≤）→ 不计
				src: "差 1 容忍 1：边界含",
				a: [10, 20, 30, 255], b: [11, 20, 30, 255],
				tol: {perPixel: 1}, differing: 0, maxDelta: 1, pass: true
			},
			{
				// 差 1，缺省（无 tol 参数）：逐字节严格 → 记差异
				src: "差 1 无容差：严格红",
				a: [10, 20, 30, 255], b: [11, 20, 30, 255],
				tol: null, differing: 1, maxDelta: 1, pass: false
			},
			{
				// 差 1，空容差对象（字段全缺省按 0）：同严格
				src: "差 1 空容差对象：字段缺省 0",
				a: [10, 20, 30, 255], b: [11, 20, 30, 255],
				tol: {}, differing: 1, maxDelta: 1, pass: false
			},
			{
				// R 差 2，perPixel=1：超容忍 1 → 记
				src: "差 2 容忍 1：超",
				a: [10, 20, 30, 255], b: [12, 20, 30, 255],
				tol: {perPixel: 1}, differing: 1, maxDelta: 2, pass: false
			},
			{
				// 差取绝对值（b 更小也算）：G 20→14 差 6，容忍 5 → 超
				src: "反向差（b 更小）：|20-14|=6 容忍 5",
				a: [10, 20, 30, 255], b: [10, 14, 30, 255],
				tol: {perPixel: 5}, differing: 1, maxDelta: 6, pass: false
			},
			{
				// alpha 通道等权：仅 A 255→250 差 5，容忍 4 → 超
				src: "仅 alpha 差 5 容忍 4：四通道等权",
				a: [10, 20, 30, 255], b: [10, 20, 30, 250],
				tol: {perPixel: 4}, differing: 1, maxDelta: 5, pass: false
			},
			{
				// 仅 alpha 差 5，容忍 5：边界含 → 不计
				src: "仅 alpha 差 5 容忍 5：边界含",
				a: [10, 20, 30, 255], b: [10, 20, 30, 250],
				tol: {perPixel: 5}, differing: 0, maxDelta: 5, pass: true
			},
			{
				// 四通道取最大：R +3 且 G +7 → 像素差 7（不是 10、不是 3），
				// 容忍 5 → 记、maxDelta 7
				src: "R+3 G+7：像素差取四通道最大 7",
				a: [10, 20, 30, 255], b: [13, 27, 30, 255],
				tol: {perPixel: 5}, differing: 1, maxDelta: 7, pass: false
			},
			{
				// 极限：perPixel=255 全通道差都 ≤ 容忍 → 全图容忍
				src: "差 255 容忍 255：极限全容忍",
				a: [0, 0, 0, 255], b: [255, 0, 0, 255],
				tol: {perPixel: 255}, differing: 0, maxDelta: 255, pass: true
			}
		];
		for (r in rows) {
			var d:ShotDiff = PixelDiff.compare(img(1, 1, r.a), img(1, 1, r.b), r.tol);
			Assert.equals(r.differing, d.differing, r.src);
			Assert.equals(r.maxDelta, d.maxDelta, r.src);
			Assert.equals(r.pass, d.pass, r.src);
			// 判定与统计一致：有差异像素时非零占比
			Assert.floatEquals(r.differing, d.ratio, 1e-9, r.src);
			Assert.equals(1, d.total, r.src);
			Assert.isFalse(d.sizeMismatch, r.src);
		}
	}

	// ---- ratio 容差：占比边界含（≤ 通过） ----

	function test_ratio_tolerance_boundary() {
		// 2×2（total=4）：两像素差 10（容忍 5 记差异）→ 占比 0.5
		var two = shifted2x2([0, 1]);
		var one = shifted2x2([3]);
		var half = PixelDiff.compare(img(2, 2, base2x2()), img(2, 2, two), {perPixel: 5, ratio: 0.5});
		Assert.equals(2, half.differing);
		Assert.floatEquals(0.5, half.ratio);
		Assert.isTrue(half.pass, "2/4 差异占比 0.5 ≤ 0.5：边界含通过");
		var under = PixelDiff.compare(img(2, 2, base2x2()), img(2, 2, two), {perPixel: 5, ratio: 0.49});
		Assert.isFalse(under.pass, "占比 0.5 > 0.49：红");
		var quarter = PixelDiff.compare(img(2, 2, base2x2()), img(2, 2, one), {perPixel: 5, ratio: 0.25});
		Assert.equals(1, quarter.differing);
		Assert.floatEquals(0.25, quarter.ratio);
		Assert.isTrue(quarter.pass, "1/4 差异占比 0.25 ≤ 0.25：边界含通过");
	}

	// ---- 尺寸不等：哨兵红，容差不救 ----

	function test_size_mismatch_sentinel() {
		// 尺寸不等直接红：像素统计不可比（differing/total=0、ratio=0.0、
		// maxDelta=-1 哨兵——静态目标上 null 不能当 Int）
		var rows:Array<{src:String, a:ShotImage, b:ShotImage, tol:Tolerance}> = [
			{src: "2×2 vs 2×3：高不等", a: img(2, 2, base2x2()), b: img(2, 3, zeros(24)), tol: null},
			{src: "2×2 vs 3×2：宽不等", a: img(2, 2, base2x2()), b: img(3, 2, zeros(24)), tol: null},
			{
				// 宽容差不救尺寸：渲染矩形变了就是回归，不吃容差
				src: "2×2 vs 2×3 带全容忍容差：仍红",
				a: img(2, 2, base2x2()), b: img(2, 3, zeros(24)),
				tol: {perPixel: 255, ratio: 1.0}
			}
		];
		for (r in rows) {
			var d = PixelDiff.compare(r.a, r.b, r.tol);
			Assert.isFalse(d.pass, r.src);
			Assert.isTrue(d.sizeMismatch, r.src);
			Assert.equals(0, d.differing, r.src);
			Assert.equals(0, d.total, r.src);
			Assert.floatEquals(0.0, d.ratio, r.src);
			Assert.equals(-1, d.maxDelta, r.src);
		}
	}

	// ---- 长度契约：调用方数据错先炸，不静默比对 ----

	function test_length_validation_throws() {
		var rows:Array<{src:String, a:ShotImage, b:ShotImage}> = [
			{src: "a 的 pixels 短 1 字节", a: img(2, 2, base2x2().slice(0, 15)), b: img(2, 2, base2x2())},
			{src: "b 的 pixels 多 1 字节", a: img(2, 2, base2x2()), b: img(2, 2, base2x2().concat([0]))},
			{
				// 长度校验先于尺寸判断（stub 类头契约）：b 既短又尺寸不符 →
				// 报长度错而不是当尺寸不匹配静默红
				src: "b 短且尺寸不符：长度先报",
				a: img(2, 2, base2x2()), b: img(2, 3, zeros(23))
			}
		];
		for (r in rows) {
			var msg:String = null;
			try {
				PixelDiff.compare(r.a, r.b);
			} catch (e:haxe.Exception) {
				msg = e.message;
			}
			Assert.isTrue(msg != null && StringTools.contains(msg, "长度"), r.src + "：须抛消息含 长度 的 haxe.Exception");
		}
	}

	// ---- 完成标准 2 的纯逻辑面：改坏一处（整幅跑偏）必红 ----

	function test_shifted_image_reds() {
		// 全图通道跑偏（0→255）：全差异、占比 1、最差 255——任何容差配置
		// 下至少在合理容差处红（此处 perPixel 254 仍记差异）
		var d = PixelDiff.compare(img(2, 2, zeros(16)), img(2, 2, [for (_ in 0...16) 255]), {perPixel: 254, ratio: 0.0});
		Assert.isFalse(d.pass);
		Assert.equals(4, d.differing);
		Assert.floatEquals(1.0, d.ratio);
		Assert.equals(255, d.maxDelta);
	}

	// ---- 测试自用：合成小图（判定语义的输入，见类头） ----

	static function img(width:Int, height:Int, pixels:Array<Int>):ShotImage {
		return {width: width, height: height, pixels: pixels};
	}

	/** 2×2 四像素基准（行优先）。 */
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

	static function zeros(n:Int):Array<Int> {
		return [for (_ in 0...n) 0];
	}
}
