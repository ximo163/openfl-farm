package com.qzone.qfa.debug;

import openfl.display.Sprite;
import openfl.text.StyleSheet;
import openfl.text.TextField;

// SimpleConsoleWindow.as 逐句对应。
class SimpleConsoleWindow extends Sprite implements IConsoleWindow {
	// SimpleConsoleWindow.as:19
	private var _textField:TextField;

	// SimpleConsoleWindow.as:21
	private var _logType:Int = -1;

	public function new() {
		super();
		this.initSkin();
	}

	// SimpleConsoleWindow.as:23-26
	public var logType(get, set):Int;

	// SimpleConsoleWindow.as:28-34
	public function hide():Void {
		if (this.parent != null) {
			this.stage.focus = this.stage;
			this.parent.removeChild(this);
		}
	}

	private function get_logType():Int {
		return this._logType;
	}

	// SimpleConsoleWindow.as:36-38
	private function set_logType(param1:Int):Int {
		this._logType = param1;
		return param1;
	}

	// SimpleConsoleWindow.as:40-61
	private function initSkin():Void {
		this.graphics.clear();
		this.graphics.beginFill(0, 0.8);
		this.graphics.drawRoundRectComplex(0, 0, 700, 200, 0, 0, 0, 10);
		this.graphics.endFill();
		this._textField = this._textField == null ? new TextField() : this._textField;
		this._textField.width = 700;
		this._textField.height = 200;
		this._textField.multiline = true;
		this._textField.wordWrap = true;
		var _loc1_:StyleSheet = new StyleSheet();
		_loc1_.setStyle("p", {
			"fontFamily": "Lucida Sans Unicode",
			"fontSize": 13,
			"color": "#00FF00"
		});
		_loc1_.setStyle(".t", {"leading": -20});
		_loc1_.setStyle(".m", {"marginLeft": 90});
		this._textField.styleSheet = _loc1_;
		addChild(this._textField);
	}

	// SimpleConsoleWindow.as:63-66
	public var isHidden(get, never):Bool;

	private function get_isHidden():Bool {
		return this.stage == null;
	}

	// SimpleConsoleWindow.as:68-76
	public var dataProvider(never, set):Array<Dynamic>;

	private function set_dataProvider(param1:Array<Dynamic>):Array<Dynamic> {
		if (param1 == null) {
			return param1;
		}
		this._textField.htmlText = param1.join("");
		this._textField.scrollV = this._textField.maxScrollV;
		return param1;
	}
}
