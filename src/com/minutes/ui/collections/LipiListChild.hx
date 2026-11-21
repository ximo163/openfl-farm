package com.minutes.ui.collections;

import openfl.display.Sprite;

/**
 * com.minutes.ui.collections.LipiListChild —— LipiListChild.as 逐句对应
 * （issue #19 Master2 闭包顺手译）。
 */
@:keep
class LipiListChild extends Sprite implements ILipiTileChild {
	private var _fixedX:Float;
	private var _data:Dynamic;
	private var _fixedY:Float;

	public function new() {
		super();
	}

	// LipiListChild.as:19-27 等（AS3 public get/set 对）
	public var fixedY(get, set):Float;

	public function get_fixedY():Float {
		return this._fixedY;
	}

	public function set_fixedY(param1:Float):Float {
		this._fixedY = param1;
		return param1;
	}

	public var fixedX(get, set):Float;

	public function get_fixedX():Float {
		return this._fixedX;
	}

	public function set_fixedX(param1:Float):Float {
		this._fixedX = param1;
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
}
