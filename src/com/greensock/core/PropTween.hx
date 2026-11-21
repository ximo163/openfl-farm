package com.greensock.core;

/**
 * com.greensock.core.PropTween —— PropTween.as 逐句对应（issue #18 TweenLite
 * core 片）。属性补间节点（双向链表）：纯数据持有者，target 是 AS3 Object →
 * Dynamic。TweenCore/SimpleTimeline 的构造链触发 TweenLite.initClass()
 * （ENTER_FRAME + getTimer），不进单测，时间轴推进行为由 CI 时间轴比对覆盖。
 */
class PropTween {
	// PropTween.as:6-20
	public var priority:Int;

	public var start:Float;

	public var prevNode:PropTween;

	public var change:Float;

	public var target:Dynamic;

	public var name:String;

	public var property:String;

	public var nextNode:PropTween;

	public var isPlugin:Bool;

	// PropTween.as:24-39
	public function new(param1:Dynamic, param2:String, param3:Float, param4:Float, param5:String, param6:Bool,
			param7:PropTween = null, param8:Int = 0) {
		this.target = param1;
		this.property = param2;
		this.start = param3;
		this.change = param4;
		this.name = param5;
		this.isPlugin = param6;
		if (param7 != null) {
			param7.prevNode = this;
			this.nextNode = param7;
		}
		this.priority = param8;
	}
}
