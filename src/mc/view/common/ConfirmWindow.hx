package mc.view.common;

import com.minutes.ui.control.LipiButton;
import com.minutes.ui.core.LipiSkin;
import common.MaterialLib;
import mc.view.main.windowControl.WControl;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.events.TextEvent;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import shim.As3;
import shim.QQOutlets;

/**
 * mc.view.common.ConfirmWindow —— ConfirmWindow.as 逐句对应（issue #87
 * 牧场「通用视图」片；#19 签名面 stub 充真身）。确认/取消双钮窗：
 * ConfirmIcon 居中 y=60，确定钮 x=width/2-64-10、取消钮 x=width/2+10，
 * y 同 height-45；data.text/data.error 任一键进来都重排高度
 * （height=文本.height+文本.y+70）。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/common/ConfirmWindow.as。
 *
 * PORT-NOTE（ExternalInterface.call → shim.QQOutlets）：与 AlertWindow
 * 同决策族（见该处类头）。
 * PORT-NOTE（`getMaterial("ConfirmIcon") as Sprite`，:73）：as 失配-null
 * 语义走 isOfType 门 + 直取；原文**无 null 守卫**——素材缺失即 NPE
 * 与原版一致，逐字保留（单测经 support/MaterialFakes 假域注入命中）。
 * PORT-NOTE（confirmFn 调用无 null 守卫，:129）：confirmButtonClick 里
 * `this.confirmFn()` 直调——未赋 confirmFn 即点确定 NPE 与原版一致；
 * cancelButtonClick 的 `if(this.cancelFn != null)` 判空是原文写出的
 * 不对称，逐字保留。
 */
@:keep
class ConfirmWindow extends BaseWindow {
	// ConfirmWindow.as:18-32
	private var _cancelFn:Dynamic;
	private var cancelButton:LipiButton = new LipiButton();
	private var confirmButton:LipiButton;
	private var errorText:TextField;
	private var alertText:TextField;
	private var _confirmEnable:Bool = true;
	private var _confirmFn:Dynamic;

	// ConfirmWindow.as:34-54
	public function new(param1:Float = 360) {
		super();
		this.width = param1;
		height = 320;
		titleIMG = MaterialLib.getInstance().getClass("AlertWindowTitle");
		windowName = "ConfirmWindow";
		mode = true;
		this.alertText = new TextField();
		this.alertText.selectable = false;
		var _loc2_:TextFormat = new TextFormat("Verdana", 14, 8999699, null, null, null, null, null, TextFormatAlign.CENTER);
		_loc2_.leading = 8;
		this.alertText.defaultTextFormat = _loc2_;
		this.alertText.width = width - 60;
		this.alertText.x = (width - this.alertText.width) / 2;
		this.alertText.y = 170;
		this.alertText.wordWrap = true;
		this.alertText.multiline = true;
		this.alertText.autoSize = TextFieldAutoSize.CENTER;
		this.alertText.htmlText = "";
		addChild(this.alertText);
	}

	// ConfirmWindow.as:56/152
	public var cancelFn(get, set):Dynamic;

	private function set_cancelFn(param1:Dynamic):Dynamic {
		this._cancelFn = param1;
		return param1;
	}

	// ConfirmWindow.as:61/157
	public var confirmEnable(get, set):Bool;

	private function set_confirmEnable(param1:Bool):Bool {
		if (this.confirmButton != null) {
			this.confirmButton.enable = param1;
			this.confirmButton.mouseChildren = param1;
		}
		this._confirmEnable = param1;
		return param1;
	}

	// ConfirmWindow.as:71-123
	override public function init(param1:openfl.geom.Rectangle = null):Void {
		var _matIcon:Dynamic = MaterialLib.getInstance().getMaterial("ConfirmIcon");
		var _loc1_:Sprite = Std.isOfType(_matIcon, Sprite) ? cast(_matIcon, Sprite) : null;
		_loc1_.x = (width - _loc1_.width) / 2;
		_loc1_.y = 60;
		addChild(_loc1_);
		this.errorText = new TextField();
		this.errorText.autoSize = TextFieldAutoSize.LEFT;
		this.errorText.selectable = false;
		var _loc2_:TextFormat = new TextFormat("Verdana", 12, 10027008, null, null, null, null, null, TextFormatAlign.CENTER);
		_loc2_.leading = 8;
		this.errorText.defaultTextFormat = _loc2_;
		this.errorText.x = (width - this.errorText.width) / 2;
		this.errorText.y = this.alertText.y + 20;
		this.errorText.htmlText = "";
		this.errorText.wordWrap = true;
		this.errorText.multiline = true;
		this.errorText.autoSize = TextFieldAutoSize.CENTER;
		addChild(this.errorText);
		this.confirmButton = new LipiButton();
		this.confirmButton.bgAlpha = 0;
		this.confirmButton.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonOrange"));
		this.confirmButton.width = 64;
		this.confirmButton.height = 25;
		this.confirmButton.x = width / 2 - this.confirmButton.width - 10;
		this.confirmButton.y = height - 45;
		this.confirmButton.label = "确定";
		this.confirmButton.textColor = 16777215;
		this.confirmButton.addEventListener(MouseEvent.CLICK, this.confirmButtonClick);
		addChild(this.confirmButton);
		this.cancelButton.bgAlpha = 0;
		this.cancelButton.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonBlue"));
		this.cancelButton.width = 64;
		this.cancelButton.height = 25;
		this.cancelButton.x = width / 2 + 10;
		this.cancelButton.y = height - 45;
		this.cancelButton.label = "取消";
		this.cancelButton.textColor = 16777215;
		this.cancelButton.addEventListener(MouseEvent.CLICK, this.cancelButtonClick);
		addChild(this.cancelButton);
		this.setData();
	}

	// ConfirmWindow.as:66-70（width 覆写联动 alertText.width）
	override private function set_width(param1:Float):Float {
		super.set_width(param1);
		if (this.alertText != null) {
			this.alertText.width = param1 - 60;
		}
		return param1;
	}

	// ConfirmWindow.as:123-127（data 覆写：存后 setData）
	override private function set_data(param1:Dynamic):Dynamic {
		super.set_data(param1);
		this.setData();
		return param1;
	}

	// ConfirmWindow.as:129-135
	private function confirmButtonClick(param1:MouseEvent = null):Void {
		if (this.confirmButton.enable == true) {
			WControl.close(this);
			this.confirmFn();
		}
	}

	// ConfirmWindow.as:138/162
	public var confirmFn(get, set):Dynamic;

	private function set_confirmFn(param1:Dynamic):Dynamic {
		this._confirmFn = param1;
		return param1;
	}

	// ConfirmWindow.as:143-149
	public function cancelButtonClick(param1:MouseEvent):Void {
		WControl.close(this);
		if (this.cancelFn != null) {
			this.cancelFn();
		}
	}

	private function get_cancelFn():Dynamic {
		return this._cancelFn;
	}

	private function get_confirmEnable():Bool {
		return this._confirmEnable;
	}

	private function get_confirmFn():Dynamic {
		return this._confirmFn;
	}

	// ConfirmWindow.as:170-203
	private function setData():Void {
		if (this.confirmButton != null && this.alertText != null && data != null) {
			if (As3.hasProp(data, "text")) {
				this.alertText.htmlText = Reflect.field(data, "text");
				height = this.alertText.height + this.alertText.y + 70;
				this.cancelButton.y = height - 45;
				this.confirmButton.y = height - 45;
				if (Reflect.field(data, "url") != null && Reflect.field(data, "url") != "") {
					this.alertText.addEventListener(TextEvent.LINK, this.onLinkClicked, false, 0, true);
				}
			}
			if (As3.hasProp(data, "error")) {
				this.errorText.text = Reflect.field(data, "error");
				this.errorText.x = (width - this.errorText.width) / 2;
				height = this.errorText.height + this.errorText.y + 70;
				this.cancelButton.y = height - 45;
				this.confirmButton.y = height - 45;
			}
		}
		if (this.confirmButton != null) {
			this.confirmButton.enable = this.confirmEnable;
		}
	}

	// ConfirmWindow.as:205-211
	private function onLinkClicked(param1:TextEvent):Void {
		if (Reflect.field(data, "url") != null && Reflect.field(data, "url") != "") {
			QQOutlets.call("window.open", Reflect.field(data, "url"));
		}
	}

	// ConfirmWindow.as:213-216
	override public function keyEnter():Void {
		this.confirmButtonClick();
	}
}
