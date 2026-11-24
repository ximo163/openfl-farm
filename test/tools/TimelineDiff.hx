package tools;

import tools.TimelineTypes.ActualClip;
import tools.TimelineTypes.AssetSpec;
import tools.TimelineTypes.ClipReport;
import tools.TimelineTypes.GateReport;
import tools.TimelineTypes.LabelHit;
import tools.TimelineTypes.Mismatch;
import tools.TimelineTypes.ProbeRecord;
import tools.TimelineTypes.StepFrame;
import tools.TimelineTypes.StepName;

/**
 * T3 时间轴行为对拍——比对器：期望侧（TimelineSpec 从 swf 结构派生）vs
 * 实跑侧（探针记录 JSON）逐项 diff，产出结构化报告（issue #56；write-tests
 * 阶段为 stub，契约由 test/tools/TimelineDiffTest.hx 钉死）。
 *
 * 实跑记录 JSON（探针按此产出；与 test/fixtures/timeline-fish01-probe.json
 * 同构；labels/frameEvents 可缺省 = 空）：
 *
 *   { "asset": "<同结构 JSON 的 asset>",
 *     "steps": 8,
 *     "clips": [ { "key": "FS_01_0_2",
 *                  "frames": [2,3,4,5,6,7,8,1],   // 每步后 currentFrame
 *                  "labels": [ {"step":3,"name":"..."} ],
 *                  "loops": 1, "endFrame": 1,
 *                  "frameEvents": [ {"step":2,"frame":2} ] } ] }
 *
 * 判定语义（序列项四件逐项独立判红，跑偏定位到「哪个符号哪一步哪一项」）：
 *   - steps：记录的 steps != TimelineSpec.stepsFor(期望) → 资产级 mismatch
 *     （item "steps"，step=0），其余项仍尽力比对。
 *   - 剪辑对齐：按 key（主时间轴 ""/导出名/"#<charId>"）。期望有记录无 →
 *     item "clipMissing"；记录有期望无（含单帧剪辑被记录）→ item "clipExtra"
 *     （两者 step=0，只报存在性不比对内容）。
 *   - currentFrame：与 frameSequence 逐位相等；序列长度不等也是本项红。
 *     首个不等处的步号（1 基）与期望/实测值进 detail。
 *   - labelHits：期望命中序列（TimelineSpec.labelHits 的 {step,name}）与
 *     实测逐位相等，首个不等处（期望漏命中/实测多出）的 step 进 detail。
 *   - loops / endFrame：数值分别比对（独立判红，可单独注入跑偏），step=0。
 *   - frameEvents：期望侧没有原版 AS3 帧脚本可执行（issue #56 盲区；swf
 *     3.4.0 FrameScriptParser.convertToJS 只对有类绑定的符号做 AVM2→JS，
 *     AnimateTimeline.hx:102-130 非 js 目标直接丢弃 scriptSource）——
 *       · scriptFrames 为空的剪辑：swf 里本无帧脚本，期望帧事件为空，
 *         实测非空 → item "frameEvents" 判红（step=首个事件的步号）；
 *       · scriptFrames 非空的剪辑：帧事件项无法期望 → 不判红也不静默放
 *         行：ClipReport.downgraded = true（降级标注），实测事件照录进
 *         ClipReport.frameEvents（「只能记 openfl 侧行为，报告里降级标注
 *         而不是假绿」），计入 GateReport.downgraded。
 *   - pass = 资产级 mismatches 为空 且 所有剪辑无任何 mismatch（降级不
 *     翻红、也不算 mismatch）。
 *
 * render 输出人读报告：每条跑偏一行，含资产、符号 key、item、步号
 * （「第N步」，无步长项不带）、期望/实测值；降级剪辑逐条带「降级」行。
 * 只做纯逻辑：JSON 字符串进、报告出，不读文件不碰显示对象。
 */
class TimelineDiff {
	/** 探针记录 JSON → ProbeRecord（labels/frameEvents 缺省补 []）。 */
	static public function parseRecord(json:String):ProbeRecord {
		// 记录 JSON 键名契约 // issue #56（类头「实跑记录 JSON」）；labels/
		// frameEvents 缺省 = []（fixture 同构）
		var d:Dynamic = haxe.Json.parse(json);
		var rows:Array<Dynamic> = d.clips != null ? d.clips : [];
		var clips:Array<ActualClip> = [];
		for (row in rows) {
			var frames:Array<Int> = [];
			var frameRows:Array<Dynamic> = Reflect.field(row, "frames");
			if (frameRows != null) {
				for (f in frameRows) frames.push(Std.int(f));
			}
			var labels:Array<StepName> = [];
			var labelRows:Array<Dynamic> = Reflect.field(row, "labels");
			if (labelRows != null) {
				for (l in labelRows) labels.push({step: Std.int(l.step), name: l.name});
			}
			var events:Array<StepFrame> = [];
			var eventRows:Array<Dynamic> = Reflect.field(row, "frameEvents");
			if (eventRows != null) {
				for (e in eventRows) events.push({step: Std.int(e.step), frame: Std.int(e.frame)});
			}
			var loops:Dynamic = Reflect.field(row, "loops");
			var endFrame:Dynamic = Reflect.field(row, "endFrame");
			clips.push({
				key: row.key,
				frames: frames,
				labels: labels,
				loops: loops == null ? 0 : Std.int(loops),
				endFrame: endFrame == null ? 0 : Std.int(endFrame),
				frameEvents: events
			});
		}
		var steps:Dynamic = d.steps;
		return {asset: d.asset, steps: steps == null ? 0 : Std.int(steps), clips: clips};
	}

	/** 期望（结构派生）vs 实跑记录 JSON → 门禁报告。steps 取
	 * TimelineSpec.stepsFor(期望)；只比 multiFrameClips(期望)。 */
	static public function compare(expected:AssetSpec, recordJson:String):GateReport {
		var record = parseRecord(recordJson);
		var steps = TimelineSpec.stepsFor(expected);
		var assetMismatches:Array<Mismatch> = [];
		// steps：探针步数 != 期望侧派生步数 → 资产级红，其余项仍尽力比对
		if (record.steps != steps) {
			assetMismatches.push({item: "steps", step: 0, detail: "期望 " + steps + " 步，实测 " + record.steps + " 步"});
		}

		var multi = TimelineSpec.multiFrameClips(expected);
		var expectedKeys = new Map<String, Bool>();
		for (c in multi) expectedKeys.set(c.key, true);
		var recByKey = new Map<String, ActualClip>();
		for (r in record.clips) recByKey.set(r.key, r);

		var clipReports:Array<ClipReport> = [];
		var downgradedCount = 0;

		for (c in multi) {
			var rec = recByKey.get(c.key);
			if (rec == null) {
				clipReports.push({
					key: c.key,
					pass: false,
					downgraded: false,
					downgradeReason: "",
					mismatches: [{item: "clipMissing", step: 0, detail: "期望存在（" + c.frames + " 帧），记录缺失"}],
					frameEvents: []
				});
				continue;
			}

			var mismatches:Array<Mismatch> = [];

			// currentFrame：逐位相等；长度不等也是本项红（首偏差处定位）
			var expSeq = TimelineSpec.frameSequence(c, steps);
			var actSeq = rec.frames;
			var curIdx = firstIndexDiffInt(expSeq, actSeq);
			if (curIdx >= 0) {
				var expVal = curIdx < expSeq.length ? Std.string(expSeq[curIdx]) : "序列提前结束（长度 " + expSeq.length + "）";
				var actVal = curIdx < actSeq.length ? Std.string(actSeq[curIdx]) : "序列提前结束（长度 " + actSeq.length + "）";
				mismatches.push({item: "currentFrame", step: curIdx + 1, detail: "期望 " + expVal + "，实测 " + actVal});
			}

			// labelHits：期望命中序列 vs 实测逐位（step+name 都相等才算同位）
			var expHits = TimelineSpec.labelHits(c, steps);
			var actHits = rec.labels;
			var hitIdx = firstIndexDiffLabel(expHits, actHits);
			if (hitIdx >= 0) {
				var step = hitIdx < expHits.length ? expHits[hitIdx].step : (hitIdx < actHits.length ? actHits[hitIdx].step : 0);
				var expVal = hitIdx < expHits.length ? "第" + expHits[hitIdx].step + "步命中 \"" + expHits[hitIdx].name + "\"" : "无命中";
				var actVal = hitIdx < actHits.length ? "第" + actHits[hitIdx].step + "步命中 \"" + actHits[hitIdx].name + "\"" : "无命中";
				mismatches.push({item: "labelHits", step: step, detail: "期望 " + expVal + "，实测 " + actVal});
			}

			// loops / endFrame：独立判红（可单独注入跑偏）
			var le = TimelineSpec.loopEnd(c, steps);
			if (rec.loops != le.loops) {
				mismatches.push({item: "loops", step: 0, detail: "期望 " + le.loops + "，实测 " + rec.loops});
			}
			if (rec.endFrame != le.endFrame) {
				mismatches.push({item: "endFrame", step: 0, detail: "期望 " + le.endFrame + "，实测 " + rec.endFrame});
			}

			// frameEvents：盲区降级（不判红、非假绿）vs 无脚本凭空触发判红
			var downgraded = c.scriptFrames.length > 0;
			var reportEvents:Array<StepFrame> = [];
			var reason = "";
			if (downgraded) {
				reason = "scriptFrames=" + c.scriptFrames + "（无原版 AS3 帧脚本可执行，issue #56 盲区）——openfl 侧行为只能照录";
				reportEvents = rec.frameEvents;
			} else if (rec.frameEvents.length > 0) {
				var ev = rec.frameEvents[0];
				mismatches.push({
					item: "frameEvents",
					step: ev.step,
					detail: "期望无帧事件（scriptFrames 空），实测第 " + ev.step + " 步触发 frame " + ev.frame
				});
			}

			clipReports.push({
				key: c.key,
				pass: mismatches.length == 0,
				downgraded: downgraded,
				downgradeReason: reason,
				mismatches: mismatches,
				frameEvents: reportEvents
			});
			if (downgraded) downgradedCount++;
		}

		// 记录有、期望无（含单帧剪辑被记录）→ clipExtra，只报存在性
		for (r in record.clips) {
			if (!expectedKeys.exists(r.key)) {
				clipReports.push({
					key: r.key,
					pass: false,
					downgraded: false,
					downgradeReason: "",
					mismatches: [{item: "clipExtra", step: 0, detail: "期望无此多帧剪辑，记录多出"}],
					frameEvents: []
				});
			}
		}

		var pass = assetMismatches.length == 0;
		for (cr in clipReports) {
			if (!cr.pass) pass = false;
		}
		return {asset: expected.asset, steps: steps, pass: pass, downgraded: downgradedCount, clips: clipReports, mismatches: assetMismatches};
	}

	/** 报告 → 多行文本（PR/issue 评论贴的大报告由此拼）。 */
	static public function render(r:GateReport):String {
		var lines:Array<String> = [];
		lines.push("资产 " + r.asset + "：" + (r.pass ? "通过" : "红") + "（steps=" + r.steps + "，剪辑 "
			+ r.clips.length + " 个，降级 " + r.downgraded + " 个）");
		for (m in r.mismatches) {
			lines.push("跑偏 asset=" + r.asset + " item=" + m.item + stepTag(m.step) + " " + m.detail);
		}
		for (c in r.clips) {
			for (m in c.mismatches) {
				lines.push("跑偏 asset=" + r.asset + " clip=" + c.key + " item=" + m.item + stepTag(m.step) + " " + m.detail);
			}
			if (c.downgraded) {
				var events = "";
				if (c.frameEvents.length > 0) {
					events = "；实测帧事件照录：";
					for (ev in c.frameEvents) events += "第" + ev.step + "步 frame" + ev.frame + " ";
				} else {
					events = "；实测帧事件 0 条";
				}
				lines.push("降级 asset=" + r.asset + " clip=" + c.key + " item=frameEvents " + c.downgradeReason + events);
			}
		}
		return lines.join("\n");
	}

	/** 「第N步」标签：无步长语义的项（step=0）不带。 */
	static function stepTag(step:Int):String {
		return step > 0 ? " 第" + step + "步" : "";
	}

	/** 首个不等下标：值不等，或一侧提前结束（长度不等）。无跑偏返回 -1。 */
	static function firstIndexDiffInt(exp:Array<Int>, act:Array<Int>):Int {
		var len = exp.length < act.length ? exp.length : act.length;
		for (i in 0...len) {
			if (exp[i] != act[i]) return i;
		}
		if (exp.length != act.length) return len;
		return -1;
	}

	/** labelHits 的逐位比较：同位的 step 与 name 都相等才算相等。 */
	static function firstIndexDiffLabel(exp:Array<LabelHit>, act:Array<StepName>):Int {
		var len = exp.length < act.length ? exp.length : act.length;
		for (i in 0...len) {
			if (exp[i].step != act[i].step || exp[i].name != act[i].name) return i;
		}
		if (exp.length != act.length) return len;
		return -1;
	}
}
