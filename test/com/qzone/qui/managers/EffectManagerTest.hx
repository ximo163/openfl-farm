package com.qzone.qui.managers;

import openfl.display.Sprite;
import utest.Assert;

/**
 * EffectManager 纯逻辑（issue #44）：playEffect 的无 effect 分支
 * （:38-41）——目标未挂 "effect" 动效时，effectInstances 里登记过的旧实例
 * 先 complete()（:39），再以 rest 参数调用完成回调（:40 apply）；In/Out
 * 只是按名路由（"In"/"Out"，:26-29/:44-47）。
 *
 * 测法：真 new Sprite() 作容器/目标（DisplayObject 家族，编译口径与翻译
 * 后的形参类型都兼容）。挂 "effect" 属性的目标分支（:33-36）不进单测——
 * 需要带 effect 动效属性的显示对象（依赖 ClipProps/子类字段等实现侧表
 * 示），归 CI 画面比对。effectInstances 是公共静态弱键字典，测试直接种
 * entry 驱动 :39，用例尾摘除。
 *
 * stub 阶段失败点：In/Out/playEffect 是 no-op，回调与 complete 都不触发。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/com/qzone/qui/managers/EffectManager.as
 * （In :26-29、playEffect :31-42、Out :44-47）
 */
class EffectManagerTest {
	public function new() {}

	// :26-29 → :38-41：无 effect 目标走 else——完成回调以 rest 参数调用
	public function test_In_without_effect_invokes_callback_with_args() {
		var container = new Sprite();
		var target = new Sprite();
		var calls = 0;
		var gotA:Dynamic = null;
		var gotB:Dynamic = null;
		var fn:Dynamic = function(a:Dynamic = null, b:Dynamic = null):Void {
			calls++;
			gotA = a;
			gotB = b;
		};
		EffectManager.In(container, target, fn, [3, "好"]);
		Assert.equals(1, calls); // :40
		Assert.equals(3, gotA); // rest 透传
		Assert.equals("好", gotB);
	}

	// :44-47 → :38-41：Out 同路（按名 "Out" 路由）
	public function test_Out_without_effect_invokes_callback_with_args() {
		var container = new Sprite();
		var target = new Sprite();
		var calls = 0;
		var got:Dynamic = null;
		var fn:Dynamic = function(a:Dynamic = null):Void {
			calls++;
			got = a;
		};
		EffectManager.Out(container, target, fn, [9]);
		Assert.equals(1, calls);
		Assert.equals(9, got);
	}

	// :40：param5 缺省 null → apply(null, null) 以零参调用
	public function test_playEffect_null_args_invokes_callback_without_args() {
		var container = new Sprite();
		var target = new Sprite();
		var calls = 0;
		var fn:Dynamic = function(a:Dynamic = null):Void {
			calls++;
			Assert.isNull(a); // 无参调用
		};
		EffectManager.playEffect("In", container, target, fn, null);
		Assert.equals(1, calls);
	}

	// :39-40：无 effect 但 effectInstances 已登记旧实例 → 先 complete()
	// 再调回调（两行都执行）
	public function test_playEffect_calls_registered_complete_then_callback() {
		var container = new Sprite();
		var target = new Sprite();
		var completes = 0;
		var calls = 0;
		EffectManager.effectInstances.set(target, {complete: function():Void completes++});
		var fn:Dynamic = function():Void {
			calls++;
		};
		EffectManager.playEffect("In", container, target, fn, []);
		Assert.equals(1, completes); // :39
		Assert.equals(1, calls); // :40
		EffectManager.effectInstances.remove(target); // 用例清理
	}
}
