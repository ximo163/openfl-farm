package common.view.window;

import interfaces.IMsgCenter;
import openfl.display.Sprite;

/**
 * common.view.window.BaseWindow —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * 窗口基类（原版继承 qui TitleWindow，带 data/windowName/mode 存取与
 * 初始化生命周期）属于通用视图的窗口片；这里只保公共 API 形态
 * （BaseWindow.as:25-118 的签名）让 WindowControl/FarmApplication 编译，
 * 标题栏/布局/关闭按钮随窗口片接入。
 */
@:keep
class BaseWindow extends Sprite {
	// BaseWindow.as:27
	private var _data:Dynamic;

	// BaseWindow.as:29
	private var _windowName:String = "";

	// BaseWindow.as:31
	private var _mode:Bool = false;

	// BaseWindow.as:25-40
	public function new(param1:IMsgCenter = null) {
		super();
	}

	// BaseWindow.as:42-58（initalize：加入舞台后的初始化，窗口片翻译）
	public function initalize(param1:Dynamic):Void {}

	// BaseWindow.as:60-68（onEffectEnd：开关窗动效结束，窗口片翻译）
	public function onEffectEnd():Void {}

	// BaseWindow.as:70-78
	public var mode(get, set):Bool;

	private function get_mode():Bool {
		return this._mode;
	}

	private function set_mode(param1:Bool):Bool {
		this._mode = param1;
		return param1;
	}

	// BaseWindow.as:80-91
	public var data(get, set):Dynamic;

	private function get_data():Dynamic {
		return this._data;
	}

	private function set_data(param1:Dynamic):Dynamic {
		this._data = param1;
		return param1;
	}

	// BaseWindow.as:94-97
	public var windowName(get, set):String;

	private function get_windowName():String {
		return this._windowName;
	}

	private function set_windowName(param1:String):String {
		this._windowName = param1;
		return param1;
	}

	// BaseWindow.as:113-116
	public var isInit(get, never):Bool;

	private function get_isInit():Bool {
		return false;
	}
}
