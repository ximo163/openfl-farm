package tools;

import tools.RenderTypes.ShotImage;
import tools.RenderTypes.Tolerance;
import utest.Assert;

/**
 * T1b 场景视觉对拍——运动能量曲线计算纯逻辑（issue #59，write-tests 阶段
 * 对 stub 失败）。被测 tools.MotionEnergy 只做数据进出，不碰显示对象/
 * 真实时间（连拍驱动在 implement 阶段的探针里）。stub 在
 * tools/tools/MotionEnergy.hx（「stub 归树」规矩，implement 原地填充）。
 *
 * 期望值出处：
 * - 曲线形态（相邻帧像素变化量的时间序列；「原版在动、移植版冻住」在
 *   曲线上立刻分叉——冻住＝全零）：verification.md「场景连拍与运动能量
 *   曲线」节，引文以 issue #59 转述为准（docs 仓库容器外不可达，实测
 *   404 同 #56/#57）——// issue #59。
 * - 计数语义（四通道等权取最大、> perPixel 计变化、边界含、tol.ratio
 *   不参与）：PixelDiff 语义的复用（tools/tools/PixelDiff.hx 类头，
 *   // issue #57 已钉）——// issue #59（能量点 = PixelDiff.differing，
 *   不另造第二套计数；交叉核对用已实现的 PixelDiff 现算，无共享代码）。
 * - 数据错先炸（相邻帧尺寸不等抛消息含 尺寸、像素长度错上抛 长度）：
 *   原版没有的工具行为，// issue #59（契约钉死：尺寸漂移是采集侧数据
 *   错，静默计 0 会把「画面换尺寸」当「冻住」——门禁必须有牙）。
 * - 像素数据是合成小图（2×2，#57 PixelDiffTest 同款基准）：被测的是
 *   计数语义，不是某场景的画面；合成像素不构成「凭空期望」——数值本身
 *   即输入定义（// issue #59）。
 */
class MotionEnergyTest {
	public function new() {}

	// ---- 曲线点 = 相邻帧变化像素数，长度 = 帧数 - 1 ----

	function test_curve_counts_changed_pixels_per_adjacent_pair() {
		// A→B（像素 0 三色 +10 → 差 10 记 1 个变化像素）；B→C（B 挪了
		// 像素 0、C 挪了 1/2/3 → 四个像素各差 10 记 4）
		var a = img(2, 2, base2x2());
		var b = img(2, 2, shifted2x2([0]));
		var c = img(2, 2, shifted2x2([1, 2, 3]));
		var curve:Array<Int> = MotionEnergy.curve([a, b, c]);
		Assert.equals(2, curve.length, "3 帧 → 2 个相邻对");
		Assert.equals(1, curve[0], "A→B 变化像素数");
		Assert.equals(4, curve[1], "B→C 变化像素数");
	}

	function test_frozen_sequence_is_all_zero() {
		// 冻住的动画：相邻帧全同（结构相等、不同实例）→ 能量全零。完成
		// 标准 2 注入自检的判定基点（「原版在动、移植版冻住」立刻分叉，
		// verification.md 节引文以 issue #59 转述为准）
		var a = img(2, 2, base2x2());
		var curve:Array<Int> = MotionEnergy.curve([a, img(2, 2, base2x2()), img(2, 2, base2x2()), a]);
		Assert.equals(3, curve.length, "4 帧 → 3 个相邻对");
		for (i in 0...curve.length) {
			Assert.equals(0, curve[i], '冻住序列第 ${i} 点能量为 0');
		}
	}

	function test_tolerance_absorbs_small_deltas() {
		var a = img(2, 2, base2x2());
		var b = img(2, 2, shifted2x2([0]));
		// perPixel=10：像素差恰 10 ≤ 容忍（边界含）→ 不计变化
		var absorbed:Array<Int> = MotionEnergy.curve([a, b], {perPixel: 10});
		Assert.equals(1, absorbed.length);
		Assert.equals(0, absorbed[0], "差 10 容忍 10：边界含不计");
		// perPixel=9：差 10 超容忍 → 计
		var counted:Array<Int> = MotionEnergy.curve([a, b], {perPixel: 9});
		Assert.equals(1, counted[0], "差 10 容忍 9：超计");
	}

	function test_ratio_tolerance_not_involved_in_counting() {
		// ratio 是单张判定的占比门（PixelDiff 契约），不参与能量计数：
		// 给足 ratio 仍按 perPixel 缺省 0 计数——曲线是计数不是判定
		var a = img(2, 2, base2x2());
		var b = img(2, 2, shifted2x2([0]));
		var curve:Array<Int> = MotionEnergy.curve([a, b], {ratio: 1.0});
		Assert.equals(1, curve.length);
		Assert.equals(1, curve[0]);
	}

	// ---- 帧数 ≤ 1 无曲线 ----

	function test_no_adjacent_pairs_means_no_curve() {
		Assert.equals(0, MotionEnergy.curve(null).length, "null 序列 → []");
		Assert.equals(0, MotionEnergy.curve([]).length, "空序列 → []");
		Assert.equals(0, MotionEnergy.curve([img(2, 2, base2x2())]).length, "单帧无相邻对 → []");
	}

	// ---- 数据错先炸：尺寸 / 长度 ----

	function test_adjacent_size_mismatch_throws() {
		// 相邻帧尺寸不等是采集侧数据错：静默计 0 会把「画面换尺寸」当
		// 「冻住」——必须炸（消息含 尺寸）
		var rows:Array<{src:String, frames:Array<ShotImage>}> = [
			{src: "第 2 帧高不等", frames: [img(2, 2, base2x2()), img(2, 3, zeros(24))]},
			{src: "第 1 帧宽不等", frames: [img(1, 2, zeros(8)), img(2, 2, base2x2())]}
		];
		for (r in rows) {
			var msg:String = null;
			try {
				MotionEnergy.curve(r.frames);
			} catch (e:haxe.Exception) {
				msg = e.message;
			}
			Assert.isTrue(msg != null && StringTools.contains(msg, "尺寸"),
				r.src + "：须抛消息含 尺寸 的 haxe.Exception");
		}
	}

	function test_malformed_pixels_throw_length() {
		// 像素数组长度错由 PixelDiff 的 长度 校验上抛（数据错先炸，不静默
		// 比对——#57 同款分工）
		var rows:Array<{src:String, frames:Array<ShotImage>}> = [
			{src: "第 2 帧短 1 字节", frames: [img(2, 2, base2x2()), img(2, 2, base2x2().slice(0, 15))]},
			{src: "第 2 帧多 1 字节", frames: [img(2, 2, base2x2()), img(2, 2, base2x2().concat([0]))]}
		];
		for (r in rows) {
			var msg:String = null;
			try {
				MotionEnergy.curve(r.frames);
			} catch (e:haxe.Exception) {
				msg = e.message;
			}
			Assert.isTrue(msg != null && StringTools.contains(msg, "长度"),
				r.src + "：须抛消息含 长度 的 haxe.Exception");
		}
	}

	// ---- 与 PixelDiff.differing 的交叉核对（不另造计数） ----

	function test_curve_matches_pixeldiff_differing() {
		// 同一对帧、同容差下能量点 == PixelDiff(...).differing：PixelDiff
		// 已由 #57 实现并在测，这里钉「能量 = 容差像素 diff 的计数语义」
		// （两实现独立跑，无共享代码）
		var a = img(2, 2, base2x2());
		var b = img(2, 2, shifted2x2([0, 2]));
		var c = img(2, 2, shifted2x2([3]));
		var tols:Array<Null<Tolerance>> = [null, {perPixel: 5}, {perPixel: 10}];
		for (tol in tols) {
			var curve:Array<Int> = MotionEnergy.curve([a, b, c], tol);
			Assert.equals(PixelDiff.compare(a, b, tol).differing, curve[0], 'tol=${Std.string(tol)} 的 A→B 点');
			Assert.equals(PixelDiff.compare(b, c, tol).differing, curve[1], 'tol=${Std.string(tol)} 的 B→C 点');
		}
	}

	// ---- 测试自用：合成小图（计数语义的输入，见类头） ----

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

	static function zeros(n:Int):Array<Int> {
		return [for (_ in 0...n) 0];
	}
}
