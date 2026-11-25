package tools;

import tools.RenderTypes.ShotDiff;

/**
 * T1b 场景视觉对拍（issue #59）的共享数据契约：检查点视觉拍法、连拍能量
 * 曲线与两级判定的纯数据形状。
 *
 * 行为规格是 openfl-farm-docs docs/plan/verification.md「场景连拍与运动能量
 * 曲线」节（交互瞬间同频率连拍、两级判定 = 逐张容差 diff + 运动能量曲线，
 * 「原版在动、移植版冻住」立刻分叉）——docs 仓库容器外不可达
 * （github.com/ximo163/openfl-farm-docs 实测 404，#56 同因），引文以
 * issue #59 转述为准；键名契约（原版没有的工具）出处 // issue #59。
 *
 * 位置约定（#56 教训的「stub 归树」规矩）：与 T2 的 RenderTypes/PixelDiff
 * 等同住 tools/tools/（包 tools）——它们是被测的「验证基建」，完工后在
 * 这里被 implement 原地填充（tools/ 对 implement 不是 append-only）。本
 * 模块必须同时编进两条链：test.hxml（-cp tools）与视觉探针/CLI（#57
 * RenderGate 同款 -cp tools -cp test -lib openfl -lib lime 编译线）——所以
 * 只依赖 haxe 标准库与本包 RenderTypes（ShotDiff 复用 #57 的单张判定
 * 结果形状，ShotImage/Tolerance 同源）。
 *
 * 两侧同构（沿 T1 的「场景声明 = 判定输入，基线记录 = 判定输出」契约，
 * // issue #59）：场景侧 checkpoint 携带 screenshot/burst 键（SceneShotPlan
 * 解析成 ShotSpec）；记录侧同形携带拍法 + 连拍帧 + 能量曲线（帧数 =
 * count、曲线点数 = count-1，对齐门 SceneShotDiff.recordMatches）。
 */

/** 检查点视觉拍法（场景声明 checkpoint 的 screenshot/burst 键解析结果）：
 * kind "screenshot"（单张）时 intervalMs 恒 0、count 恒 1；kind "burst"
 * （连拍）时 intervalMs ≥ 1 为同频率连拍间隔（毫秒）、count ≥ 2 为张数
 * （能量曲线至少要一个相邻对）。场景声明未写视觉键 = screenshot（未声明
 * 的默认单张，// issue #59——既有场景不加键也在视觉门里，加 burst 键
 * 算加严）。 */
typedef ShotSpec = {
	kind:String,
	intervalMs:Int,
	count:Int,
};

/** 场景级逐步拍法（SceneShotPlan.specsOfScenario 的输出）：step 为场景
 * steps[i].name，按步序排列——报告定位「哪个检查点」靠它。 */
typedef StepSpec = {
	step:String,
	spec:ShotSpec,
};

/** 能量曲线（判定输出侧的核心形状）：相邻帧变化像素数的时间序列，长度 =
 * 帧数 - 1（tools.MotionEnergy.curve 的输出）。连拍记录两侧同构地带它——
 * 两份记录的曲线 diff 不需要像素（跨侧/diff 模式没有帧数据也能判「动没
 * 动」，// issue #59）。 */
typedef EnergyCurve = Array<Int>;

/** 曲线 diff 结果（tools.SceneShotDiff.diffCurves 的输出）：pass = 等长且
 * 逐点 |Δ| ≤ tol（边界含）。lengthMismatch=true 时不可比：maxDelta/
 * divergedAt 为 -1 哨兵（静态目标上 null 不能当 Int，#57 ShotDiff 的
 * maxDelta=-1 同款）。divergedAt = 首个超容差点下标（-1 = 无）——报告
 * 定位「曲线从第几点分叉」。 */
typedef CurveDiff = {
	pass:Bool,
	lengthMismatch:Bool,
	maxDelta:Int,
	divergedAt:Int,
};

/** 连拍两级判定结果（tools.SceneShotDiff.compareBurst 的输出）。第一级
 * frames = 逐张 PixelDiff（帧号对齐：同频率连拍的下标即时间对齐，基线 i
 * 比 实拍 i）；第二级 curve = 两侧能量曲线 diff。pass = 全帧 pass 且
 * curve.pass。帧数不齐时帧比公共前缀、曲线按长度不齐判红（哨兵），拍点
 * 数的对齐由记录侧 SceneShotDiff.recordMatches 钉——比对器不做静默对齐
 * 假绿。 */
typedef BurstDiff = {
	pass:Bool,
	/** 第一级逐张结果（下标 = 帧号，与连拍序一致；ShotDiff 为 #57
	 * RenderTypes 的单张判定结果形状，复用不另造）。 */
	frames:Array<ShotDiff>,
	/** 第一级红张数（frames 里 pass=false 的个数）。 */
	frameFails:Int,
	/** 第二级：基线侧能量曲线（如实携带，报告与记录输出用）。 */
	curveBaseline:Array<Int>,
	/** 第二级：实拍侧能量曲线。 */
	curveCurrent:Array<Int>,
	/** 第二级：两侧曲线 diff 的结局。 */
	curve:CurveDiff,
};
