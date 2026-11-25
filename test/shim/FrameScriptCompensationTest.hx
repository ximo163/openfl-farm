package shim;

import shim.FrameScriptCompensation.FrameScriptAction;
import utest.Assert;

/**
 * 帧脚本补偿登记表（shim.FrameScriptCompensation，issue #58 write-tests
 * 阶段，对 stub 失败）。只测纯查表逻辑：登记键、帧号、动作序列。
 * 接线（SymbolClass.afterAttach / LocalSwfLoader 之后调
 * MovieClip.addFrameScript）是显示层行为，不在单测里证明——那由
 * CI web-build/web-smoke 与画面比对负责（CLAUDE.md 测试规则）。
 *
 * 注入自检语义：issue 的验收标准是「人为去掉一处补偿，haxe test.hxml
 * 必须变红」。本用例就是那条门：删掉表里 MaoPaoFlag 或 RedUp 任一登记
 * （或改帧号/动作），下方对应断言直接红，不需要另写注入脚本。
 *
 * 期望值出处（帧归属以字节码为准，纠正既有 PORT-NOTE，见类尾注意）：
 * - farmui_full_v_40 / MaoPaoFlag（气泡符号，char 符号名 MaoPaoFlag）：
 *   legacy/deploy/QFarmFlash/source/core/module/ui/main/farmui_full_v_40.swf
 *   DoABC2 类 MaoPaoFlag 构造器 addFrameScript(0, frame1, 23, frame24)
 *   （FFDec 同文 legacy/decompiled/farmui_full_v_40/scripts/MaoPaoFlag.as:17）。
 *   frame1 体空（OThis/OScope/RetVoid）→ 空体不登记；frame24 体 =
 *   infoTxt.text = talkInfo; stop()（MaoPaoFlag.as:24-28；字节码 11 op：
 *   GetProp(infoTxt) ← GetProp(talkInfo) SetProp(text) + CallProperty
 *   (stop,0)）。→ 唯一登记在帧 24（1 基 = 实参 23 + 1），动作序照字节码
 *   （赋值在前 stop 在后）。调用方：LandTalkTag → MaoPaoFlag 走
 *   gotoAndPlay 播到 24 帧时文本落上、停住。
 * - RedUp / 主时间轴（升级动画）：legacy/deploy/QFarmFlash/source/core/
 *   module/ui/main/RedUp.swf DoABC2 类 RedUp_fla.MainTimeline 构造器
 *   addFrameScript(133, frame134)（FFDec 同文 legacy/decompiled/RedUp/
 *   scripts/RedUp_fla/MainTimeline.as:13）；frame134 体 =
 *   this.dispatchEvent(new Event("end"))（MainTimeline.as:16-19；字节码
 *   ConstructProperty(Event,1) + CallPropVoid(dispatchEvent,1)）。主轴
 *   共 134 帧（legacy/decompiled/RedUp/header.txt:12 frameCount=134）→
 *   末帧自报 "end"。加载链：nc_data.php:37 secondList {"id":"redup",
 *   "src":"$url/module/ui/main/RedUp.swf"} → FarmLandController.as:576-623
 *   onPlayUpgradeRedLandAnim getSecondUrl("redup") → LocalSwfLoader
 *   （根时间轴，symbolKey 空串）→ FarmLandsView.as:613 监听 "end"
 *   收尾清场。
 * - 空体/无关键 → []：FarmInfoPlus（farmui_full_v_40 同 swf，构造器只有
 *   addFrameScript(0, frame1) 且 frame1 体空——DoABC2 实测，
 *   src/FarmInfoPlus.hx:12-16 头注同认）；TalkBoxHe1（该 swf 全部
 *   DoABC2 类里无此名、全 swf 无 frameN 方法——容器内 format 3.7.0 全量
 *   扫描实测，见 issue #58 清查）；不存在的库/符号键。
 * - 收获动画（第三例）：nc_data.php assets 表引用的
 *   Crop_158/168/334_movie.swf（nc_data.php:2567/:2615/:3212 的 asset
 *   3476/3942/4729，分别挂在 :6171/:6181/:6301 三个 isAnimation:1 作物
 *   的 "h" 槽）不在部署包内（legacy/deploy 全树 find 查无），字节码
 *   无从提取，本表无法为其登记——收尾目前依赖已译的 IO_ERROR → close
 *   路径（src/common/view/floating/HarvestAnimationCustom.hx onComplete/
 *   onIOError）。此处不虚造登记（原版行为推不出，不自行设计）；
 *   DispatchEvent 原语已覆盖同族机制，资产入库后按字节码补表即可。
 */
class FrameScriptCompensationTest {
	public function new() {}

	function test_maopao_flag_bubble_text_at_frame_24() {
		// MaoPaoFlag.as:17 addFrameScript(0,frame1,23,frame24)：frame1 空体
		// 不译，唯一登记帧 24（1 基 = 0 基实参 23 + 1，与方法名 frame24 的
		// N 互证）
		var entries = FrameScriptCompensation.entriesFor("farmui_full_v_40", "MaoPaoFlag");
		Assert.equals(1, entries.length, "MaoPaoFlag 只登记 frame24（frame1 空体不译）");
		var e = entries[0];
		Assert.equals("farmui_full_v_40", e.libraryId, "登记键回显库 id");
		Assert.equals("MaoPaoFlag", e.symbolKey, "登记键回显符号名");
		Assert.equals(24, e.frame, "帧号 1 基：addFrameScript 实参 23 + 1");
		// frame24 体（MaoPaoFlag.as:24-28）：赋值在前、stop 在后
		Assert.same(
			[SetText("infoTxt", "talkInfo"), Stop],
			e.actions,
			"frame24：infoTxt.text = talkInfo; stop()"
		);
	}

	function test_maopao_flag_frame1_empty_body_not_registered() {
		// MaoPaoFlag.frame1 体空（OThis/OScope/RetVoid，DoABC2 实测；
		// MaoPaoFlag.as:20-22 空方法）——空体不登记（FarmInfoPlus 先例，
		// src/FarmInfoPlus.hx:12-16）
		var entries = FrameScriptCompensation.entriesFor("farmui_full_v_40", "MaoPaoFlag");
		var frame1 = [for (e in entries) if (e.frame == 1) e];
		Assert.equals(0, frame1.length, "frame1 空体：不产生登记");
	}

	function test_redup_main_timeline_dispatches_end_at_last_frame() {
		// RedUp.swf 主时间轴（symbolKey 空串 = 根）：addFrameScript(133,
		// frame134)（MainTimeline.as:13）→ 登记帧 134（= 133 + 1，主轴
		// frameCount=134 的末帧，header.txt:12）；frame134 体 =
		// dispatchEvent(new Event("end"))（MainTimeline.as:16-19）
		var entries = FrameScriptCompensation.entriesFor("RedUp", "");
		Assert.equals(1, entries.length, "RedUp 主轴只登记 frame134");
		var e = entries[0];
		Assert.equals("RedUp", e.libraryId, "登记键回显库 id");
		Assert.equals("", e.symbolKey, "主时间轴符号键为空串");
		Assert.equals(134, e.frame, "帧号 1 基：addFrameScript 实参 133 + 1，恰为末帧");
		Assert.same([DispatchEvent("end")], e.actions, "frame134：dispatchEvent(new Event(\"end\"))");
	}

	function test_unregistered_symbols_have_no_entries() {
		// 空体键（FarmInfoPlus frame1 空，DoABC2 实测）、无帧脚本符号
		// （TalkBoxHe1——farmui_full_v_40 全 swf 无此帧脚本类）、未知库/符号
		// 一律 []：登记表不虚造
		Assert.same(
			[],
			FrameScriptCompensation.entriesFor("farmui_full_v_40", "FarmInfoPlus"),
			"FarmInfoPlus frame1 空体：无登记"
		);
		Assert.same(
			[],
			FrameScriptCompensation.entriesFor("farmui_full_v_40", "TalkBoxHe1"),
			"TalkBoxHe1 无帧脚本：无登记"
		);
		Assert.same(
			[],
			FrameScriptCompensation.entriesFor("NoSuchLibrary_v_9", "MaoPaoFlag"),
			"未知库：无登记"
		);
		Assert.same(
			[],
			FrameScriptCompensation.entriesFor("farmui_full_v_40", "NoSuchSymbol"),
			"未知符号：无登记"
		);
	}
}
