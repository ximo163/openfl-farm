package module.load;

import common.Consts;
import common.view.DataLoading;
import events.CommonEvent;
import openfl.display.Sprite;
import openfl.events.TextEvent;
import openfl.text.TextField;
import support.FakeMsgCenter;
import utest.Assert;

/**
 * module.load.UserChangingBar 纯逻辑（issue #43）：onUserSwitchResult 的
 * 切换结果分支（null 门 / error 缺位或空串走 showLoading / 非空走错误文案）
 * 与 onLinkClicked 的 __reload__ 重派发。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/module/load/UserChangingBar.as
 * （onUserSwitchResult :59-76、onLinkClicked :78-83；三个显示件是
 * onAddedToStage :31-57 才建的——stage 语义不进单测，直接钉实例）。
 *
 * 期望初态对齐 :38/:43/:54（三件都 visible=false 的静默态）。
 * stub 阶段失败点：onUserSwitchResult/onLinkClicked 是 throw stub。
 */
@:access(module.load.UserChangingBar)
class UserChangingBarTest {
	public function new() {}

	// 空实例 + 钉 onAddedToStage 产物：三显示件全 visible=false（:38/:43/:54）
	private function makeBar():{bar:UserChangingBar, mask:Sprite, loading:DataLoading, text:TextField} {
		var bar = Type.createEmptyInstance(UserChangingBar);
		var mask = new Sprite();
		mask.visible = false;
		var loading = new DataLoading();
		loading.visible = false;
		var text = new TextField();
		text.visible = false;
		Reflect.setField(bar, "m_mask", mask);
		Reflect.setField(bar, "m_dataLoading", loading);
		Reflect.setField(bar, "m_textField", text);
		return {bar: bar, mask: mask, loading: loading, text: text};
	}

	// :61-64 null 事件 / null data：早退，三件静默态不动
	public function test_onUserSwitchResult_null_event_or_data_is_noop() {
		var t = makeBar();
		t.mask.visible = true; // 哨兵：早退则保持，走了分支则被覆盖
		t.bar.onUserSwitchResult(null);
		Assert.isTrue(t.mask.visible);

		var t2 = makeBar();
		t2.bar.onUserSwitchResult(new CommonEvent(Consts.MSG_USER_SWITCH_FLAG, null));
		Assert.isFalse(t2.mask.visible);
		Assert.isFalse(t2.loading.visible);
		Assert.isFalse(t2.text.visible);
	}

	// :65-69 error 键缺位：showLoading 布尔直写遮罩与转圈
	public function test_onUserSwitchResult_showLoading_drives_mask_and_spinner() {
		var on = makeBar();
		on.bar.onUserSwitchResult(new CommonEvent(Consts.MSG_USER_SWITCH_FLAG, {showLoading: true}));
		Assert.isTrue(on.mask.visible); // :68
		Assert.isTrue(on.loading.visible); // :67

		var off = makeBar();
		off.mask.visible = true;
		off.loading.visible = true;
		off.bar.onUserSwitchResult(new CommonEvent(Consts.MSG_USER_SWITCH_FLAG, {showLoading: false}));
		Assert.isFalse(off.mask.visible);
		Assert.isFalse(off.loading.visible);
	}

	// :65 error == ""：与缺位同路（仍走 showLoading 分支）
	public function test_onUserSwitchResult_empty_error_treated_as_no_error() {
		var t = makeBar();
		t.bar.onUserSwitchResult(new CommonEvent(Consts.MSG_USER_SWITCH_FLAG, {error: "", showLoading: true}));
		Assert.isTrue(t.mask.visible);
		Assert.isTrue(t.loading.visible);
		Assert.isFalse(t.text.visible); // 文案不亮
	}

	// :70-75 error 非空：错误文案覆盖显示、转圈熄灭
	public function test_onUserSwitchResult_error_text_overrides() {
		var t = makeBar();
		t.loading.visible = true;
		t.bar.onUserSwitchResult(new CommonEvent(Consts.MSG_USER_SWITCH_FLAG, {error: "切换失败，<a href='event:reload'>重试</a>"}));
		Assert.isTrue(t.text.visible); // :73
		Assert.isFalse(t.loading.visible); // :74
		Assert.equals("切换失败，<a href='event:reload'>重试</a>", t.text.htmlText); // :72 原样 HTML
	}

	// :78-83 onLinkClicked：向 msgCenter 重派发 __reload__ 载荷的
	// MSG_USER_SWITCH_FLAG，文案隐藏、转圈复亮
	public function test_onLinkClicked_redispatches_reload_and_respinner() {
		var t = makeBar();
		var bus = new FakeMsgCenter();
		Reflect.setField(t.bar, "m_app", bus);
		t.text.visible = true;
		t.bar.onLinkClicked(new TextEvent(TextEvent.LINK));
		Assert.equals(1, bus.events.length); // 单次派发
		var sent = cast(bus.events[0], CommonEvent);
		Assert.equals(Consts.MSG_USER_SWITCH_FLAG, sent.type); // :80
		Assert.isTrue(Reflect.field(sent.data, "__reload__")); // :80 载荷
		Assert.isFalse(t.text.visible); // :81
		Assert.isTrue(t.loading.visible); // :82
	}
}
