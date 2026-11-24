package shim;

import openfl.display.InteractiveObject;
import openfl.display.MovieClip;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.text.TextField;

// PORT-NOTE: issue #58 帧脚本补偿登记表（契约由 test/shim/
// FrameScriptCompensationTest.hx 钉死）。为什么需要这层胶水：原版素材 swf 的符号关联类在
// 构造器里 addFrameScript(帧0基, frameN) 登记帧脚本，播放头到达该帧时执行
// frameN 方法体（MaoPaoFlag 的 infoTxt.text = talkInfo; stop()、RedUp 主轴
// 的 dispatchEvent(new Event("end"))）。openfl 侧资产经 swf haxelib 转换后
// 这些脚本不生效：只有 SymbolClass 绑定的符号才带 scriptSource
// （FrameScriptParser 转的 JS），且只在 html5 目标 eval、在 Haxe 实例上跑
// 不动（动态属性缺失，异常被 Log 吞）；非 js 目标整体丢弃（swf 3.4.0
// AnimateLibraryExporter/AnimateTimeline，容器内 /usr/local/lib/haxelib/
// swf/3,4,0 实测）。结果即 issue 列的已知三例：气泡文本不出现、升级动画
// 不自报 "end"、收获动画收不了尾；清查器（tools/FrameScriptAudit，#58）
// 又扫出同病一族——光标帧 1 不 stop（播放头越帧）、加载环 48 帧不回跳
// "loop"、GiftIcon 不进 "GiftMove" 循环、水花/喂食特效 15 帧不自摘、
// PackageTab 页签帧脚本不挂按钮监听（背包页签切换整链死）、newIconTip
// 不定住——登记表按符号逐条收录（消费点见各条注释）。
//
// 补偿方式遵守符号 shim 惯例（src/FarmInfoPlus.hx / handbook/architecture/
// assets.md）：不改被翻译类的原调用形态（LandTalkTag 照旧 gotoAndPlay +
// 写 talkInfo、FarmLandsView 照旧监听 "end"），接线点查本表后用 openfl
// MovieClip.addFrameScript 按原登记形态回挂（帧号是 0 基实参，与原版
// addFrameScript(23, frame24) 同形）。注意 openfl 9.5.2 的 addFrameScript
// 只在实例已挂 Timeline 时生效（否则静默丢弃）——接线必须在
// SymbolClass.afterAttach（符号绑定场景）或 LocalSwfLoader content
// （根时间轴场景）之后。
//
// 表内容逐条出自 legacy 字节码（DoABC2 构造器 + frameN 方法体，出处注释
// 在 test/shim/FrameScriptCompensationTest.hx 与
// test/shim/FrameScriptCompensationInUseTest.hx）。空体脚本不登记——
// frame1 只有 return 的类（FarmInfoPlus 等）本来就无行为可补，
// src/FarmInfoPlus.hx:14-16 的「空体不译」先例同款。

/** 一条补偿登记：libraryId 是 libraries.xml 的库 id；symbolKey 是符号
 *  导出名，空串 = 主时间轴（T3 约定，tools/TimelineTypes）；frame 是
 *  1 基帧号（= 原版 addFrameScript 的 0 基实参 + 1，与 frameN 方法名的
 *  N 恒一致）；actions 是 frameN 方法体逐句还原的动作序列。 */
typedef FrameScriptEntry = {
	libraryId:String,
	symbolKey:String,
	frame:Int,
	actions:Array<FrameScriptAction>
}

/** 帧脚本动作原语。只列已登记方法体里实际出现的形态；新形态出现时须先
 *  扩本枚举（带字节码出处）再登记，不得并入近似原语。 */
enum FrameScriptAction {
	/** 方法体里的 stop()：停在当前帧。 */
	Stop;
	/** dispatchEvent(new Event(name))：素材对外自报完成（RedUp "end"、
	 *  PackageTab 帧脚本的页签切换事件）。 */
	DispatchEvent(name:String);
	/** 具名子件 target 的 text 属性 ← 本实例同名属性 prop（MaoPaoFlag
	 *  frame24：infoTxt.text = talkInfo）。 */
	SetText(target:String, prop:String);
	/** gotoAndPlay(label)（FarmLoading frame48 / FarmLoading_Lite frame48
	 *  的 "loop"、GiftIcon frame42 的 "GiftMove"；标签在 swf FrameLabel
	 *  tag，dump_swf.php 可证）。 */
	GotoAndPlay(label:String);
	/** gotoAndStop(frame)（PackageTab 帧脚本闭包里的页签切换）。 */
	GotoAndStop(frame:Int);
	/** if (parent != null) parent.removeChild(this)：播完自摘（FishWave
	 *  frame15、FishFoodEffect frame15）。 */
	RemoveSelf;
	/** 具名子件 childName 挂 MouseEvent.CLICK 监听，点击执行 actions
	 *  （PackageTab 帧脚本的闭包体：gotoAndStop(N) + dispatchEvent）。
	 *  每次帧脚本执行都新建闭包重挂——原版闭包同样每次进帧重建，重复
	 *  进帧监听器累积的原版行为照原样保留。 */
	AddClickListener(childName:String, actions:Array<FrameScriptAction>);
}

class FrameScriptCompensation {
	/** 登记表（出处逐条见 test/shim/FrameScriptCompensationTest.hx 与
	 *  test/shim/FrameScriptCompensationInUseTest.hx 的期望值注释；空体不
	 *  登记）。前两条是 issue #58 点名的已知三例之二；收获动画第三例无
	 *  登记：nc_data.php 挂 "h" 槽的三个 isAnimation 作物（158/168/334）
	 *  的 *_movie.swf 不在部署包，字节码无从提取，不虚造（原版跑这份部
	 *  署包同样加载不到，收尾走 HarvestAnimationCustom 已译的 IO_ERROR →
	 *  close 路径）。其余各条是清查器（tools/FrameScriptAudit）扫出的实
	 *  义帧脚本里**已在移植代码里构造的符号**（消费点逐条见 InUse 测试
	 *  注释）；未被构造的符号（farmui1 全族、farmui2 的 wild 系、
	 *  Fertilizer 的 CursorTool2x、help.swf）无补偿通道需求，待符号
	 *  shim 立项时随符号补，处置见 PR 报告。 */
	static final entries:Array<FrameScriptEntry> = [
		{
			// farmui_full_v_40.swf DoABC2 MaoPaoFlag 构造器 addFrameScript(0,
			// frame1, 23, frame24)（MaoPaoFlag.as:17）；frame1 空体不译，
			// frame24 = infoTxt.text = talkInfo; stop()（:24-28）
			libraryId: "farmui_full_v_40",
			symbolKey: "MaoPaoFlag",
			frame: 24,
			actions: [SetText("infoTxt", "talkInfo"), Stop]
		},
		{
			// RedUp.swf DoABC2 RedUp_fla.MainTimeline 构造器 addFrameScript(133,
			// frame134)（MainTimeline.as:13）；主轴 134 帧的末帧，frame134 =
			// this.dispatchEvent(new Event("end"))（:16-19）
			libraryId: "RedUp",
			symbolKey: "",
			frame: 134,
			actions: [DispatchEvent("end")]
		},
		// ==== farmui_full_v_40 的 in-use 符号（清查批次 2，出处都是
		// legacy/decompiled/farmui_full_v_40/scripts/<类>.as）====
		{
			// AddHealth.as:15 addFrameScript(0,frame1)；frame1 = stop()。
			// 消费点 common/view/floating/AddHealthAnimation.hx:26
			libraryId: "farmui_full_v_40",
			symbolKey: "AddHealth",
			frame: 1,
			actions: [Stop]
		},
		{
			// CursorArrow.as:15 addFrameScript(0,frame1,1,frame2)；两帧各
			// stop()。消费点 module/FarmStage.hx:138-146（光标注册表）
			libraryId: "farmui_full_v_40",
			symbolKey: "CursorArrow",
			frame: 1,
			actions: [Stop]
		},
		{
			// CursorArrow.as:19 frame2 = stop()
			libraryId: "farmui_full_v_40",
			symbolKey: "CursorArrow",
			frame: 2,
			actions: [Stop]
		},
		{
			// CursorHand.as:15 addFrameScript(0,frame1)；frame1 = stop()。
			// 消费点 FarmStage.hx:138-146
			libraryId: "farmui_full_v_40",
			symbolKey: "CursorHand",
			frame: 1,
			actions: [Stop]
		},
		{
			// CursorHoe.as:15；frame1 = stop()。消费点 FarmStage.hx:138-146
			libraryId: "farmui_full_v_40",
			symbolKey: "CursorHoe",
			frame: 1,
			actions: [Stop]
		},
		{
			// CursorHook.as:15；frame1 = stop()。消费点 FarmStage.hx:138-146
			libraryId: "farmui_full_v_40",
			symbolKey: "CursorHook",
			frame: 1,
			actions: [Stop]
		},
		{
			// CursorInsect.as:15；frame1 = stop()。消费点 FarmStage.hx:138-146
			libraryId: "farmui_full_v_40",
			symbolKey: "CursorInsect",
			frame: 1,
			actions: [Stop]
		},
		{
			// CursorOneClickHand.as:15；frame1 = stop()。消费点
			// FarmStage.hx:138-146
			libraryId: "farmui_full_v_40",
			symbolKey: "CursorOneClickHand",
			frame: 1,
			actions: [Stop]
		},
		{
			// CursorPesticide.as:15；frame1 = stop()。消费点
			// FarmStage.hx:138-146
			libraryId: "farmui_full_v_40",
			symbolKey: "CursorPesticide",
			frame: 1,
			actions: [Stop]
		},
		{
			// CursorWater.as:15；frame1 = stop()。消费点 FarmStage.hx:138-146
			libraryId: "farmui_full_v_40",
			symbolKey: "CursorWater",
			frame: 1,
			actions: [Stop]
		},
		{
			// CursorWeed.as:15；frame1 = stop()。消费点 FarmStage.hx:138-146
			libraryId: "farmui_full_v_40",
			symbolKey: "CursorWeed",
			frame: 1,
			actions: [Stop]
		},
		{
			// FarmLoading.as:17 addFrameScript(47,frame48)；frame48 =
			// gotoAndPlay("loop")（标签在帧 23，dump_swf.php sprite#680）。
			// 消费点 module/water/ModuleWater.hx:54、module/water/WaterPool.hx:512
			libraryId: "farmui_full_v_40",
			symbolKey: "FarmLoading",
			frame: 48,
			actions: [GotoAndPlay("loop")]
		},
		{
			// GiftIcon.as:17 addFrameScript(41,frame42)；frame42 =
			// gotoAndPlay("GiftMove")（标签在帧 3，dump_swf.php sprite#76）。
			// 消费点 module/uitools/widgets/ShortcutBar.hx:577
			libraryId: "farmui_full_v_40",
			symbolKey: "GiftIcon",
			frame: 42,
			actions: [GotoAndPlay("GiftMove")]
		},
		{
			// PackageTab.as:26-31 frame1：btnTool/btnFish 各挂 CLICK（闭包
			// gotoAndStop + dispatchEvent，事件名与 MyBagView 监听的
			// Consts.MSG_SWITCH_TO_* 同串），末尾 stop()
			libraryId: "farmui_full_v_40",
			symbolKey: "PackageTab",
			frame: 1,
			actions: [
				AddClickListener("btnTool", [GotoAndStop(2), DispatchEvent("tool")]),
				AddClickListener("btnFish", [GotoAndStop(3), DispatchEvent("fish")]),
				Stop
			]
		},
		{
			// PackageTab.as:33-41 frame2：btnSeed/btnFish 同款 + stop()
			libraryId: "farmui_full_v_40",
			symbolKey: "PackageTab",
			frame: 2,
			actions: [
				AddClickListener("btnSeed", [GotoAndStop(1), DispatchEvent("seed")]),
				AddClickListener("btnFish", [GotoAndStop(3), DispatchEvent("fish")]),
				Stop
			]
		},
		{
			// PackageTab.as:43-51 frame3：btnSeed/btnTool 同款 + stop()。
			// 消费点 module/warehouse/bag/MyBagView.hx:479（页签三帧开关）
			libraryId: "farmui_full_v_40",
			symbolKey: "PackageTab",
			frame: 3,
			actions: [
				AddClickListener("btnSeed", [GotoAndStop(1), DispatchEvent("seed")]),
				AddClickListener("btnTool", [GotoAndStop(2), DispatchEvent("tool")]),
				Stop
			]
		},
		{
			// SellLockIcon.as:15；frame1 = stop()（帧 1 标签 "lock"，
			// dump_swf.php sprite#536——停即锁态）。消费点
			// module/warehouse/house/widgets/PlantRenderItem / FishRenderItem
			libraryId: "farmui_full_v_40",
			symbolKey: "SellLockIcon",
			frame: 1,
			actions: [Stop]
		},
		// ==== farmui2_v_58 的 in-use 符号（swf 未反编译——baseline 登记账
		// 把 farmui2 的 59 类帧脚本族归 #58 跟踪；出处＝tools/FrameScriptAudit
		// 的 ABC 清查输出：构造器 addFrameScript 实参 + frameN 方法体 op 流）====
		{
			// ABC 清查：ctor addFrameScript(0, frame1)；frame1 =
			// stop()。消费点 common/view/floating/AddMoneyFloating.hx:29
			// （AddExpFloating 继承同构造链）
			libraryId: "farmui2_v_58",
			symbolKey: "AddAnimationEx",
			frame: 1,
			actions: [Stop]
		},
		{
			// ABC 清查：ctor addFrameScript(299, frame300)；frame300 =
			// stop()（停在末帧空帧，闪完定住）。消费点
			// module/uitools/UIController.hx:614
			libraryId: "farmui2_v_58",
			symbolKey: "newIconTip",
			frame: 300,
			actions: [Stop]
		},
		// ==== lite_ui_v_0 的 in-use 符号（出处
		// legacy/decompiled/lite_ui_v_0/scripts/<类>.as）====
		{
			// CursorHand_Lite.as:15；frame1 = stop()。消费点
			// module/lite/FarmLiteView.hx:257
			libraryId: "lite_ui_v_0",
			symbolKey: "CursorHand_Lite",
			frame: 1,
			actions: [Stop]
		},
		{
			// FarmLoading_Lite.as:15 addFrameScript(47,frame48)；frame48 =
			// gotoAndPlay("loop")（标签在帧 23，dump_swf.php sprite#9）。
			// 消费点 module/lite/FarmLiteView.hx:224/236
			libraryId: "lite_ui_v_0",
			symbolKey: "FarmLoading_Lite",
			frame: 48,
			actions: [GotoAndPlay("loop")]
		},
		// ==== Fertilizer_v_7 的 in-use 符号（出处
		// legacy/decompiled/Fertilizer_v_7/scripts/<类>.as）====
		{
			// FishFoodEffect.as:15 addFrameScript(14,frame15)；frame15 =
			// stop(); if (parent != null) parent.removeChild(this)。
			// 消费点 module/water/FishMover.hx:365
			libraryId: "Fertilizer_v_7",
			symbolKey: "FishFoodEffect",
			frame: 15,
			actions: [Stop, RemoveSelf]
		},
		{
			// Cursor_FishFood_1.as:15；frame1 = stop()。消费点
			// common/view/cursor/CursorTool.hx:57（鱼食光标）
			libraryId: "Fertilizer_v_7",
			symbolKey: "Cursor_FishFood_1",
			frame: 1,
			actions: [Stop]
		},
		{
			// Cursor_FishFood_2.as:15；frame1 = stop()。消费点同上
			libraryId: "Fertilizer_v_7",
			symbolKey: "Cursor_FishFood_2",
			frame: 1,
			actions: [Stop]
		},
		{
			// Cursor_FishFood_3.as:15；frame1 = stop()。消费点同上
			libraryId: "Fertilizer_v_7",
			symbolKey: "Cursor_FishFood_3",
			frame: 1,
			actions: [Stop]
		},
		{
			// Cursor_FishFood_4.as:15；frame1 = stop()。消费点同上
			libraryId: "Fertilizer_v_7",
			symbolKey: "Cursor_FishFood_4",
			frame: 1,
			actions: [Stop]
		},
		// ==== water_ui_v_0 的 in-use 符号（出处
		// legacy/decompiled/water_ui_v_0/scripts/<类>.as）====
		{
			// CursorFishNet.as:15；frame1 = stop()。消费点
			// module/FarmStage.hx:162、module/water/WaterController.hx:392
			libraryId: "water_ui_v_0",
			symbolKey: "CursorFishNet",
			frame: 1,
			actions: [Stop]
		},
		{
			// CursorFishNetAll.as:15；frame1 = stop()。消费点
			// module/FarmStage.hx:163、module/water/WaterController.hx:393
			libraryId: "water_ui_v_0",
			symbolKey: "CursorFishNetAll",
			frame: 1,
			actions: [Stop]
		},
		{
			// FishWave_0.as:15 addFrameScript(14,frame15)；frame15 =
			// if (parent != null) parent.removeChild(this)。消费点
			// module/water/WaterPool.hx:231（showWaterFlower 四方向水花）
			libraryId: "water_ui_v_0",
			symbolKey: "FishWave_0",
			frame: 15,
			actions: [RemoveSelf]
		},
		{
			// FishWave_1.as:15；frame15 同款自摘。消费点同上
			libraryId: "water_ui_v_0",
			symbolKey: "FishWave_1",
			frame: 15,
			actions: [RemoveSelf]
		},
		{
			// FishWave_2.as:15；frame15 同款自摘。消费点同上
			libraryId: "water_ui_v_0",
			symbolKey: "FishWave_2",
			frame: 15,
			actions: [RemoveSelf]
		},
		{
			// FishWave_3.as:15；frame15 同款自摘。消费点同上
			libraryId: "water_ui_v_0",
			symbolKey: "FishWave_3",
			frame: 15,
			actions: [RemoveSelf]
		}
	];

	/** 查 (libraryId, symbolKey) 的全部补偿登记，按 frame 升序。未登记
	 *  的组合返回 []——含空体脚本的键（空体=无行为可补）与整个 swf 无
	 *  帧脚本的符号。 */
	public static function entriesFor(libraryId:String, symbolKey:String):Array<FrameScriptEntry> {
		var out:Array<FrameScriptEntry> = [
			for (e in entries) if (e.libraryId == libraryId && e.symbolKey == symbolKey) {
				libraryId: e.libraryId, symbolKey: e.symbolKey, frame: e.frame, actions: e.actions.copy()
			}
		];
		out.sort(function(a:FrameScriptEntry, b:FrameScriptEntry):Int {
			return a.frame - b.frame;
		});
		return out;
	}

	/** 运行时接线（显示层行为，单测不覆盖——CI web-build/web-smoke 与画面
	 *  比对负责）：查表登记的帧脚本按原 0 基实参回挂到已挂 Timeline 的剪辑
	 *  上（openfl Timeline.__addFrameScript 用 set——同帧的 scriptSource
	 *  残骸（html5 侧 eval 出的跑不动 JS）被顶掉，不会双跑）。调用点必须
	 *  在 Timeline 已挂上之后（SymbolClass.attach / LocalSwfLoader content），
	 *  addFrameScript 在无 Timeline 的实例上是静默无操作。 */
	public static function attach(target:MovieClip, libraryId:String, symbolKey:String):Void {
		var list:Array<FrameScriptEntry> = entriesFor(libraryId, symbolKey);
		for (e in list) {
			var actions:Array<FrameScriptAction> = e.actions;
			target.addFrameScript(e.frame - 1, function():Void {
				run(actions, target);
			});
		}
	}

	/** frameN 方法体逐动作执行。原语语义见 FrameScriptAction 各项注释；
	 *  具名子件经 As3.childOf（先字段后 getChildByName，时间轴 PlaceObject
	 *  命名的子件走后者），AS3 的 String 强转（null → "null"）以 Std.string
	 *  同形。子件缺失留痕不抛（原版此处 NPE，deviations 候选级差异）。
	 *  gotoAndStop/gotoAndPlay 在方法体内跳帧后，openfl Timeline.__goto
	 *  会评估目标帧自己的帧脚本（含再挂监听）——与 Flash 进帧即跑帧脚本
	 *  同序。 */
	private static function run(actions:Array<FrameScriptAction>, target:MovieClip):Void {
		for (a in actions) {
			switch (a) {
				case SetText(childName, propName):
					var child:Dynamic = As3.childOf(target, childName);
					if (Std.isOfType(child, TextField)) {
						var value:Dynamic = As3.childOf(target, propName);
						cast(child, TextField).text = Std.string(value);
					} else {
						trace("FrameScriptCompensation: 子件缺失 " + childName + "（" + Type.getClass(target) + "）");
					}
				case Stop:
					target.stop();
				case DispatchEvent(name):
					target.dispatchEvent(new Event(name));
				case GotoAndPlay(label):
					target.gotoAndPlay(label);
				case GotoAndStop(frame):
					target.gotoAndStop(frame);
				case RemoveSelf:
					if (target.parent != null) {
						target.parent.removeChild(target);
					}
				case AddClickListener(childName, clickActions):
					var child:Dynamic = As3.childOf(target, childName);
					if (Std.isOfType(child, InteractiveObject)) {
						// 闭包每次执行帧脚本都重建重挂（原版同款，见枚举项
						// 注释）；点击体内 run 复入本函数
						cast(child, InteractiveObject).addEventListener(MouseEvent.CLICK, function(event:MouseEvent):Void {
							run(clickActions, target);
						});
					} else {
						trace("FrameScriptCompensation: 子件缺失 " + childName + "（" + Type.getClass(target) + "）");
					}
			}
		}
	}
}
