package com.qzone.qfa.debug;

import com.qzone.qfa.events.DebugEvent;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;
import shim.As3;

// DebuggerWindow.as 逐句对应。
// PORT-NOTE: `this._textField = this._textField || new TextField()` → 判空再 new
//（Haxe 无短路 || 表达式赋值的等价直译，语义相同）。
class DebuggerWindow extends Sprite {
	// DebuggerWindow.as:11
	private var _initialized:Bool = false;

	// DebuggerWindow.as:13
	private var _textField:TextField;

	// DebuggerWindow.as:15-20
	public function new() {
		super();
		this.mouseEnabled = false;
		this.addEventListener(Event.ADDED_TO_STAGE, this.handleAddToStage);
	}

	// DebuggerWindow.as:22-29
	private function handleDebug(param1:DebugEvent):Void {
		if (As3.truthy(this._textField) && As3.truthy(this.stage)) {
			this._textField.appendText(param1.log + "\n");
			this._textField.scrollV = this._textField.maxScrollV;
		}
	}

	// DebuggerWindow.as:31-37
	private override function set_visible(param1:Bool):Bool {
		super.set_visible(param1);
		if (this.visible) {
			this.mouseChildren = true;
		}
		return param1;
	}

	// DebuggerWindow.as:39-45
	private function handleAddToStage(param1:Event):Void {
		if (!this._initialized) {
			this._initialized = true;
			this.initSkin();
		}
	}

	// DebuggerWindow.as:47-72
	private function keyHandler(param1:KeyboardEvent):Void {
		trace(param1.keyCode);
		if (param1.keyCode == 191 && param1.ctrlKey) {
			this.visible = !this.visible;
			if (this.parent != null) {
				this.parent.setChildIndex(this, this.parent.numChildren - 1);
			}
		} else if (param1.keyCode == 88) {
			if (this._textField != null) {
				this._textField.text = "";
			}
		}
		if (this.visible == false) {
			return;
		}
		switch (param1.keyCode) {
			case 27:
				this.mouseChildren = !this.mouseChildren;
			default:
		}
	}

	// DebuggerWindow.as:74-89
	private function initSkin():Void {
		this.graphics.clear();
		this.graphics.beginFill(0, 0.6);
		this.graphics.drawRoundRectComplex(0, 0, 600, 200, 0, 0, 0, 10);
		this.graphics.endFill();
		if (this._textField == null) {
			this._textField = new TextField();
		}
		this._textField.width = 600;
		this._textField.height = 200;
		this._textField.multiline = true;
		this._textField.wordWrap = true;
		this._textField.defaultTextFormat = new TextFormat("Lucida Sans Unicode", 13, 65280);
		addChild(this._textField);
		stage.addEventListener(KeyboardEvent.KEY_UP, this.keyHandler);
		this.visible = false;
	}
}
