package common.view.cursor;

import CursorHoe;
import common.Consts;
import events.CursorEvent;
import support.FakeMsgCenter;
import utest.Assert;

/**
 * CursorControl 光标控件纯逻辑（issue #9）：注册表查询、setCursor 的
 * SET_CURSOR 派发、useSystem 的系统/自定义切换播报。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/common/view/cursor/
 * CursorControl.as（ctor :20-26、getClass :32-42、register :45-51、
 * useSystem :74-86、setCursor :88-99）；Consts.as:112/:114
 * （CURSOR_SYSTEM/CURSOR_CUSTOMIZE 取值）。
 *
 * CursorLayer 据 SET_CURSOR 换光标实例、FarmApplication 据 SWITCH_CURSOR 调
 * Mouse.hide/show——派发内容本身就是验收面，用 FakeMsgCenter 记录断言。
 * 注册表用真光标类引用（CursorHoe，#7 的素材壳）。
 */
class CursorControlTest {
	public function new() {}

	// :88-99：setCursor 记名/参数并派发 SET_CURSOR（cursorName/cursorArgument）；
	// 预先 :45-51 register、:32-42 getClass 走一遍注册表
	public function test_register_lookup_and_setcursor_dispatch() {
		var center = new FakeMsgCenter();
		var ctrl = new CursorControl(center);

		Assert.isNull(ctrl.name); // :23 ctor 里 m_name = m_preName = null
		Assert.isNull(ctrl.getClass("CursorHoe")); // :38-40 未注册
		Assert.isNull(ctrl.getClass("")); // :34-36 空名直接 null

		ctrl.register(Consts.CURSOR_STYLE_HOE, CursorHoe); // :45-51
		Assert.equals(CursorHoe, ctrl.getClass(Consts.CURSOR_STYLE_HOE));

		ctrl.setCursor(Consts.CURSOR_STYLE_HOE, "3,6");

		Assert.equals(Consts.CURSOR_STYLE_HOE, ctrl.name); // :94
		Assert.equals("3,6", ctrl.cursorArgument); // :95
		Assert.equals(1, center.events.length);
		var ce = cast(center.events[0], CursorEvent);
		Assert.equals(CursorEvent.SET_CURSOR, ce.type);
		Assert.equals(Consts.CURSOR_STYLE_HOE, ce.cursorName); // :97
		Assert.equals("3,6", ce.cursorArgument); // :98
	}

	// :90-93：name 非空才滚动 preName；重设同名也再次派发（无去重门）
	public function test_setcursor_keeps_prename_only_for_nonempty_name() {
		var center = new FakeMsgCenter();
		var ctrl = new CursorControl(center);

		ctrl.setCursor(Consts.CURSOR_STYLE_HOE);
		ctrl.setCursor(Consts.CURSOR_STYLE_WATER, "2,4");
		ctrl.setCursor(Consts.CURSOR_STYLE_HOE);

		Assert.equals(3, center.events.length); // 每次 setCursor 都派发
		Assert.equals(Consts.CURSOR_STYLE_HOE, ctrl.name);
		Assert.equals("", ctrl.cursorArgument); // 默认参数空串
	}

	// :74-86：useSystem(true/false) → SWITCH_CURSOR 带系统/自定义名
	//（Consts.as:112/:114），默认 true
	public function test_useSystem_switches_between_system_and_customize() {
		var center = new FakeMsgCenter();
		var ctrl = new CursorControl(center);

		ctrl.useSystem(true);
		ctrl.useSystem(false);
		ctrl.useSystem(); // 默认参 true

		Assert.equals(3, center.events.length);
		Assert.equals(CursorEvent.SWITCH_CURSOR, center.events[0].type);
		Assert.equals(Consts.CURSOR_SYSTEM, cast(center.events[0], CursorEvent).cursorName); // :79
		Assert.equals(Consts.CURSOR_CUSTOMIZE, cast(center.events[1], CursorEvent).cursorName); // :83
		Assert.equals(Consts.CURSOR_SYSTEM, cast(center.events[2], CursorEvent).cursorName); // :74 默认参 true
	}
}
