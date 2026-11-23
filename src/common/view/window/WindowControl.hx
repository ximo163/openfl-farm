package common.view.window;

import events.WindowEvent;
import interfaces.IMsgCenter;

/**
 * common.view.window.WindowControl —— WindowControl.as 逐句对应（issue #41
 * 替换 #7 的闭包 stub）。窗口控件：窗口名→类的注册表（m_lib，register 前
 * 为 null，getClass 走 null 门）+ open/openForName/close/closeForName 四个
 * WindowEvent 派发出口（真正的弹窗/关窗在 WindowLayer 的监听里）。
 */
@:keep
class WindowControl {
	// WindowControl.as:9
	private var m_msgCenter:IMsgCenter;

	// WindowControl.as:11（register 前 null）
	private var m_lib:Dynamic;

	// WindowControl.as:13-17
	public function new(param1:IMsgCenter) {
		this.m_msgCenter = param1;
	}

	// WindowControl.as:19-22
	public function getMsgCenter():IMsgCenter {
		return this.m_msgCenter;
	}

	// WindowControl.as:24-33
	public function open(param1:BaseWindow):Void {
		if (param1 == null) {
			return;
		}
		var _loc2_:WindowEvent = new WindowEvent(WindowEvent.OPEN);
		_loc2_.window = param1;
		this.m_msgCenter.dispatchEvent(_loc2_);
	}

	// WindowControl.as:35-42
	public function getClass(param1:String):Class<Dynamic> {
		if (this.m_lib == null) {
			return null;
		}
		return Reflect.field(this.m_lib, param1);
	}

	// WindowControl.as:44-54
	public function openForName(param1:String, param2:Dynamic = null):Void {
		if (param1 == null || param1.length == 0) {
			return;
		}
		var _loc3_:WindowEvent = new WindowEvent(WindowEvent.OPEN);
		_loc3_.windowName = param1;
		_loc3_.windowArgument = param2;
		this.m_msgCenter.dispatchEvent(_loc3_);
	}

	// WindowControl.as:56-63
	public function register(param1:String, param2:Class<Dynamic>):Void {
		if (this.m_lib == null) {
			this.m_lib = {};
		}
		Reflect.setField(this.m_lib, param1, param2);
	}

	// WindowControl.as:65-74
	public function closeForName(param1:String):Void {
		if (param1 == null || param1.length == 0) {
			return;
		}
		var _loc2_:WindowEvent = new WindowEvent(WindowEvent.CLOSE);
		_loc2_.windowName = param1;
		this.m_msgCenter.dispatchEvent(_loc2_);
	}

	// WindowControl.as:76-85
	public function close(param1:BaseWindow):Void {
		if (param1 == null) {
			return;
		}
		var _loc2_:WindowEvent = new WindowEvent(WindowEvent.CLOSE);
		_loc2_.window = param1;
		this.m_msgCenter.dispatchEvent(_loc2_);
	}
}
