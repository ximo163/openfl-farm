package com.minutes.ui.control;

import com.minutes.ui.core.LipiUIComponent;
import com.minutes.ui.core.UIEvent;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.TextEvent;
import openfl.text.TextField;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;

/**
 * com.minutes.ui.control.LipiTextArea —— LipiTextArea.as 逐句对应
 * （issue #86 牧场库底座，LipiUI 组件库片）。
 * legacy/decompiled/Master2_v_142/scripts/com/minutes/ui/control/LipiTextArea.as。
 *
 * PORT-NOTE（`Number(param1.data)` 与 scrollV 的 int 通道，:86）：
 * `this.textField.scrollV = Number(param1.data) * this.textField.numLines + 1`
 * ——Number 算式赋进 int 属性，AS3 隐式截断（向零），Haxe 经 shim.As3.intOf
 * 等价。param1.data 是 Dynamic，Number() 强转经 shim.As3.floatOf。
 * PORT-NOTE（_preScroll 是 int、getTimer() 毫秒值，:18/:87/:118）：
 * AS3 getTimer 返 int——shim.As3.getTimer 同通道（int），差值比较直翻。
 * PORT-NOTE（构造器里 getLineLength 的 if/else 两分支同体，:33-40）：
 * 原版缺陷/冗余逐字保留（两分支都执行 `pageHeight = numLines`）。
 */
@:keep
class LipiTextArea extends LipiUIComponent {
	// LipiTextArea.as:16-20
	private var _textField:TextField;
	private var _preScroll:Int = 0;
	public var vLipiScrollBar:LipiScrollBar;

	// :22-48
	public function new() {
		super();
		this.textField = new TextField();
		this.textField.defaultTextFormat = new TextFormat("Verdana");
		this.textField.type = TextFieldType.INPUT;
		this.textField.wordWrap = true;
		this.textField.multiline = true;
		this.textField.addEventListener(KeyboardEvent.KEY_UP, this.keyUpHandler);
		this.textField.addEventListener(Event.SCROLL, this.textFieldScrollHandler);
		this.vLipiScrollBar = new LipiScrollBar();
		if (this.textField.getLineLength(this.textField.numLines - 1) == 0) {
			this.vLipiScrollBar.pageHeight = this.textField.numLines;
		} else {
			this.vLipiScrollBar.pageHeight = this.textField.numLines;
		}
		this.vLipiScrollBar.visibleHeight = this.textField.bottomScrollV - this.textField.scrollV + 1;
		this.reChildPosition();
		addChild(this.textField);
		addChild(this.vLipiScrollBar);
		addEventListener(UIEvent.RESIZE, this.onResize);
		addEventListener(UIEvent.TEXT_CHANGE, this.textChangeHandler);
		this.vLipiScrollBar.addEventListener(LipiScrollBar.SCROLL, this.onScroll);
	}

	// :50-53
	public var textField(get, set):TextField;

	private function set_textField(param1:TextField):TextField {
		this._textField = param1;
		return param1;
	}

	// :55-60
	public var text(get, set):String;

	private function set_text(param1:String):String {
		this.textField.text = param1;
		var _loc2_:UIEvent = new UIEvent(UIEvent.TEXT_CHANGE);
		dispatchEvent(_loc2_);
		return param1;
	}

	// :62-65
	private function get_text():String {
		return this.textField.text;
	}

	// :67-72
	public function appendText(param1:String):Void {
		this.textField.appendText(param1);
		var _loc2_:UIEvent = new UIEvent(UIEvent.TEXT_CHANGE);
		dispatchEvent(_loc2_);
	}

	// :74-77
	public var type(get, set):String;

	private function get_type():String {
		return this.textField.type;
	}

	// :79-82
	private function onResize(param1:UIEvent):Void {
		this.reChildPosition();
	}

	// :84-88（int 截断见类头 PORT-NOTE）
	private function onScroll(param1:UIEvent):Void {
		this.textField.scrollV = shim.As3.intOf(shim.As3.floatOf(param1.data) * this.textField.numLines + 1);
		this._preScroll = shim.As3.getTimer();
	}

	// :90-94
	private function textInputHandler(param1:TextEvent):Void {
		var _loc2_:UIEvent = new UIEvent(UIEvent.TEXT_CHANGE);
		dispatchEvent(_loc2_);
	}

	// :96-99
	private function get_textField():TextField {
		return this._textField;
	}

	// :101-105
	private function keyUpHandler(param1:KeyboardEvent):Void {
		var _loc2_:UIEvent = new UIEvent(UIEvent.TEXT_CHANGE);
		dispatchEvent(_loc2_);
	}

	// :107-114
	private function reChildPosition():Void {
		this.textField.width = this.width - this.vLipiScrollBar.width;
		this.textField.height = this.height;
		this.vLipiScrollBar.y = 0;
		this.vLipiScrollBar.x = this.width - this.vLipiScrollBar.width;
		this.vLipiScrollBar.height = this.height;
	}

	// :116-122
	private function textFieldScrollHandler(param1:Event):Void {
		if (shim.As3.getTimer() - this._preScroll > 100) {
			this.enforceScrollPosition();
		}
	}

	// :124-128
	private function enforceScrollPosition():Void {
		var _loc1_:Float = (this.textField.scrollV - 1) / this.textField.numLines;
		this.vLipiScrollBar.enforceScrollPosition(_loc1_);
	}

	// :130-133
	private function set_type(param1:String):String {
		this.textField.type = param1;
		return param1;
	}

	// :135-140
	private function textChangeHandler(param1:UIEvent):Void {
		this.vLipiScrollBar.pageHeight = this.textField.numLines;
		this.vLipiScrollBar.visibleHeight = this.textField.bottomScrollV - this.textField.scrollV + 1;
		this.enforceScrollPosition();
	}

	// :142-145
	public var htmlText(get, set):String;

	private function get_htmlText():String {
		return this.textField.htmlText;
	}

	// :147-152
	private function set_htmlText(param1:String):String {
		this.textField.htmlText = param1;
		var _loc2_:UIEvent = new UIEvent(UIEvent.TEXT_CHANGE);
		dispatchEvent(_loc2_);
		return param1;
	}
}
