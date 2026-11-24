package tools;

import tools.RenderTypes.ShotDiff;
import tools.RenderTypes.ShotImage;
import tools.RenderTypes.Tolerance;

/**
 * T2 资产渲染对拍——单张容差像素 diff（issue #57；write-tests 阶段为
 * stub，契约由 test/tools/PixelDiffTest.hx 钉死）。逐张比两幅 ShotImage，
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
		throw new haxe.Exception("not implemented");
	}
}
