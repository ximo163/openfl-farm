package mc.view.main.windowControl;

import mc.control.ViewControl;
import mc.events.WindowEvent;
import mc.view.common.BaseWindow;

/**
 * mc.view.main.windowControl.WControl —— WControl.as 逐句对应（issue #19
 * Master2 闭包顺手译）。窗口开闭静态门面：经 ViewControl 派发 WindowEvent，
 * 真正的层管理在 WindowLayer（牧场片 stub）。
 * PORT-NOTE(命名)：原包 `mc.view.main.WindowControl` 首字母大写，Haxe 包段
 * 必须小写开头，落 `windowControl`（类名不变）。
 */
@:keep
class WControl {
	public function new() {}

	// WControl.as:11-16
	public static function close(param1:BaseWindow):Void {
		var _loc2_:WindowEvent = new WindowEvent(WindowEvent.CLOSE);
		_loc2_.window = param1;
		ViewControl.getInstance().dispatchEvent(_loc2_);
	}

	// WControl.as:18-23
	public static function open(param1:BaseWindow):Void {
		var _loc2_:WindowEvent = new WindowEvent(WindowEvent.OPEN);
		_loc2_.window = param1;
		ViewControl.getInstance().dispatchEvent(_loc2_);
	}

	// WControl.as:25-31
	public static function closeForName(param1:String, param2:Dynamic = null):Void {
		var _loc3_:WindowEvent = new WindowEvent(WindowEvent.CLOSE);
		_loc3_.windowName = param1;
		_loc3_.windowArgument = param2;
		ViewControl.getInstance().dispatchEvent(_loc3_);
	}

	// WControl.as:33-39
	public static function openForName(param1:String, param2:Dynamic = null):Void {
		var _loc3_:WindowEvent = new WindowEvent(WindowEvent.OPEN);
		_loc3_.windowName = param1;
		_loc3_.windowArgument = param2;
		ViewControl.getInstance().dispatchEvent(_loc3_);
	}
}
