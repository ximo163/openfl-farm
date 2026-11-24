package tools;

/**
 * T2 资产渲染对拍门禁（issue #57）的共享数据契约：截图图像、容差、单张
 * 比对结果、拍点计划、基线条目/文档与自回归门禁报告的纯数据形状。
 *
 * 行为规格是 openfl-farm-docs docs/plan/verification.md「动画与特效怎么验」
 * 的截图部分（静态帧对拍 + 第 2 节「播放中的抽帧」）——docs 仓库在容器外
 * 不可达（github.com/ximo163/openfl-farm-docs 实测 404，#56 同因），引文以
 * issue #57 转述为准；键名契约（原版没有的工具）出处 // issue #57。
 *
 * 位置约定（#56 教训的「stub 归树」规矩）：本组类型与 T2 的对拍器/哈希/
 * 拍点/基线类同住 tools/tools/（包 tools）——它们是被测的「验证基建」，
 * 完工后就在这里被 implement 原地填充（tools/ 对 implement 不是
 * append-only；T3 的 TimelineTypes 落 test/ 是 write-tests 阶段布局所迫，
 * 不再沿用）。本模块必须同时编进两条链：test.hxml（-cp tools）与 T2 探针
 * /CLI（-cp tools -cp test -lib swf -lib openfl -lib lime，T3 TimelineGate
 * 同款编译线）——所以只依赖 haxe 标准库。
 */

/** 截图图像（纯数据，不含显示对象）：RGBA 字节序（每像素 R,G,B,A 四字节、
 * 行优先、值 0..255）。探针侧把 canvas 像素整理成这个形状再进比对/哈希。 */
typedef ShotImage = {
	width:Int,
	height:Int,
	pixels:Array<Int>,
};

/** 像素容差（缺省逐字段 0 = 逐字节严格，自回归基线抓「没变」的缺省立场）：
 * perPixel = 单像素四通道最大差的容忍上限（≤ 容忍、> 记差异）；ratio =
 * 差异像素占比的通过上限（≤ 通过）。字段可只给部分（缺者按 0）——容差是
 * 显式参数，html5 抗锯齿/预乘噪声经 perPixel 吸收，不做透明像素等通道
 * 特例。 */
typedef Tolerance = {
	?perPixel:Int,
	?ratio:Float,
};

/** 单张像素 diff 结果。maxDelta = 全图最差像素的四通道最大差（含被容忍的，
 * 报告量级用）。sizeMismatch=true 时像素统计不可比：differing/total=0、
 * ratio=0.0、maxDelta=-1（哨兵值；静态目标上 null 不能当 Int）。 */
typedef ShotDiff = {
	pass:Bool,
	sizeMismatch:Bool,
	differing:Int,
	total:Int,
	ratio:Float,
	maxDelta:Int,
};

/** 单个拍点（一个要截图的时刻）。id 是基线键的稳定组分：
 * "f<帧号>"（静态关键帧，index 为 1 基帧号）/"s<步号>"（播放抽帧，index
 * 为 0 基步号——步 s 的画面 = 固定步长推进 s 步后，s=0 即冻结起点、
 * s=frames 即播放头回绕到第 1 帧之后，StepAnimate.hx:79 的步进式）。 */
typedef ShotPlan = {
	id:String,
	/** "f" = gotoAndStop 静态帧 | "s" = play 状态播放中抽帧 */
	kind:String,
	index:Int,
};

/** 基线条目：图像内容哈希（RenderHash.imageHash 的输出）+ 尺寸。自回归
 * （source="self"）与保真对拍（source="references"，legacy/references 采集
 * 重建）两来源同形——换源只是重建基线的图像来源不同（issue #57 换源口）。 */
typedef BaselineEntry = {
	hash:String,
	width:Int,
	height:Int,
};

/** 基线文档（基线文件的 JSON 形状，生成/重建命令的产物）：
 * { "source": "self"|"references", "entries": { "<拍点键>": BaselineEntry } }。
 * source 只记来源供人读；比对逻辑不按它分支（两来源条目同形同判）。 */
typedef BaselineDoc = {
	source:String,
	entries:Map<String, BaselineEntry>,
};

/** 本次实拍的单拍点：key 为 BaselineDoc.shotKey 式拍点键，image 为截图。 */
typedef CurrentShot = {
	key:String,
	image:ShotImage,
};

/** 单拍点比对结局（聚合报告的输入）。missing = 基线缺该拍点（红：新冒出
 * 的渲染面）；extra = 基线有而本次没拍到（红：渲染面消失/拍点漂移）；
 * 缺的一侧哈希为 ""。 */
typedef ShotOutcome = {
	key:String,
	pass:Bool,
	missing:Bool,
	extra:Bool,
	baselineHash:String,
	currentHash:String,
};

/** 自回归门禁总报告：哪些拍点超容差/缺/多（issue #57「聚合报告（哪些
 * 符号哪些帧超容差）」——符号与帧都在 key 里）。pass = 三类计数全 0。
 * 播放抽帧的补间/嵌套错位只能靠像素变化暴露，落点也在此报告的 key 上。 */
typedef RenderReport = {
	pass:Bool,
	failed:Int,
	missing:Int,
	extra:Int,
	shots:Array<ShotOutcome>,
};
