package com.qzone.qui.managers;

import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import utest.Assert;

/**
 * DragManager 纯逻辑（issue #44）：_targets 按 hitArea.name 登记的注册表
 * （addTarget :86-98 的 `param3 || param1` 缺省命中区、removeTarget :57-66
 * 的 hasOwnProperty 门）与 MOUSE_DOWN → 父容器挂 MOUSE_MOVE/MOUSE_UP
 * （loader_MOUSE_DOWN :74-84 + addEvent :51-55）、MOUSE_MOVE 起拖
 * （loader_MOUSE_MOVE :34-49）、MOUSE_UP 摘监听 + `_draging` 时派发
 * "LOCATION_CHANGE"（loader_MOUSE_UP :100-109，:104 门——未拖过不派发）。
 *
 * 测法：真 new Sprite() 作 target/hitArea/parent（MouseEvent 派发不需要
 * 舞台，容器内实测通；loader_MOUSE_DOWN 的 `_target.stage` 回退因显式传
 * param4 父容器而不触发）。Sprite 名字由 openfl 自动生成且全局唯一
 * （instanceN），_targets 按名键不串。startDrag/stopDrag 无舞台不炸
 * （openfl 只置拖拽位）。触屏合成、真实拖拽视觉归 shim/CI。
 *
 * stub 阶段失败点：addTarget/removeTarget 是 no-op，监听永不出现。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/com/qzone/qui/managers/DragManager.as
 */
class DragManagerTest {
	public function new() {}

	// :86-98：addTarget 缺省 hitArea=target 自身（:91 `param3 || param1`），
	// MOUSE_DOWN 监听落在它上面；removeTarget(:57-66) 按名摘除
	public function test_addTarget_listens_mousedown_on_target_itself() {
		var target = new Sprite();
		DragManager.addTarget(target);
		Assert.isTrue(target.hasEventListener(MouseEvent.MOUSE_DOWN)); // :97
		DragManager.removeTarget(target);
		Assert.isFalse(target.hasEventListener(MouseEvent.MOUSE_DOWN)); // :63
	}

	// :91 + :57-59：显式 hitArea 时监听挂 hitArea、不挂 target；摘除也按
	// hitArea（`param2 || param1`）
	public function test_addTarget_explicit_hitArea_receives_listener() {
		var target = new Sprite();
		var hitArea = new Sprite();
		DragManager.addTarget(target, null, hitArea);
		Assert.isTrue(hitArea.hasEventListener(MouseEvent.MOUSE_DOWN));
		Assert.isFalse(target.hasEventListener(MouseEvent.MOUSE_DOWN));
		DragManager.removeTarget(target, hitArea);
		Assert.isFalse(hitArea.hasEventListener(MouseEvent.MOUSE_DOWN));
	}

	// :61-65：未登记的名字摘除是 no-op（hasOwnProperty 门），不抛错
	public function test_removeTarget_unregistered_is_noop() {
		var fresh = new Sprite();
		DragManager.removeTarget(fresh); // 不应抛错
		Assert.isFalse(fresh.hasEventListener(MouseEvent.MOUSE_DOWN));
	}

	// :74-84 + :51-55 + :68-72 + :100-109：MOUSE_DOWN 后父容器挂
	// MOUSE_MOVE/MOUSE_UP 两监听；MOUSE_UP 后双双摘除；未拖过（_draging
	// false）不派发 LOCATION_CHANGE（:104 门）
	public function test_mousedown_wires_parent_listeners_until_mouseup() {
		var target = new Sprite();
		var hitArea = new Sprite();
		var parent = new Sprite();
		var locations = 0;
		target.addEventListener("LOCATION_CHANGE", function(_:Event):Void locations++);
		DragManager.addTarget(target, null, hitArea, parent);
		hitArea.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
		Assert.isTrue(parent.hasEventListener(MouseEvent.MOUSE_MOVE)); // :53
		Assert.isTrue(parent.hasEventListener(MouseEvent.MOUSE_UP)); // :54
		parent.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
		Assert.isFalse(parent.hasEventListener(MouseEvent.MOUSE_MOVE)); // :70
		Assert.isFalse(parent.hasEventListener(MouseEvent.MOUSE_UP)); // :71
		Assert.equals(0, locations); // :104 未拖过不派发
		DragManager.removeTarget(target, hitArea);
	}

	// :34-49 + :100-108：MOUSE_MOVE 起拖（_draging 置位 + startDrag）后
	// MOUSE_UP → target 收到一次 "LOCATION_CHANGE"
	public function test_drag_move_then_mouseup_dispatches_location_change() {
		var target = new Sprite();
		var hitArea = new Sprite();
		var parent = new Sprite();
		var locations = 0;
		target.addEventListener("LOCATION_CHANGE", function(_:Event):Void locations++);
		DragManager.addTarget(target, null, hitArea, parent);
		hitArea.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
		parent.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE)); // :37-39 起拖
		parent.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP)); // :102-108
		Assert.equals(1, locations); // :106
		DragManager.removeTarget(target, hitArea);
	}
}
