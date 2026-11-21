package mc.events;

import openfl.events.Event;

/**
 * mc.events.WindowEvent —— WindowEvent.as 逐句对应（issue #19 Master2 闭包
 * 顺手译）。WControl 开/关窗口经 ViewControl 派发，载荷按 window 或
 * windowName+windowArgument 两种形态。
 */
@:keep
class WindowEvent extends Event {
	// WindowEvent.as:10-12
	public static final OPEN:String = "windowOpen";
	public static final CLOSE:String = "windowClose";

	// WindowEvent.as:14
	private var _windowArgument:Dynamic;

	// WindowEvent.as:16
	private var _window:mc.view.common.BaseWindow;

	// WindowEvent.as:18
	private var _startX:Int = 0;

	// WindowEvent.as:20
	private var _windowName:String = "";

	// WindowEvent.as:22
	private var _startY:Int = 0;

	public function new(param1:String, param2:Bool = false, param3:Bool = false) {
		super(param1, param2, param3);
	}

	// WindowEvent.as:31-34（AS3 public get/set window 对）
	public var window(get, set):mc.view.common.BaseWindow;

	private function get_window():mc.view.common.BaseWindow {
		return this._window;
	}

	private function set_window(param1:mc.view.common.BaseWindow):mc.view.common.BaseWindow {
		this._window = param1;
		return param1;
	}

	// WindowEvent.as:36-39
	public var windowArgument(get, set):Dynamic;

	private function get_windowArgument():Dynamic {
		return this._windowArgument;
	}

	private function set_windowArgument(param1:Dynamic):Dynamic {
		this._windowArgument = param1;
		return param1;
	}

	// WindowEvent.as:41-（get windowName / set :63-）
	public var windowName(get, set):String;

	private function get_windowName():String {
		return this._windowName;
	}

	private function set_windowName(param1:String):String {
		this._windowName = param1;
		return param1;
	}

	// WindowEvent.as:（get/set startX、startY）
	public var startX(get, set):Int;

	private function get_startX():Int {
		return this._startX;
	}

	private function set_startX(param1:Int):Int {
		this._startX = param1;
		return param1;
	}

	public var startY(get, set):Int;

	private function get_startY():Int {
		return this._startY;
	}

	private function set_startY(param1:Int):Int {
		this._startY = param1;
		return param1;
	}
}
