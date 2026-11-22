package com.qzone.qui.makers;

import utest.Assert;

/**
 * StepperMaker 纯逻辑（issue #35）：shop_v_7 携带的 qui 数量步进器
 * （买入窗口的 +/- 数量控件）的夹取数学。stepNumber :134-159 的次序是
 * 原版字面：先 `param1 >= maximum` 高夹、再 `param1 <= minimum` 低夹、
 * 最后 `Math.floor(param1 * 100) / 100` 无条件收两位（收在夹取之后，
 * 不是只收中段）；maximum 被夹小到 minimum 之下时后写的 minimum 段赢
 * （字面顺序即优先级）。minimum/maximum/value 三个 setter 都只回灌
 * stepNumber（:116-120/:176-180/:193-196）。
 *
 * 不在本测试范围（需 Sprite/TextField 显示对象，测试规则不碰）：
 * setSkin/eventHandle 的皮肤接线（:59-91/:228-245）、_CHANGE/_FOCUS_OUT
 * 的文本解析 `Number(Number(text) || minimum)`（:128-132/:182-191）、
 * changeNumber/_MOUSE_DOWN/_TIMER 的箭头交互（:98-109/:161-174/:122-126）
 * ——归 CI web-smoke。字段表内联初值是纯数据，照钉。
 *
 * 出处：
 * - legacy/decompiled/shop_v_7/scripts/com/qzone/qui/makers/StepperMaker.as
 *   （字段 :17/:25/:29/:35/:37/:45/:47/:49、ctor :51-57、set minimum
 *   :116-120、_FOCUS_OUT :128-132、stepNumber :134-159、set maximum
 *   :176-180、set value :193-196）
 * - warehouse_v_23 的同名文件与之逐字一致（spec/modules/farm-shop-ui.json
 *   notes），本测试对两份实现同时生效
 */
class StepperMakerTest {
	public function new() {}

	// ctor :51-57 只写 maximum/minimum/stepSize；_value 保持字段初值 1（:49）；
	// 字段表内联初值（:17/:25/:29/:35/:37/:47）照钉
	public function test_ctor_defaults_and_field_literals() {
		var s = new StepperMaker();
		Assert.equals(10.0, s.maximum); // :54 param1 默认 10
		Assert.equals(1.0, s.minimum); // :55 param2 默认 1
		Assert.equals(1.0, s.value); // :49 _value 初值，ctor 不动
		Assert.equals(1.0, s.stepSize); // :56 param3 默认 1
		Assert.equals(40, s.repeatInterval); // :17
		Assert.equals(500, s.repeatDelay); // :25
		Assert.equals("prev_btn", s.buttonPrevName); // :29
		Assert.equals("num_txt", s.textName); // :35
		Assert.equals(5, s.maxChars); // :37
		Assert.equals("next_btn", s.buttonNextName); // :47

		var t = new StepperMaker(20, 5, 2);
		Assert.equals(20.0, t.maximum);
		Assert.equals(5.0, t.minimum);
		Assert.equals(2.0, t.stepSize);
		Assert.equals(1.0, t.value); // ctor 仍不写 _value
	}

	// set value → stepNumber :134-159：高夹（>= maximum）先行、低夹（<=
	// minimum）后行、floor(x*100)/100 无条件收尾
	public function test_value_setter_clamps_and_floors() {
		var s = new StepperMaker(); // maximum 10 / minimum 1
		s.value = 15; // :136-138 15 >= 10 → 10
		Assert.equals(10.0, s.value);
		s.value = 10; // 边界：>= 也走高夹
		Assert.equals(10.0, s.value);
		s.value = 0; // :145-147 0 <= 1 → 1
		Assert.equals(1.0, s.value);
		s.value = -3;
		Assert.equals(1.0, s.value);
		s.value = 1; // 低边界：<= 也走低夹
		Assert.equals(1.0, s.value);
		s.value = 7.365; // :154 floor(736.5)/100 = 7.36
		Assert.equals(7.36, s.value);
		s.value = 2.999; // floor(299.9)/100 = 2.99
		Assert.equals(2.99, s.value);
		s.value = 7.5; // 整百不损
		Assert.equals(7.5, s.value);
		s.value = 8; // 段内原样
		Assert.equals(8.0, s.value);
	}

	// set maximum/set minimum 只回灌 stepNumber(_value)（:178-179/:118-119），
	// 夹取按新边界重算；maximum 压到 minimum 之下时后段（minimum）赢
	public function test_maximum_minimum_setters_reclamp_current_value() {
		var s = new StepperMaker(); // 10 / 1
		s.value = 8;
		Assert.equals(8.0, s.value);
		s.maximum = 5; // :178-179 stepNumber(8) → 8 >= 5 → 5
		Assert.equals(5.0, s.value);
		Assert.equals(5.0, s.maximum);
		s.maximum = 12; // stepNumber(5) 段内 → 不动
		Assert.equals(5.0, s.value);
		s.value = 2;
		Assert.equals(2.0, s.value);
		s.minimum = 3; // :118-119 stepNumber(2) → 2 <= 3 → 3
		Assert.equals(3.0, s.value);
		Assert.equals(3.0, s.minimum);
		s.minimum = 0; // stepNumber(3) 段内 → 不动
		Assert.equals(3.0, s.value);
	}

	// 边界倒挂（maximum < minimum）：高夹先执行、低夹后执行 → minimum 段
	// 的赋值字面在后，净效果 minimum 赢；floor 在夹取之后无条件收尾
	public function test_inverted_bounds_minimum_wins_and_floor_applies_after_clamp() {
		var s = new StepperMaker(); // 10 / 1
		s.maximum = 2; // stepNumber(1)：1>=2 否；1<=1 是 → _value 1
		Assert.equals(1.0, s.value);
		s.minimum = 5; // stepNumber(1)：1>=2 否；1<=5 是 → 5
		Assert.equals(5.0, s.value);
		s.value = 7; // 7>=2 → 2；2<=5 → 5
		Assert.equals(5.0, s.value);

		// floor(:154) 收在两段夹取之后：夹到非整百的 maximum 也被收两位
		var t = new StepperMaker();
		t.maximum = 7.365; // stepNumber(1)：1<=1 是 → _value 1
		Assert.equals(1.0, t.value);
		t.value = 9; // 9 >= 7.365 → 7.365；7.365 <= 1 否 → floor(736.5)/100 = 7.36
		Assert.equals(7.36, t.value);
	}
}
