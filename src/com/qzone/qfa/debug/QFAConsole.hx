package com.qzone.qfa.debug;

import com.qzone.qfa.model.DebugLog;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.events.KeyboardEvent;
import shim.As3;

// QFAConsole.as 逐句对应。
class QFAConsole {
	// QFAConsole.as:17
	public static var consoleWindow:IConsoleWindow;

	// QFAConsole.as:19
	private static var _logs:Array<Dynamic>;

	// QFAConsole.as:21
	public static var consoleWindowClass:Class<Dynamic>;

	// QFAConsole.as:23
	private static var _stage:DisplayObjectContainer;

	// QFAConsole.as:25-33。`param2 || SimpleConsoleWindow`：Class 值只在 null 时
	// 为假，落到判空即可
	public function new(param1:DisplayObjectContainer, param2:Class<Dynamic> = null) {
		consoleWindowClass = param2 != null ? param2 : SimpleConsoleWindow;
		_stage = param1;
		if (_stage != null) {
			_stage.addEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
		}
	}

	// QFAConsole.as:35-38
	public static function getAllLogs():Array<Dynamic> {
		return _logs;
	}

	// QFAConsole.as:40-47
	public static var stage(get, set):DisplayObjectContainer;

	private static function get_stage():DisplayObjectContainer {
		return _stage;
	}

	private static function set_stage(param1:DisplayObjectContainer):DisplayObjectContainer {
		_stage = param1;
		if (_stage != null) {
			_stage.addEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
		}
		return param1;
	}

	// QFAConsole.as:49-66
	public static function log(param1:Dynamic, param2:Int = 0):Void {
		_logs = _logs == null ? [] : _logs;
		var _loc3_:DebugLog = new DebugLog(Std.string(param1), param2);
		_logs.push(_loc3_);
		if (consoleWindow != null) {
			if (consoleWindow.logType == -1) {
				consoleWindow.dataProvider = _logs;
			} else {
				consoleWindow.dataProvider = getLogsByType(consoleWindow.logType) == null ? [] : getLogsByType(consoleWindow.logType);
			}
		}
		trace(_loc3_.toStringWithoutFormat());
	}

	// QFAConsole.as:68-70
	public static function clear():Void {
		_logs = [];
		if (As3.truthy(consoleWindow) && !consoleWindow.isHidden) {
			consoleWindow.dataProvider = _logs;
		}
	}

	// QFAConsole.as:72-110
	private static function handleKeyUp(param1:KeyboardEvent):Void {
		var _loc3_:Array<Dynamic> = null;
		if (param1.keyCode == 191 && param1.ctrlKey) {
			if (consoleWindow == null) {
				// `new consoleWindowClass()`：反射实例化
				consoleWindow = cast(Type.createInstance(consoleWindowClass, []), IConsoleWindow);
			}
			if (consoleWindow.isHidden) {
				show();
			} else {
				hide();
			}
		}
		if (consoleWindow == null || consoleWindow.isHidden || param1.keyCode == 33 || param1.keyCode == 34) {
			return;
		}
		if (param1.keyCode == 88 && As3.truthy(consoleWindow) && !consoleWindow.isHidden) {
			clear();
		}
		var _loc2_:Int = param1.keyCode - 49;
		if (_loc2_ == DebugLog.ERROR || _loc2_ == DebugLog.LOG || _loc2_ == DebugLog.TRAFFIC || _loc2_ == DebugLog.WARNING) {
			_loc3_ = getLogsByType(_loc2_) == null ? [] : getLogsByType(_loc2_);
			consoleWindow.logType = _loc2_;
		} else {
			_loc3_ = _logs == null ? [] : _logs;
			consoleWindow.logType = -1;
		}
		consoleWindow.dataProvider = _loc3_;
	}

	// QFAConsole.as:112-128
	public static function getLogsByType(param1:Int):Array<Dynamic> {
		var _loc3_:DebugLog = null;
		var _loc2_:Int = _logs.length;
		var _loc4_:Array<Dynamic> = [];
		var _loc5_:Int = 0;
		while (_loc5_ < _loc2_) {
			_loc3_ = cast(_logs[_loc5_], DebugLog);
			if (_loc3_.type == param1) {
				_loc4_.push(_loc3_);
			}
			_loc5_++;
		}
		return _loc4_;
	}

	// QFAConsole.as:130-139
	public static function hide():Void {
		if (consoleWindow != null) {
			if (!consoleWindow.isHidden) {
				consoleWindow.hide();
			}
		}
	}

	// QFAConsole.as:141-154
	public static function show():Void {
		if (consoleWindow == null) {
			consoleWindow = cast(Type.createInstance(consoleWindowClass, []), IConsoleWindow);
		}
		if (consoleWindow.isHidden) {
			_stage.addChildAt(cast(consoleWindow, DisplayObject), _stage.numChildren);
			consoleWindow.dataProvider = consoleWindow.logType == -1 ? _logs : getLogsByType(consoleWindow.logType);
		}
	}
}
