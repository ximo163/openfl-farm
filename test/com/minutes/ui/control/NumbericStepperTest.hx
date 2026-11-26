package com.minutes.ui.control;

import com.minutes.ui.core.UIEvent;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.events.MouseEvent;
import openfl.text.TextFieldType;
import utest.Assert;

/**
 * NumbericStepper 步进边界纯逻辑（issue #86 牧场库底座，LipiUI 组件库片）：
 * get_num 的 min/max/NaN 钳制、updateSpinBtns 的钮位翻转、disable 三分支
 * 位标志、滚轮/点击步进出界钳回、numTextChange 的双派发、focusOut 拉回。
 *
 * 出处：legacy/decompiled/Master2_v_142/scripts/com/minutes/ui/control/
 * NumbericStepper.as（字段 :22-40（_min_num=1 :34、_max_num=99 :38）；ctor
 * :42-47（init :45、_disable_type=0 :46）；set get_num :49-70（isNaN → min
 * :51-53、< min → min + setSelection :55-59、> max → max :60-62、区间内直写
 * :64-66、派发 TEXT_CHANGE :68、updateSpinBtns :69）；get get_num :159-162
 * （int(numText.text)）；init :92-150（restrict "0-9" :135、type INPUT :136、
 * text "1" :138、挂点 :131-133/:141-142、四个 addChild :128-130/:147、
 * 常挂的 numText 监听 :143-146、Timer(60) :148）；updateSpinBtns :171-189
 * （==min 关左钮 :173-180、==max 关右钮 :181-188）；disable :202-253
 * （param2==0 分支 :204-217（位 |=1/&=~1 :211/:216、mouseEnabled/
 * mouseChildren 极性 :207-208）、param2==1 分支 :218-231、else 分支
 * :233-252（两钮同灰、numText.type :241、mouseEnabled :242、
 * mouseWheelEnabled :243、底色 0x666666/0xFFFFFF :246/:249，不碰位标志））；
 * numTextChange :191-195（text 原样进 setter :193 + 自发一条 :194）；
 * textWheel :334-344（delta>0 +1、否则 −1）；focusOut :84-90；
 * leftButtonClick :292-295（−1）、rightButtonClick :351-354（+1）；
 * min_num/max_num 存取 :346-349/:357-360/:72-75/:197-200。TEXT_CHANGE 类型
 * 串 "textChange" 出 com/minutes/ui/core/UIEvent.as:12。
 *
 * 测试环境说明（eval 适配）：NUmbericStepperSkin 的 DecSkin/IncSkin/BgSkin
 * 是无初始化的 Class 静态（NUmbericStepperSkin.as:6-10，运行期由皮肤装载
 * 赋值），单测环境全 null → init() 的三处皮肤 if 全跳过（:97/:109/:121）：
 * 按钮实例照建照 addChild、x 挂点照设（:128-133 在 if 外），但按钮点击
 * 监听只在皮肤非空时挂（:100/:112）——点击处理器以直接调用钉（等价于挂
 * 监听后的真实路径）；numText 的 CHANGE/MOUSE_WHEEL/FOCUS_* 监听常挂
 * （:143-146），走真实事件派发。onTimer/leftButtonDown/rightButtonDown
 * 走 getTimer() 真实时钟（:155/:277/:302）与 60ms Timer（:148）——不进
 * 单测（测试规则：不读真实时间），连续步进面归 CI 时间轴对拍。
 *
 * 空串面：numTextChange 把 "" 写进 setter 时，AS3 Number("")==0 走 <min
 * 分支；eval 的 String NaN/比较语义（实测 Math.isNaN("") 为 true、"" < 1
 * 为 false）可让真身走 :51-53 的 isNaN 分支——两分支可见文本同为
 * min_num（:53/:57 都写 min_num.toString()），故只钉文本、不钉该行的
 * setSelection（:58 的分支差异只在选区）。
 */
@:access(com.minutes.ui.control.NumbericStepper)
class NumbericStepperTest {
	public function new() {}

	// 测试侧入口：全新 stepper（ctor/init 全跑，皮肤静态 null）
	private function build():NumbericStepper {
		return new NumbericStepper();
	}

	// :42-47 + :92-150：无皮肤态的构造落位——文本 "1"、restrict、四个
	// 子件层级与挂点、位标志 0、按钮 mouseEnabled 保持默认 true
	public function test_ctor_state_without_skins() {
		var s = build();
		Assert.equals(1, s.min_num); // :34
		Assert.equals(99, s.max_num); // :38
		Assert.equals(1, s.get_num); // :138 "1" 经 :159-162 int()
		Assert.equals(0, s._disable_type); // :46
		Assert.equals("1", s.numText.text); // :138
		Assert.equals("0-9", s.numText.restrict); // :135
		Assert.equals(TextFieldType.INPUT, s.numText.type); // :136
		Assert.notNull(s.leftButton); // :94
		Assert.notNull(s.rightButton); // :95
		Assert.notNull(s.bg); // :96
		Assert.notNull(s.timer); // :148
		Assert.equals(4, s.numChildren); // :128-130 + :147
		Assert.equals(s.leftButton, s.getChildAt(0));
		Assert.equals(s.rightButton, s.getChildAt(1));
		Assert.equals(s.bg, s.getChildAt(2));
		Assert.equals(s.numText, s.getChildAt(3));
		Assert.equals(0.0, s.leftButton.x); // :131
		Assert.equals(20.0, s.bg.x); // :132
		Assert.equals(70.0, s.rightButton.x); // :133
		Assert.equals(20.0, s.numText.x); // :141 = this.bg.x
		Assert.equals(2.0, s.numText.y); // :142
		Assert.isTrue(s.leftButton.mouseEnabled); // 皮肤分支跳过 → 保持默认
		Assert.isTrue(s.rightButton.mouseEnabled);
	}

	// :49-70 步进边界钳制表（每行全新 stepper，缺省 min=1/max=99）：
	// 区间内直写；低于 min 拉 min 且带选区（:58）；高于 max 压 max；NaN
	// 落 min（:51-53，无 setSelection——与 <min 分支的差异面）
	public function test_set_get_num_clamps_to_min_and_max() {
		var cases:Array<{input:Dynamic, expectText:String, expectSel:Array<Int>}> = [
			{input: 5, expectText: "5", expectSel: [0, 0]}, // :64-66 区间内
			{input: 1, expectText: "1", expectSel: [0, 0]}, // 恰在下界：1 < 1 false → 区间分支
			{input: 0, expectText: "1", expectSel: [0, 1]}, // :55-58 低于 min
			{input: -5, expectText: "1", expectSel: [0, 1]}, // :55-58
			{input: 99, expectText: "99", expectSel: [0, 0]}, // 恰在上界 → 区间分支
			{input: 100, expectText: "99", expectSel: [0, 0]}, // :60-62 高于 max（无 setSelection）
			{input: Math.NaN, expectText: "1", expectSel: [0, 0]} // :51-53 isNaN（无 setSelection）
		];
		for (c in cases) {
			var s = build();
			s.get_num = c.input;
			Assert.equals(c.expectText, s.numText.text, 'input=${c.input} 文本');
			Assert.same(c.expectSel, [s.numText.selectionBeginIndex, s.numText.selectionEndIndex], 'input=${c.input} 选区');
			Assert.equals(Std.parseInt(c.expectText), s.get_num, 'input=${c.input} get_num');
		}
	}

	// :346-349/:197-200：min_num/max_num setter 落位，钳制随新边界
	public function test_custom_min_max_bounds() {
		var s = build();
		s.min_num = 5;
		s.max_num = 10;
		Assert.equals(5, s.min_num); // :357-360
		Assert.equals(10, s.max_num); // :72-75
		s.get_num = 3;
		Assert.equals("5", s.numText.text); // < 5 → min
		s.get_num = 11;
		Assert.equals("10", s.numText.text); // > 10 → max
		s.get_num = 7;
		Assert.equals("7", s.numText.text); // 区间内
		s.get_num = 5;
		Assert.equals("5", s.numText.text); // 恰下界
		s.get_num = 10;
		Assert.equals("10", s.numText.text); // 恰上界
	}

	// :159-162：get_num = int(numText.text)——数字串解析，前导零照收
	public function test_get_num_parses_numText() {
		var s = build();
		s.numText.text = "42";
		Assert.equals(42, s.get_num);
		s.numText.text = "007";
		Assert.equals(7, s.get_num);
	}

	// :68：setter 末尾恰派发一条 UIEvent.TEXT_CHANGE
	public function test_set_get_num_dispatches_one_text_change() {
		var s = build();
		var count = 0;
		s.addEventListener(UIEvent.TEXT_CHANGE, function(e:UIEvent) count++);
		s.get_num = 5;
		Assert.equals(1, count);
	}

	// :191-195：numText 的 Event.CHANGE → numTextChange 把 text 原样写进
	// setter（:193，String 进 setter 的 `*` 形参）后再自发一条（:194）——
	// 一次 CHANGE 共两条 TEXT_CHANGE（原版双发照抄）
	public function test_numText_change_routes_text_and_double_dispatches() {
		var s = build();
		var count = 0;
		s.addEventListener(UIEvent.TEXT_CHANGE, function(e:UIEvent) count++);
		s.numText.text = "30";
		s.numText.dispatchEvent(new Event(Event.CHANGE));
		Assert.equals("30", s.numText.text); // :193 → :64-66 区间内直写
		Assert.equals(30, s.get_num);
		Assert.equals(2, count); // :68 setter 的 + :194 直发的
	}

	// 空串面（见类头说明）：可见文本钳回 min，两分支同为 min_num.toString()
	public function test_numText_change_with_empty_text_clamps_to_min() {
		var s = build();
		s.numText.text = "";
		s.numText.dispatchEvent(new Event(Event.CHANGE));
		Assert.equals("1", s.numText.text);
	}

	// :334-344：滚轮 delta>0 +1、delta<0 −1（监听常挂 :144），步进出界经
	// setter 钳回——上界 99 再 +1 压回 99、下界 1 再 −1 拉回 1
	public function test_textWheel_steps_and_clamps_at_bounds() {
		var s = build();
		s.get_num = 98;
		wheel(s, 1);
		Assert.equals(99, s.get_num); // 98 + 1 → 恰上界
		Assert.equals("99", s.numText.text);
		wheel(s, 1);
		Assert.equals(99, s.get_num); // 99 + 1 → :60-62 压回 99
		wheel(s, -1);
		Assert.equals(98, s.get_num); // 99 − 1
		s.get_num = 2;
		wheel(s, -1);
		Assert.equals(1, s.get_num); // 2 − 1 → 恰下界
		wheel(s, -1);
		Assert.equals(1, s.get_num); // 1 − 1 → :55-59 拉回 1
		Assert.equals("1", s.numText.text);
	}

	// :84-90：FOCUS_OUT 时低于 min 拉回 min（监听常挂 :145）——:88 经 setter
	// 赋 min_num，恰等于 min → 走 :64-66 区间分支
	public function test_focus_out_pulls_below_min_to_min() {
		var s = build();
		s.numText.text = "0"; // 绕开 setter 直接写低值
		Assert.equals(0, s.get_num);
		s.numText.dispatchEvent(new FocusEvent(FocusEvent.FOCUS_OUT));
		Assert.equals("1", s.numText.text);
		Assert.equals(1, s.get_num);
	}

	// :292-295 / :351-354：左右按钮点击 ±1 步进，出界经 setter 钳回；点击
	// 监听只在皮肤非空时挂（:100/:112），测试环境无皮肤 → 直接调处理器
	// （等价于挂监听后的真实路径）
	public function test_button_click_steps_and_clamps_at_bounds() {
		var s = build();
		s.get_num = 50;
		s.leftButtonClick(new MouseEvent(MouseEvent.CLICK)); // −1
		Assert.equals(49, s.get_num);
		s.rightButtonClick(new MouseEvent(MouseEvent.CLICK)); // +1
		Assert.equals(50, s.get_num);
		s.get_num = 99;
		s.rightButtonClick(new MouseEvent(MouseEvent.CLICK)); // 99 + 1 → 压回 99
		Assert.equals(99, s.get_num);
		Assert.equals("99", s.numText.text);
		s.get_num = 1;
		s.leftButtonClick(new MouseEvent(MouseEvent.CLICK)); // 1 − 1 → 拉回 1
		Assert.equals(1, s.get_num);
		Assert.equals("1", s.numText.text);
	}

	// :171-189（经 :69 setter 末尾调用）：值==min 关左减钮（置 bit0）、
	// 值==max 关右加钮（置 bit1），开钮清位；:207-208/:221-222 的
	// mouseEnabled/mouseChildren 极性是 `param1 == false`
	public function test_update_spin_buttons_flip_at_bounds() {
		var s = build();
		s.get_num = 1; // == min
		Assert.equals(1, s._disable_type); // :211 |= 1
		Assert.isFalse(s.leftButton.mouseEnabled);
		Assert.isFalse(s.leftButton.mouseChildren);
		Assert.isTrue(s.rightButton.mouseEnabled); // 1 < 99 → 右钮开
		s.get_num = 2; // > min
		Assert.equals(0, s._disable_type); // :216 &= ~1
		Assert.isTrue(s.leftButton.mouseEnabled);
		Assert.isTrue(s.leftButton.mouseChildren);
		s.get_num = 99; // == max
		Assert.equals(2, s._disable_type); // :225 |= 2
		Assert.isFalse(s.rightButton.mouseEnabled);
		Assert.isFalse(s.rightButton.mouseChildren);
		Assert.isTrue(s.leftButton.mouseEnabled); // 99 > 1 → 左钮开
		s.get_num = 50;
		Assert.equals(0, s._disable_type);
		Assert.isTrue(s.leftButton.mouseEnabled);
		Assert.isTrue(s.rightButton.mouseEnabled);
	}

	// :202-253：disable 三分支——param2==0 左钮（位 0）、param2==1 右钮
	// （位 1）、else 分支两钮同灰 + 文本输入面（type/两 mouse 位/底色），
	// else 分支不碰位标志
	public function test_disable_branches_and_bit_flags() {
		var s = build();
		s.disable(true, 0); // 左钮
		Assert.equals(1, s._disable_type); // :211
		Assert.isFalse(s.leftButton.mouseEnabled); // :207（param1==false 极性）
		Assert.isFalse(s.leftButton.mouseChildren); // :208
		Assert.isTrue(s.rightButton.mouseEnabled); // 未触
		s.disable(true, 1); // 右钮
		Assert.equals(3, s._disable_type); // :225 |= 2
		Assert.isFalse(s.rightButton.mouseEnabled);
		Assert.isFalse(s.rightButton.mouseChildren);
		s.disable(false, 0); // 左钮恢复
		Assert.equals(2, s._disable_type); // :216 &= ~1
		Assert.isTrue(s.leftButton.mouseEnabled);
		Assert.isTrue(s.leftButton.mouseChildren);
		s.disable(false, 1);
		Assert.equals(0, s._disable_type);

		var t = build();
		t.disable(true, 2); // :233-252 else 分支
		Assert.equals(0, t._disable_type); // else 不碰位标志
		Assert.isFalse(t.leftButton.mouseEnabled); // :235
		Assert.isFalse(t.rightButton.mouseEnabled); // :238
		Assert.isFalse(t.numText.mouseEnabled); // :242
		Assert.isFalse(t.numText.mouseWheelEnabled); // :243
		Assert.equals(TextFieldType.DYNAMIC, t.numText.type); // :241
		Assert.equals(6710886, t.numText.backgroundColor); // :246（0x666666）
		t.disable(false, 2);
		Assert.equals(TextFieldType.INPUT, t.numText.type); // :241 三元
		Assert.equals(16777215, t.numText.backgroundColor); // :249（0xFFFFFF）
	}

	// 滚轮事件垫子：MOUSE_WHEEL 监听挂在 numText（:144），delta 走 openfl
	// MouseEvent 第 11 参（write-tests 阶段探明）
	private function wheel(s:NumbericStepper, delta:Int) {
		s.numText.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_WHEEL, false, false, 0, 0, null, false, false, false, false, delta));
	}
}
