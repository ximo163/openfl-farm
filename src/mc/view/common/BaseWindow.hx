package mc.view.common;

import com.minutes.ui.core.LipiPanel;
import openfl.display.Sprite;

/**
 * mc.view.common.BaseWindow —— BaseWindow.as 的签名面 stub（原类 134 loc，
 * 牧场片真身待译——#pasture；issue #19 只保 profile/公告窗族用到的成员：
 * mode/windowName/data/isInit 属性对与 init/addedToLayer/closeHandler 通道）。
 * 成员清单见 legacy/decompiled/Master2_v_142/scripts/mc/view/common/BaseWindow.as。
 */
@:keep
class BaseWindow extends LipiPanel {
	// BaseWindow.as:13-23
	private var _mode:Bool = false;
	private var _data:Dynamic;
	private var _windowMode:Sprite;
	private var _isInit:Bool = false;
	private var _windowName:String = "";

	public function new() {
		super();
	}

	// BaseWindow.as:32
	public function addAll():Void {}

	// BaseWindow.as:43（protected：子窗关窗钩子）
	private function closeHandler():Void {}

	// BaseWindow.as:50/103
	public var isInit(get, set):Bool;

	private function get_isInit():Bool {
		return this._isInit;
	}

	private function set_isInit(param1:Bool):Bool {
		this._isInit = param1;
		return param1;
	}

	// BaseWindow.as:55
	public function addedToLayer():Void {}

	// BaseWindow.as:59/108
	public var mode(get, set):Bool;

	private function get_mode():Bool {
		return this._mode;
	}

	private function set_mode(param1:Bool):Bool {
		this._mode = param1;
		return param1;
	}

	// BaseWindow.as:64
	public function removedFromLayer():Void {}

	// BaseWindow.as:68
	public function keyEnter():Void {}

	// BaseWindow.as:72/113
	public var windowMode(get, set):Sprite;

	private function get_windowMode():Sprite {
		return this._windowMode;
	}

	private function set_windowMode(param1:Sprite):Sprite {
		this._windowMode = param1;
		return param1;
	}

	// BaseWindow.as:77
	public function removeAll():Void {}

	// BaseWindow.as:89
	public function init():Void {}

	// BaseWindow.as:93/118
	public var data(get, set):Dynamic;

	private function get_data():Dynamic {
		return this._data;
	}

	private function set_data(param1:Dynamic):Dynamic {
		this._data = param1;
		return param1;
	}

	// BaseWindow.as:98/123
	public var windowName(get, set):String;

	private function get_windowName():String {
		return this._windowName;
	}

	private function set_windowName(param1:String):String {
		this._windowName = param1;
		return param1;
	}
}
