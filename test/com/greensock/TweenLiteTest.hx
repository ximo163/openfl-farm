package com.greensock;

import utest.Assert;

/**
 * TweenLite 纯逻辑（issue #39）：「终态直写」stub 换真身的可测纯面——
 * 默认 easeOut 的插值采样、自定义 ease、from 的 runBackwards/immediateRender、
 * overwrite 语义、delayedCall/killTweensOf/killVars。
 *
 * 测法：补间目标是匿名对象（x/y 数值字段，不碰显示对象）；推进不走
 * updateAll/ENTER_FRAME（真实时间不进单测，帧驱动链归 CI 时间轴比对），
 * 直接调 renderTime(t) 手动采样——入参是补间本地时刻（delay 只定位
 * cachedStartTime，直接调用绕过时间轴），采样值确定。rootTimeline/
 * masterList 等静态跨用例共享，但用例各自新建目标对象（Dictionary 身份
 * 键），互不串门。
 *
 * 出处：
 * - legacy/decompiled/main3_v_221/scripts/com/greensock/TweenLite.as
 *   （ctor :90-126、initClass :128-145、killTweensOf :147-171、from :173-181、
 *   easeOut :183-186、delayedCall :188-198、to :231-234、renderTime :241-320、
 *   init :348-435、killVars :437-490）
 * - legacy/decompiled/main3_v_221/scripts/com/greensock/core/TweenCore.as
 *   （ctor :54-84 的 active 判定、complete :154-180 的 onComplete 门）
 */
class TweenLiteTest {
	public function new() {}

	// :90-126 + TweenCore.as:54-84：duration>0 且无 immediateRender 时构造期
	// active 为假（param1==0 才真）→ :122 的 renderTime(0) 不跑，目标属性
	// 保持原值、不 init；:231-234 to 返回 new TweenLite、:94 记 target
	public function test_to_leaves_target_untouched_until_first_render() {
		var target = {x: 0.0};
		var tween = TweenLite.to(target, 1, {x: 100.0});
		Assert.notNull(tween);
		Assert.equals(target, tween.target);
		Assert.equals(0.0, target.x);
		Assert.isFalse(tween.initted);
	}

	// :286-289 早退门：首调 renderTime(0) 时 cachedTime 与 _loc5_ 同为 0 且
	// 未带 force → 直接 return，不 init、不写起点、ratio 保持 0
	public function test_first_render_at_zero_returns_early_without_init() {
		var target = {x: 5.0};
		var tween = TweenLite.to(target, 1, {x: 100.0});
		tween.renderTime(0);
		Assert.isFalse(tween.initted);
		Assert.equals(5.0, target.x);
		Assert.equals(0.0, tween.ratio);
	}

	// :30 defaultEase=easeOut、:183-186 公式 1-(1-t/d)²、:284/:295 ratio=
	// _ease(t,0,1,d)、:305 写 start + ratio*change。多组 (t,d) 采样（公式只
	// 看 t/d，d=2 验证 cachedDuration 作第四参），含非零起点
	public function test_default_ease_out_interpolation_sampling() {
		var cases:Array<{t:Float, d:Float, from:Float, to:Float, expectedRatio:Float, why:String}> = [
			{t: 0.25, d: 1.0, from: 0.0, to: 100.0, expectedRatio: 0.4375, why: "1-(1-0.25)²=0.4375"},
			{t: 0.5, d: 1.0, from: 0.0, to: 100.0, expectedRatio: 0.75, why: "1-(1-0.5)²=0.75"},
			{t: 0.5, d: 2.0, from: 0.0, to: 100.0, expectedRatio: 0.4375, why: "t/d=0.25，同首行"},
			{t: 1.5, d: 2.0, from: 10.0, to: 20.0, expectedRatio: 0.9375, why: "1-(1-0.75)²=0.9375，非零起点"}
		];
		for (c in cases) {
			var target = {x: c.from};
			var tween = TweenLite.to(target, c.d, {x: c.to});
			tween.renderTime(c.t);
			Assert.equals(c.expectedRatio, tween.ratio, 'ratio t=${c.t} d=${c.d}（${c.why}）');
			Assert.equals(c.from + c.expectedRatio * (c.to - c.from), target.x, 'x t=${c.t} d=${c.d}（${c.why}）');
		}
	}

	// :356-359 init：vars.ease 是函数则覆盖 _ease（linear → ratio = t/d）
	public function test_custom_ease_function_replaces_default() {
		var target = {x: 0.0};
		var tween = TweenLite.to(target, 1, {x: 100.0, ease: function(t:Float, b:Float, c:Float, d:Float):Float {
			return t / d;
		}});
		tween.renderTime(0.5);
		Assert.equals(0.5, tween.ratio);
		Assert.equals(50.0, target.x);
	}

	// :246-259 终点分支（ratio=1、_loc4_ 完成）+ :302-307 先写值后 :312-319
	// complete（TweenCore.as:154-180 onComplete 门）+ :286-289 再推同刻早退
	// 不重复派发；complete(true) 经 rootTimeline.autoRemoveChildren 置 gc
	public function test_render_at_duration_completes_and_fires_onComplete_once() {
		var target = {x: 0.0};
		var fired = 0;
		var xAtFire = -1.0;
		var tween = TweenLite.to(target, 1, {x: 100.0, onComplete: function(p:Int):Void {
			fired++;
			xAtFire = target.x;
		}, onCompleteParams: [7]});
		tween.renderTime(1);
		Assert.equals(100.0, target.x); // :305 ratio=1 → start+change
		Assert.equals(1.0, tween.ratio); // :249
		Assert.equals(1, fired);
		Assert.equals(100.0, xAtFire); // 写值（:302-307）先于 complete（:318）
		Assert.isTrue(tween.gc); // setEnabled(false) 收尾
		tween.renderTime(1);
		Assert.equals(1, fired); // :286-289 早退，不重复 complete
	}

	// :173-181 from 写入 runBackwards、缺省补 immediateRender=true → 构造期
	// :122 即 renderTime(0,false,true)：init :408-417 交换 start/change
	// （start=vars 值、change 取反），ratio=0 时目标已停在 vars 值；推到
	// 终点回到原值（FarmLandsView 飞机 scale 3→1 同款语义）
	public function test_from_renders_backwards_start_immediately() {
		var target = {x: 10.0};
		var tween = TweenLite.from(target, 1, {x: 100.0});
		Assert.equals(true, Reflect.field(tween.vars, "runBackwards")); // :175
		Assert.equals(true, Reflect.field(tween.vars, "immediateRender")); // :176-179
		Assert.equals(100.0, target.x); // start=100、ratio=0
		tween.renderTime(1);
		Assert.equals(10.0, target.x); // ratio=1 → 100 + 1*(-90)
	}

	// :101 _overwrite 缺省取 overwriteManager.mode=1（initClass :140-144）→
	// :107-117 同目标第二个补间把未 gc 的第一个 setEnabled(false)（gc 置位、
	// masterList 换成只剩新补间）
	public function test_overwrite_default_kills_previous_tween_on_same_target() {
		var target = {x: 0.0, y: 0.0};
		var first = TweenLite.to(target, 1, {x: 100.0});
		var second = TweenLite.to(target, 1, {y: 50.0});
		Assert.isTrue(first.gc);
		Assert.isFalse(first.active); // setEnabled(false) 顺带摘活
		Assert.isFalse(second.gc);
		second.renderTime(0.5);
		Assert.equals(37.5, target.y); // 0 + 0.75*50
		Assert.equals(0.0, target.x); // first 从未 init，x 不动
	}

	// :101 显式 overwrite:0 → _overwrite=0 → :119-120 只追加不禁用，同目标
	// 两个补间并行到各自终点
	public function test_overwrite_zero_keeps_both_tweens() {
		var target = {x: 0.0, y: 0.0};
		var first = TweenLite.to(target, 1, {x: 100.0, overwrite: 0});
		var second = TweenLite.to(target, 1, {y: 50.0, overwrite: 0});
		Assert.isFalse(first.gc);
		Assert.isFalse(second.gc);
		first.renderTime(1);
		second.renderTime(1);
		Assert.equals(100.0, target.x);
		Assert.equals(50.0, target.y);
	}

	// :102-106 masterList 按目标身份分桶：内容相同的两个目标对象也不能串桶
	// （AS3 Dictionary 身份键语义；若实现退化成字符串键，本用例的 ta.gc
	// 会因 tb 建桶时覆盖而误真）
	public function test_tweens_on_distinct_targets_are_independent() {
		var a = {x: 0.0};
		var b = {x: 0.0};
		var ta = TweenLite.to(a, 1, {x: 100.0});
		var tb = TweenLite.to(b, 1, {x: 200.0});
		Assert.isFalse(ta.gc);
		Assert.isFalse(tb.gc);
		ta.renderTime(0.5);
		tb.renderTime(0.5);
		Assert.equals(75.0, a.x);
		Assert.equals(150.0, b.x); // 0 + 0.75*200
	}

	// :188-198 delayedCall：duration 0、immediateRender:false、overwrite:0 →
	// 构造期不派发；推进越过 delay 的本地时刻即 complete（:246-258 duration==0
	// 的 rawPrevTime 门 + TweenCore complete 门），二次推进 :286-289 早退不
	// 重复派发
	public function test_delayedCall_fires_once_when_driven_past_delay() {
		var fired = 0;
		var received = -1;
		var tween = TweenLite.delayedCall(2, function(p:Int):Void {
			fired++;
			received = p;
		}, [41]);
		Assert.notNull(tween); // :190-197 返回 new TweenLite
		Assert.equals(0, fired); // 构造期不派发
		tween.renderTime(2.5);
		Assert.equals(1, fired);
		Assert.equals(41, received); // onCompleteParams 透传
		tween.renderTime(3);
		Assert.equals(1, fired);
	}

	// :147-171 killTweensOf(target)（param2 缺省 false）：逐个 setEnabled(false)
	// 并删 masterList 桶——不补渲染、不派发 onComplete，停在杀掉时的值
	public function test_killTweensOf_disables_without_completing() {
		var target = {x: 0.0};
		var fired = 0;
		var tween = TweenLite.to(target, 1, {x: 100.0, onComplete: function():Void {
			fired++;
		}});
		tween.renderTime(0.5);
		Assert.equals(75.0, target.x);
		TweenLite.killTweensOf(target);
		Assert.isTrue(tween.gc); // :165 setEnabled(false,false)
		Assert.equals(75.0, target.x);
		Assert.equals(0, fired);
	}

	// :157-163 param2=true → complete(false,false) 补渲染到 cachedTotalDuration
	// 再收尾：终点值与 onComplete 都到
	public function test_killTweensOf_with_complete_renders_end_state() {
		var target = {x: 0.0};
		var fired = 0;
		var tween = TweenLite.to(target, 1, {x: 100.0, onComplete: function():Void {
			fired++;
		}});
		TweenLite.killTweensOf(target, true);
		Assert.equals(100.0, target.x);
		Assert.equals(1, fired);
		Assert.isTrue(tween.gc);
	}

	// :437-490 killVars：把 x 的 PropTween 从链表与 propTweenLookup 摘除
	// （:481 delete），之后推进只写余下属性，x 停在摘除时的值；非插件路径
	// 返回值恒假（_loc5_ 只在插件 activeDisable 置真）
	public function test_killVars_freezes_removed_property() {
		var target = {x: 0.0, y: 0.0};
		var tween = TweenLite.to(target, 1, {x: 100.0, y: 50.0});
		tween.renderTime(0.5);
		Assert.equals(75.0, target.x);
		Assert.equals(37.5, target.y);
		Assert.isFalse(tween.killVars({x: 1}));
		tween.renderTime(1);
		Assert.equals(75.0, target.x); // x 已摘链
		Assert.equals(50.0, target.y);
		Assert.isFalse(Reflect.hasField(tween.propTweenLookup, "x")); // :481
	}

	// :399-400 init 为每个数值属性建 PropTween（start=当前值、change=目标值-
	// 当前值）并登记 propTweenLookup（:365-401；onComplete 等保留属性
	// （:36-70 _reservedProps）不建）
	public function test_propTween_lookup_records_start_and_change() {
		var target = {x: 20.0};
		var tween = TweenLite.to(target, 1, {x: 120.0, onComplete: function():Void {}});
		tween.renderTime(0.5); // 触发 init
		var pt:Dynamic = Reflect.field(tween.propTweenLookup, "x");
		Assert.notNull(pt);
		Assert.equals(20.0, pt.start); // init 时的当前值
		Assert.equals(100.0, pt.change); // 120 - 20
		Assert.equals(target, pt.target);
		Assert.equals("x", pt.property);
		Assert.isFalse(Reflect.hasField(tween.propTweenLookup, "onComplete")); // 保留属性不建 PT
	}

	// :128-145 首个实例构造触发 TweenCore 构造链 → initClass（#18 已译的
	// 四静态真身；本用例对 stub 即绿——钉实现期补 _shape/ENTER_FRAME hookup
	// 时不得破坏该链）
	public function test_constructor_chain_wires_root_timelines() {
		new TweenLite({}, 1, {});
		Assert.equals(0.0, TweenLite.rootFrame); // :130
		Assert.notNull(TweenLite.rootTimeline); // :131
		Assert.notNull(TweenLite.rootFramesTimeline); // :132
		Assert.isTrue(TweenLite.rootTimeline.autoRemoveChildren); // :135
		Assert.isTrue(TweenLite.rootFramesTimeline.autoRemoveChildren); // :136
		Assert.notNull(TweenLite.overwriteManager); // :138-144
	}
}
