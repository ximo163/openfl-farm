package module.mainScene.npc.widgets;

import common.Consts;
import entities.Item;
import events.CommonEvent;
import module.FarmApplication;
import module.mainScene.npc.NPCController;
import module.mainScene.npc.NPCModel;
import module.mainScene.npc.NPCView;
import module.shop.ModuleShop;
import openfl.text.TextField;
import utest.Assert;

/**
 * DogFoodWindow 纯逻辑（issue #29）：addFood 构造 9002 狗粮礼包并派发
 * MSG_SHOW_BUY_DOG_FOOD；setData 的剩余天数/小时 html 拼装。
 *
 * 出处：
 * - legacy/decompiled/main3_v_221/scripts/module/mainScene/npc/widgets/
 *   DogFoodWindow.as（:45-66 addFood、:120-149 setData；:122-124
 *   `m_leftime == null` 早退；:129 `_loc1_["hours"] != undefined` 门；
 *   :131 `parseInt`、:132 `int(_loc3_/24)` 截断、:138 `<24` 文案分岔；
 *   前缀/两文案串逐字含第二个 `<font` 后的双空格与 ASCII 标点「,」「!」/
 *   全角「！」）
 * - 载荷形状：legacy/deploy/QFarmFlash/source/core/source/nc/mod/
 *   dog_feedmoney.php:13 `{"hours":<int>,"saleOut":"<串>"}`（:8-10 钳
 *   hours≥0）——hours 是 JSON 数字、saleOut 是字符串（PHP false 拼接成 ""）。
 * - Item 字段行号见 src/entities/Item.hx 头注释（_id :42、_type :18、
 *   _name :28、_desc :34、_effect :38、_price :12、_fb :36、_yfb :44、
 *   _timeLimit :32、_saleOut :10）。
 * - `["saleOut"] as Boolean`：AS3 Boolean(x) 真值规则 → shim/As3.hx
 *   truthy（""/null 假，"1" 与 "0" 皆真）。
 * - _fb=20/_yfb=16 是 swf 客户端硬编码（DogFoodWindow.as:56-57）；
 *   配置 toolstype.php:19 的 9002 行 FBPrice 20/YFBPrice 15 与 _yfb=16
 *   不一致——按「原版客户端 swf 为行为权威」取 16（deviations 候选，见
 *   PR 说明）。9002 行出处同 #9 UIController.onGetDogValidTime 先例。
 *
 * 显示链路（super.close 的 Event.CLOSE 派发、窗口 chrome）不在单测面：
 * NPCView/NPCModel 用空实例 + 私有字段钉入构造假宿主链（FarmLiteTest
 * 先例），TextField 在 eval 上只当字符串持有器（HarvestAnimationTest
 * 先例）。stub 阶段失败点：addFood 为 throw stub；setData 未覆写
 * （BaseWindow.setData :96 空实现）→ 钉入的 m_leftime.htmlText 保持 ""。
 */
@:access(framework.base.Controller)
@:access(module.mainScene.npc.NPCView)
@:access(module.mainScene.npc.NPCModel)
@:access(module.mainScene.npc.widgets.DogFoodWindow)
class DogFoodWindowTest {
	public function new() {}

	// 假宿主链：NPCView（空实例）→ NPCController → NPCModel（m_dogFood
	// 钉成 dogFeedmoney 回包形状）→ DogFoodWindow。返回 (win, app)，
	// app 即 DogFoodWindow.as:65 `this.controller.module.app` 派发目标。
	private function buildWindow(dogFood:Dynamic):Array<Dynamic> {
		var app = new FarmApplication();
		var module = new ModuleShop(app);
		var ctrl = new NPCController(module);
		ctrl.m_model = new NPCModel();
		var model:NPCModel = ctrl.m_model;
		model.m_dogFood = dogFood; // selfDogFood getter 读它（NPCModel.hx:113-116）
		var view = Type.createEmptyInstance(NPCView);
		view.m_controller = ctrl;
		return [new DogFoodWindow(view), app];
	}

	// DogFoodWindow.as:138-143 拼装模板逐字复刻（自检用；第二个 <font 后
	// 双空格、`0x333333` 无引号色值都是原文）
	private function expectedHtml(days:Int, mod:Int, low:Bool):String {
		var s = '<p align="left"><font size="11" face="Verdana" color="#FF6600"><b>'
			+ days + '</b></font> 天 <font  face="Verdana" size="11" color="#FF6600"><b>'
			+ mod + '</b></font> 小时 </font><br><br>';
		if (low) {
			s += '<font size="14" face="Verdana" color="0x333333">您的狗粮不足,赶紧购买吧!</font></p>';
		} else {
			s += '<font size="14" face="Verdana" color="0x333333">记得及时给自己的狗买狗粮！</font></p>';
		}
		return s;
	}

	// DogFoodWindow.as:45-66：addFood → super.close → 构造 9002 礼包
	// Item（字段逐字）→ 按 selfDogFood["saleOut"] as Boolean 覆盖 → 派发
	// MSG_SHOW_BUY_DOG_FOOD（载荷即该 Item）
	public function test_addFood_builds_9002_package_and_dispatches_buy_dog_food() {
		var r = buildWindow({hours: 30, saleOut: ""}); // dog_feedmoney.php:13 真实形状
		var win:DogFoodWindow = r[0];
		var app:FarmApplication = r[1];
		var count = 0;
		var payload:Item = null;
		app.addEventListener(Consts.MSG_SHOW_BUY_DOG_FOOD, function(e:CommonEvent) {
			count++;
			payload = e.data;
		});
		win.addFood();
		// 恰派发一次（Consts.hx:96 "ShowBuyDogFood"）
		Assert.equals(1, count);
		// 载荷是 Item（与 #9 UIController.onGetDogValidTime 同通道）
		Assert.isTrue(Std.isOfType(payload, Item));
		// DogFoodWindow.as:50-58 逐字
		Assert.equals(9002, payload._id);
		Assert.equals(909090, payload._type);
		Assert.equals("狗粮5送2礼包", payload._name);
		Assert.equals("一次性购买5天狗粮，可额外获赠2天狗粮，让狗狗为您看守农场一周。", payload._desc);
		Assert.equals("", payload._effect);
		Assert.equals(0, payload._price);
		Assert.equals(20, payload._fb);
		Assert.equals(16, payload._yfb);
		Assert.equals(0, payload._timeLimit);
		// 默认 _saleOut=false 后被 saleOut ""（as Boolean → false）覆盖仍 false
		Assert.isFalse(payload._saleOut);
	}

	// DogFoodWindow.as:59-61：`_loc2_ != null && _loc2_["saleOut"] != undefined`
	// 门 + `as Boolean` 真值规则（shim/As3.hx truthy：""/null 假、"0" 真）
	public function test_addFood_saleOut_polarity() {
		var cases:Array<{dogFood:Dynamic, expected:Bool, why:String}> = [
			{dogFood: {hours: 30, saleOut: "1"}, expected: true, why: "\"1\" 真"},
			{dogFood: {hours: 30, saleOut: "0"}, expected: true, why: "\"0\" 按 AS3 真值规则也为真"},
			{dogFood: {hours: 30, saleOut: ""}, expected: false, why: "空串假（PHP false 拼接形态）"},
			{dogFood: {hours: 30}, expected: false, why: "缺 saleOut 键 → != undefined 门不进"},
			{dogFood: {hours: 30, saleOut: null}, expected: false, why: "值 null 同 undefined 不进"},
			{dogFood: null, expected: false, why: "selfDogFood null 早退，保持默认 false"}
		];
		for (c in cases) {
			var r = buildWindow(c.dogFood);
			var win:DogFoodWindow = r[0];
			var app:FarmApplication = r[1];
			var payload:Item = null;
			app.addEventListener(Consts.MSG_SHOW_BUY_DOG_FOOD, function(e:CommonEvent) payload = e.data);
			win.addFood();
			Assert.equals(c.expected, payload._saleOut, 'dogFood=${c.dogFood}（${c.why}）');
		}
	}

	// DogFoodWindow.as:120-149 setData：hours 门内 parseInt（"25.9"→25 前缀
	// 截断）、int(hours/24) 天数、%24 小时、<24 文案分岔；门外 htmlText 落 ""
	public function test_setData_hours_renders_day_hour_html() {
		var cases:Array<{data:Dynamic, days:Int, mod:Int, low:Bool, why:String}> = [
			// dog_feedmoney.php 真实形状：hours JSON 数字（30→1 天 6 小时）
			{data: {hours: 30}, days: 1, mod: 6, low: false, why: "数字 30"},
			// :8-10 钳 0 的下限形态：0 天 0 小时 + 不足文案
			{data: {hours: 0}, days: 0, mod: 0, low: true, why: "钳 0"},
			{data: {hours: 20}, days: 0, mod: 20, low: true, why: "<24 不足文案"},
			// 24 恰好不小于 24 → 提醒文案
			{data: {hours: 24}, days: 1, mod: 0, low: false, why: "24<24 为假"},
			// 字符串形状钉 parseInt 前缀整数段截断（"25.9"→25；parseFloat 才是 25.9）
			{data: {hours: "25.9"}, days: 1, mod: 1, low: false, why: "parseInt 截断"}
		];
		for (c in cases) {
			var r = buildWindow(null);
			var win:DogFoodWindow = r[0];
			win.m_leftime = new TextField(); // 钉入显示字段（ctor 置 null）
			win.data = c.data; // BaseWindow.set_data → 虚分派 setData（BaseWindow.hx:120）
			Assert.equals(expectedHtml(c.days, c.mod, c.low), win.m_leftime.htmlText,
				'data=${c.data}（${c.why}）');
		}

		// hours 缺键：门不进，htmlText 落 ""（:128-145 的 _loc2_ 初值）
		var r2 = buildWindow(null);
		var win2:DogFoodWindow = r2[0];
		win2.m_leftime = new TextField();
		win2.data = {};
		Assert.equals("", win2.m_leftime.htmlText);

		// :122-124 m_leftime null 早退：不崩且不落任何文本
		var r3 = buildWindow(null);
		var win3:DogFoodWindow = r3[0];
		win3.data = {hours: 30}; // ctor 后 m_leftime 仍 null
		Assert.isTrue(win3.m_leftime == null);
	}
}
