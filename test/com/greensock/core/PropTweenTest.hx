package com.greensock.core;

import utest.Assert;

/**
 * PropTween 纯数据逻辑（issue #18）：TweenLite core 的属性补间节点——
 * 构造字段与双向链表接线。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/com/greensock/core/PropTween.as
 * （字段 :6-20、ctor :24-39）。
 *
 * TweenCore/SimpleTimeline 的构造链会触发 TweenLite.initClass()（TweenLite.as
 * :128-137：_shape 的 Event.ENTER_FRAME 监听 + getTimer() 真实时钟），显示
 * 对象/真实时间不进单测——时间轴推进行为由 CI 时间轴比对（固定步长对拍）
 * 覆盖，本用例只钉 PropTween 纯数据节点。target 是 AS3 Object，这里用
 * String 哨兵（等值比较无歧义）。
 */
class PropTweenTest {
	public function new() {}

	// :24-39 单节点：七参照抄、无 param7 时不接线（nextNode/prevNode 保持
	// null）、priority 默认 0
	public function test_single_node_fields_and_defaults() {
		var pt = new PropTween("TARGET", "x", 5, 10, "x", false);
		Assert.equals("TARGET", pt.target);
		Assert.equals("x", pt.property);
		Assert.equals(5, pt.start);
		Assert.equals(10, pt.change);
		Assert.equals("x", pt.name);
		Assert.isFalse(pt.isPlugin);
		Assert.equals(0, pt.priority); // :38 param8 默认 0
		Assert.isNull(pt.nextNode); // :33 无 param7 → 不进 :34-37 接线分支
		Assert.isNull(pt.prevNode);
	}

	// :33-37 传入 param7（既有表头）：新节点插到表头——param7.prevNode = this、
	// this.nextNode = param7（双向）
	public function test_prev_node_wired_both_directions() {
		var head = new PropTween("T1", "x", 0, 1, "x", false);
		var node = new PropTween("T2", "y", 0, 2, "y", true, head, 3);
		Assert.equals(head, node.nextNode);
		Assert.equals(node, head.prevNode);
		Assert.isTrue(node.isPlugin);
		Assert.equals(3, node.priority);
		Assert.isNull(head.nextNode); // 原表头后向指针不动
	}
}
