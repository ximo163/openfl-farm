package com.minutes.ui.control;

import com.minutes.ui.core.LipiSkin;
import com.minutes.ui.core.LipiUIComponent;
import com.minutes.ui.core.UIEvent;
import shim.As3;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.events.MouseEvent;
import openfl.events.TimerEvent;
import openfl.filters.ColorMatrixFilter;
import openfl.text.TextField;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.utils.Timer;

/**
 * com.minutes.ui.control.NumbericStepper —— NumbericStepper.as 逐句对应
 * （issue #86 牧场库底座，LipiUI 组件库片）。
 * legacy/decompiled/Master2_v_142/scripts/com/minutes/ui/control/NumbericStepper.as。
 *
 * PORT-NOTE（get_num 属性，AS3 :49/:159）：AS3 形态是 getter 返 int、setter
 * 形参 `*`（numTextChange :193 直接把 TextField.text 的 String 写进来）。
 * 按本仓 EvtAPI.data / UIEvent.data 先例统一为 Dynamic 属性——Int 化的
 * 属性编不过 :193 的 String 写入。
 * PORT-NOTE: setter 的 `isNaN(param1)`（:51）是 AS3 全局 isNaN（先转
 * Number 再判：Number("")==0 非 NaN、Number("abc")/Number(undefined) 为
 * NaN）。Haxe 无全局 isNaN 强转语义，用 As3.isNaN 等价（shim）。
 * PORT-NOTE: `int(this.numText.text)`（:161）是 AS3 int() 强转——数字串
 * 截断取整、非数字串/空串为 0；Haxe 经 As3.intOf 等价。
 * PORT-NOTE: `++this.get_num`/`--this.get_num`（:293/:339）与
 * `this.get_num += n`（:268/:353）是 AS3 的属性读写复合——先 get 再 set。
 * int()+字符串拼接语义见各行注释。
 */
@:keep
class NumbericStepper extends Sprite {
	// NumbericStepper.as:22
	private var timer:Timer;

	// :24
	private var bg:LipiUIComponent;

	// :26
	private var downTime:Int = 0;

	// :28（AS3 uint → UInt）
	private var _disable_type:UInt;

	// :30
	private var numText:TextField;

	// :33
	public var leftButton:LipiUIComponent;

	// :34
	private var _min_num:Int = 1;

	// :36
	private var addValue:Int = 0;

	// :38
	private var _max_num:Int = 99;

	// :40
	public var rightButton:LipiUIComponent;

	// :42-47
	public function new() {
		super();
		this.init();
		this._disable_type = 0;
	}

	// :49-70/:159-162（属性形态见类头 PORT-NOTE）。`param1.toString()`
	// （:53/:57/:61/:66）对 Number/int/String 同字面；`this.min_num.toString()`
	// 经 Std.string 等价。isNaN 判定走 As3.isNaN（Number("") == 0 非 NaN——
	// 空串落 :55 的 < min 分支，与 eval 原生 isNaN("") == true 的语义不同，
	// 两分支可见文本同为 min，差异只在 :58 的 setSelection）
	public var get_num(get, set):Dynamic;

	private function get_get_num():Dynamic {
		return As3.intOf(this.numText.text);
	}

	private function set_get_num(param1:Dynamic):Dynamic {
		// AS3 的 `param1 < min` 对 `*` 形参是数值比较（字符串先 Number() 转
		// 换："30"<1 false、""<1 true——Number("")==0）；Haxe eval 上 Dynamic
		// 字符串与 Int 比较恒 false（""<1 落不进分支）。先按 AS3 Number()
		// 规则归一出比较值；写文本仍用 param1 原样的 toString（:66 区间内
		// "30" 原文写入，不归一）
		var _cmp:Float = compareNumber(param1);
		if (As3.isNaN(param1)) {
			this.numText.text = Std.string(this.min_num);
		} else if (_cmp < this.min_num) {
			this.numText.text = Std.string(this.min_num);
			this.numText.setSelection(0, this.numText.text.length);
		} else if (_cmp > this.max_num) {
			this.numText.text = Std.string(this.max_num);
		} else {
			this.numText.text = Std.string(param1);
		}
		dispatchEvent(new UIEvent(UIEvent.TEXT_CHANGE));
		this.updateSpinBtns();
		return param1;
	}

	// :72-75/:197-200
	public var max_num(get, set):Int;

	private function get_max_num():Int {
		return this._max_num;
	}

	private function set_max_num(param1:Int):Int {
		this._max_num = param1;
		return param1;
	}

	// :346-349/:357-360
	public var min_num(get, set):Int;

	private function get_min_num():Int {
		return this._min_num;
	}

	private function set_min_num(param1:Int):Int {
		this._min_num = param1;
		return param1;
	}

	// :77-82
	private function leftButtonUp(param1:MouseEvent):Void {
		this.downTime = 0;
		this.addValue = 0;
		this.timer.stop();
	}

	// :84-90
	private function focusOut(param1:FocusEvent):Void {
		if ((this.get_num : Int) < this.min_num) {
			this.get_num = this.min_num;
		}
	}

	// :92-150
	private function init():Void {
		this.leftButton = new LipiUIComponent();
		this.rightButton = new LipiUIComponent();
		this.bg = new LipiUIComponent();
		if (NUmbericStepperSkin.DecSkin != null) {
			this.leftButton.bgSkin = new LipiSkin(NUmbericStepperSkin.DecSkin);
			this.leftButton.addEventListener(MouseEvent.CLICK, this.leftButtonClick);
			this.leftButton.addEventListener(MouseEvent.MOUSE_DOWN, this.leftButtonDown);
			this.leftButton.addEventListener(MouseEvent.MOUSE_UP, this.leftButtonUp);
			this.leftButton.addEventListener(MouseEvent.ROLL_OUT, this.leftButtonUp);
			this.leftButton.bgAlpha = 0;
			this.leftButton.width = 20;
			this.leftButton.height = 20;
			this.leftButton.y = 1;
		}
		if (NUmbericStepperSkin.IncSkin != null) {
			this.rightButton.bgSkin = new LipiSkin(NUmbericStepperSkin.IncSkin);
			this.rightButton.addEventListener(MouseEvent.CLICK, this.rightButtonClick);
			this.rightButton.addEventListener(MouseEvent.MOUSE_DOWN, this.rightButtonDown);
			this.rightButton.addEventListener(MouseEvent.MOUSE_UP, this.rightButtonUp);
			this.rightButton.addEventListener(MouseEvent.ROLL_OUT, this.rightButtonUp);
			this.rightButton.bgAlpha = 0;
			this.rightButton.width = 20;
			this.rightButton.height = 20;
			this.rightButton.y = 1;
		}
		if (NUmbericStepperSkin.BgSkin != null) {
			this.bg.bgSkin = new LipiSkin(NUmbericStepperSkin.BgSkin);
			this.bg.bgAlpha = 0;
			this.bg.width = 50;
			this.bg.height = 22;
		}
		addChild(this.leftButton);
		addChild(this.rightButton);
		addChild(this.bg);
		this.leftButton.x = 0;
		this.bg.x = 20;
		this.rightButton.x = 70;
		this.numText = new TextField();
		this.numText.restrict = "0-9";
		this.numText.type = TextFieldType.INPUT;
		this.numText.defaultTextFormat = new TextFormat("Verdana", 12, 3355443, null, null, null, null, null, TextFormatAlign.CENTER);
		this.numText.text = "1";
		this.numText.width = this.bg.width;
		this.numText.height = this.bg.width; // :139 原文即 width（非笔误修正对象）
		this.numText.x = this.bg.x;
		this.numText.y = 2;
		this.numText.addEventListener(Event.CHANGE, this.numTextChange);
		this.numText.addEventListener(MouseEvent.MOUSE_WHEEL, this.textWheel);
		this.numText.addEventListener(FocusEvent.FOCUS_OUT, this.focusOut);
		this.numText.addEventListener(FocusEvent.FOCUS_IN, this.foncusIn);
		addChild(this.numText);
		this.timer = new Timer(60);
		this.timer.addEventListener(TimerEvent.TIMER, this.onTimer);
	}

	// :152-157
	private function leftButtonDown(param1:MouseEvent):Void {
		this.addValue = -1;
		this.downTime = shim.As3.getTimer();
		this.timer.start();
	}

	// :164-169
	private function foncusIn(param1:FocusEvent):Void {
		var _loc2_:Timer = new Timer(10, 1);
		_loc2_.addEventListener(TimerEvent.TIMER, this.allSelection);
		_loc2_.start();
	}

	// :171-189
	private function updateSpinBtns():Void {
		if ((this.get_num : Int) > this._min_num) {
			this.disable(false, 0);
		} else {
			this.disable(true, 0);
		}
		if ((this.get_num : Int) < this._max_num) {
			this.disable(false, 1);
		} else {
			this.disable(true, 1);
		}
	}

	// :191-195（text 原样进 setter——String 写入 `*` 形参的入口；双派发
	// 照抄：:193 setter 内一条 + :194 这里直发一条）
	private function numTextChange(param1:Event):Void {
		this.get_num = this.numText.text;
		dispatchEvent(new UIEvent(UIEvent.TEXT_CHANGE));
	}

	// AS3 Number(x) 转换（比较专用）：数字直取、数字串按整串严格解析
	// （""→0——Number("") 的原版语义；非数字串/undefined→NaN，NaN 的比较
	// 恒 false，与 AS3 一致——NaN 分支在 setter 里已被 isNaN 先拦）
	private static function compareNumber(param1:Dynamic):Float {
		if (param1 == null) {
			return Math.NaN;
		}
		if (Std.isOfType(param1, Bool)) {
			return param1 ? 1 : 0;
		}
		if (Std.isOfType(param1, Int) || Std.isOfType(param1, Float)) {
			return param1;
		}
		if (Std.isOfType(param1, String)) {
			var s:String = param1;
			if (s == "") {
				return 0;
			}
			var f:Null<Float> = Std.parseFloat(s);
			if (f == null || Math.isNaN(f)) {
				return Math.NaN;
			}
			return f;
		}
		return Math.NaN;
	}

	// :202-253
	public function disable(param1:Bool, param2:Int):Void {
		if (param2 == 0) {
			this.grayMc(this.leftButton, param1);
			this.leftButton.mouseEnabled = param1 == false;
			this.leftButton.mouseChildren = param1 == false;
			if (param1) {
				this._disable_type |= 1;
			} else {
				this._disable_type &= ~1;
			}
		} else if (param2 == 1) {
			this.grayMc(this.rightButton, param1);
			this.rightButton.mouseEnabled = param1 == false;
			this.rightButton.mouseChildren = param1 == false;
			if (param1) {
				this._disable_type |= 2;
			} else {
				this._disable_type &= ~2;
			}
		} else {
			this.grayMc(this.leftButton, param1);
			this.leftButton.mouseEnabled = param1 == false;
			this.leftButton.mouseChildren = param1 == false;
			this.grayMc(this.rightButton, param1);
			this.rightButton.mouseEnabled = param1 == false;
			this.rightButton.mouseChildren = param1 == false;
			this.grayMc(this.bg, param1);
			this.numText.type = param1 == true ? TextFieldType.DYNAMIC : TextFieldType.INPUT;
			this.numText.mouseEnabled = param1 == false;
			this.numText.mouseWheelEnabled = param1 == false;
			if (param1 == true) {
				this.numText.backgroundColor = 6710886;
			} else {
				this.numText.backgroundColor = 16777215;
			}
		}
	}

	// :255-260
	private function rightButtonUp(param1:MouseEvent):Void {
		this.downTime = 0;
		this.addValue = 0;
		this.timer.stop();
	}

	// :262-266
	private function allSelection(param1:Event):Void {
		if (stage != null) {
			stage.focus = this.numText;
		}
		this.numText.setSelection(0, this.numText.text.length);
	}

	// :268-283（`this.get_num += this.addValue` 是 get+Int 加+set 复合；
	// getter 是 int() 强转——见类头）
	private function onTimer(param1:TimerEvent):Void {
		if (this.downTime == 0) {
			return;
		}
		if (shim.As3.getTimer() - 500 > this.downTime) {
			this.get_num = (this.get_num : Int) + this.addValue;
		}
		if ((this.get_num : Int) < this._min_num) {
			this.get_num = this._min_num;
		}
		if ((this.get_num : Int) > this._max_num) {
			this.get_num = this._max_num;
		}
		this.updateSpinBtns();
	}

	// :285-295（`--this.get_num` 同复合语义）
	private function leftButtonClick(param1:MouseEvent):Void {
		this.get_num = (this.get_num : Int) - 1;
		this.updateSpinBtns();
	}

	// :297-302
	private function rightButtonDown(param1:MouseEvent):Void {
		this.addValue = 1;
		this.downTime = shim.As3.getTimer();
		this.timer.start();
	}

	// :304-332（mat 矩阵与 try/catch 原样；`as MovieClip` 无。AS3 try 内
	// 赋值失败吞掉——Haxe 同构 try/catch）
	private function grayMc(param1:Sprite, param2:Bool):Void {
		var mat:Array<Dynamic> = null;
		var colorMat:ColorMatrixFilter = null;
		var mc:Sprite = param1;
		var flag:Bool = param2;
		if (mc == null) {
			return;
		}
		try {
			if (flag) {
				mat = [0.33, 0.33, 0.33, 0, 0, 0.33, 0.33, 0.33, 0, 0, 0.33, 0.33, 0.33, 0, 0, 0, 0, 0, 1, 0];
				colorMat = new ColorMatrixFilter(cast mat);
				mc.filters = [colorMat];
			} else {
				mc.filters = [];
			}
		} catch (e:Dynamic) {
			trace(e);
		}
	}

	// :334-344
	private function textWheel(param1:MouseEvent):Void {
		if (param1.delta > 0) {
			this.get_num = (this.get_num : Int) + 1;
		} else {
			this.get_num = (this.get_num : Int) - 1;
		}
	}

	// :351-354
	private function rightButtonClick(param1:MouseEvent):Void {
		this.get_num = (this.get_num : Int) + 1;
		this.updateSpinBtns();
	}
}
