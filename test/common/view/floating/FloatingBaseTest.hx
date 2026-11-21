package common.view.floating;

import common.Consts;
import events.FloatingEvent;
import support.FakeMsgCenter;
import utest.Assert;

/**
 * FloatingBase 飘字段基类纯逻辑（issue #9）：fid 计数、floatName、start
 * 落点解析、close 的关播报。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/common/view/floating/
 * FloatingBase.as（ID_COUNTER :10、ctor :20-26、floatName :33-41、
 * start :43-58、close :60-69、set fid :71-74）。
 *
 * 派发经 IMsgCenter，用 FakeMsgCenter 记录。纯数据成员（fid/floatName）
 * 直读直写，不碰显示列表。
 */
@:access(common.view.floating.FloatingBase)
class FloatingBaseTest {
	public function new() {}

	// :24：ctor 里 _fid = ID_COUNTER++，跨实例单调递增
	public function test_fid_increments_across_instances() {
		var a = new FloatingBase(null);
		var b = new FloatingBase(null);
		Assert.equals(a.fid + 1, b.fid);
		Assert.isTrue(b.fid > 0); // 计数从 0 起，首实例即非 0
	}

	// :33-41：floatName 直存直读
	public function test_floatName_roundtrip() {
		var fb = new FloatingBase(null);
		Assert.equals("", fb.floatName); // :25 ctor 置空串
		fb.floatName = Consts.FLOAT_TYPE_HA;
		Assert.equals(Consts.FLOAT_TYPE_HA, fb.floatName);
	}

	// :49-55：null 早退；_data 存原对象；x/y 判键后经 parseInt 落坐标
	//（服务器侧 x/y 是字符串坐标，farmlandstatus 的 JSON 数字串）
	public function test_start_parses_x_y_and_stores_data() {
		var fb = new FloatingBase(null);
		fb.start({x: "120", y: "45", value: 3});
		Assert.equals(120.0, fb.x); // :51 parseInt("120")
		Assert.equals(45.0, fb.y); // :54 parseInt("45")
		Assert.equals(3, Reflect.field(fb._data, "value")); // :49 存原对象
	}

	// :45-48：null 载荷直接返回，不动任何状态
	public function test_start_null_payload_is_noop() {
		var fb = new FloatingBase(null);
		fb.start(null);
		Assert.isNull(fb._data);
		Assert.equals(0.0, fb.x);
		Assert.equals(0.0, fb.y);
	}

	// :50-52/:53-55：缺 x/y 键不写坐标（undefined 键不进 parseInt）
	public function test_start_without_coordinates_keeps_position() {
		var fb = new FloatingBase(null);
		fb.start({value: 1});
		Assert.equals(0.0, fb.x);
		Assert.equals(0.0, fb.y);
		Assert.equals(1, Reflect.field(fb._data, "value"));
	}

	// :60-69：close 经 msgCenter 派发 FLOATING_CLOSE，带注册名与 fid；
	// msgCenter 为 null 时静默（:64-67 的判空）
	public function test_close_dispatches_floating_close_with_name_and_fid() {
		var center = new FakeMsgCenter();
		var fb = new FloatingBase(center);
		fb.floatName = "AddMoneyFloating";
		fb.fid = 55;

		fb.close();

		Assert.equals(1, center.events.length);
		var fe = cast(center.events[0], FloatingEvent);
		Assert.equals(FloatingEvent.FLOATING_CLOSE, fe.type);
		Assert.equals("AddMoneyFloating", fe.floating); // :62
		Assert.equals(55, fe.fid); // :63

		var orphan = new FloatingBase(null);
		orphan.close(); // 无 msgCenter → 不抛
		Assert.equals(1, center.events.length);
	}
}
