package common.view.window;

import common.Consts;
import events.WindowEvent;
import support.FakeMsgCenter;
import utest.Assert;

/**
 * WindowControl 纯逻辑（issue #41）：窗口注册表（register/getClass）与
 * open/openForName/close/closeForName 的 WindowEvent 派发语义。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/common/view/window/
 * WindowControl.as（getClass :35-42 的 m_lib null 门、open :24-33、
 * openForName :44-54 的名空早退、register :56-63、closeForName :65-74、
 * close :76-85；事件类型常量 events/WindowEvent.as:9/:11
 * CLOSE="windowClose"/OPEN="windowOpen"）。
 *
 * 窗口实例用 Type.createEmptyInstance 造句柄（open/close 只存引用不碰
 * 显示树，:31/:83 只赋 _loc2_.window）。派发经 FakeMsgCenter 记录
 * （FloatingBaseTest 先例）。
 */
class WindowControlTest {
	public function new() {}

	// :56-63 + :35-42：register 进注册表后 getClass 按名取回；未注册名与
	// 「从未 register 过」的控件（m_lib null 门）都取 null
	public function test_register_then_getClass_returns_it_and_null_for_unknown() {
		var center = new FakeMsgCenter();
		var ctrl = new WindowControl(center);
		// m_lib null 门（:36-39）：一个都没注册时恒 null
		Assert.isNull(ctrl.getClass("AlertWindow"));
		ctrl.register("AlertWindow", AlertWindow);
		Assert.equals(AlertWindow, ctrl.getClass("AlertWindow"));
		// 注册表外的名字不命中
		Assert.isNull(ctrl.getClass("NoSuchWindow"));
		// 重名后注册覆盖前者
		ctrl.register("AlertWindow", ConfirmWindow);
		Assert.equals(ConfirmWindow, ctrl.getClass("AlertWindow"));
	}

	// :26-29：null 窗口早退，不派发
	public function test_open_null_window_dispatches_nothing() {
		var center = new FakeMsgCenter();
		var ctrl = new WindowControl(center);
		ctrl.open(null);
		Assert.equals(0, center.events.length);
	}

	// :30-33：open 弹已建好的窗 → 恰一条 windowOpen，window 挂实例
	public function test_open_dispatches_windowOpen_with_window_instance() {
		var center = new FakeMsgCenter();
		var ctrl = new WindowControl(center);
		var win = Type.createEmptyInstance(AlertWindow);
		ctrl.open(win);
		Assert.equals(1, center.events.length);
		var ev:WindowEvent = cast center.events[0];
		Assert.equals(WindowEvent.OPEN, ev.type); // "windowOpen"
		Assert.equals(win, ev.window);
	}

	// :46-49：名 null / 空串早退，不派发
	public function test_openForName_empty_name_dispatches_nothing() {
		var center = new FakeMsgCenter();
		var ctrl = new WindowControl(center);
		ctrl.openForName(null);
		ctrl.openForName("");
		Assert.equals(0, center.events.length);
	}

	// :50-53：openForName → windowOpen，windowName/windowArgument 落事件、
	// window 保持 null（按名弹窗不预建实例）
	public function test_openForName_dispatches_windowOpen_with_name_and_argument() {
		var center = new FakeMsgCenter();
		var ctrl = new WindowControl(center);
		var arg = {place: 3, text: "升级红土地"};
		ctrl.openForName("AlertWindow", arg);
		Assert.equals(1, center.events.length);
		var ev:WindowEvent = cast center.events[0];
		Assert.equals(WindowEvent.OPEN, ev.type);
		Assert.equals("AlertWindow", ev.windowName);
		Assert.equals(arg, ev.windowArgument);
		Assert.isNull(ev.window);
	}

	// :77-80：null 窗口早退，不派发
	public function test_close_null_window_dispatches_nothing() {
		var center = new FakeMsgCenter();
		var ctrl = new WindowControl(center);
		ctrl.close(null);
		Assert.equals(0, center.events.length);
	}

	// :81-85：close 关已建好的窗 → 恰一条 windowClose，window 挂实例
	public function test_close_dispatches_windowClose_with_window_instance() {
		var center = new FakeMsgCenter();
		var ctrl = new WindowControl(center);
		var win = Type.createEmptyInstance(ConfirmWindow);
		ctrl.close(win);
		Assert.equals(1, center.events.length);
		var ev:WindowEvent = cast center.events[0];
		Assert.equals(WindowEvent.CLOSE, ev.type); // "windowClose"
		Assert.equals(win, ev.window);
	}

	// :66-69：名 null / 空串早退，不派发
	public function test_closeForName_empty_name_dispatches_nothing() {
		var center = new FakeMsgCenter();
		var ctrl = new WindowControl(center);
		ctrl.closeForName(null);
		ctrl.closeForName("");
		Assert.equals(0, center.events.length);
	}

	// :70-74：closeForName → windowClose，只落 windowName
	public function test_closeForName_dispatches_windowClose_with_name() {
		var center = new FakeMsgCenter();
		var ctrl = new WindowControl(center);
		ctrl.closeForName(Consts.WINDOW_NAME_ALERT);
		Assert.equals(1, center.events.length);
		var ev:WindowEvent = cast center.events[0];
		Assert.equals(WindowEvent.CLOSE, ev.type);
		Assert.equals(Consts.WINDOW_NAME_ALERT, ev.windowName);
		Assert.isNull(ev.window);
	}
}
