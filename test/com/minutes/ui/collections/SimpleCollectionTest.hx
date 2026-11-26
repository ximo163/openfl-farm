package com.minutes.ui.collections;

import openfl.display.Sprite;
import utest.Assert;

/**
 * SimpleCollection 纯逻辑（issue #86 牧场库底座，LipiUI 组件库片）：bg
 * 装配/换装语义、width/height 覆写与对 bg 的两维写透。
 *
 * 出处：legacy/decompiled/Master2_v_142/scripts/com/minutes/ui/collections/
 * SimpleCollection.as（字段 :9-13；bg getter :20-23；set bg :30-47（_bg==null
 * 首装分支 :32-38：尺寸写透 :35-36 + addChild :37；换装分支 :39-46：先
 * removeChild 旧件 :41 再写透 :43-44）；set height :49-57（两维都写 :53-55）；
 * get height :59-63；set width :64-72（两维都写 :67-70））。
 *
 * eval 适配（测试侧零件，FrameTimerTest 的 FakeStage 先例）：bg 用本文件
 * 的 FakeBg——Sprite 子类以 plain 字段重载 width/height 访问器，记录
 * set bg/set width 写下来的值，避开 openfl 空剪辑的测量语义（空 Sprite
 * 的 width 缺省 0，真测量通道写不进 100）。SimpleCollection 本体的
 * width/height 也是覆写访问器（:25/:49/:64），同 openfl 属性面。
 */
class SimpleCollectionTest {
	public function new() {}

	// :11-13 + :15-18：ctor 后宽高走字段初值 100（AS3 字段初始化），bg 缺
	// null，无子件
	public function test_ctor_defaults_width_height_100() {
		var sc = new SimpleCollection();
		Assert.equals(100.0, sc.width); // :11（get width :25-27）
		Assert.equals(100.0, sc.height); // :12（get height :59-63）
		Assert.isNull(sc.bg); // :9 无初值
		Assert.equals(0, sc.numChildren);
	}

	// :32-38：首次设 bg → 尺寸按当前 width/height 写透 + addChild 成首个子件
	public function test_bg_first_attach_sizes_and_adds() {
		var sc = new SimpleCollection();
		var fake = new FakeBg();
		Assert.equals(-1.0, fake.w); // 装配前未被写过
		sc.bg = fake;
		Assert.equals(100.0, fake.w); // :35 this._bg.width = this.width
		Assert.equals(100.0, fake.h); // :36 this._bg.height = this.height
		Assert.equals(1, sc.numChildren);
		Assert.equals(fake, sc.getChildAt(0)); // :37 addChild
		Assert.equals(fake, sc.bg); // :20-23 getter
	}

	// :39-46：换装分支——旧件 removeChild（:41）、新件按当前宽高写透
	// （:43-44）、子件数不变仍占 0 号层
	public function test_bg_replace_swaps_child_and_sizes_to_current() {
		var sc = new SimpleCollection();
		var first = new FakeBg();
		sc.bg = first;
		sc.width = 200; // :64-72（写透见下一测试）
		sc.height = 50;
		var second = new FakeBg();
		sc.bg = second; // :41-45
		Assert.isFalse(sc.contains(first)); // :41 removeChild
		Assert.equals(second, sc.getChildAt(0));
		Assert.equals(1, sc.numChildren); // 换装不叠层
		Assert.equals(200.0, second.w); // :43 尺寸取 this.width 当前值
		Assert.equals(50.0, second.h); // :44
		Assert.equals(second, sc.bg);
	}

	// :64-72 / :49-57：width/height setter 写字段并把两维都写透到 bg——
	// 两个 setter 都是先 _bg.width 后 _bg.height（:53-55/:67-70 同序）
	public function test_width_height_write_through_to_bg() {
		var sc = new SimpleCollection();
		var fake = new FakeBg();
		sc.bg = fake;
		sc.width = 200; // :66-70
		Assert.equals(200.0, fake.w);
		Assert.equals(100.0, fake.h); // 未动 height → bg 的 height 仍写当前值 100
		Assert.equals(200.0, sc.width);
		sc.height = 50; // :51-55
		Assert.equals(200.0, fake.w); // :54 width 先重写（值不变仍 200）
		Assert.equals(50.0, fake.h); // :55
		Assert.equals(50.0, sc.height);
	}
}

/**
 * 测试零件（附于本模块）：Sprite 子类用 plain 字段背书 width/height 访问器，
 * 只记录 SimpleCollection 写进来的尺寸值，不进 openfl 测量。
 */
class FakeBg extends Sprite {
	public var w:Float = -1;
	public var h:Float = -1;

	public function new() {
		super();
	}

	private override function get_width():Float {
		return this.w;
	}

	private override function set_width(param1:Float):Float {
		this.w = param1;
		return param1;
	}

	private override function get_height():Float {
		return this.h;
	}

	private override function set_height(param1:Float):Float {
		this.h = param1;
		return param1;
	}
}
