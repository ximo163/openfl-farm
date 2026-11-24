package tools;

import tools.RenderTypes.ShotDiff;
import tools.RenderTypes.ShotImage;
import tools.RenderTypes.Tolerance;

/**
 * T2 资产渲染对拍——单张容差像素 diff（issue #57）。逐张比两幅 ShotImage，
 * 产出差异统计与通过判定，供聚合报告定位「哪些符号哪些帧超容差」。
 *
 * 判定语义（// issue #57，自回归/保真两模式共用）：
 * - 尺寸不等直接红：pass=false、sizeMismatch=true、像素统计不可比
 *   （differing/total=0、ratio=0.0、maxDelta=-1 哨兵）。
 * - 逐像素四通道等权（RGBA 各 |a-b|，取最大为该像素差；无透明像素等
 *   通道特例——html5 预乘舍入噪声走 perPixel 容差吸收，不特判）。
 * - 像素差 > perPixel 才计差异（≤ 即容忍，边界含）；差异像素占比
 *   ≤ ratio 才通过（边界含）。缺省 0/0 = 逐字节严格。
 * - maxDelta 记全图最差像素差（含被容忍的）：通过时也如实记录量级。
 * - pixels.length != width*height*4 是调用方数据错：抛 haxe.Exception
 *   且消息含 "长度"（比对前校验，先于尺寸判断）。
 */
class PixelDiff {
	/** 容差像素 diff：a vs b（同尺寸才比像素，尺寸不等见类头）。tol 可
	 * 缺省或只给部分字段（缺者按 0）。 */
	static public function compare(a:ShotImage, b:ShotImage, ?tol:Tolerance):ShotDiff {
		// 长度校验先于尺寸判断：b 既短又尺寸不符时报长度错，不当尺寸不匹配
		// 静默红（「长度」进消息，调用方能定位是数据坏了不是渲染变了）
		validateLength(a);
		validateLength(b);

		var perPixel = tol != null && tol.perPixel != null ? tol.perPixel : 0;
		var ratioLimit = tol != null && tol.ratio != null ? tol.ratio : 0.0;

		if (a.width != b.width || a.height != b.height) {
			return {
				pass: false,
				sizeMismatch: true,
				differing: 0,
				total: 0,
				ratio: 0.0,
				maxDelta: -1
			};
		}

		var total = a.width * a.height;
		var differing = 0;
		var maxDelta = 0;
		var pa = a.pixels;
		var pb = b.pixels;
		for (i in 0...total) {
			var o = i * 4;
			var d = pa[o] - pb[o];
			if (d < 0) d = -d;
			var d2 = pa[o + 1] - pb[o + 1];
			if (d2 < 0) d2 = -d2;
			if (d2 > d) d = d2;
			var d3 = pa[o + 2] - pb[o + 2];
			if (d3 < 0) d3 = -d3;
			if (d3 > d) d = d3;
			var d4 = pa[o + 3] - pb[o + 3];
			if (d4 < 0) d4 = -d4;
			if (d4 > d) d = d4;
			if (d > maxDelta) maxDelta = d;
			if (d > perPixel) differing++;
		}
		var ratio = total > 0 ? differing / total : 0.0;
		return {
			pass: ratio <= ratioLimit,
			sizeMismatch: false,
			differing: differing,
			total: total,
			ratio: ratio,
			maxDelta: maxDelta
		};
	}

	static function validateLength(image:ShotImage):Void {
		var expected = image.width * image.height * 4;
		if (image.pixels == null || image.pixels.length != expected) {
			var got = image.pixels == null ? -1 : image.pixels.length;
			throw new haxe.Exception('图像数据长度不符: pixels ${got} != ${image.width}*${image.height}*4（width/height 与像素数组对不上）');
		}
	}
}
