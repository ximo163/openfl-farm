package support;

import interfaces.ITip;
import openfl.display.DisplayObject;

// 测试侧 ITip 假实现：只记录 data 写入（issue #42）。TipLayer.onTipUpdate
// 的同型刷新路由用它断言（原版 m_tip 是 ITip，data 写入即刷新动作）。
// 形态镜像 common/view/tip/Tip（访问器私有、字段直存），不含任何显示件
// （displayObject 恒 null——onTipUpdate 路径不碰它）。
class FakeTip implements ITip {
	public var dataWrites:Array<Dynamic> = [];

	private var _tipName:String;
	private var _data:Dynamic;
	private var _mX:Float = 0;
	private var _mY:Float = 0;
	private var _tX:Float = 0;
	private var _tY:Float = 0;

	public function new(param1:String = "FakeTip") {
		this._tipName = param1;
	}

	public var displayObject(get, never):DisplayObject;

	private function get_displayObject():DisplayObject {
		return null;
	}

	public var tipName(get, never):String;

	private function get_tipName():String {
		return this._tipName;
	}

	public var data(get, set):Dynamic;

	private function get_data():Dynamic {
		return this._data;
	}

	private function set_data(param1:Dynamic):Dynamic {
		this.dataWrites.push(param1);
		this._data = param1;
		return param1;
	}

	public var tX(get, set):Float;

	private function get_tX():Float {
		return this._tX;
	}

	private function set_tX(param1:Float):Float {
		this._tX = param1;
		return param1;
	}

	public var tY(get, set):Float;

	private function get_tY():Float {
		return this._tY;
	}

	private function set_tY(param1:Float):Float {
		this._tY = param1;
		return param1;
	}

	public var mX(get, set):Float;

	private function get_mX():Float {
		return this._mX;
	}

	private function set_mX(param1:Float):Float {
		this._mX = param1;
		return param1;
	}

	public var mY(get, set):Float;

	private function get_mY():Float {
		return this._mY;
	}

	private function set_mY(param1:Float):Float {
		this._mY = param1;
		return param1;
	}
}
