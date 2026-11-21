package common.view.tip;

import interfaces.ITip;
import openfl.display.DisplayObject;
import openfl.display.Sprite;

/**
 * common.view.tip.Tip —— Tip.as 逐句对应（issue #19 补齐 #7 的闭包 stub：
 * messages 片的 HistoryItemTip 继承本类并覆写 data/mX/mY）。
 * 提示基类：只存 tX/tY/mX/mY/_data/_tipName，定位/显隐由 TipControl 驱动。
 */
@:keep
class Tip extends Sprite implements ITip {
	// Tip.as:9
	private var _tX:Float;

	// Tip.as:11
	private var _tY:Float;

	// Tip.as:13
	private var _tipName:String;

	// Tip.as:15
	private var _data:Dynamic;

	// Tip.as:17
	private var _mX:Float;

	// Tip.as:19
	private var _mY:Float;

	public function new() {
		super();
		this._mX = 0;
		this._mY = 0;
		this._tX = 0;
		this._tY = 0;
		this._data = null;
	}

	// Tip.as:31-34（get tY :88-91）
	public var tY(get, set):Float;

	private function get_tY():Float {
		return this._tY;
	}

	private function set_tY(param1:Float):Float {
		this._tY = param1;
		return param1;
	}

	// Tip.as:36-39
	public var mY(get, set):Float;

	private function get_mY():Float {
		return this._mY;
	}

	private function set_mY(param1:Float):Float {
		this._mY = param1;
		return param1;
	}

	// Tip.as:41-44
	public var tipName(get, never):String;

	private function get_tipName():String {
		return this._tipName;
	}

	// Tip.as:46-49（get tX :82-85）
	public var tX(get, set):Float;

	private function get_tX():Float {
		return this._tX;
	}

	private function set_tX(param1:Float):Float {
		this._tX = param1;
		return param1;
	}

	// Tip.as:51-54（子类 HistoryItemTip/HistoryTip 覆写：写 mY 顺带挪 y）
	public var mX(get, set):Float;

	private function get_mX():Float {
		return this._mX;
	}

	private function set_mX(param1:Float):Float {
		this._mX = param1;
		return param1;
	}

	// Tip.as:60-63
	public var displayObject(get, never):DisplayObject;

	private function get_displayObject():DisplayObject {
		return this;
	}

	// Tip.as:65-68（子类覆写装载内容）
	public var data(get, set):Dynamic;

	private function get_data():Dynamic {
		return this._data;
	}

	private function set_data(param1:Dynamic):Dynamic {
		this._data = param1;
		return param1;
	}
}
