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
	// ConfirmWindow.as:18-32
	private var _confirmFn:Dynamic;
	private var cancelButton:com.minutes.ui.control.LipiButton;
	private var confirmButton:com.minutes.ui.control.LipiButton;
	private var errorText:openfl.text.TextField;
	private var alertText:openfl.text.TextField;
	private var _cancelFn:Dynamic;
	private var _confirmEnable:Bool = true;

	// ConfirmWindow.as:34-54（ctor 原文即完整：尺寸/窗名/mode + alertText
	// 装配逐字——#19 stub 漏了 alertText 段，#87 补全）
	public function new(param1:Float = 360) {
		super();
		this.width = param1;
		height = 320;
		titleIMG = MaterialLib.getInstance().getClass("AlertWindowTitle");
		windowName = "ConfirmWindow";
		mode = true;
		this.alertText = new openfl.text.TextField();
		this.alertText.selectable = false;
		var _loc2_:openfl.text.TextFormat = new openfl.text.TextFormat("Verdana", 14, 8999699, null, null, null, null, null, openfl.text.TextFormatAlign.CENTER);
		_loc2_.leading = 8;
		this.alertText.defaultTextFormat = _loc2_;
		this.alertText.width = width - 60;
		this.alertText.x = (width - this.alertText.width) / 2;
		this.alertText.y = 170;
		this.alertText.wordWrap = true;
		this.alertText.multiline = true;
		this.alertText.autoSize = openfl.text.TextFieldAutoSize.CENTER;
		this.alertText.htmlText = "";
		addChild(this.alertText);
	}

	// ConfirmWindow.as:71-123（按钮/图标装配——真身随 implement）
	override public function init(param1:openfl.geom.Rectangle = null):Void {
		throw new openfl.errors.Error("not implemented");
	}

	// ConfirmWindow.as:66-70（width 覆写联动 alertText.width——原文即完整）
	override private function set_width(param1:Float):Float {
		super.set_width(param1);
		if (this.alertText != null) {
			this.alertText.width = param1 - 60;
		}
		return param1;
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
