package mc.view.main.floating;

import mc.control.ViewControl;
import mc.events.FloatingEvent;
import mc.view.main.floating.Float;
import mc.view.main.floating.FloatingBase;
import utest.Assert;

/**
 * mc.view.main.floating.Float 纯逻辑（issue #87 write-tests，对 stub 失败）：
 * 飘字开/关的静态派发面。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/view/main/floating/Float.as
 * —— open :17-22（经 ViewControl 派 FloatingEvent.FLOATING_OPEN、载荷
 * floating 是传入实例）；close :9-15（同构 FLOATING_CLOSE）。常量值
 * 见 FloatingEvent.as:9-11（"floatingOpen"/"floatingClose"）。
 *
 * PORT-NOTE(类名)：Haxe 侧 `mc.view.main.floating.Float` 遮蔽标准库
 * Float——本测试在包内（同为 mc.view.main.floating），`Float` 直写指本
 * 类；数值类型用不到。implement 翻译时同注意。
 */
class FloatTest {
	var captured:Array<{type:String, floating:FloatingBase}>;

	public function new() {}

	function setup() {
		captured = [];
		var vc = ViewControl.getInstance();
		vc.addEventListener(FloatingEvent.FLOATING_OPEN, onEvent);
		vc.addEventListener(FloatingEvent.FLOATING_CLOSE, onEvent);
	}

	function teardown() {
		var vc = ViewControl.getInstance();
		vc.removeEventListener(FloatingEvent.FLOATING_OPEN, onEvent);
		vc.removeEventListener(FloatingEvent.FLOATING_CLOSE, onEvent);
	}

	function onEvent(e:FloatingEvent):Void {
		captured.push({type: e.type, floating: e.floating});
	}

	// open 派 FLOATING_OPEN 且载荷是传入实例本身（Float.as:17-22）
	public function test_open_dispatches_with_payload() {
		var fb = new FloatingBase();
		Float.open(fb);
		Assert.equals(1, captured.length);
		Assert.equals(FloatingEvent.FLOATING_OPEN, captured[0].type);
		Assert.equals(fb, captured[0].floating);
	}

	// close 派 FLOATING_CLOSE 同构（Float.as:9-15）
	public function test_close_dispatches_with_payload() {
		var fb = new FloatingBase();
		Float.close(fb);
		Assert.equals(1, captured.length);
		Assert.equals(FloatingEvent.FLOATING_CLOSE, captured[0].type);
		Assert.equals(fb, captured[0].floating);
	}
}
