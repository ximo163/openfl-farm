package mc.control;

import mc.view.main.WindowLayer;
import openfl.errors.Error;
import openfl.events.EventDispatcher;

/**
 * mc.control.ViewControl —— ViewControl.as 逐句对应（issue #19 Master2 闭包
 * 顺手译）。视图层单例事件总线：WControl/TipControl 的窗口与提示开闭都经它
 * 派发，windowsLayer 由建层流程注入（WindowLayer 为牧场片 stub）。
 */
@:keep
class ViewControl extends EventDispatcher {
	// ViewControl.as:10
	private static var instance:ViewControl;

	// ViewControl.as:12
	public var windowsLayer:WindowLayer;

	public function new() {
		// PORT-NOTE(cpp)：原版 super() 在守卫内、throw 路径不调；Haxe/cpp
		// 要求所有路径先调 super，EventDispatcher 构造无副作用，前移等价
		super();
		if (instance == null) {
			return;
		}
		throw new Error("实例化单例类出错-ViewControl");
	}

	// ViewControl.as:22-29
	public static function getInstance():ViewControl {
		if (instance == null) {
			instance = new ViewControl();
		}
		return instance;
	}
}
