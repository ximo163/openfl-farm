package tools;

/**
 * T3 时间轴行为对拍门禁（issue #56）的共享数据契约：期望侧（swf 结构静态
 * 提取）、实跑侧（openfl 探针记录）、比对报告三方的纯数据形状。
 *
 * 行为规格是 openfl-farm-docs docs/plan/verification.md「动画与特效怎么验」
 * 第 1 节（时间轴行为比对）——序列项四件：每步后 currentFrame（抓不动/
 * 跳帧/倒放/提前 stop）、帧标签命中序列、循环次数与终点、帧事件（帧脚本/
 * addFrameScript 回调）。verification.md 本体在容器外（docs 仓库不可达），
 * 引文以 issue #56 转述为准；键名契约（原版没有的工具）出处 // issue #56。
 *
 * 本模块必须同时编进三条工具链：test.hxml（-cp test）、format 结构提取器
 * （-cp tools -lib format）、node 探针/比对 CLI（-cp tools -lib swf -lib
 * openfl -lib lime，StepAnimate 同款）——所以只依赖 haxe 标准库。
 */

/** 期望侧帧标签表条目。frame 为 1 基帧号（SWF FrameLabel / DefineSceneAndFrameLabelData 语义）。 */
typedef LabelEntry = {
	frame:Int,
	name:String,
};

/** 期望侧多帧剪辑的规格（issue #56「期望侧提取器」的输出项：帧数、标签表、是否主轴；scriptFrames 供盲区标注）。 */
typedef ClipSpec = {
	/** 比对两侧的对齐键：主时间轴 ""（StepAnimate「空串=根」先例）；SymbolClass/ExportAssets 导出名；无导出名 "#<charId>" */
	key:String,
	isMain:Bool,
	frames:Int,
	labels:Array<LabelEntry>,
	/** 本层 DoAction/DoABC 出现帧（1 基）。非空 = 帧事件项盲区（降级标注） */
	scriptFrames:Array<Int>,
};

typedef AssetSpec = {
	asset:String,
	clips:Array<ClipSpec>,
};

/** 期望侧帧标签命中：step 为 1 基步号（第几步后），frame 为命中时的 currentFrame。 */
typedef LabelHit = {
	step:Int,
	frame:Int,
	name:String,
};

/** 循环次数与终点（序列项三）：loops = floor(steps/frames)（回到第 1 帧的次数），endFrame = (steps%frames)+1。 */
typedef LoopEnd = {
	loops:Int,
	endFrame:Int,
};

/** 实跑侧记录里的帧标签命中（探针按步记录；frame 可由期望侧推导，不重复记）。 */
typedef StepName = {
	step:Int,
	name:String,
};

/** 实跑侧记录的帧事件（帧脚本/addFrameScript 回调触发）。 */
typedef StepFrame = {
	step:Int,
	frame:Int,
};

/** 探针对单个剪辑的实跑记录（记录 JSON 的 clips[] 条目形状；labels/frameEvents 可缺省 = 空）。 */
typedef ActualClip = {
	key:String,
	/** 每步后的 currentFrame（序列项一） */
	frames:Array<Int>,
	labels:Array<StepName>,
	loops:Int,
	endFrame:Int,
	frameEvents:Array<StepFrame>,
};

typedef ProbeRecord = {
	asset:String,
	steps:Int,
	clips:Array<ActualClip>,
};

/** 单项跑偏。item ∈ {steps, clipMissing, clipExtra, currentFrame, labelHits, loops, endFrame, frameEvents}；无步长语义的项 step=0。 */
typedef Mismatch = {
	item:String,
	step:Int,
	detail:String,
};

/** 单剪辑比对结果。downgraded = 帧事件项盲区（scriptFrames 非空）——不判红也不算无异常通过，报告里逐条标注。 */
typedef ClipReport = {
	key:String,
	pass:Bool,
	downgraded:Bool,
	downgradeReason:String,
	mismatches:Array<Mismatch>,
	/** 降级剪辑照录的 openfl 侧帧事件（issue #56「只能记 openfl 侧行为」） */
	frameEvents:Array<StepFrame>,
};

typedef GateReport = {
	asset:String,
	steps:Int,
	pass:Bool,
	/** 帧事件盲区剪辑数 */
	downgraded:Int,
	clips:Array<ClipReport>,
	/** 资产级跑偏（目前仅 steps：探针步数 != 期望侧派生步数） */
	mismatches:Array<Mismatch>,
};
