package tools;

import tools.FrameScriptSurvey.FrameScriptBinding;
import tools.FrameScriptSurvey.FrameScriptOp;
import utest.Assert;

/**
 * 帧脚本清查器纯逻辑（tools.FrameScriptSurvey，issue #58 write-tests 阶段，
 * 对 stub 失败）。入口收 FrameScriptOp 流（format.abc OpCode 的镜像，构造
 * 侧真实解码器走 DumpAbcMethod.hx 先例，不在单测范围）。
 *
 * fixtures 全部取自部署 swf 的 DoABC2 字节码（容器内 format 3.7.0 逐 op
 * 导出，与 FFDec 反编译文本互证；OInt 镜像同时覆盖 OSmallInt/OIntRef 两种
 * 压帧常量形态——值同），操作码序列逐字照抄不省略——构造器四型取方法
 * 形态（OFindPropStrict+OGetProp / OGetLex / OThis+OGetProp）与多对单
 * 调用是抽取的硬分支：
 * - module/ui/main/farmui_full_v_40.swf MaoPaoFlag 构造器（FFDec 同文
 *   legacy/decompiled/farmui_full_v_40/scripts/MaoPaoFlag.as:14-18）；
 * - module/ui/main/RedUp.swf RedUp_fla.MainTimeline 构造器
 *   （legacy/decompiled/RedUp/scripts/RedUp_fla/MainTimeline.as:10-14）；
 * - module/mc/main/farmui1_v_42.swf MaoPaoFlag 构造器（同符号早版，取法
 *   为 OGetLex 直取；farmui1 的 frame1 体非空：talkInfo = ""——与
 *   farmui_full 同名符号行为分叉，登记须按 swf 版本取数据）；
 * - module/ui/main/farmui2_v_58.swf WildMaoPaoFlag 构造器（取法为
 *   OThis+OGetProp）；
 * - module/ui/main/farmui_full_v_40.swf FarmInfoPlus 构造器（单对：
 *   addFrameScript(0, frame1)，frame1 空体——src/FarmInfoPlus.hx:12-16
 *   头注同认）。
 * 方法体空体判定的 fixtures 同样逐字：FarmInfoPlus.frame1 /
 * farmui_full MaoPaoFlag.frame1（3 op 空体）、farmui1 MaoPaoFlag.frame1
 * （talkInfo = ""，6 op 实义）、MaoPaoFlag.frame24（11 op）、RedUp
 * frame134（8 op，第二个 OThis 是 this.dispatchEvent 的接收者）、
 * AddHealth.frame1（stop()，6 op）。
 */
class FrameScriptSurveyTest {
	public function new() {}

	// ---- ctorBindings：构造器 op 流 → 登记表 ----

	function test_ctor_bindings_multi_pair_farmui_full_form() {
		// farmui_full_v_40 MaoPaoFlag 构造器（MaoPaoFlag.as:14-18）：两对
		// (0,frame1)(23,frame24) 合成单次 4 实参 addFrameScript；方法取法
		// FindPropStrict+GetProp；返回值有接收（OCallProperty+OPop）。
		// 期望帧号 1 基 = 0 基实参 + 1，与 frameN 方法名 N 互证
		var ops:Array<FrameScriptOp> = [
			OThis, OScope, OThis, OConstructSuper(0),
			OFindPropStrict("addFrameScript"), OInt(0),
			OFindPropStrict("frame1"), OGetProp("frame1"), OInt(23),
			OFindPropStrict("frame24"), OGetProp("frame24"),
			OCallProp("addFrameScript", 4), OPop, ORetVoid
		];
		Assert.same(
			[{frame: 1, method: "frame1"}, {frame: 24, method: "frame24"}],
			FrameScriptSurvey.ctorBindings(ops),
			"farmui_full MaoPaoFlag：两对单调用，1 基帧号"
		);
	}

	function test_ctor_bindings_single_pair_getlex_redup() {
		// RedUp MainTimeline 构造器（MainTimeline.as:10-14）：单对
		// (133,frame134)；方法取法 OGetLex；返回值无人接收（OCallPropVoid）
		var ops:Array<FrameScriptOp> = [
			OThis, OScope, OThis, OConstructSuper(0),
			OFindPropStrict("addFrameScript"), OInt(133), OGetLex("frame134"),
			OCallPropVoid("addFrameScript", 2), ORetVoid
		];
		Assert.same(
			[{frame: 134, method: "frame134"}],
			FrameScriptSurvey.ctorBindings(ops),
			"RedUp MainTimeline：单对 OGetLex 取法"
		);
	}

	function test_ctor_bindings_multi_pair_getlex_farmui1() {
		// farmui1_v_42 MaoPaoFlag 构造器：两对合成 4 实参，方法取法 OGetLex
		// 直取（与 farmui_full 的 FindPropStrict+GetProp 同义异形——同一
		// 符号不同期编译器产物，两形都要抽得出）
		var ops:Array<FrameScriptOp> = [
			OThis, OScope, OThis, OConstructSuper(0),
			OFindPropStrict("addFrameScript"), OInt(0), OGetLex("frame1"),
			OInt(23), OGetLex("frame24"),
			OCallPropVoid("addFrameScript", 4), ORetVoid
		];
		Assert.same(
			[{frame: 1, method: "frame1"}, {frame: 24, method: "frame24"}],
			FrameScriptSurvey.ctorBindings(ops),
			"farmui1 MaoPaoFlag：两对单调用 OGetLex 取法"
		);
	}

	function test_ctor_bindings_othis_getprop_farmui2() {
		// farmui2_v_58 WildMaoPaoFlag 构造器：两对合成 4 实参，方法取法
		// OThis+OGetProp（this.frameN 实例方法引用）；第二对之前插入的
		// OThis 不得破坏配对
		var ops:Array<FrameScriptOp> = [
			OThis, OScope, OThis, OConstructSuper(0),
			OFindPropStrict("addFrameScript"), OInt(0), OThis, OGetProp("frame1"),
			OInt(23), OThis, OGetProp("frame24"),
			OCallPropVoid("addFrameScript", 4), ORetVoid
		];
		Assert.same(
			[{frame: 1, method: "frame1"}, {frame: 24, method: "frame24"}],
			FrameScriptSurvey.ctorBindings(ops),
			"farmui2 WildMaoPaoFlag：OThis+OGetProp 取法"
		);
	}

	function test_ctor_bindings_single_pair_farminfoplus() {
		// farmui_full_v_40 FarmInfoPlus 构造器：单对 (0,frame1)，
		// FindPropStrict+GetProp 取法、返回值有接收——与 MaoPaoFlag 的
		// 差别只在实参个数（2 而非 4）
		var ops:Array<FrameScriptOp> = [
			OThis, OScope, OThis, OConstructSuper(0),
			OFindPropStrict("addFrameScript"), OInt(0),
			OFindPropStrict("frame1"), OGetProp("frame1"),
			OCallProp("addFrameScript", 2), OPop, ORetVoid
		];
		Assert.same(
			[{frame: 1, method: "frame1"}],
			FrameScriptSurvey.ctorBindings(ops),
			"FarmInfoPlus：单对 2 实参"
		);
	}

	function test_ctor_without_addframescript_returns_empty() {
		// 无 addFrameScript 调用的构造器 → []（空登记是「无脚本」，与
		// 空体登记区分开——后者登记了 frameN 但体空）。形态为最小 AS3
		// 构造器（// issue #58 工具契约：无调用即无登记，不猜默认帧）
		var ops:Array<FrameScriptOp> = [
			OThis, OScope, OThis, OConstructSuper(0), ORetVoid
		];
		Assert.same([], FrameScriptSurvey.ctorBindings(ops), "无 addFrameScript 调用：无登记");
	}

	// ---- isBodyEmpty：frameN 方法体 → 空体判定 ----

	function test_empty_bodies() {
		// 3 op 空体（OThis/OScope/RetVoid）：剥壳后无行为 op
		// - farmui_full_v_40 FarmInfoPlus.frame1（DoABC2 实测；
		//   src/FarmInfoPlus.hx:12-16「空体不译」先例）
		// - farmui_full_v_40 MaoPaoFlag.frame1（DoABC2 实测；FFDec 同文
		//   MaoPaoFlag.as:20-22 空方法体）
		var farmuiEmpty:Array<FrameScriptOp> = [OThis, OScope, ORetVoid];
		Assert.isTrue(FrameScriptSurvey.isBodyEmpty(farmuiEmpty), "FarmInfoPlus.frame1 / MaoPaoFlag.frame1：3 op 空体");
	}

	function test_empty_body_ignores_debug_ops() {
		// 带调试信息（ODebug/ODebugFile/ODebugReg）的方法体仍是空体：
		// 调试 op 与行为无关（本仓素材 swf 实测无调试 op，规则面向 main
		// 等带调试信息的 ABC；// issue #58 工具契约：判空必须忽略调试 op，
		// 否则同一空体在带/不带 -debug 编译下分类漂移）
		var withDebug:Array<FrameScriptOp> = [
			OThis, OScope, ODebug("ODebugReg(\"x\",r1,line3)"),
			ODebug("ODebugFile(\"MaoPaoFlag.as\")"), ORetVoid
		];
		Assert.isTrue(FrameScriptSurvey.isBodyEmpty(withDebug), "调试 op 不算行为");
	}

	function test_meaningful_bodies() {
		// 期望值独立列写（不与实现共享判定代码）：
		// - farmui1_v_42 MaoPaoFlag.frame1：talkInfo = ""（OInitProp 实义
		//   ——置空串也是行为，DoABC2 实测 6 op；farmui_full 同名符号的
		//   frame1 是空体，两版分叉）
		// - farmui_full_v_40 AddHealth.frame1：stop()（DoABC2 实测 6 op，
		//   OFindPropStrict+OCallProperty）
		// - farmui_full_v_40 MaoPaoFlag.frame24：infoTxt.text = talkInfo;
		//   stop()（DoABC2 实测 11 op；FFDec 同文 MaoPaoFlag.as:24-28）
		// - RedUp MainTimeline.frame134：this.dispatchEvent(new Event("end"))
		//   （DoABC2 实测 8 op；FFDec 同文 MainTimeline.as:16-19）
		var rows:Array<{src:String, ops:Array<FrameScriptOp>}> = [
			{
				src: "farmui1 MaoPaoFlag.frame1：talkInfo = \"\"",
				ops: [OThis, OScope, OFindProp("talkInfo"), OStr(""), OInitProp("talkInfo"), ORetVoid]
			},
			{
				src: "AddHealth.frame1：stop()",
				ops: [OThis, OScope, OFindPropStrict("stop"), OCallProp("stop", 0), OPop, ORetVoid]
			},
			{
				src: "MaoPaoFlag.frame24：infoTxt.text = talkInfo; stop()",
				ops: [
					OThis, OScope, OFindPropStrict("infoTxt"), OGetProp("infoTxt"),
					OFindPropStrict("talkInfo"), OGetProp("talkInfo"), OSetProp("text"),
					OFindPropStrict("stop"), OCallProp("stop", 0), OPop, ORetVoid
				]
			},
			{
				src: "RedUp frame134：dispatchEvent(new Event(\"end\"))",
				ops: [
					OThis, OScope, OThis, OFindPropStrict("Event"), OStr("end"),
					OConstructProp("Event", 1), OCallPropVoid("dispatchEvent", 1), ORetVoid
				]
			}
		];
		for (r in rows) {
			Assert.isFalse(FrameScriptSurvey.isBodyEmpty(r.ops), r.src + "：实义体");
		}
	}

	function test_unmapped_op_counts_as_meaningful() {
		// 清查器不猜：解码器吐不出的 op（OOther）一律按实义——宁可误报
		// 待人工核对，不可静默漏报行为（// issue #58 工具契约）
		var ops:Array<FrameScriptOp> = [OThis, OScope, OOther("OJump"), ORetVoid];
		Assert.isFalse(FrameScriptSurvey.isBodyEmpty(ops), "未映射 op 按实义");
	}
}
