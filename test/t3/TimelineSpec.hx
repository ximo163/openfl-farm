package t3;

import haxe.Json;
import tools.TimelineTypes.AssetSpec;
import tools.TimelineTypes.ClipSpec;
import tools.TimelineTypes.LabelEntry;
import tools.TimelineTypes.LabelHit;
import tools.TimelineTypes.LoopEnd;

/**
 * T3 时间轴行为对拍——期望侧：swf 结构 → 期望序列（issue #56）。
 *
 * 为什么在 test/t3/ 而不是 test/tools/TimelineSpec.hx（write-tests 留的
 * stub）里实现：test/** 是 append-only（orchestrator 规则，attempt 1 在此
 * 被驳回——原地填 stub 属于改既有文件）；stub 类路径 tools.TimelineSpec 被
 * 它占死又不能动，实现只能换模块路径。测试（不可改）在 package tools 里
 * 用未限定名 TimelineSpec/Diff 调用——靠 test/tools/import.hx 的默认
 * import（`import t3.TimelineSpec;` 等）把它们解析到本包：Haxe 的名字解析
 * import 优先于同包类型（容器 haxe 4.3.6 --interp 实测），stub 文件保持
 * 原样、不再被编译加载。契约出处不变：test/tools/TimelineSpecTest.hx 钉死。
 *
 * 输入是「结构 JSON」：format 库读 swf 的提取器（tools/tools/TimelineExtract.hx）
 * 逐资产产出的纯数据（键名 // issue #56；与
 * test/fixtures/timeline-fish01-structure.json 同构）。
 * 提取器注意：format 3.7.0 的 Reader 在 a6291_1.swf（清单第 8 行）上抛 Eof
 * （PlaceObject3 className，Reader.hx:961），69 个清单资产只能读 68 个——
 * 提取器对该件要么自带标签走查（dump_swf.php 同款，零依赖），要么单点容
 * 错跳过并记录（本片走前者：TimelineExtract 的 via=raw fallback）。
 *
 * 结构 JSON 形状：
 *   { "asset": "<assets/legacy-assets.txt 相对路径>",
 *     "clips": [ {
 *         "id": 23,             // DefineSprite char id；主时间轴为 null
 *         "symbol": "FS_01_0_2", // SymbolClass/ExportAssets 绑定名；无绑定为 null
 *         "isMain": false,       // 是否主时间轴
 *         "frames": 8,           // 本层 ShowFrame 计数
 *         "labels": [ {"frame":3,"name":"..."} ], // 1 基；可缺省 = 无
 *         "scriptFrames": [1]    // 本层 DoAction/DoABC 帧位（1 基）；可缺省 = 无
 *       } ] ] }
 *
 * 剪辑键（比对两侧的对齐键）：主时间轴 → ""（tools/StepAnimate.hx:17
 * 「空串=根」先例）；有导出名 → symbol；无导出名 → "#<id>"（char id）。
 *
 * 推进契约（钉死；出处 tools/StepAnimate.hx:79 根剪辑、:107-113 stopTree
 * 整树先冻结在第 1 帧、:116-129 stepTree 每步每剪辑 gotoAndStop((currentFrame
 * % totalFrames) + 1) 后记录，issue #56「固定步长推进（StepAnimate 复用）」）：
 * 第 s 步（1 基）后 currentFrame = (s % frames) + 1；完成圈数 loops =
 * floor(steps / frames)（回到第 1 帧的次数）；终点 endFrame =
 * (steps % frames) + 1。固定步长推进不读帧率（step 模式与 fps 无关，
 * 12fps 的 redUpBanner_v_2 与 24fps 的 fish_01 同一公式）。
 *
 * 只做纯逻辑：不读文件、不碰显示对象——结构 JSON 由调用方（提取器 CLI/
 * 测试）传入。单帧剪辑不产生比对单元（StepAnimate.hx:122 的 totalFrames>1
 * 门同款，由 multiFrameClips 落实）。
 *
 * 编进两条链（tools.TimelineTypes.hx 类头「三条工具链」约束）：test.hxml
 * （-cp test，经 test/tools/import.hx 被 *Test 引用）与探针 CLI（-cp tools
 * -cp test，tools/TimelineProbe.hx 显式 import t3.TimelineSpec）。
 */
class TimelineSpec {
	/** 结构 JSON → AssetSpec。labels/scriptFrames 缺省补 []；clips 顺序保持
	 * swf 里的出现顺序（dump 顺序），主时间轴条目照收（是否参与比对由
	 * multiFrameClips 决定）。 */
	static public function parseAssetStructure(json:String):AssetSpec {
		// 结构 JSON 的键名契约 // issue #56（类头「结构 JSON 形状」）；labels/
		// scriptFrames 缺省 = []（fixture 里 FS_01_1_2 等整体省略）
		var d:Dynamic = Json.parse(json);
		var rows:Array<Dynamic> = d.clips != null ? d.clips : [];
		var clips:Array<ClipSpec> = [];
		for (row in rows) {
			var id:Dynamic = Reflect.field(row, "id");
			var symbol:Dynamic = Reflect.field(row, "symbol");
			var isMain:Bool = row.isMain;
			var key = isMain ? "" : (symbol != null ? symbol : "#" + id);
			var labels:Array<LabelEntry> = [];
			var labelRows:Array<Dynamic> = Reflect.field(row, "labels");
			if (labelRows != null) {
				for (l in labelRows) labels.push({frame: Std.int(l.frame), name: l.name});
			}
			var scriptFrames:Array<Int> = [];
			var scriptRows:Array<Dynamic> = Reflect.field(row, "scriptFrames");
			if (scriptRows != null) {
				for (sf in scriptRows) scriptFrames.push(Std.int(sf));
			}
			clips.push({key: key, isMain: isMain, frames: Std.int(row.frames), labels: labels, scriptFrames: scriptFrames});
		}
		return {asset: d.asset, clips: clips};
	}

	/** 多帧剪辑（frames > 1）。单帧剪辑（主轴或子剪辑）不产生比对单元。 */
	static public function multiFrameClips(a:AssetSpec):Array<ClipSpec> {
		var out:Array<ClipSpec> = [];
		for (c in a.clips) {
			if (c.frames > 1) out.push(c);
		}
		return out;
	}

	/** 推进步数：多帧剪辑的最大帧数（每个剪辑至少走满一圈，末步恰回到第 1 帧）；
	 * 无多帧剪辑的资产返回 0（探针/比对都无事可做）。 */
	static public function stepsFor(a:AssetSpec):Int {
		var max = 0;
		for (c in multiFrameClips(a)) {
			if (c.frames > max) max = c.frames;
		}
		return max;
	}

	/** 期望的每步后 currentFrame 序列（序列项一）：第 s 步（1 基）后
	 * (s % frames) + 1。steps <= 0 返回 []。 */
	static public function frameSequence(c:ClipSpec, steps:Int):Array<Int> {
		if (steps <= 0) return [];
		var seq:Array<Int> = [];
		for (s in 1...steps + 1) {
			seq.push((s % c.frames) + 1);
		}
		return seq;
	}

	/** 期望的帧标签命中序列（序列项二）：按步序，第 s 步落在带标签的帧上即
	 * 命中（currentLabel 变为该名）；同帧多标签按 labels 表顺序（防御性
	 * 规则——清单 12 个带标签资产的标签都在相异帧，此分支无实测用例）。
	 * 标签来源 tag43 与 tag86 并收（运行侧 haxelib swf 3.4.0 两路都进
	 * frameIndexes；清单内 tag86 帧标签段全空，实测标签均出自 tag43）。 */
	static public function labelHits(c:ClipSpec, steps:Int):Array<LabelHit> {
		var hits:Array<LabelHit> = [];
		if (steps <= 0) return hits;
		for (s in 1...steps + 1) {
			var frame = (s % c.frames) + 1;
			for (l in c.labels) {
				if (l.frame == frame) hits.push({step: s, frame: frame, name: l.name});
			}
		}
		return hits;
	}

	/** 期望的循环次数与终点（序列项三）。 */
	static public function loopEnd(c:ClipSpec, steps:Int):LoopEnd {
		if (c.frames <= 0) return {loops: 0, endFrame: 1};
		return {loops: Std.int(steps / c.frames), endFrame: (steps % c.frames) + 1};
	}
}
