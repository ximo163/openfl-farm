package tools;

import tools.RenderTypes.ShotPlan;
import tools.TimelineTypes.ClipSpec;

/**
 * T2 资产渲染对拍——拍点计划（issue #57；write-tests 阶段为 stub，契约由
 * test/tools/RenderPlanTest.hx 钉死）。静态关键帧拍点（gotoAndStop 起点帧 +
 * 各标签帧）与播放抽帧拍点（每隔 k 步 + 起点/中间/回绕必抽）的纯推导。
 *
 * 输入是 T3 的结构侧 ClipSpec（tools.TimelineTypes——swf 结构静态提取的
 * 帧数/标签表，帧数出处 dump_swf.php 实测，见 TimelineSpecTest 类头）：T2
 * 复用 T3 的子剪辑枚举与固定步长推进（issue #57 依赖说明），拍点在同一个
 * ClipSpec 世界里推导，不另造结构。
 *
 * 步号语义与 T3 一致（tools/StepAnimate.hx:79 步进式）：第 s 步（0 基）后
 * currentFrame = (s % frames) + 1；s=0 为冻结起点，s=frames 恰为回绕到第 1
 * 帧之后（「循环回绕帧」拍点）。单帧剪辑不产生播放拍点（StepAnimate.hx:122
 * 的 totalFrames>1 门同款）。
 */
class RenderPlan {
	/** 静态关键帧拍点：起点帧（gotoAndStop(1)）+ 各标签帧，升序去重。
	 * 单帧剪辑也返回起点帧（issue #57「逐符号截图」覆盖单帧符号——
	 * help 的 pageN 一族就是单帧带脚本符号）。标签帧与起点同帧时去重。
	 * 标签表乱序输入也输出升序（基线键稳定）。 */
	static public function staticShots(clip:ClipSpec):Array<ShotPlan> {
		throw new haxe.Exception("not implemented");
	}

	/** 播放抽帧拍点（0 基步号，升序去重）：必抽 {0（起点）、
	 * floor(frames/2)（中间，落帧 floor(frames/2)+1）、每个 s%frames==0
	 * 且 s>0 的回绕步} ∪ {k 的非负倍数 ≤ steps}，全域 [0, steps]。
	 * steps 为本次推进的总步数（T3 stepsFor 语义，资产级最大帧数）。
	 * clip.frames <= 1 或 steps <= 0 返回 []（无播放可比）。k < 1 时抛
	 * haxe.Exception 且消息含 "k"（配置错先于数据形状报，不被单帧门吞掉）。 */
	static public function playbackShots(clip:ClipSpec, steps:Int, k:Int):Array<ShotPlan> {
		throw new haxe.Exception("not implemented");
	}
}
