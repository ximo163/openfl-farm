package tools;

/**
 * issue #94 T2/T3 门禁接线——CI wrapper 的判定纯逻辑（write-tests 阶段
 * stub，契约由 test/tools/CiGatesVerdictTest.hx 钉死，implement 原地填充）。
 * 被测类只判两闸退出码与报告文本，不起进程、不读文件、不碰真实时间——
 * 跑双闸、读报告、两闸 `--self-check` 的 CI 同跑（或省略理由）、web.yml
 * 的接线全归 wrapper 脚本半边（implement 阶段交付；.github/ 人管线由人）。
 *
 * 为什么存在：T2/T3 的机器件（tools/RenderGate.mjs、tools/TimelineGate.mjs
 * 及探针）已并入 main 但**零调用**——渲染/时间轴跑偏的 PR 今天照常自动合并
 * （// issue #94 背景）。接线后 web-build 的门禁步须满足三件 bash 里最难读
 * 对的事，判定本体提到这里用 eval 单测钉死，脚本只剩进程编排（#64 的
 * BootSmokeVerdict 同款分层）：
 *
 *   1. 退出码分流（// issue #94 要什么 2）：两闸的退出码契约是 0 全过 /
 *      1 有红或有错 / 2 基建坏（探针编译失败/缺基线——tools/RenderGate.mjs
 *      :29-30、tools/TimelineGate.mjs:23）。1 与 2 都判 CI 红；2 的行里标注
 *      「gate 基建问题非渲染回归」（先修基建，别去查渲染回归）。未声明的
 *      非零码（node 崩溃/被信号杀，bash $? 呈 137/139 形态）不在契约里：
 *      闸没按契约说话＝闸自己坏了，归基建侧不归回归侧。
 *   2. 两闸独立不拖累（// issue #94 要什么 1 尾）：一个闸红/基建坏不得把
 *      另一个闸的结果埋掉——`A && B` 短路就埋掉了，所以摘要恒两闸在场。
 *      基建坏的闸**不读报告红行**：两闸的 exit(2) 位点都在报告落盘之前
 *      （tools/RenderGate.mjs:52/:69/:87/:166/:205/:211/:233 vs 落盘
 *      :280-281；tools/TimelineGate.mjs:53/:72 vs :167-168），盘上只可能是
 *      上一轮的陈旧报告——吐出来就是把旧红冒充本轮结果。
 *   3. 红≠一律修的裁决流（// issue #94 要什么 3 + 完成标准）：已裁决登记
 *      的偏差候选照打进步日志（带登记理由——豁免不是静默放行）但不判
 *      CI 红；未登记的红照红。登记表在 tools.GateExemptions
 *      （farmui1_v_42 先例）。
 *
 * judge 判定语义（行为由测试逐条钉死）：
 *   - pass = 两闸都不基建坏 且 无未豁免的定位行（比对红行 + 资产错误行）。
 *     退出码 1 但定位行全部对上登记的，照绿——「CI 实跑两闸全量对拍
 *     出绿」的机器面就在这条（farmui1_v_42 的红已按裁决流登记豁免）。
 *   - exitCode：0 绿；1 CI 红。红/错/基建坏都失败，不透传 2——CI 只认
 *     红绿，基建坏靠行里的标注说清。
 *   - 定位行提取只对非基建坏的闸做；报告里有红行而退出码说绿的（闸内
 *     不一致）也照红——退出码的绿不遮报告的红。
 *   - 退出码 1 但报告里提取不出任何定位行的照红——豁免只对「看得见、
 *     对得上登记」的红生效；看不见的红当绿等于给报告丢失开静默后门。
 *   - 错误行（`资产 …：错误——…`）不可豁免：错误是闸的执行失败（探针
 *     没跑成/清单外资产），不是比对偏差候选。
 *   - 豁免匹配按登记条目的 (gate, asset) 整串：gate 不符不豁、资产键
 *     （assets/legacy-assets.txt 的清单路径）不整串相等不豁——basename
 *     同形的别目录资产、子串命中都不算。
 *   - lines（step 日志块，wrapper 原样 echo）：恒含两闸状态行（闸名 +
 *      退出码 + 报告路径 export/timeline-gate/report.txt、
 *      export/render-gate/report.txt——两闸 --out 缺省，
 *      tools/TimelineGate.mjs:37、tools/RenderGate.mjs:48）；未豁免/
 *      豁免的定位行逐字进块；基建坏带标注；降级行、通过资产行、统计
 *      头行不进块——step 日志是定位面不是大报告转储（聚合报告在
 *      export/ 下，// issue #94 要什么 1）。
 */
class CiGatesVerdict {
	/** 闸退出码 → 三态（契约见类头 1）。 */
	static public function classifyExit(exit:Int):GateStatus {
		throw new haxe.Exception("not implemented");
	}

	/** T2 报告文本 → 判红定位行：拍点键红行（`红 <asset>|<symbol>|<shotId>
	 * ：<原因>`——tools/tools/RenderDiff.hx:98/:100/:102，行形由
	 * test/tools/RenderDiffTest.hx:179-184 钉死）与资产错误行（`资产
	 * <asset>：错误——<detail>`——tools/RenderGate.mjs:266）。统计头/
	 * 红资产行/通过资产段不是定位行。原序原样，单行不截断。 */
	static public function renderRedLines(report:String):Array<String> {
		throw new haxe.Exception("not implemented");
	}

	/** T3 报告文本 → 判红定位行：跑偏行（`跑偏 asset=<asset> [clip=<key>]
	 * item=<item> [第N步] <期望/实测>`——test/t3/TimelineDiff.hx:221/:225，
	 * 行形由 test/tools/TimelineDiffTest.hx 钉死）与资产错误行
	 * （tools/TimelineGate.mjs:156）。降级行（t3.TimelineDiff.hx:235）是
	 * 盲区的诚实标注不是红（handbook/architecture/timeline-gate.md 判定
	 * 语义节），资产头行/统计行不进。原序原样，单行不截断。 */
	static public function timelineRedLines(report:String):Array<String> {
		throw new haxe.Exception("not implemented");
	}

	/** 双闸结果 → CI 判定 + step 日志块（判定语义见类头）。timeline 在前
	 * ——接线命令行的跑序（`node tools/TimelineGate.mjs && node
	 * tools/RenderGate.mjs`，// issue #94 要什么 1）。exemptions 传
	 * tools.GateExemptions.registered（判式不绑死登记表本体，测试可注入
	 * 合成条目）。 */
	static public function judge(timelineExit:Int, timelineReport:String, renderExit:Int, renderReport:String,
			exemptions:Array<GateExemption>):GateRunVerdict {
		throw new haxe.Exception("not implemented");
	}
}

/** 闸退出码的三态：绿（0）/ 红·错（1）/ 基建坏（2 与未声明非零）。 */
enum GateStatus {
	Green;
	Red;
	Infra;
}

/** 豁免条目归属的闸（登记按闸生效——T2/T3 各自的偏差候选互不代管）。 */
enum GateKind {
	Render;
	Timeline;
}

/** 已裁决登记的偏差候选（「红≠一律修」裁决流的机器面）。 */
typedef GateExemption = {
	/** 归属闸。 */
	var gate:GateKind;

	/** 资产键：assets/legacy-assets.txt 的清单路径整串（报告里 asset= 的
	 * 原串形态，test/fixtures/timeline-fish01-probe.json 同构）。 */
	var asset:String;

	/** 裁决记录：技术根因 + 状态——step 日志原样带出，复审的人从日志就能
	 * 追到「为什么豁免」。 */
	var reason:String;
};

/** judge 的判定结果。 */
typedef GateRunVerdict = {
	/** CI 绿：两闸都不基建坏、定位行里没有未豁免项。 */
	var pass:Bool;

	/** 0 绿；1 CI 红（红/错/基建坏都失败，不透传 2——见类头）。 */
	var exitCode:Int;

	/** step 日志块（契约见类头 lines 节）。 */
	var lines:Array<String>;
};
