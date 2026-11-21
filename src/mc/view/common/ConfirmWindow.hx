package mc.view.common;

import common.MaterialLib;

/**
 * mc.view.common.ConfirmWindow —— ConfirmWindow.as 的签名面 stub（原类
 * 211 loc，牧场片真身待译——#pasture；issue #19 只保 profile 窗族「清空
 * 记录」确认用到的 ctor/data/confirmFn/cancelFn 通道）。成员清单见
 * legacy/decompiled/Master2_v_142/scripts/mc/view/common/ConfirmWindow.as:16
 * （ctor `ConfirmWindow(param1:Number = 360)`）；ctor 常量按原文 :26-31
 * 逐字镜像（height=320、AlertWindowTitle、"ConfirmWindow"——不发明）。
 */
@:keep
class ConfirmWindow extends BaseWindow {
	private var _confirmFn:Dynamic;
	private var _cancelFn:Dynamic;
	private var _confirmEnable:Bool = true;

	public function new(param1:Float = 360) {
		super();
		width = param1;
		height = 320;
		titleIMG = MaterialLib.getInstance().getClass("AlertWindowTitle");
		windowName = "ConfirmWindow";
		mode = true;
	}

	// ConfirmWindow.as:71
	override public function init():Void {
		super.init();
	}

	// ConfirmWindow.as:123/（data：{"text":...}）
	override private function set_data(param1:Dynamic):Dynamic {
		return super.set_data(param1);
	}

	// ConfirmWindow.as:138/162
	public var confirmFn(get, set):Dynamic;

	private function get_confirmFn():Dynamic {
		return this._confirmFn;
	}

	private function set_confirmFn(param1:Dynamic):Dynamic {
		this._confirmFn = param1;
		return param1;
	}

	// ConfirmWindow.as:56/152
	public var cancelFn(get, set):Dynamic;

	private function get_cancelFn():Dynamic {
		return this._cancelFn;
	}

	private function set_cancelFn(param1:Dynamic):Dynamic {
		this._cancelFn = param1;
		return param1;
	}

	// ConfirmWindow.as:61/157
	public var confirmEnable(get, set):Bool;

	private function get_confirmEnable():Bool {
		return this._confirmEnable;
	}

	private function set_confirmEnable(param1:Bool):Bool {
		this._confirmEnable = param1;
		return param1;
	}

	// ConfirmWindow.as:143
	public function cancelButtonClick(param1:Dynamic):Void {}

	// ConfirmWindow.as:205
	override public function keyEnter():Void {}
}
