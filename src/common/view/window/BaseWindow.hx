package common.view.window;

import com.qzone.qui.containers.TitleWindow;
import com.qzone.qui.core.Align;
import com.qzone.qui.effects.Move;
import interfaces.IMsgCenter;
import openfl.events.Event;
import openfl.text.TextFormat;

/**
 * common.view.window.BaseWindow —— BaseWindow.as 逐句对应（issue #18 qui
 * 收尾：通用窗口片整类翻译，替换 #7 的签名 stub）。通用窗口基类：换
 * WindowBg/CloseButton 皮肤、居中标题、ADDED_TO_STAGE 触发 initalize →
 * addedToLayer 生命周期；data 带 width/height 时置 _recenter，等动效结束
 * onEffectEnd 再居中（PopUpLayer 的 In 效果回调会调到它）。
 */
@:keep
class BaseWindow extends TitleWindow {
	// BaseWindow.as:13-23
	private var _mode:Bool;

	private var m_msgCenter:IMsgCenter;

	private var _recenter:Bool;

	private var _data:Dynamic;

	private var _isInit:Bool;

	private var _windowName:String;

	// :25-40
	public function new(param1:IMsgCenter = null) {
		super();
		this.m_msgCenter = param1;
		defaultSkin = WindowBg;
		closeButtonSkin = CloseButton;
		showCloseButton = true;
		titleAlign = Align.CENTER;
		titleDefautFormat = new TextFormat("Verdana", 16, 16777215, true);
		effect = Move;
		this._data = null;
		this._isInit = false;
		this._mode = false;
		this._recenter = false;
		addEventListener(Event.ADDED_TO_STAGE, this.initalize, false, 0, true);
	}

	// :42-58
	public function initalize(param1:Event):Void {
		param1.target.removeEventListener(Event.ADDED_TO_STAGE, this.initalize);
		if (this._inited == false) {
			this.init();
		}
		if (closeButton != null) {
			closeButton.useHandCursor = true;
		}
		if (panelTitle != null) {
			panelTitle.y = 3;
		}
		this.addedToLayer();
	}

	// :60-68
	public function onEffectEnd():Void {
		if (this._recenter == true && parent != null) {
			x = (parent.width - this.width) * 0.5;
			y = (parent.height - this.height) * 0.5;
			this._recenter = false;
		}
	}

	// :70-78
	public var mode(get, set):Bool;

	private function get_mode():Bool {
		return this._mode;
	}

	private function set_mode(param1:Bool):Bool {
		this._mode = param1;
		return param1;
	}

	// :80-83 + :99-111（AS3 public get/set data 对）
	public var data(get, set):Dynamic;

	private function get_data():Dynamic {
		return this._data;
	}

	// :85-87（空实现：子类覆写点，ContentWindow 覆写）
	private function setData():Void {}

	// :89-92（默认只落 _isInit，子类覆写点）
	private function addedToLayer():Void {
		this._isInit = true;
	}

	// :94-97 + :118-121（AS3 public get/set windowName 对）
	public var windowName(get, set):String;

	private function set_windowName(param1:String):String {
		this._windowName = param1;
		return param1;
	}

	// :99-111（`_data.hasOwnProperty("width")`：数据是匿名记录 → hasField）
	private function set_data(param1:Dynamic):Dynamic {
		this._data = param1;
		this._recenter = false;
		if (this._data != null) {
			if (Reflect.hasField(this._data, "width") == true || Reflect.hasField(this._data, "height") == true) {
				this._recenter = true;
			}
		}
		this.setData();
		return param1;
	}

	// :113-116
	public var isInit(get, never):Bool;

	private function get_isInit():Bool {
		return this._isInit;
	}

	// :118-121
	private function get_windowName():String {
		return this._windowName;
	}
}
