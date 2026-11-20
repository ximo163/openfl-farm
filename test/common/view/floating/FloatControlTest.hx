package common.view.floating;

import common.Consts;
import events.FloatingEvent;
import support.FakeMsgCenter;
import utest.Assert;

/**
 * FloatControl 飘字控件纯逻辑（issue #9）：open/close 的经 msgCenter 派发、
 * 注册表查询。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/common/view/floating/
 * FloatControl.as（open :20-27、getClass :34-41、register :43-51、
 * close :52-58）。
 *
 * 派发内容本身就是验收面（FloatingLayer 据 FLOATING_OPEN 建 float 实例），
 * 用 FakeMsgCenter 记录断言；注册表用真类引用（HarvestAnimation）。
 */
class FloatControlTest {
	public function new() {}

	// :20-27：open → FLOATING_OPEN 带 floating 名 / fid / 原样 data；
	// 同一控制面先走一遍注册表（:43-51 写入、:34-41 查询）确保链路自洽
	public function test_open_dispatches_floating_open_with_payload() {
		var center = new FakeMsgCenter();
		var fc = new FloatControl(center);
		fc.register(Consts.FLOAT_TYPE_HA, HarvestAnimation);
		Assert.equals(HarvestAnimation, fc.getClass(Consts.FLOAT_TYPE_HA));
		Assert.isNull(fc.getClass("NoSuchFloat")); // 未注册 → null

		fc.open(Consts.FLOAT_TYPE_HA, 7, {text: "20", cId: 2});

		Assert.equals(1, center.events.length);
		var fe = cast(center.events[0], FloatingEvent);
		Assert.equals(FloatingEvent.FLOATING_OPEN, fe.type);
		Assert.equals(Consts.FLOAT_TYPE_HA, fe.floating); // :23
		Assert.equals(7, fe.fid); // :24
		Assert.equals("20", Reflect.field(fe.data, "text")); // :25 原样引用
	}

	// :52-58：close → FLOATING_CLOSE 只带 floating 名；未注册过的控制面
	// getClass 恒 null（:35-38 的 m_lib null 门）
	public function test_close_dispatches_floating_close_by_name() {
		var center = new FakeMsgCenter();
		var fc = new FloatControl(center);
		Assert.isNull(fc.getClass(Consts.FLOAT_TYPE_MONEY)); // 全新控制面

		fc.close(Consts.FLOAT_TYPE_MONEY);

		Assert.equals(1, center.events.length);
		var fe = cast(center.events[0], FloatingEvent);
		Assert.equals(FloatingEvent.FLOATING_CLOSE, fe.type);
		Assert.equals(Consts.FLOAT_TYPE_MONEY, fe.floating); // :55
		Assert.equals(-1, fe.fid); // close 不写 fid，保持事件 ctor 的 -1
	}
}
