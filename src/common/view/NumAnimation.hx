package common.view;

import openfl.events.TimerEvent;
import openfl.utils.Timer;
import shim.As3;

/**
 * common.view.NumAnimation —— NumAnimation.as 逐句对应（issue #9）。
 * 数值滚动补间：50ms Timer，每步 current += (end-current)*0.2、写回
 * int(current)，收敛 (<1) 即停并直写终值。PersonInfo 的金币/经验数字用。
 */
class NumAnimation {
	// NumAnimation.as:9-19
	private var aObject:Dynamic;
	private var timer:Timer;
	private var startValue:Float = 0;
	private var aAttr:String;
	private var endValue:Float = 0;
	private var currentValue:Float = 0;

	// NumAnimation.as:21-28
	public function new(param1:Dynamic, param2:String, param3:Float, param4:Float) {
		this.aObject = param1;
		this.aAttr = param2;
		this.startValue = param3;
		this.endValue = param4;
	}

	// NumAnimation.as:30-44（startValue 超界直接收敛；表只建一次）
	public function start():Void {
		if (this.startValue > 2100000000) {
			this.stop();
			return;
		}
		if (this.timer == null) {
			this.timer = new Timer(50);
			this.timer.addEventListener(TimerEvent.TIMER, this.onTimer, false, 0, true);
			this.currentValue = this.startValue;
		}
		this.timer.start();
	}

	// NumAnimation.as:46-56（逼近步长 (end-current)*0.2；attr 写 int 截断值）
	private function onTimer(param1:TimerEvent):Void {
		var _loc2_:Float = this.currentValue;
		_loc2_ += (this.endValue - _loc2_) * 0.2;
		this.currentValue = _loc2_;
		Reflect.setField(this.aObject, this.aAttr, As3.intOf(_loc2_));
		if (Math.abs(this.endValue - _loc2_) < 1) {
			this.stop();
		}
	}

	// NumAnimation.as:58-68（停表 + 属性直写终值（Number，无 int 截断））
	public function stop():Void {
		if (this.timer != null) {
			this.timer.stop();
		}
		if (this.aObject != null) {
			Reflect.setField(this.aObject, this.aAttr, this.endValue);
		}
	}

	// NumAnimation.as:70-82
	public var end(never, set):Float;

	private function set_end(param1:Float):Float {
		this.endValue = param1;
		if (this.endValue > 2100000000) {
			this.stop();
			return param1;
		}
		if (this.timer != null) {
			this.timer.start();
		}
		return param1;
	}
}
