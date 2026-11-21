package mc.view.main.tip;

import openfl.display.Sprite;

/**
 * mc.view.main.tip.Tip —— Tip.as 逐句对应（issue #19 Master2 闭包顺手译）。
 */
@:keep
class Tip extends Sprite implements ITip {
	// Tip.as:8-16
	private var _tX:Float = 0;
	private var _tY:Float = 0;
	private var _data:Dynamic;
	private var _mX:Float = 0;
	private var _mY:Float = 0;

	public function new() {
		super();
	}

	// Tip.as:23-26 等（AS3 public get/set 对，声明顺序打乱无行为差异）
	public var tX(get, set):Float;

	public function get_tX():Float {
		return this._tX;
	}

	public function set_tX(param1:Float):Float {
		this._tX = param1;
		return param1;
	}

	public var tY(get, set):Float;

	public function get_tY():Float {
		return this._tY;
	}

	public function set_tY(param1:Float):Float {
		this._tY = param1;
		return param1;
	}

	public var data(get, set):Dynamic;

	public function get_data():Dynamic {
		return this._data;
	}

	public function set_data(param1:Dynamic):Dynamic {
		this._data = param1;
		return param1;
	}

	public var mX(get, set):Float;

	public function get_mX():Float {
		return this._mX;
	}

	public function set_mX(param1:Float):Float {
		this._mX = param1;
		return param1;
	}

	public var mY(get, set):Float;

	public function get_mY():Float {
		return this._mY;
	}

	public function set_mY(param1:Float):Float {
		this._mY = param1;
		return param1;
	}
}
