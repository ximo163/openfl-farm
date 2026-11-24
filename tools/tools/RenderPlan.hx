package tools;

import tools.RenderTypes.ShotPlan;
import tools.TimelineTypes.ClipSpec;

/**
 * T2 资产渲染对拍——拍点计划（issue #57）。静态关键帧拍点（gotoAndStop 起点帧 +
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
		// 起点恒在；标签帧即使与起点同帧也只记一条（id 进基线键，序必须确定）
		var frames = [1];
		if (clip.labels != null) {
			for (label in clip.labels) {
				frames.push(label.frame);
			}
		}
		frames.sort(function(a, b) return a - b);
		var out:Array<ShotPlan> = [];
		var prev = -1;
		for (f in frames) {
			if (f == prev) continue;
			prev = f;
			out.push({id: "f" + f, kind: "f", index: f});
		}
		return out;
	}

	/** 播放抽帧拍点（0 基步号，升序去重）：必抽 {0（起点）、
	 * floor(frames/2)（中间，落帧 floor(frames/2)+1）、每个 s%frames==0
	 * 且 s>0 的回绕步} ∪ {k 的非负倍数 ≤ steps}，全域 [0, steps]。
	 * steps 为本次推进的总步数（T3 stepsFor 语义，资产级最大帧数）。
	 * clip.frames <= 1 或 steps <= 0 返回 []（无播放可比）。k < 1 时抛
	 * haxe.Exception 且消息含 "k"（配置错先于数据形状报，不被单帧门吞掉）。 */
	static public function playbackShots(clip:ClipSpec, steps:Int, k:Int):Array<ShotPlan> {
		if (k < 1) {
			throw new haxe.Exception('播放抽帧间隔 k 非法: k=${k}（须 ≥ 1）');
		}
		var frames = clip.frames;
		if (frames <= 1 || steps <= 0) {
			return [];
		}
		var set = new Map<Int, Bool>();
		set.set(0, true); // 起点（冻结首帧）
		var mid = Math.floor(frames / 2);
		if (mid <= steps) set.set(mid, true); // 中间（域内必抽，域外不虚造）
		var wrap = frames; // s%frames==0 且 s>0：回绕步，直到 steps 为止
		while (wrap <= steps) {
			set.set(wrap, true);
			wrap += frames;
		}
		var grid = 0; // k 的非负倍数
		while (grid <= steps) {
			set.set(grid, true);
			grid += k;
		}
		var list = [for (s in set.keys()) s];
		list.sort(function(a, b) return a - b);
		return [for (s in list) {id: "s" + s, kind: "s", index: s}];
	}
}
