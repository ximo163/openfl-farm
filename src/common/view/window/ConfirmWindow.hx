package common.view.window;

import com.qzone.qui.controls.Button;
import com.qzone.utils.AlignUtil;
import common.Consts;
import common.misc.Utils;
import interfaces.IMsgCenter;
import openfl.display.Sprite;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import shim.As3;

/**
 * common.view.window.ConfirmWindow —— ConfirmWindow.as 逐句对应（issue #41
 * 替换 #7/#21 的闭包 stub）。确定/取消双钮确认框：setData 从 data 提取
 * error/text/confirmFn/title/width/height/confirmEnable/hideIcon 并摆图标
 * （hideIcon 摘图标、高度 110/80），确认钮走 confirmButtonClick（enabled 门
 * → 关窗 → _confirmFn → 用后即清）。
 */
@:keep
class ConfirmWindow extends BaseWindow {
	// ConfirmWindow.as:19（protected → Haxe private，子类可见）
	private var _confirmButton:Button;

	// ConfirmWindow.as:21
	private var _confirmIcon:Sprite;

	// ConfirmWindow.as:23
	private var _confirmEnable:Bool;

	// ConfirmWindow.as:25（字段默认值建实例，RedUpWindow 等子类沿用）
	private var _errorText:TextField = new TextField();

	// ConfirmWindow.as:27（Function → Dynamic）
	private var _confirmFn:Dynamic;

	// ConfirmWindow.as:29
	private var _alertText:TextField = new TextField();

	// ConfirmWindow.as:31
	private var _cancelButton:Button;

	// ConfirmWindow.as:33
	private var _hideIcon:Bool;

	// ConfirmWindow.as:35-46
	public function new(param1:IMsgCenter) {
		super(param1);
		width = 320;
		height = 240;
		title = "确定";
		windowName = Consts.WINDOW_NAME_CONFIRM;
		mode = true;
		this._hideIcon = false;
		this._confirmEnable = true;
		this._confirmFn = null;
	}

	// ConfirmWindow.as:48-91
	override private function setSize():Void {
		super.setSize();
		if (this._errorText != null) {
			this._errorText.x = (width - this._errorText.width) / 2;
			this._errorText.y = height - 70;
		}
		if (this._alertText != null) {
			this._alertText.x = (width - this._alertText.width) / 2;
			if (this._hideIcon == true) {
				this._alertText.y = 60;
			} else if (this._confirmIcon != null) {
				this._alertText.y = this._confirmIcon.y + this._confirmIcon.height + 50;
			} else {
				this._alertText.y = 120;
			}
		}
		if (this._confirmButton != null) {
			this._confirmButton.x = width / 2 - this._confirmButton.width - 10;
			this._confirmButton.y = height - 45;
		}
		if (this._cancelButton != null) {
			this._cancelButton.x = width / 2 + 10;
			this._cancelButton.y = height - 45;
		}
		if (this._confirmIcon != null && this._hideIcon == false) {
			this._confirmIcon.x = (width - this._confirmIcon.width) / 2;
			this._confirmIcon.y = 40;
		}
		if (panelTitle != null) {
			panelTitle.x = AlignUtil.middle(width, panelTitle.width);
		}
	}

	// ConfirmWindow.as:93-103（AS3 setter 无返回值，Haxe 属性 setter 返回入参）
	private function set_confirmEnable(param1:Bool):Bool {
		if (this._confirmButton != null) {
			this._confirmButton.enabled = param1;
			this._confirmButton.mouseEnabled = param1;
			this._confirmButton.mouseChildren = param1;
			this._confirmButton.useHandCursor = param1;
		}
		this._confirmEnable = param1;
		return param1;
	}

	// ConfirmWindow.as:105-144
	override private function init():Void {
		this._alertText = new TextField();
		this._alertText.selectable = false;
		var _loc1_:TextFormat = new TextFormat("Verdana", 14, 3355443, null, null, null, null, null,
			TextFormatAlign.CENTER);
		_loc1_.leading = 8;
		this._alertText.defaultTextFormat = _loc1_;
		this._alertText.width = width - 10;
		this._alertText.height = 80;
		this._alertText.wordWrap = true;
		this._alertText.multiline = true;
		addChild(this._alertText);
		this._errorText = new TextField();
		this._errorText.autoSize = TextFieldAutoSize.LEFT;
		this._errorText.selectable = false;
		var _loc2_:TextFormat = new TextFormat("Verdana", 12, 10027008, null, null, null, null, null,
			TextFormatAlign.CENTER);
		_loc2_.leading = 8;
		this._errorText.defaultTextFormat = _loc2_;
		this._errorText.height = this._errorText.textHeight + 10;
		this._errorText.htmlText = "";
		addChild(this._errorText);
		this._confirmButton = new Button();
		this._confirmButton.defaultSkin = Utils.getClass("ButtonOrange");
		this._confirmButton.width = 64;
		this._confirmButton.height = 25;
		this._confirmButton.x = width / 2 - this._confirmButton.width - 10;
		this._confirmButton.y = height - 45;
		this._confirmButton.text = "确定";
		this._confirmButton.addEventListener(MouseEvent.CLICK, this.confirmButtonClick);
		addChild(this._confirmButton);
		this._cancelButton = new Button();
		this._cancelButton.defaultSkin = Utils.getClass("ButtonBlue");
		this._cancelButton.width = 64;
		this._cancelButton.height = 25;
		this._cancelButton.x = width / 2 + 10;
		this._cancelButton.y = height - 45;
		this._cancelButton.text = "取消";
		this._cancelButton.addEventListener(MouseEvent.CLICK, this.cancelButtonClick);
		addChild(this._cancelButton);
	}

	// ConfirmWindow.as:146-157
	private function confirmButtonClick(param1:MouseEvent = null):Void {
		if (this._confirmButton.enabled == true) {
			super.close();
			if (this._confirmFn != null) {
				this._confirmFn();
			}
			this._confirmFn = null;
		}
	}

	// ConfirmWindow.as:159-162
	private function set_confirmFn(param1:Dynamic):Dynamic {
		this._confirmFn = param1;
		return param1;
	}

	// ConfirmWindow.as:164-167
	private function cancelButtonClick(param1:MouseEvent):Void {
		super.close();
	}

	// ConfirmWindow.as:169-182
	private function customizeIcon():Void {
		var _loc1_:Sprite = null;
		if (As3.hasProp(data, "customIcon")) {
			_loc1_ = Std.isOfType(Utils.getMaterial(Reflect.field(data, "customIcon")),
				Sprite) ? cast(Utils.getMaterial(Reflect.field(data, "customIcon")), Sprite) : null;
		}
		if (_loc1_ == null) {
			_loc1_ = Std.isOfType(Utils.getMaterial("ConfirmIcon"), Sprite) ? cast(Utils.getMaterial("ConfirmIcon"),
				Sprite) : null;
		}
		this._confirmIcon = _loc1_;
		addChild(this._confirmIcon);
	}

	// ConfirmWindow.as:184-202
	private function adjustIcon():Void {
		if (this._hideIcon == true) {
			if (this._confirmIcon != null && this.contains(this._confirmIcon) == true) {
				removeChild(this._confirmIcon);
			}
			this._alertText.height = 110;
		} else {
			if (this._confirmIcon != null && this.contains(this._confirmIcon) == false) {
				addChild(this._confirmIcon);
			}
			this._alertText.height = 80;
		}
	}

	// ConfirmWindow.as:204-206
	private function get_confirmFn():Dynamic {
		return this._confirmFn;
	}

	// ConfirmWindow.as:209-211
	private function get_confirmEnable():Bool {
		return this._confirmEnable;
	}

	// ConfirmWindow.as:214-217
	override public function keyEnter(param1:KeyboardEvent):Void {
		this.confirmButtonClick();
	}

	// ConfirmWindow.as:219-296
	override private function setData():Void {
		if (data != null) {
			this.graphics.clear();
			this._errorText.text = "";
			if (this._errorText != null && As3.hasProp(data, "error")) {
				this._errorText.text = As3.or(Reflect.field(data, "error"), "");
			}
			if (this._alertText != null && As3.hasProp(data, "text")) {
				this._alertText.htmlText = As3.or(Reflect.field(data, "text"), "");
				this._alertText.height = this._alertText.textHeight + 10;
			}
			if (this._errorText != null && this._alertText != null) {
				this.height = this._errorText.textHeight + this._alertText.height + this._alertText.y + 20 + 45;
			}
			if (As3.hasProp(data, "confirmFn")) {
				this._confirmFn = Reflect.field(data, "confirmFn");
			} else {
				this._confirmFn = null;
			}
			if (As3.hasProp(data, "title")) {
				this.title = Std.isOfType(Reflect.field(data, "title"),
					String) ? cast(Reflect.field(data, "title"), String) : null;
			} else {
				this.title = "确定";
			}
			if (As3.hasProp(data, "width")) {
				this.width = As3.intOf(Reflect.field(data, "width"));
				this._alertText.width = this.width - 20;
			} else {
				this.width = 320;
				this._alertText.width = this.width - 20;
			}
			if (As3.hasProp(data, "height")) {
				this.height = As3.intOf(Reflect.field(data, "height"));
			} else {
				this.height = 240;
			}
			if (As3.hasProp(data, "confirmEnable")) {
				this.confirmEnable = As3.truthy(Reflect.field(data, "confirmEnable"));
			} else {
				this.confirmEnable = true;
			}
			if (As3.hasProp(data, "hideIcon")) {
				this._hideIcon = As3.truthy(Reflect.field(data, "hideIcon"));
				this.adjustIcon();
			} else {
				this._hideIcon = false;
				this.customizeIcon();
				this.adjustIcon();
			}
		}
		if (this._confirmButton != null) {
			this._confirmButton.enabled = this.confirmEnable;
		}
	}

	public var confirmEnable(get, set):Bool;
	public var confirmFn(get, set):Dynamic;
}
