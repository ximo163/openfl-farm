package tools;

/**
 * issue #95：swf-inventory 再生成对账门的判式纯逻辑（write-tests 阶段为
 * stub，契约由 test/tools/SwfInventoryReconcileTest.hx 钉死，implement
 * 原地填充）。
 *
 * 为什么这门存在：#83 完成标准原文「『死了无人察觉』不再可能」——
 * scripts/swf-inventory.py 的再生成回路里手写增补（code/triage/…）任何
 * 一块消失都必须当场红，而不是靠事后人肉对 diff。#95 行动项 2：「checks/
 * 加一条（或并入 tools/swf_code_audit.py 口径）——再生成前后手写键集合
 * 对账，任何已登记手写块消失即红」。scripts/、checks/ 是人管路径，对账
 * 判式与 runner 归 tools/（#95「runner 随接线同做，不拆」），本类是判式
 * 单源（#63 教训：不在 python/bash 半边留第二份拷贝）。
 *
 * 职责边界：本类只做 JSON 文本进 → 对账结果出的纯逻辑（不读文件、不走
 * 目录、不读真实时间、不起进程）。三个纯逻辑面：
 *
 * 1) reconcile(oldText, newText) —— 再生成前后手写键集合对账。手写键判
 *    定与 SwfInventoryMerge 同规则（条目键集减机器键闭集 MACHINE_KEYS，
 *    判式单源只在那里有一份，本类引用它的 isHandwrittenKey 不复制闭集）。
 *    对账单元是 (path, 手写键名) 二元组：旧文件里每个带手写键的条目贡献
 *    一组；新文件侧同 path 条目须带同名手写键才算存活。报告缺口三态：
 *    - missing_entry：旧条目在新清单里整体消失（swf 被删/改名——条目增
 *      删是机器面、生成器权威，但已登记手写块随条目消失同样是「死了」，
 *      对账门照红：要么 swf 真删了该先清手写登记，要么是事故）；
 *    - missing_key：条目还在、手写键没了（399a5faa 同型事故的裸暴露面，
 *      生成器接线漏跑 merge 就会产出这个形态）；
 *    - altered：键还在但值变了（逐字比对值子串——手写块被人手正当更新
 *      时新旧文件本就同值；merge 搬运逐字，值变了只能是绕开判式的手改
 *      或腐化）。值比对按 JSON 语义比（parse 后深比），不比原文子串—
 *      —手写块在旧文件里的缩进形态不该影响对账。
 *
 * 2) reconcileLive(text) —— 单文件自检形态：#95 行动项 2 的「或并入」裁
 *    决空间——对账门跑在再生成回路时喂再生成前后两份（reconcile），跑在
 *    常规 CI/收工自检时只有现文件一份：此时对账基线是「文件内部自洽」
 *    ——每条带手写键的条目，手写键的值必须是合法 JSON 且非 null，且
 *    path 在文件内唯一（重复 path 会让 merge 的配对键失锚）。返回与
 *    reconcile 同构的报告（kind 用 selfcheck_invalid_value /
 *    selfcheck_duplicate_path）。这个形态防的是「手写块登记本身腐化」，
 *    不替代再生成前后对账。
 *
 * 3) workflowKeepsHandwritten(workflowText, scriptText) —— 生成器接线的
 *    静态对账（#95 行动项 1 的机器化）：legacy-decompile.yml 与
 *    swf-inventory.py 两份文本进，判「再生成回路确实过了 merge」：
 *    - 脚本侧：swf-inventory.py 不再是 json.dump 直写 --out 的形态（裸奔
 *      面：#95 背景「CI legacy-decompile.yml:55 仍直接 python3
 *      scripts/swf-inventory.py（:115-117 从零全量 json.dump 重写）」）
 *      ——接线后生成产物必须先落临时文件、merge 之后才是 spec 路径。判式
 *      不要求逐字读 diff，只查脚本文本里 merge 接线证据（调用
 *      SwfInventoryMergeRun 的痕迹）且 json.dump 的落盘对象不是 --out 直
 *      指形态；
 *    - 工作流侧：legacy-decompile.yml 的生成资产清单步之后、提交步之前
 *      存在 haxe 调 tools.SwfInventoryMergeRun 的运行步（#95 原文给出的
 *      接线形态：「legacy-decompile.yml 补装 haxe 调 haxe -cp tools
 *      --run tools.tools.SwfInventoryMergeRun」——haxe 命令行里模块名
 *      的写法以仓库既有 runner 先例 tools.TestStubScanRun 为准，即
 *      tools.SwfInventoryMergeRun）。
 *    返回缺口清单（哪一侧缺什么证据），空清单 = 接线在。文本级判式——
 *    不解析 yaml/python AST，按行匹配（判式是门禁不是编译器；人管路径
 *    的文本形态稳定，匹配串写死在判式里，脚本/工作流改形态时同改这里，
 *    #63 判式单源同款约束）。
 *
 * 报告形状：ReconcileResult { pass:Bool, gaps:Array<ReconcileGap> }，
 * ReconcileGap { path:String, key:String, kind:String }（kind 取值
 * missing_entry / missing_key / altered / selfcheck_invalid_value /
 * selfcheck_duplicate_path；workflow 对账的 path 键位放证据载体名
 * "scripts/swf-inventory.py" / ".github/workflows/legacy-decompile.yml"，
 * key 位放缺的证据串，kind 用 wiring_missing）。reportLine 单行形态
 * `reconcile <kind> <path> <key>`（机读分拣面，与 SwfInventoryMerge.
 * reportLine 的 `keep <path> <键>` 互补——keep 行说保住了什么，
 * reconcile 行说没保住什么）。
 */
class SwfInventoryReconcile {
	/** 再生成前后对账（契约见类头 1）。oldText 形状不符（不是合法 JSON/
	 * 顶层无 swfs 数组）时按空手写面处理（与 SwfInventoryMerge 同语义—
	 * —旧文件损坏不阻塞再生成，首次生成旧文件本就不存在）；newText 形状
	 * 不符抛异常（新文件是生成器产出，坏了不得静默绿）。 */
	static public function reconcile(oldText:String, newText:String):ReconcileResult {
		throw new haxe.Exception("not implemented");
	}

	/** 单文件自检（契约见类头 2）。text 形状不符抛异常——自检喂的是仓内
	 * 现文件，它坏了就是事故，没有「视为空」的宽免。 */
	static public function reconcileLive(text:String):ReconcileResult {
		throw new haxe.Exception("not implemented");
	}

	/** 生成器接线静态对账（契约见类头 3）。两份文本任一为空串/null 即全
	 * 缺（文件读不到 = 接线不可能在）。 */
	static public function workflowKeepsHandwritten(workflowText:String, scriptText:String):ReconcileResult {
		throw new haxe.Exception("not implemented");
	}

	/** 报告行（机读分拣面）：`reconcile <kind> <path> <key>`。 */
	static public function reportLine(gap:ReconcileGap):String {
		throw new haxe.Exception("not implemented");
	}
}

/** 对账结果：pass = gaps 为空。gaps 排序确定（path 字典序、同 path 按
 * key 字典序、再按 kind）——输出是机读分拣面，顺序不稳就没法 diff。 */
typedef ReconcileResult = {
	pass:Bool,
	gaps:Array<ReconcileGap>
};

/** 单条缺口：path/key/kind 语义见类头。 */
typedef ReconcileGap = {
	path:String,
	key:String,
	kind:String
};
