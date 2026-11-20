package common.view.floating;

import common.Consts;
import common.misc.Utils;
import interfaces.IMsgCenter;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.TimerEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.utils.Timer;
import shim.As3;

/**
 * common.view.floating.FarmOperateFloating —— FarmOperateFloating.as 逐句
 * 对应（issue #9）。农田操作气泡（TalkBoxMy1/TalkBoxHe1 + 文本框），
 * Timer 2500ms×1 自关。
 */
@:keep
class FarmOperateFloating extends FloatingBase {
	// FarmOperateFloating.as:16
	private var _timer:Timer;

	// FarmOperateFloating.as:18
	private var _textField:TextField;

	// FarmOperateFloating.as:20-27
	public function new(param1:IMsgCenter) {
		super(param1);
		this.floatName = Consts.FLOAT_TYPE_OPERATE;
		this._textField = null;
		this._timer = null;
		this.addEventListener(Event.REMOVED_FROM_STAGE, this.onRemoved, false, 0, true);
	}

	// FarmOperateFloating.as:29-60（me 决定 TalkBox 款式与文字色；文本框
	// 90×46、(-58,-58) 落位。已建过（numChildren == 2）早退）
	private function initialize(param1:Bool):Void {
		if (this.numChildren == 2) {
			return;
		}
		var _loc2_:Sprite = null;
		if (param1 == true) {
			_loc2_ = cast Utils.getMaterial("TalkBoxMy1");
		} else {
			_loc2_ = cast Utils.getMaterial("TalkBoxHe1");
		}
		addChild(_loc2_);
		this._textField = new TextField();
		this._textField.wordWrap = true;
		if (param1 == true) {
			this._textField.defaultTextFormat = new TextFormat("Verdana", 12, 3355443);
		} else {
			this._textField.defaultTextFormat = new TextFormat("Verdana", 12, 16777215);
		}
		this._textField.width = 90;
		this._textField.height = 46;
		this._textField.x = -58;
		this._textField.y = -58;
		addChild(this._textField);
	}

	// FarmOperateFloating.as:62-76（<16 字 12 号，否则 10 号后置文本）
	public var text(never, set):String;

	private function set_text(param1:String):String {
		if (this._textField != null) {
			if (param1.length < 16) {
				this._textField.defaultTextFormat = new TextFormat("Verdana", 12, 3355443);
			} else {
				this._textField.defaultTextFormat = new TextFormat("Verdana", 10, 3355443);
			}
			this._textField.text = param1;
		}
		return param1;
	}

	// FarmOperateFloating.as:78-99（me 真值经 AS3 Boolean() 强转；y 随
	// yAdjust 偏移；timer 复用或新建后启动）
	override public function start(param1:Dynamic):Void {
		super.start(param1);
		if (param1 == null) {
			return;
		}
		this.initialize(As3.truthy(Reflect.field(param1, "me")));
		this.text = Std.string(Reflect.field(param1, "text"));
		this._textField.y = -56 + As3.parseInt(Reflect.field(param1, "yAdjust"));
		if (this._timer == null) {
			this._timer = new Timer(2500, 1);
			this._timer.addEventListener(TimerEvent.TIMER, this.onTimer);
			this._timer.start();
		} else {
			this._timer.reset();
			this._timer.start();
		}
	}

	// FarmOperateFloating.as:101-109
	private function onRemoved(param1:Event):Void {
		if (this._timer != null) {
			this._timer.stop();
			this._timer.removeEventListener(TimerEvent.TIMER, this.onTimer);
			this._timer = null;
		}
	}

	// FarmOperateFloating.as:111-121（end：跑着的 timer 重挂监听后置空——
	// 原版如此（不 removeEventListener），照抄）
	override public function end():Void {
		super.end();
		if (this._timer != null && this._timer.running == true) {
			this._timer.stop();
			this._timer.addEventListener(TimerEvent.TIMER, this.onTimer);
			this._timer = null;
		}
		this._textField = null;
	}

	// FarmOperateFloating.as:123-132（timer 到点：摘监听置空后 close）
	private function onTimer(param1:TimerEvent):Void {
		if (this._timer != null) {
			this._timer.stop();
			this._timer.removeEventListener(TimerEvent.TIMER, this.onTimer);
			this._timer = null;
		}
		super.close();
	}
}
