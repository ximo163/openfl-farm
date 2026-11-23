package common.view.tip;

import common.Consts;
import events.TipEvent;
import support.FakeMsgCenter;
import utest.Assert;

/**
 * TipControl 提示控件纯逻辑（issue #42）：注册表查询 + show/update/hide 的
 * TipEvent 派发。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/common/view/tip/TipControl.as
 * （update :25-31、getClass :33-40、hide :42-46、register :48-55、show :57-65；
 * TipEvent 类型常量 TipEvent.as:9-11 "tipShow"/"update"/"tipHide"）。
 *
 * 派发内容本身就是验收面（TipLayer 据 TIP_SHOW 延时建 tip 实例、TIP_UPDATE
 * 刷新同屏 tip），用 FakeMsgCenter 记录断言；注册表用真类引用（MouseTip）。
 * stub 阶段失败点：show/hide/update 是空体 stub——不派发，events 计数 0。
 */
class TipControlTest {
	public function new() {}

	// :57-65：show → TIP_SHOW 带 tip 名 / 载荷 / tX / tY；同一控制面先走一遍
	// 注册表（:48-55 写入、:33-40 查询）确保链路自洽（FarmStage 按同款
	// register(Consts.TIP_NAME_MOUSE, MouseTip) 建表）
	public function test_show_dispatches_tip_show_with_payload() {
		var center = new FakeMsgCenter();
		var tc = new TipControl(center);
		tc.register(Consts.TIP_NAME_MOUSE, MouseTip);
		Assert.equals(MouseTip, tc.getClass(Consts.TIP_NAME_MOUSE)); // :54
		Assert.isNull(tc.getClass("NoSuchTip")); // 未注册 → null（:39）

		var payload = {x: 1};
		tc.show(Consts.TIP_NAME_LAND_INFOR, payload, 12, 34);

		if (center.events.length != 1) {
			Assert.fail("expected one dispatched TipEvent, got " + center.events.length); // stub 无派发
			return;
		}
		var te = cast(center.events[0], TipEvent);
		Assert.equals(TipEvent.TIP_SHOW, te.type);
		Assert.equals("tipShow", te.type); // TipEvent.as:10
		Assert.equals(Consts.TIP_NAME_LAND_INFOR, te.tipType); // :62
		Assert.equals(payload, te.tipArgument); // :61 原样引用
		Assert.equals(12, te.tX); // :63
		Assert.equals(34, te.tY); // :64
	}

	// :57-65：tX/tY 缺省 0（默认参 param3:int = 0, param4:int = 0）
	public function test_show_defaults_txy_to_zero() {
		var center = new FakeMsgCenter();
		var tc = new TipControl(center);
		tc.show(Consts.TIP_NAME_MOUSE, "文字提示");

		if (center.events.length != 1) {
			Assert.fail("expected one dispatched TipEvent, got " + center.events.length);
			return;
		}
		var te = cast(center.events[0], TipEvent);
		Assert.equals(0, te.tX);
		Assert.equals(0, te.tY);
	}

	// :25-31：update → TIP_UPDATE（"update"）带 tip 名 / 载荷
	public function test_update_dispatches_tip_update_with_payload() {
		var center = new FakeMsgCenter();
		var tc = new TipControl(center);
		var payload = {itemName: "稻草人"};
		tc.update(Consts.TIP_NAME_DIY_MOUSE, payload);

		if (center.events.length != 1) {
			Assert.fail("expected one dispatched TipEvent, got " + center.events.length);
			return;
		}
		var te = cast(center.events[0], TipEvent);
		Assert.equals(TipEvent.TIP_UPDATE, te.type);
		Assert.equals("update", te.type); // TipEvent.as:11
		Assert.equals(Consts.TIP_NAME_DIY_MOUSE, te.tipType); // :29
		Assert.equals(payload, te.tipArgument); // :28
	}

	// :42-46：hide → TIP_HIDE 只带类型名；tipType 保持事件 ctor 的 ""
	// （TipEvent.as:17）；全新控制面 getClass 恒 null（:35-38 的 m_lib null 门）
	public function test_hide_dispatches_tip_hide_bare() {
		var center = new FakeMsgCenter();
		var tc = new TipControl(center);
		Assert.isNull(tc.getClass(Consts.TIP_NAME_MOUSE)); // m_lib 未建

		tc.hide();

		if (center.events.length != 1) {
			Assert.fail("expected one dispatched TipEvent, got " + center.events.length);
			return;
		}
		var te = cast(center.events[0], TipEvent);
		Assert.equals(TipEvent.TIP_HIDE, te.type);
		Assert.equals("tipHide", te.type); // TipEvent.as:9
		Assert.equals("", te.tipType); // hide 不写字段
	}
}
