package framework.layers;

import common.Consts;
import common.view.tip.TipControl;
import events.TipEvent;
import openfl.errors.ArgumentError;
import support.FakeMsgCenter;
import support.FakeTip;
import utest.Assert;

/**
 * TipLayer 提示宿主层纯逻辑（issue #42）：构造形态、getTip 的门位分支、
 * onTipShow 的待显暂存、onTipUpdate 的同型刷新路由。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/framework/layers/TipLayer.as
 * （ctor :31-49、getTip :60-95、onTipShow :148-160、onTipUpdate :162-173）。
 *
 * 300ms Timer 延时显示与 stageMove 跟随走真实 Timer/鼠标事件，不进单测
 * （CI 时间轴/场景比对兜底）；被测面用直调私有方法（@:access）钉住。
 * m_tip 用 support.FakeTip 记录 data 写入（原版 m_tip:ITip）。
 * stub 阶段失败点：getTip/onTipShow/onTipUpdate 是 throw stub。
 */
@:access(framework.layers.TipLayer)
class TipLayerTest {
	public function new() {}

	private function makeLayer():TipLayer {
		return new TipLayer(new TipControl(new FakeMsgCenter()));
	}

	// :31-49：构造即 LAYER_TIP 名 + 鼠标穿透；null 参抛 ArgumentError
	// （:48 "Null parameter"）
	public function test_ctor_shape_and_null_parameter() {
		var layer = makeLayer();
		Assert.equals(Consts.LAYER_TIP, layer.name); // :45
		Assert.isFalse(layer.mouseEnabled); // :43
		Assert.isFalse(layer.mouseChildren); // :44

		var threw:ArgumentError = null;
		try {
			new TipLayer(null);
		} catch (e:ArgumentError) {
			threw = e;
		}
		Assert.notNull(threw);
		Assert.equals("Null parameter", threw.message); // :48
	}

	// :63-66：空名直接 null（不查注册表）
	public function test_getTip_empty_name_returns_null() {
		var layer = makeLayer();
		Assert.isNull(layer.getTip(""));
	}

	// :67-70：m_ctrl 为 null 直接 null
	public function test_getTip_without_ctrl_returns_null() {
		var layer = makeLayer();
		layer.m_ctrl = null;
		Assert.isNull(layer.getTip(Consts.TIP_NAME_MOUSE));
	}

	// :72-88：未注册的类型 → ctrl.getClass null → null（m_libs 实例缓存
	// 不落键，:74-78 的 _loc3_ == null 门）
	public function test_getTip_unregistered_type_returns_null() {
		var layer = makeLayer();
		Assert.isNull(layer.getTip(Consts.TIP_NAME_MOUSE));
	}

	// :148-160：onTipShow 暂存待显四元组（tip 名 / 载荷 / tX / tY）；
	// 未 init 的层 m_timer 为 null → :155-159 计时分支整段跳过（不碰 Timer）
	public function test_onTipShow_stashes_wait_state() {
		var layer = makeLayer();
		var evt = new TipEvent(TipEvent.TIP_SHOW);
		evt.tipType = Consts.TIP_NAME_LAND_INFOR;
		evt.tipArgument = {place: 3};
		evt.tX = 11;
		evt.tY = 22;
		layer.onTipShow(evt);
		Assert.equals(Consts.TIP_NAME_LAND_INFOR, layer.m_waitTip); // :151
		Assert.equals(3, Reflect.field(layer.m_waitArg, "place")); // :152
		Assert.equals(11, layer.m_waitTX); // :153
		Assert.equals(22, layer.m_waitTY); // :154
	}

	// :162-173：onTipUpdate 只刷新同屏同型的 tip——异名早退（:168-171）、
	// 同名才写 data（:172）；m_tip 为 null 也早退（:164-167）
	public function test_onTipUpdate_routes_data_by_tip_name() {
		var layer = makeLayer();
		var fake = new FakeTip(Consts.TIP_NAME_DIY_MOUSE);
		layer.m_tip = fake;

		var other = new TipEvent(TipEvent.TIP_UPDATE);
		other.tipType = Consts.TIP_NAME_MOUSE;
		other.tipArgument = {itemName: "木牌"};
		layer.onTipUpdate(other);
		Assert.equals(0, fake.dataWrites.length); // 异名不写

		var same = new TipEvent(TipEvent.TIP_UPDATE);
		same.tipType = Consts.TIP_NAME_DIY_MOUSE;
		same.tipArgument = {itemName: "稻草人"};
		layer.onTipUpdate(same);
		Assert.equals(1, fake.dataWrites.length); // 同名写 data
		Assert.equals("稻草人", Reflect.field(fake.dataWrites[0], "itemName"));
	}

	// :164-167：当前无 tip（m_tip null）时 update 是 no-op
	public function test_onTipUpdate_without_shown_tip_is_noop() {
		var layer = makeLayer();
		var evt = new TipEvent(TipEvent.TIP_UPDATE);
		evt.tipType = Consts.TIP_NAME_MOUSE;
		evt.tipArgument = {a: 1};
		layer.onTipUpdate(evt);
		Assert.isNull(layer.m_tip);
	}
}
