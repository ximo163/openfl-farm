package com.greensock.core;

import openfl.errors.Error;

/**
 * com.greensock.core.PropTween —— issue #18 write-tests 签名 stub
 * （PropTween.as 43 loc，TweenLite core 片整类翻译）。
 * 属性补间节点（双向链表）：纯数据持有者，target 是 Dynamic（AS3 Object）。
 * 字段与方法签名照抄，体 throw not implemented。
 * TweenCore/SimpleTimeline 的构造链触发 TweenLite.initClass()（ENTER_FRAME
 * + getTimer），不进单测，时间轴推进行为由 CI 时间轴比对覆盖。
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

	// :24-39
	public function new(param1:Dynamic, param2:String, param3:Float, param4:Float, param5:String, param6:Bool,
			param7:PropTween = null, param8:Int = 0) {
		throw new Error("not implemented");
	}
}
