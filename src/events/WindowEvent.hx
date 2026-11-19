package events;

import common.view.window.BaseWindow;
import openfl.events.Event;

// events.WindowEvent —— WindowEvent.as 逐句对应。
class WindowEvent extends Event {
	// WindowEvent.as:9/:11
	public static final CLOSE:String = "windowClose";
	public static final OPEN:String = "windowOpen";

	// WindowEvent.as:13-21
	private var _windowArgument:Dynamic;
	private var _window:BaseWindow;
	private var _startX:Int = 0; // AS3 int 默认值
	private var _startY:Int = 0;
	private var _windowName:String = "";

	// WindowEvent.as:23-26
	public function new(param1:String, param2:Bool = false, param3:Bool = false) {
		super(param1, param2, param3);
	}

	// WindowEvent.as:28-74
	public var window(get, set):BaseWindow;
	public var windowArgument(get, set):Dynamic;
	public var windowName(get, set):String;
	public var startX(get, set):Int;
	public var startY(get, set):Int;

	private function get_windowName():String {
		return this._windowName;
	}

	private function set_windowName(param1:String):String {
		this._windowName = param1;
		return param1;
	}

	private function get_windowArgument():Dynamic {
		return this._windowArgument;
	}

	private function set_windowArgument(param1:Dynamic):Dynamic {
		this._windowArgument = param1;
		return param1;
	}

	private function get_window():BaseWindow {
		return this._window;
	}

	private function set_window(param1:BaseWindow):BaseWindow {
		this._window = param1;
		return param1;
	}

	private function get_startX():Int {
		return this._startX;
	}

	private function set_startX(param1:Int):Int {
		this._startX = param1;
		return param1;
	}

	private function get_startY():Int {
		return this._startY;
	}

	private function set_startY(param1:Int):Int {
		this._startY = param1;
		return param1;
	}
}
