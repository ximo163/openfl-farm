package com.qzone.qui.controls;

import com.qzone.qui.core.Direction;
import com.qzone.qui.events.ScrollEvent;
import com.qzone.qui.utils.EventUtil;
import com.qzone.utils.AlignUtil;
import openfl.events.Event;
import openfl.events.MouseEvent;
import shim.As3;

/**
 * com.qzone.qui.controls.TextArea —— TextArea.as 逐句对应（issue #18 qui
 * 收尾：控件片）。多行文本域：按 maxScrollV/maxScrollH 懒挂竖/横滚动条，
 * TextField SCROLL 事件驱动重排。`param1 || ""` → As3.or。
 */
class TextArea extends TextInput {
	// TextArea.as:12-22
	private var vScroll:VScrollBar;

	private var _scrollW:Int;

	public var wordWrap:Bool = true;

	private var hScroll:HScrollBar;

	private var _scrollH:Int;

	// :24-30
	public function new() {
		super();
		this._height = 100;
		this._width = 100;
		this._textField.multiline = true;
	}

	// :32-35
	private function textFieldScrollHandle(param1:Event):Void {
		this.updateScrollBar();
	}

	// :37-46
	private function scrollHandle(param1:ScrollEvent):Void {
		if (param1.direction == Direction.VERTICAL) {
			this._textField.scrollV = Std.int(param1.position + 1);
		} else if (param1.direction == Direction.HORIZONTAL) {
			this._textField.scrollH = Std.int(param1.position);
		}
	}

	// :48-52
	private function textChanged():Void {
		this.updateScrollBar();
		this._textField.removeEventListener(Event.SCROLL, this.textFieldScrollHandle);
	}

	// :54-105
	private function updateScrollBar():Void {
		var _loc1_:Float = Math.NaN;
		var _loc2_:Float = Math.NaN;
		var _loc3_:Float = Math.NaN;
		if (this._textField.maxScrollV > 1) {
			if (this.vScroll == null) {
				this.vScroll = new VScrollBar();
				this.vScroll.addEventListener(ScrollEvent.SCROLL, this.scrollHandle);
				this.vScroll.addEventListener(MouseEvent.CLICK, EventUtil.stopImmediatePropagation);
				this.addChild(this.vScroll);
			}
			_loc1_ = this._textField.numLines - (this._textField.maxScrollV - 1);
			_loc2_ = this._textField.numLines;
			_loc3_ = this._textField.scrollV - 1;
			this.vScroll.setScrollProperties(_loc1_, _loc3_, _loc2_);
			this.vScroll.visible = true;
			this._scrollW = Std.int(this.vScroll.width);
		} else {
			if (this.vScroll != null) {
				this.vScroll.visible = false;
			}
			this._scrollW = 0;
		}
		if (this._textField.maxScrollH > 1) {
			if (this.hScroll == null) {
				this.hScroll = new HScrollBar();
				this.hScroll.addEventListener(ScrollEvent.SCROLL, this.scrollHandle);
				this.hScroll.addEventListener(MouseEvent.CLICK, EventUtil.stopImmediatePropagation);
				this.addChild(this.hScroll);
			}
			_loc1_ = this._textField.width;
			_loc2_ = this._textField.width + this._textField.maxScrollH;
			_loc3_ = this._textField.scrollH;
			this.hScroll.setScrollProperties(_loc1_, _loc3_, _loc2_);
			this.hScroll.visible = true;
			this._scrollH = Std.int(this.hScroll.height);
		} else {
			if (this.hScroll != null) {
				this.hScroll.visible = false;
			}
			this._scrollH = 0;
		}
		this.setSize();
	}

	// :107-111
	private override function _FOCUS_OUT(param1:Event):Void {
		this._textField.removeEventListener(Event.SCROLL, this.textFieldScrollHandle);
		this._textField.mouseWheelEnabled = false;
		super._FOCUS_OUT(param1);
	}

	// :113-118
	private override function init():Void {
		this._textField.wordWrap = this.wordWrap;
		this._textField.addEventListener(Event.SCROLL, this.textFieldScrollHandle);
		super.init();
	}

	// :120-125
	private override function _FOCUS_IN(param1:Event):Void {
		this._textField.addEventListener(Event.SCROLL, this.textFieldScrollHandle);
		this._textField.mouseWheelEnabled = true;
		super._FOCUS_IN(param1);
	}

	// :127-135（AS3 `param1 || ""`）
	private override function set_htmlText(param1:String):String {
		this._text = As3.or(param1, "");
		if (this._added) {
			this._textField.htmlText = this._text;
			this.resetScrollPos();
			this.textChanged();
		}
		return param1;
	}

	// :137-145
	private override function set_text(param1:String):String {
		this._text = As3.or(param1, "");
		if (this._added) {
			this._textField.text = this._text;
			this.resetScrollPos();
			this.textChanged();
		}
		return param1;
	}

	// :147-172
	private override function setSize():Void {
		if (this.vScroll != null) {
			this.vScroll.x = AlignUtil.right(this._width, this.vScroll.width);
		}
		if (this.hScroll != null) {
			this.hScroll.y = AlignUtil.right(this._height, this.hScroll.height);
		}
		if (this._skin != null) {
			this._skin.width = this._scrollW > 0 ? this._width - this._scrollW + 1 : this._width - this._scrollW;
			this._skin.height = this._scrollH > 0 ? this._height - this._scrollH + 1 : this._height - this._scrollH;
		}
		this._textField.x = this.paddingH;
		this._textField.y = this.paddingV;
		this._textField.width = this._width - this.paddingH * 2 - this._scrollW;
		this._textField.height = this._height - this.paddingV * 2 - this._scrollH;
		this.scrollBarChange();
	}

	// :174-201
	private function scrollBarChange():Void {
		if ((this.hScroll != null && this.hScroll.visible) && (this.vScroll != null) && this.vScroll.visible) {
			this.hScroll.width = this._width - this.vScroll.width;
			this.vScroll.height = this._height - this.hScroll.height;
		} else if ((this.vScroll != null) && (this.hScroll != null) && this.hScroll.visible) {
			this.hScroll.width = this._width;
			this.vScroll.height = this._height - this.hScroll.height;
		} else if ((this.hScroll != null) && (this.vScroll != null) && this.vScroll.visible) {
			this.hScroll.width = this._width - this.vScroll.width;
			this.vScroll.height = this._height;
		} else {
			if (this.hScroll != null) {
				this.hScroll.width = this._width;
			}
			if (this.vScroll != null) {
				this.vScroll.height = this._height;
			}
		}
	}

	// :203-207
	private function resetScrollPos():Void {
		this._textField.scrollV = 0;
		this._textField.scrollH = 0;
	}
}
