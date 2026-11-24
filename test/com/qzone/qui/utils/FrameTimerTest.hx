package com.qzone.qui.utils;

import openfl.display.Stage;
import openfl.events.Event;
import openfl.events.TimerEvent;
import support.FakeStage;
import utest.Assert;

/**
 * FrameTimer 纯逻辑（issue #44）：ms→帧数换算（addTimer :92 的
 * `Math.ceil((delay || 1000) / 1000 * frameRate)`）、onEnterFrame 的
 * `frameCount % delay == 0` 触发门（:108-125，frameCount 起 1、判后自增）、
 * setTimeout 单发即清（:117-120 先 clear 再 apply）、setInterval 周发、
 * clear/clearInterval/clearTimeout 摘表、init 的 `_stage == null` 只装一次门
 * （:76-83），以及实例侧 start/stop/delay/currentCount/repeatCount/reset
 * 的帧驱动语义（Timer 的 ENTER_FRAME 替代品，closure :169-178 派发
 * TimerEvent）。
 *
 * 测法（TweenLiteTest 先例）：不挂真实时间轴——支持件 FakeStage 钉一只
 * 30fps、无窗口的 Stage，init 进 FrameTimer 后由测试手动派发
 * Event.ENTER_FRAME 逐帧推进；30fps 下 1000ms=30 帧、500ms=15 帧、
 * 250ms=ceil(7.5)=8 帧。`_stage`/`handles` 等静态整进程共享（init 幂等），
 * 用例只走公共 API，各自把定时器推到自清或显式 clear/stop，不留残表项
 * （count 归 0，addTimer 的监听重挂门 :95-98 不受前序用例影响）。
 *
 * stub 阶段失败点：静态侧 setTimeout/setInterval 返回 0 且不派发；实例侧
 * start 不注册、currentCount/running/reset 是 throw stub。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/com/qzone/qui/utils/FrameTimer.as
 * （setDelay :37-40、setTimeout :42-51、setInterval :53-61、clear :63-74、
 * init :76-83、clearInterval :85-88、addTimer :90-101、clearTimeout :103-106、
 * onEnterFrame :108-125、start :127-139、delay setter :146-153、stop :155-162、
 * currentCount :164-166、closure :169-178、reset :180-184、running :186-189）
 */
class FrameTimerTest {
	static var shared:Stage = null;

	public function new() {}

	public function setup() {
		if (shared == null) {
			shared = FakeStage.make(30);
			FrameTimer.init(shared);
		}
	}

	private function drive(frames:Int):Void {
		for (i in 0...frames) {
			shared.dispatchEvent(new Event(Event.ENTER_FRAME));
		}
	}

	private function driveOn(stage:Stage, frames:Int):Void {
		for (i in 0...frames) {
			stage.dispatchEvent(new Event(Event.ENTER_FRAME));
		}
	}

	// :42-51 + :92 + :108-125：1000ms@30fps = 30 帧；frameCount 起 1、
	// 判后自增（:123），第 30 次 ENTER_FRAME 才命中 30%30==0；timeOut 先
	// clear 再 apply（:117-121），回调参数原样透传（:121 apply arguments）
	public function test_setTimeout_fires_once_at_frame_30_for_1000ms() {
		var calls = 0;
		var gotA:Dynamic = null;
		var gotB:Dynamic = null;
		var fn:Dynamic = function(a:Dynamic = null, b:Dynamic = null):Void {
			calls++;
			gotA = a;
			gotB = b;
		};
		var id = FrameTimer.setTimeout(fn, 1000, [7, "x"]);
		Assert.isTrue(id != 0); // :93 ++index 后返回，首表项即非 0
		drive(29);
		Assert.equals(0, calls); // 第 29 帧前不触发
		drive(1);
		Assert.equals(1, calls); // 第 30 帧命中
		Assert.equals(7, gotA); // 参数透传
		Assert.equals("x", gotB);
		drive(30);
		Assert.equals(1, calls); // :117-120 触发即摘表，单发
	}

	// :92 换算表：Math.ceil(delay/1000*30)——50ms→2 帧、34ms→2 帧（进位）、
	// 1ms→1 帧、2000ms→60 帧
	public function test_setTimeout_ms_to_frame_conversion_table() {
		var cases:Array<{ms:Float, frames:Int, why:String}> = [
			{ms: 50.0, frames: 2, why: "ceil(1.5)=2"},
			{ms: 34.0, frames: 2, why: "ceil(1.02)=2，非整秒进位"},
			{ms: 1.0, frames: 1, why: "ceil(0.03)=1，第 1 帧即命中"},
			{ms: 2000.0, frames: 60, why: "两秒 60 帧"}
		];
		for (c in cases) {
			var calls = 0;
			var fn:Dynamic = function():Void {
				calls++;
			};
			FrameTimer.setTimeout(fn, c.ms);
			drive(c.frames - 1);
			Assert.equals(0, calls, '${c.ms}ms（${c.why}）：第 ${c.frames - 1} 帧前不触发');
			drive(1);
			Assert.equals(1, calls, '${c.ms}ms（${c.why}）：第 ${c.frames} 帧命中');
		}
	}

	// :92 的 `delay || 1000`：0ms 缺省按 1000ms 换算成 30 帧
	public function test_setTimeout_zero_delay_defaults_to_1000ms() {
		var calls = 0;
		var fn:Dynamic = function():Void {
			calls++;
		};
		FrameTimer.setTimeout(fn, 0);
		drive(29);
		Assert.equals(0, calls);
		drive(1);
		Assert.equals(1, calls);
	}

	// :53-61：无 timeOut 标记 → 不自清，每 15 帧复触发（500ms@30fps）
	public function test_setInterval_fires_every_15_frames_for_500ms() {
		var calls = 0;
		var fn:Dynamic = function():Void {
			calls++;
		};
		var id = FrameTimer.setInterval(fn, 500);
		Assert.isTrue(id != 0);
		drive(44);
		Assert.equals(2, calls); // 第 15/30 帧各一次
		drive(1);
		Assert.equals(3, calls); // 第 45 帧
		FrameTimer.clear(id); // 用例清理：不留常驻表项
	}

	// :63-74：clear 摘表并 --count，之后不再触发
	public function test_clear_stops_interval() {
		var calls = 0;
		var fn:Dynamic = function():Void {
			calls++;
		};
		var id = FrameTimer.setInterval(fn, 500);
		drive(15);
		Assert.equals(1, calls);
		FrameTimer.clear(id);
		drive(45);
		Assert.equals(1, calls);
	}

	// :85-88/:103-106：clearInterval/clearTimeout 都只是 clear 的别名
	public function test_clearTimeout_and_clearInterval_alias_clear() {
		var oneShot = 0;
		var fnA:Dynamic = function():Void {
			oneShot++;
		};
		var idA = FrameTimer.setTimeout(fnA, 1000);
		FrameTimer.clearTimeout(idA);
		var interval = 0;
		var fnB:Dynamic = function():Void {
			interval++;
		};
		var idB = FrameTimer.setInterval(fnB, 500);
		FrameTimer.clearInterval(idB);
		drive(60);
		Assert.equals(0, oneShot);
		Assert.equals(0, interval);
	}

	// :76-83：init 只在 `_stage == null` 时落——首装舞台一直有效，后装的
	// 舞台不接管（新定时器的 ENTER_FRAME 监听仍挂首装舞台，:95-98）
	public function test_init_first_stage_wins() {
		var calls = 0;
		var fn:Dynamic = function():Void {
			calls++;
		};
		var second = FakeStage.make(30);
		FrameTimer.init(second);
		FrameTimer.setTimeout(fn, 1000);
		driveOn(second, 30);
		Assert.equals(0, calls); // 次舞台派发不推进
		driveOn(shared, 30);
		Assert.equals(1, calls); // 首装舞台推进
	}

	// :127-139 + :169-178：实例 start 注册 closure，每 30 帧派发一次
	// TimerEvent.TIMER（1000ms@30fps）；repeatCount 缺省 0 → 永不 COMPLETE
	public function test_instance_start_dispatches_TIMER_every_30_frames() {
		var timer = new FrameTimer(1000);
		var ticks = 0;
		var completes = 0;
		timer.addEventListener(TimerEvent.TIMER, function(_:TimerEvent):Void ticks++);
		timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(_:TimerEvent):Void completes++);
		timer.start();
		Assert.isTrue(timer.running); // :186-189，start 置位
		drive(89);
		Assert.equals(2, ticks); // 第 30/60 帧
		drive(1);
		Assert.equals(3, ticks); // 第 90 帧
		Assert.equals(3, timer.currentCount); // :171 每次触发自增
		Assert.equals(0, timer.repeatCount); // ctor :34 缺省 0
		Assert.equals(0, completes); // :173 repeatCount>0 才判完成
		timer.stop(); // 用例清理
	}

	// :169-178：repeatCount=2 → 第 2 次 TIMER 后 clear 摘表并派发一次
	// TIMER_COMPLETE，之后不再触发；:175 只清表项，_running 不回落（stop
	// 未调），running 保持 true——原版如此，照钉
	public function test_instance_repeatCount_completes_and_stops() {
		var timer = new FrameTimer(500, 2);
		var ticks = 0;
		var completes = 0;
		timer.addEventListener(TimerEvent.TIMER, function(_:TimerEvent):Void ticks++);
		timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(_:TimerEvent):Void completes++);
		timer.start();
		drive(15);
		Assert.equals(1, ticks);
		Assert.equals(0, completes);
		Assert.equals(1, timer.currentCount);
		drive(15);
		Assert.equals(2, ticks);
		Assert.equals(1, completes); // :176-177
		drive(30);
		Assert.equals(2, ticks); // :175 已摘表
		Assert.equals(2, timer.currentCount);
		Assert.isTrue(timer.running); // :175 不动 _running
	}

	// :155-162 stop 摘表；:127-139 再 start 以 frameCount=1 重新注册——
	// 停在 29 帧处重启后仍要再数满 30 帧（若沿用旧计数会立即命中）
	public function test_instance_stop_then_start_restarts_frameCount() {
		var timer = new FrameTimer(1000);
		var ticks = 0;
		timer.addEventListener(TimerEvent.TIMER, function(_:TimerEvent):Void ticks++);
		timer.start();
		drive(29);
		Assert.equals(0, ticks);
		timer.stop();
		Assert.isFalse(timer.running); // :186-189，stop 复位
		drive(30);
		Assert.equals(0, ticks); // 已摘表
		timer.start();
		drive(29);
		Assert.equals(0, ticks); // 新注册从第 1 帧重数
		drive(1);
		Assert.equals(1, ticks); // 第 30 帧命中
		timer.stop();
	}

	// :146-153 + :37-40：运行中改 delay 走 setDelay 按 ms 重新换算——
	// 1000ms 改 500ms 后周期从 30 帧缩到 15 帧
	public function test_instance_delay_setter_while_running_recomputes_frames() {
		var timer = new FrameTimer(1000);
		var ticks = 0;
		timer.addEventListener(TimerEvent.TIMER, function(_:TimerEvent):Void ticks++);
		timer.start();
		timer.delay = 500;
		Assert.equals(500.0, timer.delay); // :148 存值
		drive(14);
		Assert.equals(0, ticks);
		drive(1);
		Assert.equals(1, ticks); // 15 帧命中
		timer.stop();
	}

	// :148-152：未运行时改 delay 只存值（不触发 setDelay），start 时按新值
	// 换算——250ms → ceil(7.5)=8 帧
	public function test_instance_delay_set_before_start_uses_new_delay() {
		var timer = new FrameTimer(1000);
		var ticks = 0;
		timer.addEventListener(TimerEvent.TIMER, function(_:TimerEvent):Void ticks++);
		timer.delay = 250;
		timer.start();
		drive(7);
		Assert.equals(0, ticks);
		drive(1);
		Assert.equals(1, ticks); // 第 8 帧命中
		timer.stop();
	}

	// :180-184：reset 归零 currentCount 并 stop；已派发的不补不撤
	public function test_instance_reset_zeroes_currentCount_and_stops() {
		var timer = new FrameTimer(500);
		var ticks = 0;
		timer.addEventListener(TimerEvent.TIMER, function(_:TimerEvent):Void ticks++);
		timer.start();
		drive(15);
		Assert.equals(1, ticks);
		Assert.equals(1, timer.currentCount);
		timer.reset();
		Assert.equals(0, timer.currentCount); // :182
		Assert.isFalse(timer.running); // :183 经 stop
		drive(30);
		Assert.equals(1, ticks); // 已停
	}
}
