package framework.layers;

import common.Consts;
import common.view.cursor.CursorControl;
import openfl.display.MovieClip;
import support.FakeMsgCenter;
import utest.Assert;

/**
 * framework.layers.CursorLayer 纯逻辑（issue #43）：setPosition 的两种
 * 落位（CROPSEED 居中 / 其余直接落）与 remove 的当前光标摘除。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/framework/layers/CursorLayer.as
 * （setPosition :123-139、remove :49-56）。
 *
 * 其余成员（onSetCursor/onSwitchCursor 的 Mouse.show/hide、stage 事件四连、
 * setCurrentCursor 的素材实例化）要么吃 eval 上会抛的 openfl.ui.Mouse
 * （Mouse.hx:100 空引用），要么依赖舞台/素材，不进单测——CI 时间轴/场景
 * 比对兜底。CROPSEED 居中用画了 100×50 矩形的 MC 驱动（eval 上矢量 bounds
 * 可算，width/height 真值为 100/50）。stub 阶段失败点：setPosition/remove
 * 是 throw stub。
 */
@:access(framework.layers.CursorLayer)
class CursorLayerTest {
	public function new() {}

	private function makeLayer():CursorLayer {
		return new CursorLayer(new CursorControl(new FakeMsgCenter()));
	}

	// :135-137 非 CROPSEED 光标：stageX/stageY 原样落位
	public function test_setPosition_direct_for_plain_cursor() {
		var layer = makeLayer();
		var cursor = new MovieClip(); // 默认名 instanceN，不撞 CROPSEED
		layer.m_currentCursor = cursor;
		layer.setPosition(100, 200);
		Assert.equals(100.0, cursor.x);
		Assert.equals(200.0, cursor.y);
	}

	// :129-133 CROPSEED 光标：按自身宽高居中（100×50 → 偏 -50/-25）
	public function test_setPosition_centers_cropseed_cursor() {
		var layer = makeLayer();
		var cursor = new MovieClip();
		cursor.name = Consts.CURSOR_STYLE_CROPSEED;
		cursor.graphics.beginFill(0xFF0000);
		cursor.graphics.drawRect(0, 0, 100, 50);
		cursor.graphics.endFill();
		layer.m_currentCursor = cursor;
		layer.setPosition(100, 200);
		Assert.equals(50.0, cursor.x); // 100 - 100*0.5
		Assert.equals(175.0, cursor.y); // 200 - 50*0.5
	}

	// :125-126 当前光标为 null：静默返回
	public function test_setPosition_without_cursor_is_noop() {
		var layer = makeLayer();
		layer.setPosition(10, 20); // 不抛即通过
		Assert.isTrue(true);
	}

	// :49-56 remove：摘除当前光标并置空引用
	public function test_remove_detaches_current_cursor() {
		var layer = makeLayer();
		var cursor = new MovieClip();
		layer.m_currentCursor = cursor;
		layer.addChild(cursor);
		layer.remove();
		Assert.equals(0, layer.numChildren);
		Assert.isNull(Reflect.field(layer, "m_currentCursor")); // :54 置空
	}

	// :51 无当前光标：remove 静默
	public function test_remove_without_cursor_is_noop() {
		var layer = makeLayer();
		layer.remove(); // 不抛即通过
		Assert.isTrue(true);
	}
}
