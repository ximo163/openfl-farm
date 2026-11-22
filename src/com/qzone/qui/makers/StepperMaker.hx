package com.qzone.qui.makers;

import com.qzone.qui.utils.FrameTimer;
import openfl.display.DisplayObject;
import openfl.display.InteractiveObject;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.FocusEvent;
import openfl.events.MouseEvent;
import openfl.events.TimerEvent;
import openfl.text.TextField;
import shim.As3;

/**
 * com.qzone.qui.makers.StepperMaker —— StepperMaker.as 逐句对应
 * （issue #35 功能 swf 翻译：商店）。shop_v_7 携带的 qui 数量步进器本地
 * 副本；warehouse_v_23 的同名文件与之逐字一致（spec/modules/
 * farm-shop-ui.json notes）。买入窗口的数量 +/- 控件：value 在
 * [minimum, maximum] 夹取并按 stepNumber 的 floor(x*100)/100 收两位。
 *
 * PORT-NOTE: AS3 的 `ButtonMaker[fnName2](param1)`、`param1[fnName](...)`
 * 按名取方法 → Reflect.callMethod（保 this 绑定）；`param1.currentTarget
 * .delay = ...` 的接收者是挂了 TIMER 监听的 FrameTimer 本尊，cast 到真类型
 * 走真属性（禁 Dynamic 裸写的分流规则）。`as InteractiveObject` 用
 * isOfType 守卫 cast（RSLManager 先例，target 非 InteractiveObject 时
 * AS3 得 null、Haxe 裸 cast 抛错）。
 */
class StepperMaker extends EventDispatcher {
	// StepperMaker.as:17
	public var repeatInterval:Int = 40;

	// StepperMaker.as:19
	private var downArrow:Sprite;

	// StepperMaker.as:21
	public var target:DisplayObject;

	// StepperMaker.as:23
	private var stepArrow:InteractiveObject;

	// StepperMaker.as:25
	public var repeatDelay:Int = 500;

	// StepperMaker.as:27
	private var upArrow:Sprite;

	// StepperMaker.as:29
	public var buttonPrevName:String = "prev_btn";

	// StepperMaker.as:31
	private var _textField:TextField;

	// StepperMaker.as:33
	private var _minimum:Float;

	// StepperMaker.as:35
	public var textName:String = "num_txt";

	// StepperMaker.as:37
	public var maxChars:Int = 5;

	// StepperMaker.as:39
	private var _skin:Sprite;

	// StepperMaker.as:41
	private var _maximum:Float;

	// StepperMaker.as:43
	private var stepTimer:FrameTimer;

	// StepperMaker.as:45
	public var stepSize:Float;

	// StepperMaker.as:47
	public var buttonNextName:String = "next_btn";

	// StepperMaker.as:49
	private var _value:Float = 1;

	// StepperMaker.as:51-57
	public function new(param1:Float = 10, param2:Float = 1, param3:Float = 1) {
		super();
		this._maximum = param1;
		this._minimum = param2;
		this.stepSize = param3;
	}

	// StepperMaker.as:59-91
	private function eventHandle(param1:Bool = false):Void {
		var fnName:String = null;
		var fnName2:String = null;
		var isRemove:Bool = param1;
		// 闭包捕引用：fnName/fnName2 在下方重绑后 setArrow 用新值（AS3 同语义）
		var setArrow:Sprite->Void = function(param1:Sprite):Void {
			if (param1 != null) {
				Reflect.callMethod(ButtonMaker, Reflect.field(ButtonMaker, fnName2), [param1]);
				param1.useHandCursor = false;
				Reflect.callMethod(param1, Reflect.field(param1, fnName), [MouseEvent.CLICK, _CLICK]);
				Reflect.callMethod(param1, Reflect.field(param1, fnName), [MouseEvent.MOUSE_DOWN, _MOUSE_DOWN]);
			}
		};
		fnName = "addEventListener";
		fnName2 = "addTarget";
		if (isRemove) {
			fnName = "removeEventListener";
			fnName2 = "removeTarget";
		}
		setArrow(this.upArrow);
		setArrow(this.downArrow);
		if (this._textField != null) {
			Reflect.callMethod(this._textField, Reflect.field(this._textField, fnName), [Event.CHANGE, this._CHANGE]);
			Reflect.callMethod(this._textField, Reflect.field(this._textField, fnName), [FocusEvent.FOCUS_OUT, this._FOCUS_OUT]);
			this._textField.restrict = "0-9";
			this._textField.maxChars = this.maxChars;
			this.stepNumber(this._value);
		}
	}

	// StepperMaker.as:93-95
	public var minimum(get, set):Float;

	private function get_minimum():Float {
		return this._minimum;
	}

	// StepperMaker.as:98-109
	private function changeNumber(param1:InteractiveObject):Void {
		if (param1 == this.upArrow) {
			this.stepNumber(this._value + this.stepSize);
		} else if (param1 == this.downArrow) {
			this.stepNumber(this._value - this.stepSize);
		}
		this.dispatchEvent(new Event(Event.CHANGE));
	}

	// StepperMaker.as:111-113
	public var maximum(get, set):Float;

	private function get_maximum():Float {
		return this._maximum;
	}

	// StepperMaker.as:116-120
	private function set_minimum(param1:Float):Float {
		this._minimum = param1;
		this.stepNumber(this._value);
		return param1;
	}

	// StepperMaker.as:122-126
	private function _TIMER(param1:Event):Void {
		this.changeNumber(this.stepArrow);
		cast(param1.currentTarget, FrameTimer).delay = this.repeatInterval;
	}

	// StepperMaker.as:128-132
	private function _FOCUS_OUT(param1:Event):Void {
		// Number(Number(text) || minimum)：restrict="0-9" 下文本只可能是
		// 纯数字/空，As3.floatOf 的前缀解析与 Number() 等价（TweenCore:76 先例）
		var _loc2_:Float = As3.or(As3.floatOf(this._textField.text), this.minimum);
		this.stepNumber(_loc2_);
	}

	// StepperMaker.as:134-159
	private function stepNumber(param1:Float):Void {
		if (param1 >= this.maximum) {
			param1 = this.maximum;
			this.setArrowEnabled(this.upArrow, false);
		} else {
			this.setArrowEnabled(this.upArrow, true);
		}
		if (param1 <= this.minimum) {
			param1 = this.minimum;
			this.setArrowEnabled(this.downArrow, false);
		} else {
			this.setArrowEnabled(this.downArrow, true);
		}
		this._value = Math.floor(param1 * 100) / 100;
		if (this._textField != null) {
			this._textField.text = Std.string(this._value);
		}
	}

	// StepperMaker.as:161-174
	private function _MOUSE_DOWN(param1:Event):Void {
		var _loc2_:InteractiveObject = Std.isOfType(param1.target, InteractiveObject) ? cast(param1.target, InteractiveObject) : null;
		_loc2_.addEventListener(MouseEvent.MOUSE_UP, this._MOUSE_UP);
		_loc2_.addEventListener(MouseEvent.ROLL_OUT, this._MOUSE_UP);
		if (this.stepTimer == null) {
			FrameTimer.init(this._skin);
			this.stepTimer = new FrameTimer(this.repeatDelay);
			this.stepTimer.addEventListener(TimerEvent.TIMER, this._TIMER);
		}
		this.stepArrow = _loc2_;
		this.stepTimer.start();
	}

	// StepperMaker.as:176-180
	private function set_maximum(param1:Float):Float {
		this._maximum = param1;
		this.stepNumber(this._value);
		return param1;
	}

	// StepperMaker.as:182-191
	private function _CHANGE(param1:Event):Void {
		if (this._textField.text.indexOf(".") == this._textField.text.length - 1) {
			return;
		}
		var _loc2_:Float = As3.or(As3.floatOf(this._textField.text), this.minimum);
		this.stepNumber(_loc2_);
		this.dispatchEvent(new Event(Event.CHANGE));
	}

	// StepperMaker.as:193-196
	public var value(get, set):Float;

	private function set_value(param1:Float):Float {
		this.stepNumber(param1);
		return param1;
	}

	// StepperMaker.as:198-202
	private function _CLICK(param1:Event):Void {
		var _loc2_:InteractiveObject = Std.isOfType(param1.target, InteractiveObject) ? cast(param1.target, InteractiveObject) : null;
		this.changeNumber(_loc2_);
	}

	// StepperMaker.as:204-207
	private function get_value():Float {
		return this._value;
	}

	// StepperMaker.as:209-218
	private function _MOUSE_UP(param1:Event):Void {
		var _loc2_:InteractiveObject = Std.isOfType(param1.target, InteractiveObject) ? cast(param1.target, InteractiveObject) : null;
		_loc2_.removeEventListener(MouseEvent.MOUSE_UP, this._MOUSE_UP);
		_loc2_.removeEventListener(MouseEvent.ROLL_OUT, this._MOUSE_UP);
		this.stepTimer.stop();
		this.stepTimer.removeEventListener(TimerEvent.TIMER, this._TIMER);
		this.stepTimer = null;
		this.stepArrow = null;
	}

	// StepperMaker.as:220-226
	private function setArrowEnabled(param1:Sprite, param2:Bool):Void {
		if (param1 != null) {
			ButtonMaker.setEnabled(param1, param2);
		}
	}

	// StepperMaker.as:228-245
	public function setSkin(param1:Sprite):Void {
		this.eventHandle(true);
		this._skin = param1;
		if (this._skin != null) {
			this.upArrow = cast(this._skin.getChildByName(this.buttonNextName), Sprite);
			this.downArrow = cast(this._skin.getChildByName(this.buttonPrevName), Sprite);
			this._textField = cast(this._skin.getChildByName(this.textName), TextField);
			this.eventHandle();
		} else {
			this.upArrow = null;
			this.downArrow = null;
			this._textField = null;
		}
	}
}
