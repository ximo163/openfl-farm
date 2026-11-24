package com.qzone.qui.utils;

import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.TimerEvent;
import openfl.utils.Dictionary;
import shim.As3;

// com.qzone.qui.utils.FrameTimer —— FrameTimer.as 逐句对应（issue #44 真身，
// 原 #7 闭包 stub 退役，#35/#44 两轮补的签名全部按原文落体）。ENTER_FRAME
// 驱动的 setTimeout/setInterval 替代品：表项 delay 存的是 ms 经
// Math.ceil((delay||1000)/1000*frameRate) 换算出的帧数，onEnterFrame 按
// frameCount % delay == 0 触发、判后自增（frameCount 起 1）。表项是 AS3
// Object 字面量 → Dynamic 匿名对象，字段读写全走 Reflect（静态目标 Dynamic
// 裸写会撞类字段表，CLAUDE.md 三选一）。
// legacy/decompiled/main3_v_221/scripts/com/qzone/qui/utils/FrameTimer.as
class FrameTimer extends EventDispatcher {
	// FrameTimer.as:12（键是 uint id，K 写 UInt 落 IntMap——openfl Dictionary
	// 是 @:multiType，见 #9/#37 教训；init 才建）
	private static var handles:Dictionary<UInt, Dynamic>;

	// FrameTimer.as:14（AS3 uint 静态零值 0；eval 未赋值静态是 null，
	// `++count` 会炸，显式落 0 同 AS3）
	private static var count:UInt = 0;

	// FrameTimer.as:16（同上）
	private static var index:UInt = 0;

	// FrameTimer.as:18
	private static var _stage:DisplayObject;

	// FrameTimer.as:20
	private var _running:Bool = false;

	// FrameTimer.as:22
	private var _delay:Float;

	// FrameTimer.as:24（AS3 int 零值 0，eval 显式落）
	private var _currentCount:Int = 0;

	// FrameTimer.as:26（同上；ctor 之外 AS3 也是 0）
	private var _id:UInt = 0;

	// FrameTimer.as:28
	public var repeatCount:Int;

	// FrameTimer.as:30-35
	public function new(param1:Float, param2:Int = 0) {
		super();
		this._delay = param1;
		this.repeatCount = param2;
	}

	// FrameTimer.as:37-40（param2 是 uint，收 Number 实参是 AS3 隐式截断，
	// 调用点 set_delay 以 Std.int 显式复刻）
	private static function setDelay(param1:UInt, param2:UInt):Void {
		Reflect.setField(handles.get(param1), "delay", Math.ceil(As3.or(param2, 1000) / 1000 * _stage.stage.frameRate));
	}

	// FrameTimer.as:42-51（...rest → Array<Dynamic> = null：缺省 null 对应
	// 原版 rest=[]，onEnterFrame 的 apply 侧零参调用等价）
	public static function setTimeout(param1:Dynamic, param2:Float, param3:Array<Dynamic> = null):UInt {
		return addTimer({
			"closure": param1,
			"delay": param2,
			"arguments": param3,
			"timeOut": true,
			"frameCount": 1
		});
	}

	// FrameTimer.as:53-61（无 timeOut 标记 → onEnterFrame 不自清）
	public static function setInterval(param1:Dynamic, param2:Float, param3:Array<Dynamic> = null):UInt {
		return addTimer({
			"closure": param1,
			"delay": param2,
			"arguments": param3,
			"frameCount": 1
		});
	}

	// FrameTimer.as:63-74（Dictionary 的 hasOwnProperty/delete → exists/remove）
	public static function clear(param1:UInt):Void {
		if (handles.exists(param1)) {
			handles.remove(param1);
			--count;
			if (count == 0) {
				_stage.stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
		}
	}

	// FrameTimer.as:76-83（`_stage == null` 门：首装舞台一直有效）
	public static function init(param1:DisplayObject):Void {
		if (_stage == null) {
			_stage = param1;
			handles = new Dictionary<UInt, Dynamic>();
		}
	}

	// FrameTimer.as:85-88
	public static function clearInterval(param1:UInt):Void {
		clear(param1);
	}

	// FrameTimer.as:90-101（先 ++index 再入表；count==0 时挂 ENTER_FRAME，
	// ++count 在后——0→1 换监听的次序照抄）
	private static function addTimer(param1:Dynamic):UInt {
		Reflect.setField(param1, "delay", Math.ceil(As3.or(Reflect.field(param1, "delay"), 1000) / 1000 * _stage.stage.frameRate));
		++index;
		handles.set(index, param1);
		if (count == 0) {
			_stage.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		++count;
		return index;
	}

	// FrameTimer.as:103-106
	public static function clearTimeout(param1:UInt):Void {
		clear(param1);
	}

	// FrameTimer.as:108-125（AS3 for-in 收 Dictionary 的键——openfl Dictionary
	// 的 iterator() 返回键迭代；timeOut 键缺位（setInterval 路径）Reflect 落
	// null → truthy 假，对应 AS3 undefined）
	private static function onEnterFrame(param1:Event):Void {
		var _loc2_:UInt;
		var _loc3_:Dynamic = null;
		for (_loc2_ in handles.iterator()) {
			_loc3_ = handles.get(_loc2_);
			var _loc4_:Int = Reflect.field(_loc3_, "frameCount");
			var _loc5_:Int = Reflect.field(_loc3_, "delay");
			if (_loc4_ % _loc5_ == 0) {
				if (As3.truthy(Reflect.field(_loc3_, "timeOut"))) {
					clearTimeout(_loc2_);
				}
				Reflect.callMethod(null, Reflect.field(_loc3_, "closure"), As3.or(Reflect.field(_loc3_, "arguments"), []));
			}
			Reflect.setField(_loc3_, "frameCount", _loc4_ + 1);
		}
	}

	// FrameTimer.as:127-139（`arguments` 是 start() 自身的实参表——start 无参，
	// 恒为 []，照语义直译；closure 是实例方法引用）
	public function start():Void {
		if (this._running == false) {
			this._running = true;
			this._id = FrameTimer.addTimer({
				"closure": this.closure,
				"delay": this._delay,
				"arguments": [],
				"frameCount": 1
			});
		}
	}

	// FrameTimer.as:141-153（setDelay 只在运行中触发）
	public var delay(get, set):Float;

	private function get_delay():Float {
		return this._delay;
	}

	private function set_delay(param1:Float):Float {
		this._delay = param1;
		if (this._running) {
			FrameTimer.setDelay(this._id, Std.int(this._delay));
		}
		return param1;
	}

	// FrameTimer.as:155-162
	public function stop():Void {
		if (this._running == true) {
			this._running = false;
			FrameTimer.clear(this._id);
		}
	}

	// FrameTimer.as:164-166
	public var currentCount(get, never):Int;

	private function get_currentCount():Int {
		return this._currentCount;
	}

	// FrameTimer.as:169-178（...rest 收参不碰，照 CLAUDE.md 规则落
	// Array<Dynamic> 形参；complete 后只摘表项，_running 不回落——原版如此）
	private function closure(rest:Array<Dynamic>):Void {
		++this._currentCount;
		this.dispatchEvent(new TimerEvent(TimerEvent.TIMER));
		if (this.repeatCount > 0 && this._currentCount >= this.repeatCount) {
			FrameTimer.clear(this._id);
			this.dispatchEvent(new TimerEvent(TimerEvent.TIMER_COMPLETE));
		}
	}

	// FrameTimer.as:180-184
	public function reset():Void {
		this._currentCount = 0;
		this.stop();
	}

	// FrameTimer.as:186-189
	public var running(get, never):Bool;

	private function get_running():Bool {
		return this._running;
	}
}
