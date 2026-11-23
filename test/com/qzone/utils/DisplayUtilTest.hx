package com.qzone.utils;

import openfl.display.Sprite;
import openfl.text.TextField;
import utest.Assert;

/**
 * com.qzone.utils.DisplayUtil 整类纯逻辑（issue #43）：#8 闭包只译了
 * removeChild，本片补齐其余 6 个方法。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/com/qzone/utils/DisplayUtil.as
 * （setEnabled :15-41、copyXYWH :43-45、removeChild :48-59、
 * removeChildByName :61-65、removeChildAt :67-71、disableMouse :73-83、
 * copyProperties :85-98）。
 *
 * setEnabled/copyProperties 的原版签名是 Object + hasOwnProperty 门 +
 * 下标写——按 ImageSizeUtilTest 先例用纯匿名对象驱动同一套属性读写
 * （真 DisplayObject 也走这套写法）；removeChild 三卫士是 #8 已译真身，
 * 这里补回归钉。stub 阶段失败点：setEnabled/disableMouse/copyProperties/
 * copyXYWH 空体、removeChildByName/removeChildAt 恒 null（其中
 * disableMouse/copyProperties 有运行期调用方 CursorCropSeed/TileList，
 * 保持可调不抛的空体，失败走断言值）。
 */
class DisplayUtilTest {
	public function new() {}

	// :15-41 setEnabled 全字段对象：enable=true 时四开关全开 + filters 复位
	// 空数组（:34）
	public function test_setEnabled_true_flips_all_and_clears_filters() {
		var o:Dynamic = {mouseEnabled: false, mouseChildren: false, buttonMode: false, enabled: false, filters: ["old"]};
		DisplayUtil.setEnabled(o, true, ["glow"]);
		Assert.isTrue(o.mouseEnabled); // :19
		Assert.isTrue(o.mouseChildren); // :22（hasOwnProperty 有才写）
		Assert.isTrue(o.buttonMode); // :26
		Assert.isTrue(o.enabled); // :30
		Assert.equals(0, o.filters.length); // :34 filters = []
	}

	// :15-41 setEnabled=false：四开关关 + filters 落第三参（:38）
	public function test_setEnabled_false_applies_filter_list() {
		var o:Dynamic = {mouseEnabled: true, mouseChildren: true, buttonMode: true, enabled: true, filters: []};
		DisplayUtil.setEnabled(o, false, ["glow", "blur"]);
		Assert.isFalse(o.mouseEnabled);
		Assert.isFalse(o.mouseChildren);
		Assert.isFalse(o.buttonMode);
		Assert.isFalse(o.enabled);
		Assert.equals(2, o.filters.length); // :38
		Assert.equals("glow", o.filters[0]);
		Assert.equals("blur", o.filters[1]);
	}

	// :20-30 hasOwnProperty 门：源对象缺的键不写；:33-39 filters 无条件写
	public function test_setEnabled_skips_absent_properties() {
		var o:Dynamic = {mouseEnabled: true, filters: []};
		DisplayUtil.setEnabled(o, false, ["f"]);
		Assert.isFalse(o.mouseEnabled);
		Assert.isFalse(Reflect.hasField(o, "mouseChildren")); // 缺键不凭空造
		Assert.isFalse(Reflect.hasField(o, "buttonMode"));
		Assert.isFalse(Reflect.hasField(o, "enabled"));
		Assert.equals(1, o.filters.length); // filters 仍被写（:37-39 在门之外）
	}

	// :17 空对象守卫：不碰任何属性、不抛
	public function test_setEnabled_null_target_is_noop() {
		DisplayUtil.setEnabled(null, true, []);
		Assert.isTrue(true); // 走到这没抛即通过
	}

	// :85-98 copyProperties：只拷 param1 hasOwnProperty 命中的键
	public function test_copyProperties_copies_only_present_keys() {
		var src:Dynamic = {x: 11.0, y: 22.0};
		var dst:Dynamic = {x: -1.0, y: -1.0, alpha: 9.9};
		DisplayUtil.copyProperties(src, dst, ["x", "y", "alpha"]);
		Assert.equals(11.0, dst.x);
		Assert.equals(22.0, dst.y);
		Assert.equals(9.9, dst.alpha); // src 缺 alpha → 跳过（:92）
	}

	// :88 双真值门：任一侧空直接返回
	public function test_copyProperties_null_guards() {
		var dst:Dynamic = {x: -1.0};
		DisplayUtil.copyProperties(null, dst, ["x"]);
		Assert.equals(-1.0, dst.x);
		DisplayUtil.copyProperties({x: 5.0}, null, ["x"]); // 不抛即通过
		Assert.isTrue(true);
	}

	// :43-45 copyXYWH：固定 ["x","y","width","height"] 四键走 copyProperties
	// （签名 DisplayObject，按 ImageSizeUtilTest 先例以纯对象 cast 驱动）
	public function test_copyXYWH_copies_four_keys() {
		var src:Dynamic = {x: 1.5, y: 2.5, width: 100.0, height: 50.0};
		var dst:Dynamic = {x: -9.0, y: -9.0, width: -9.0, height: -9.0};
		DisplayUtil.copyXYWH(cast src, cast dst);
		Assert.equals(1.5, dst.x);
		Assert.equals(2.5, dst.y);
		Assert.equals(100.0, dst.width);
		Assert.equals(50.0, dst.height);
	}

	// :48-59 removeChild（#8 已译，回归钉）：挂在 param1 上才摘，返回被摘子件
	public function test_removeChild_detaches_only_own_child() {
		var parent = new Sprite();
		var child = new Sprite();
		parent.addChild(child);
		Assert.equals(child, DisplayUtil.removeChild(parent, child));
		Assert.isFalse(parent.contains(child));
	}

	// :50-57 别家子件与 null 子件都返回 null 不摘
	public function test_removeChild_foreign_or_null_child_returns_null() {
		var p1 = new Sprite();
		var p2 = new Sprite();
		var child = new Sprite();
		p2.addChild(child);
		Assert.isNull(DisplayUtil.removeChild(p1, child)); // parent != param1
		Assert.isTrue(p2.contains(child)); // 原挂载不动
		Assert.isNull(DisplayUtil.removeChild(p1, null)); // :50 null 门
	}

	// :61-65 removeChildByName：按名取子件再走 removeChild
	public function test_removeChildByName_removes_named_child() {
		var parent = new Sprite();
		var child = new Sprite();
		child.name = "m_dogBowl";
		parent.addChild(child);
		Assert.equals(child, DisplayUtil.removeChildByName(parent, "m_dogBowl"));
		Assert.isFalse(parent.contains(child));
	}

	// :63-64 未命中名：getChildByName null → removeChild 的 null 门 → null
	public function test_removeChildByName_unknown_name_returns_null() {
		var parent = new Sprite();
		parent.addChild(new Sprite());
		Assert.isNull(DisplayUtil.removeChildByName(parent, "nope"));
		Assert.equals(1, parent.numChildren); // 原有子件不动
	}

	// :67-71 removeChildAt：按下标取子件再走 removeChild
	public function test_removeChildAt_removes_indexed_child() {
		var parent = new Sprite();
		var a = new Sprite();
		var b = new Sprite();
		parent.addChild(a);
		parent.addChild(b);
		Assert.equals(b, DisplayUtil.removeChildAt(parent, 1));
		Assert.equals(1, parent.numChildren);
		Assert.equals(a, parent.getChildAt(0));
	}

	// :73-83 disableMouse：DisplayObjectContainer 双分支都关（:77/:81）
	public function test_disableMouse_sprite_disables_both_flags() {
		var sp = new Sprite();
		sp.mouseEnabled = true;
		sp.mouseChildren = true;
		DisplayUtil.disableMouse(sp);
		Assert.isFalse(sp.mouseEnabled); // :77
		Assert.isFalse(sp.mouseChildren); // :81（Sprite 是 DisplayObjectContainer）
	}

	// :79-82 TextField 是 InteractiveObject 但不是 DisplayObjectContainer：
	// 只关 mouseEnabled，不触碰容器分支
	public function test_disableMouse_textfield_only_disables_mouseEnabled() {
		var tf = new TextField();
		tf.mouseEnabled = true;
		DisplayUtil.disableMouse(tf);
		Assert.isFalse(tf.mouseEnabled); // :77
		Assert.isTrue(true); // 非容器分支跳过，不抛
	}
}
