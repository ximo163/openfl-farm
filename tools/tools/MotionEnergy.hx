package tools;

import tools.RenderTypes.ShotImage;
import tools.RenderTypes.Tolerance;

/**
 * T1b 场景视觉对拍——运动能量曲线计算（issue #59；write-tests 阶段为
 * stub，契约由 test/tools/MotionEnergyTest.hx 钉死，implement 原地填充）。
 * 连拍帧序列 → 相邻帧像素变化量的时间序列；「原版在动、移植版冻住」在
 * 曲线上立刻分叉（冻住 = 全零，完成标准 2 注入自检的判定基点）。
 *
 * 判定语义（// issue #59，verification.md「场景连拍与运动能量曲线」节
 * 的转述，docs 仓库容器外不可达同 #56）：
 * - 曲线点 i = frames[i] 与 frames[i+1] 的「变化像素数」：逐像素四通道
 *   （RGBA 各 |a-b|）等权取最大为该像素差，> tol.perPixel 才计变化
 *   （≤ 容忍，边界含）——即 PixelDiff.compare(frames[i], frames[i+1],
 *   tol).differing（#57 已钉的容差像素 diff 计数语义，不另造第二套）。
 *   tol.ratio 不参与：那是单张判定的占比门，不是计数语义。
 * - 曲线长度 = 帧数 - 1（相邻对数）；帧数 ≤ 1（含 null/空序列）无曲线。
 * - 相邻两帧尺寸不等抛 haxe.Exception 且消息含 "尺寸"：连拍序列来自同
 *   一舞台的同尺寸截图，尺寸漂移是采集侧数据错——静默计 0 会把「画面
 *   换了尺寸」当「冻住」，门禁必须有牙。像素数组长度错由 PixelDiff 的
 *   "长度" 校验上抛（数据错先炸，不静默比对，#57 同款分工）。
 */
class MotionEnergy {
	/** 连拍帧序列 → 能量曲线（语义见类头）。tol 只用 perPixel（见类头）。 */
	static public function curve(frames:Array<ShotImage>, ?tol:Tolerance):Array<Int> {
		throw new haxe.Exception("not implemented");
	}
}
