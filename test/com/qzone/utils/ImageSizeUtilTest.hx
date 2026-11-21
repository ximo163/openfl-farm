package com.qzone.utils;

import utest.Assert;

/**
 * ImageSizeUtil 纯逻辑（issue #18）：图片适配矩形的缩放与对齐数学。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/com/qzone/utils/ImageSizeUtil.as
 * （风格常量 :8-20、setSize1 :27-30、setSize2 :32-131）。
 *
 * 目标是带 width/height/scaleX/scaleY/x/y 的 Dynamic（原版签名 Object，
 * 传 DisplayObject 也走这套属性写法，纯对象即可驱动同一数学）。所有期望值
 * 由 :32-131 的公式手算。**原版笔误逐字保留**：mode 3/5/6 的 else 分支把
 * param4（矩形宽）赋给 height（:66/:106/:122），deviations 候选。
 * mode 2 在原版没有命名常量，传字面量 2。
 */
class ImageSizeUtilTest {
	public function new() {}

	// 哨兵 x/y=-999、scale=3：未写回的分支一眼可见
	static function mk(w:Float, h:Float):Dynamic {
		return {x: -999, y: -999, width: w, height: h, scaleX: 3.0, scaleY: 3.0};
	}

	// :34-37 NO_HANDEL：原样返回（早于 :38 的 scale 复位，什么都不碰）
	public function test_NO_HANDEL_leaves_target_untouched() {
		var t = mk(200, 100);
		ImageSizeUtil.setSize2(t, 10, 20, 50, 60, ImageSizeUtil.NO_HANDEL);
		Assert.equals(-999, t.x);
		Assert.equals(-999, t.y);
		Assert.equals(200, t.width);
		Assert.equals(100, t.height);
		Assert.equals(3.0, t.scaleX);
		Assert.equals(3.0, t.scaleY);
	}

	// :38-42 NO_SCALE_CENTER：scale 复位 1、原尺寸居中
	// x = 10+25-100 = -65、y = 20+30-50 = 0（:129-130 公共居中公式）
	public function test_NO_SCALE_CENTER_resets_scale_and_centers() {
		var t = mk(200, 100);
		ImageSizeUtil.setSize2(t, 10, 20, 50, 60, ImageSizeUtil.NO_SCALE_CENTER);
		Assert.equals(1.0, t.scaleX);
		Assert.equals(1.0, t.scaleY);
		Assert.equals(200, t.width);
		Assert.equals(100, t.height);
		Assert.equals(-65, t.x);
		Assert.equals(0, t.y);
	}

	// :43-55 SCALE_WITH_BIG_CENTER（包含式适配）：
	// 宽向超配（4 > 5/3）→ 贴宽 h = 100/200*50 = 25；
	// 高向超配（2 < 10/3）→ 贴高 w = 100/200*60 = 30
	public function test_SCALE_WITH_BIG_CENTER_fits_inside_rect() {
		var wide = mk(200, 100);
		ImageSizeUtil.setSize2(wide, 10, 20, 50, 60, ImageSizeUtil.SCALE_WITH_BIG_CENTER);
		Assert.equals(50, wide.width);
		Assert.equals(25, wide.height);
		Assert.equals(10, wide.x); // 35 - 25
		Assert.equals(37.5, wide.y); // 50 - 12.5

		var tall = mk(100, 200);
		ImageSizeUtil.setSize2(tall, 10, 20, 50, 60, ImageSizeUtil.SCALE_WITH_BIG_CENTER);
		Assert.equals(30, tall.width);
		Assert.equals(60, tall.height);
		Assert.equals(20, tall.x); // 35 - 15
		Assert.equals(20, tall.y); // 50 - 30
	}

	// :69-73 mode 2（无名常量）：拉伸到矩形尺寸 → 恰好左上角对齐矩形原点
	public function test_mode_2_stretches_to_exact_rect() {
		var t = mk(100, 50);
		ImageSizeUtil.setSize2(t, 10, 20, 50, 60, 2);
		Assert.equals(50, t.width);
		Assert.equals(60, t.height);
		Assert.equals(10, t.x); // 35 - 25
		Assert.equals(20, t.y); // 50 - 30
	}

	// :56-68 SCALE_WITH_SMALL（覆盖式适配）：
	// then 分支（宽向差距小）与 mode 1 then 相同；else 分支 :66 把 param4
	// （矩形宽 50）赋给 height —— 原版笔误，逐字保留（deviations 候选）
	public function test_SCALE_WITH_SMALL_covers_rect_and_keeps_param4_height_bug() {
		var tall = mk(100, 200);
		ImageSizeUtil.setSize2(tall, 10, 20, 50, 60, ImageSizeUtil.SCALE_WITH_SMALL);
		Assert.equals(50, tall.width);
		Assert.equals(100, tall.height); // 200/100*50
		Assert.equals(10, tall.x);
		Assert.equals(0, tall.y); // 50 - 50

		var wide = mk(200, 100);
		ImageSizeUtil.setSize2(wide, 10, 20, 50, 60, ImageSizeUtil.SCALE_WITH_SMALL);
		Assert.equals(120, wide.width); // 200/100*60
		Assert.equals(50, wide.height); // :66 = param4（矩形宽），非 param5
		Assert.equals(-25, wide.x); // 35 - 60
		Assert.equals(25, wide.y); // 50 - 25
	}

	// :74-93 NO_SCALE_CENTER_AND_KEEP_IN_RECT：小于矩形不动、只居中；
	// 超出矩形才等比缩到贴宽
	public function test_KEEP_IN_RECT_only_downscales() {
		var small = mk(30, 20);
		ImageSizeUtil.setSize2(small, 10, 20, 50, 60, ImageSizeUtil.NO_SCALE_CENTER_AND_KEEP_IN_RECT);
		Assert.equals(30, small.width);
		Assert.equals(20, small.height);
		Assert.equals(20, small.x); // 35 - 15
		Assert.equals(40, small.y); // 50 - 10

		var big = mk(200, 100);
		ImageSizeUtil.setSize2(big, 10, 20, 50, 60, ImageSizeUtil.NO_SCALE_CENTER_AND_KEEP_IN_RECT);
		Assert.equals(50, big.width);
		Assert.equals(25, big.height);
		Assert.equals(10, big.x);
		Assert.equals(37.5, big.y);
	}

	// :96-111 SCALE_WITH_SMALL_TOP：水平居中、垂直贴矩形顶（y = param3）；
	// else 分支 :106 同款 param4→height 笔误
	public function test_SCALE_WITH_SMALL_TOP_aligns_to_rect_top() {
		var tall = mk(100, 200);
		ImageSizeUtil.setSize2(tall, 10, 20, 50, 60, ImageSizeUtil.SCALE_WITH_SMALL_TOP);
		Assert.equals(50, tall.width);
		Assert.equals(100, tall.height);
		Assert.equals(10, tall.x);
		Assert.equals(20, tall.y); // :109 = param3（顶）

		var wide = mk(200, 100);
		ImageSizeUtil.setSize2(wide, 10, 20, 50, 60, ImageSizeUtil.SCALE_WITH_SMALL_TOP);
		Assert.equals(120, wide.width);
		Assert.equals(50, wide.height); // :106 = param4 笔误
		Assert.equals(-25, wide.x);
		Assert.equals(20, wide.y);
	}

	// :112-127 SCALE_WITH_SMALL_BUTTOM：水平居中、垂直贴矩形底
	// （y = param5 - height）；else 分支 :122 同款笔误
	public function test_SCALE_WITH_SMALL_BUTTOM_aligns_to_rect_bottom() {
		var tall = mk(100, 200);
		ImageSizeUtil.setSize2(tall, 10, 20, 50, 60, ImageSizeUtil.SCALE_WITH_SMALL_BUTTOM);
		Assert.equals(50, tall.width);
		Assert.equals(100, tall.height);
		Assert.equals(10, tall.x);
		Assert.equals(-40, tall.y); // :125 = 60 - 100

		var wide = mk(200, 100);
		ImageSizeUtil.setSize2(wide, 10, 20, 50, 60, ImageSizeUtil.SCALE_WITH_SMALL_BUTTOM);
		Assert.equals(120, wide.width);
		Assert.equals(50, wide.height); // :122 = param4 笔误
		Assert.equals(-25, wide.x);
		Assert.equals(10, wide.y); // 60 - 50
	}

	// :27-30 setSize1 是 setSize2 的 rect 对象重载（x/y/width/height 四键）
	public function test_setSize1_delegates_with_rect_object() {
		var t = mk(100, 50);
		ImageSizeUtil.setSize1(t, {x: 10, y: 20, width: 50, height: 60}, 2);
		Assert.equals(50, t.width);
		Assert.equals(60, t.height);
		Assert.equals(10, t.x);
		Assert.equals(20, t.y);
	}
}
