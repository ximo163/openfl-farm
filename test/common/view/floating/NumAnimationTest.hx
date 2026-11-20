package common.view.floating;

import common.view.NumAnimation;
import utest.Assert;

/**
 * NumAnimation 数值滚动补间纯逻辑（issue #9）：金币/经验面板数字逼近公式。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/common/view/NumAnimation.as
 * （ctor :21-28、start :30-44、onTimer :46-56、stop :58-68、set end :70-82）。
 *
 * 不走 start() 驱动：Timer 在 eval --interp 无事件循环不可控，测试直接调
 * onTimer（:48-56 的补间体）并以 @:access 预置 currentValue（等价 :40 的
 * startValue 赋值）；start/set end 只测 >2100000000 的溢出守卫分支（该分支
 * 不建 Timer）。期望序列由公式 double 精确算出：current += (end-current)*0.2，
 * 显示 int(current)（截断），|end-current| < 1 → stop() 直写终值。
 */
@:access(common.view.NumAnimation)
class NumAnimationTest {
	public function new() {}

	// :48-56 前 4 拍（0 起 → 100）：20 / 36 / 48.8→48 / 59.04→59
	public function test_onTimer_eases_20_percent_and_displays_truncated_int() {
		var target:Dynamic = {gold: -1};
		var anim = new NumAnimation(target, "gold", 0, 100);

		anim.onTimer(null);
		Assert.equals(20, target.gold); // 0 + (100-0)*0.2
		anim.onTimer(null);
		Assert.equals(36, target.gold); // 20 + 80*0.2
		anim.onTimer(null);
		Assert.equals(48, target.gold); // 36 + 64*0.2 = 48.8 截断（:53 int）
		anim.onTimer(null);
		Assert.equals(59, target.gold); // 48.8 + 51.2*0.2 = 59.04 截断
	}

	// 0→100 共 21 拍收敛：100*(1-0.8^21) ≈ 99.08，|100-c| < 1 → stop 直写
	// 终值 100（:54-56 触发 :58-68），此后属性稳定
	public function test_onTimer_stops_within_one_and_pins_exact_end() {
		var target:Dynamic = {gold: 0};
		var anim = new NumAnimation(target, "gold", 0, 100);

		var ticks = 0;
		while (target.gold != 100 && ticks < 200) {
			anim.onTimer(null);
			ticks++;
		}

		Assert.equals(21, ticks);
		Assert.equals(100, target.gold); // stop() 的直写，非逼近残值
	}

	// 50→100 前 4 拍：60 / 68 / 74.4→74 / 79.52→79；@:access 预置 currentValue
	// 等价 start() 里 :40 的 currentValue = startValue
	public function test_onTimer_from_nonzero_start() {
		var target:Dynamic = {gold: 50};
		var anim = new NumAnimation(target, "gold", 50, 100);
		anim.currentValue = 50;

		anim.onTimer(null);
		Assert.equals(60, target.gold);
		anim.onTimer(null);
		Assert.equals(68, target.gold);
		anim.onTimer(null);
		Assert.equals(74, target.gold); // 74.4 截断
		anim.onTimer(null);
		Assert.equals(79, target.gold); // 79.52 截断

		var ticks = 4;
		while (target.gold != 100 && ticks < 200) {
			anim.onTimer(null);
			ticks++;
		}
		Assert.equals(18, ticks); // 50 起共 18 拍收敛
		Assert.equals(100, target.gold);
	}

	// :31-35：startValue > 2100000000 → 不建 Timer 直接 stop → 属性直写终值
	public function test_start_guard_when_start_value_overflows() {
		var target:Dynamic = {gold: 0};
		var anim = new NumAnimation(target, "gold", 2.2e9, 5);

		anim.start();

		Assert.equals(5, target.gold); // stop() 的 :63-67 直写 endValue
		Assert.isNull(anim.timer); // 守卫分支不建 Timer
	}

	// :70-82：set end 溢出 → 直接 stop 直写；正常值只改目标不碰当前显示
	//（timer 为 null 不重启，:77-80）
	public function test_set_end_guard_and_plain_set() {
		var target:Dynamic = {gold: 7};
		var anim = new NumAnimation(target, "gold", 0, 5);

		anim.end = 6; // 正常值：仅赋 endValue
		Assert.equals(7, target.gold);

		anim.end = 2.2e9; // 溢出 → stop → 直写
		Assert.equals(2.2e9, target.gold);
	}
}
