package shim;

import shim.FrameScriptCompensation.FrameScriptAction;
import utest.Assert;
import utest.Test;

/**
 * issue #58 清查批次 2 的登记表注入自检：tools/FrameScriptAudit 扫出的
 * 实义帧脚本里，凡符号已在移植代码里构造（SymbolClass.bind 可达）的都进
 * 了 shim/FrameScriptCompensation 的登记表——删掉任何一行，本文件对应断言
 * 变红。期望值逐条出自 legacy（反编译 .as 或 ABC 清查 op 流，出处写在各
 * 表行上方）；本文件不碰显示层行为（attach/run 的运行时正确性由 CI 的
 * web-build/web-smoke 与画面比对负责）。
 *
 * 未登记的实义项（处置归 PR 报告）：farmui1_v_42 全族与 help.swf（牧场
 * 批次，现无消费点）、farmui2 的 wild 系（CursorWild/WildMaoPaoFlag/
 * Wild_Animal_*）、Fertilizer 的 CursorTool21..33 与 farmui_full 的
 * AddAnimation/lock_mc_46（符号 shim 未建，getMaterial 恒 null 或为时间轴
 * 子件显式 gotoAndStop 驱动）。
 */
class FrameScriptCompensationInUseTest extends Test {
	/**
	 * 登记表期望：libraryId、symbolKey、frame、actions 逐条钉死。
	 * 出处（legacy/decompiled/<swf>/scripts/<类>.as 或 tools/FrameScriptAudit
	 * 输出）；消费点是 2026-11-24 的移植代码现状，行号随改动漂移以类为准。
	 */
	function testInUseEntries():Void {
		// ---- farmui_full_v_40（legacy/decompiled/farmui_full_v_40/scripts/）----
		// AddHealth.as:15-19：addFrameScript(0,frame1)；frame1 = stop()。
		// 消费点 common/view/floating/AddHealthAnimation（getMaterial）
		assertEntry("farmui_full_v_40", "AddHealth", [
			{frame: 1, actions: [Stop]}
		]);
		// CursorArrow.as:15-25：addFrameScript(0,frame1,1,frame2)；两帧各
		// stop()。消费点 module/FarmStage 光标注册表
		assertEntry("farmui_full_v_40", "CursorArrow", [
			{frame: 1, actions: [Stop]},
			{frame: 2, actions: [Stop]}
		]);
		// CursorHand.as:15-19；frame1 = stop()
		assertEntry("farmui_full_v_40", "CursorHand", [
			{frame: 1, actions: [Stop]}
		]);
		// CursorHoe.as:15-19；frame1 = stop()
		assertEntry("farmui_full_v_40", "CursorHoe", [
			{frame: 1, actions: [Stop]}
		]);
		// CursorHook.as:15-19；frame1 = stop()
		assertEntry("farmui_full_v_40", "CursorHook", [
			{frame: 1, actions: [Stop]}
		]);
		// CursorInsect.as:15-19；frame1 = stop()
		assertEntry("farmui_full_v_40", "CursorInsect", [
			{frame: 1, actions: [Stop]}
		]);
		// CursorOneClickHand.as:15-19；frame1 = stop()
		assertEntry("farmui_full_v_40", "CursorOneClickHand", [
			{frame: 1, actions: [Stop]}
		]);
		// CursorPesticide.as:15-19；frame1 = stop()
		assertEntry("farmui_full_v_40", "CursorPesticide", [
			{frame: 1, actions: [Stop]}
		]);
		// CursorWater.as:15-19；frame1 = stop()
		assertEntry("farmui_full_v_40", "CursorWater", [
			{frame: 1, actions: [Stop]}
		]);
		// CursorWeed.as:15-19；frame1 = stop()
		assertEntry("farmui_full_v_40", "CursorWeed", [
			{frame: 1, actions: [Stop]}
		]);
		// FarmLoading.as:15-21：addFrameScript(47,frame48)；frame48 =
		// gotoAndPlay("loop")（标签在帧 23，dump_swf.php sprite#680）。消费点
		// module/water/ModuleWater、module/water/WaterPool
		assertEntry("farmui_full_v_40", "FarmLoading", [
			{frame: 48, actions: [GotoAndPlay("loop")]}
		]);
		// GiftIcon.as:15-21：addFrameScript(41,frame42)；frame42 =
		// gotoAndPlay("GiftMove")（标签在帧 3，dump_swf.php sprite#76）。消费点
		// module/uitools/widgets/ShortcutBar
		assertEntry("farmui_full_v_40", "GiftIcon", [
			{frame: 42, actions: [GotoAndPlay("GiftMove")]}
		]);
		// PackageTab.as:26-58：三帧各挂两个按钮的 CLICK（闭包 gotoAndStop(N)
		// + dispatchEvent(new Event(页签串))——事件串与 MyBagView 监听的
		// Consts.MSG_SWITCH_TO_SEED/TOOL/FISH 同值）+ stop()。消费点
		// module/warehouse/bag/MyBagView.createButtons
		assertEntry("farmui_full_v_40", "PackageTab", [
			{
				frame: 1,
				actions: [
					AddClickListener("btnTool", [GotoAndStop(2), DispatchEvent("tool")]),
					AddClickListener("btnFish", [GotoAndStop(3), DispatchEvent("fish")]),
					Stop
				]
			},
			{
				frame: 2,
				actions: [
					AddClickListener("btnSeed", [GotoAndStop(1), DispatchEvent("seed")]),
					AddClickListener("btnFish", [GotoAndStop(3), DispatchEvent("fish")]),
					Stop
				]
			},
			{
				frame: 3,
				actions: [
					AddClickListener("btnSeed", [GotoAndStop(1), DispatchEvent("seed")]),
					AddClickListener("btnTool", [GotoAndStop(2), DispatchEvent("tool")]),
					Stop
				]
			}
		]);
		// SellLockIcon.as:15-19；frame1 = stop()（帧 1 标签 "lock"，
		// dump_swf.php sprite#536）。消费点 warehouse/house/widgets/
		// PlantRenderItem、FishRenderItem
		assertEntry("farmui_full_v_40", "SellLockIcon", [
			{frame: 1, actions: [Stop]}
		]);

		// ---- farmui2_v_58（未反编译；tools/FrameScriptAudit 的 ABC 清查
		// op 流为出处，swf-code-baseline.json 把 farmui2 帧脚本族归 #58）----
		// 构造器 addFrameScript(0, frame1)；frame1 = stop()。消费点
		// common/view/floating/AddMoneyFloating（AddExpFloating 继承）
		assertEntry("farmui2_v_58", "AddAnimationEx", [
			{frame: 1, actions: [Stop]}
		]);
		// 构造器 addFrameScript(299, frame300)；frame300 = stop()。消费点
		// module/uitools/UIController.showNewIconTip
		assertEntry("farmui2_v_58", "newIconTip", [
			{frame: 300, actions: [Stop]}
		]);

		// ---- lite_ui_v_0（legacy/decompiled/lite_ui_v_0/scripts/）----
		// CursorHand_Lite.as:15-19；frame1 = stop()。消费点
		// module/lite/FarmLiteView
		assertEntry("lite_ui_v_0", "CursorHand_Lite", [
			{frame: 1, actions: [Stop]}
		]);
		// FarmLoading_Lite.as:13-21：addFrameScript(47,frame48)；frame48 =
		// gotoAndPlay("loop")（标签在帧 23，dump_swf.php sprite#9）。消费点
		// module/lite/FarmLiteView
		assertEntry("lite_ui_v_0", "FarmLoading_Lite", [
			{frame: 48, actions: [GotoAndPlay("loop")]}
		]);

		// ---- Fertilizer_v_7（legacy/decompiled/Fertilizer_v_7/scripts/）----
		// FishFoodEffect.as:13-25：addFrameScript(14,frame15)；frame15 =
		// stop(); if (parent != null) parent.removeChild(this)。消费点
		// module/water/FishMover.playFeedEffect
		assertEntry("Fertilizer_v_7", "FishFoodEffect", [
			{frame: 15, actions: [Stop, RemoveSelf]}
		]);
		// Cursor_FishFood_1.as..4.as：addFrameScript(0,frame1)；frame1 =
		// stop()。消费点 common/view/cursor/CursorTool（鱼食分支）
		assertEntry("Fertilizer_v_7", "Cursor_FishFood_1", [
			{frame: 1, actions: [Stop]}
		]);
		assertEntry("Fertilizer_v_7", "Cursor_FishFood_2", [
			{frame: 1, actions: [Stop]}
		]);
		assertEntry("Fertilizer_v_7", "Cursor_FishFood_3", [
			{frame: 1, actions: [Stop]}
		]);
		assertEntry("Fertilizer_v_7", "Cursor_FishFood_4", [
			{frame: 1, actions: [Stop]}
		]);

		// ---- water_ui_v_0（legacy/decompiled/water_ui_v_0/scripts/）----
		// CursorFishNet.as:13-19 / CursorFishNetAll.as 同款；frame1 =
		// stop()。消费点 module/FarmStage、module/water/WaterController
		assertEntry("water_ui_v_0", "CursorFishNet", [
			{frame: 1, actions: [Stop]}
		]);
		assertEntry("water_ui_v_0", "CursorFishNetAll", [
			{frame: 1, actions: [Stop]}
		]);
		// FishWave_0.as..3.as:15：addFrameScript(14,frame15)；frame15 =
		// if (parent != null) parent.removeChild(this)。消费点
		// module/water/WaterPool.showWaterFlower
		assertEntry("water_ui_v_0", "FishWave_0", [
			{frame: 15, actions: [RemoveSelf]}
		]);
		assertEntry("water_ui_v_0", "FishWave_1", [
			{frame: 15, actions: [RemoveSelf]}
		]);
		assertEntry("water_ui_v_0", "FishWave_2", [
			{frame: 15, actions: [RemoveSelf]}
		]);
		assertEntry("water_ui_v_0", "FishWave_3", [
			{frame: 15, actions: [RemoveSelf]}
		]);
	}

	/** in-use 批次不含的键仍返回 []（farmui2 wild 系未接线，见类头注）。 */
	function testWildFamilyNotRegistered():Void {
		Assert.same([], FrameScriptCompensation.entriesFor("farmui2_v_58", "CursorWild"));
		Assert.same([], FrameScriptCompensation.entriesFor("farmui2_v_58", "WildMaoPaoFlag"));
		Assert.same([], FrameScriptCompensation.entriesFor("Fertilizer_v_7", "CursorTool21"));
		Assert.same([], FrameScriptCompensation.entriesFor("farmui_full_v_40", "AddAnimation"));
	}

	/** 表行 → 期望（frame 升序 + actions 深比较，删行/改帧/改动作全红）。 */
	private function assertEntry(libraryId:String, symbolKey:String, expected:Array<{frame:Int, actions:Array<FrameScriptAction>}>) {
		var got = FrameScriptCompensation.entriesFor(libraryId, symbolKey);
		Assert.equals(expected.length, got.length, '$libraryId:$symbolKey 条数');
		for (i in 0...expected.length) {
			Assert.equals(expected[i].frame, got[i].frame, '$libraryId:$symbolKey 第 $i 条帧号');
			Assert.same(expected[i].actions, got[i].actions, '$libraryId:$symbolKey 第 $i 条动作');
		}
	}
}
