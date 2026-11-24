package common.view.window;

import com.qzone.corelib.controls.ExtLoader;
import com.qzone.qui.controls.Button;
import com.qzone.qui.core.Align;
import com.qzone.utils.AlignUtil;
import common.Consts;
import common.misc.Utils;
import framework.api.beast.BeastAPI;
import interfaces.IMsgCenter;
import openfl.display.Sprite;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.TextEvent;
import openfl.net.URLRequest;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import shim.As3;
import shim.NavigateToURL;
import shim.QQOutlets;

/**
 * common.view.window.AlertWindow —— AlertWindow.as 逐句对应（issue #41
 * 替换 #7 的闭包 stub）。单按钮提示窗：setData 按 type 五分支摆 icon/
 * picLoader/_alertText.y，文本/标题/两个回调句柄从 data 提取，确认钮
 * 居中点亮；点钮或 keyEnter 走 confirmButtonClick（关窗 + gotourl + 句柄）。
 *
 * ExternalInterface.call("window.open",…) → shim.QQOutlets（deviations
 * qqoutlets-shim：独立页面无 QZone 宿主 JS，available=false 常量、
 * 调用点保持原形态自然落到不可用分支）。
 */
@:keep
class AlertWindow extends BaseWindow {
	// AlertWindow.as:25
	private var _alertText:TextField;

	// AlertWindow.as:27（Function → Dynamic）
	private var _textLinkHandle:Dynamic;

	// AlertWindow.as:29
	private var _confirmButton:Button;

	// AlertWindow.as:31
	private var _icon:Sprite;

	// AlertWindow.as:33（Function → Dynamic）
	private var _confirmButtonClickHandle:Dynamic;

	// AlertWindow.as:35
	private var _picLoader:ExtLoader;

	// AlertWindow.as:37-48
	public function new(param1:IMsgCenter) {
		super(param1);
		width = 320;
		height = 240;
		title = "提示";
		windowName = Consts.WINDOW_NAME_ALERT;
		mode = true;
		this._alertText = null;
		this._confirmButton = null;
		this._icon = null;
	}

	// AlertWindow.as:50-53（AS3 setter 无返回值，Haxe 属性 setter 返回入参）
	private function set_textLinkHandle(param1:Dynamic):Dynamic {
		this._textLinkHandle = param1;
		return param1;
	}

	public var textLinkHandle(never, set):Dynamic;

	// AlertWindow.as:55-204
	override private function setData():Void {
		var _loc1_:TextFormat = null;
		if (data == null) {
			return;
		}
		this.graphics.clear();
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
		if (As3.hasProp(data, "textAlign")) {
			_loc1_ = new TextFormat("Verdana", 14, 3355443, null, null, null, null, null);
			_loc1_.leading = 6;
			_loc1_.align = Reflect.field(data, "textAlign");
			this._alertText.defaultTextFormat = _loc1_;
		}
		this.createIcon();
		this.createPic();
		if (Reflect.field(data, "type") == Consts.ALERT_TYPE_SUCCESS || Reflect.field(data,
			"type") == Consts.ALERT_TYPE_ERROR || Reflect.field(data, "type") == Consts.ALERT_TYPE_TIP) {
			if (this._icon != null) {
				this._icon.visible = true;
			}
			this._alertText.y = 110;
			if (this._picLoader != null) {
				this._picLoader.visible = false;
			}
		} else if (Reflect.field(data, "type") == Consts.ALERT_TYPE_TEXT) {
			if (this._icon != null) {
				this._icon.visible = false;
			}
			this._alertText.y = 35;
			if (this._picLoader != null) {
				this._picLoader.visible = false;
			}
		} else if (Reflect.field(data, "type") == Consts.ALERT_TYPE_PIC) {
			if (this._icon != null) {
				this._icon.visible = false;
			}
			this._alertText.y = 113;
			if (this._picLoader != null) {
				this._picLoader.visible = true;
			}
		} else if (Reflect.field(data, "type") == Consts.ALERT_TYPE_PIC2) {
			if (this._icon != null) {
				this._icon.visible = false;
			}
			this._alertText.y = 140;
			if (this._picLoader != null) {
				this._picLoader.visible = true;
			}
		} else {
			if (this._icon != null) {
				this._icon.visible = false;
			}
			this._alertText.y = 110;
			if (this._picLoader != null) {
				this._picLoader.visible = false;
			}
		}
		if (As3.hasProp(data, "text")) {
			this._alertText.htmlText = Reflect.field(data, "text");
			this._alertText.width = width - 40;
			this._alertText.height = this._alertText.textHeight + 10;
			if (Reflect.field(data, "height") == null) {
				this.height = this._alertText.height + this._alertText.y + 60;
			}
			this._alertText.x = (width - this._alertText.width) / 2;
		}
		if (As3.hasProp(data, "title")) {
			title = Reflect.field(data, "title");
		} else {
			title = "提示";
		}
		if (As3.hasProp(data, "textLinkHandle")) {
			this._textLinkHandle = Reflect.isFunction(Reflect.field(data,
				"textLinkHandle")) ? Reflect.field(data, "textLinkHandle") : null;
		} else {
			this._textLinkHandle = null;
		}
		if (As3.hasProp(data, "confirmButtonClickHandle")) {
			this._confirmButtonClickHandle = Reflect.isFunction(Reflect.field(data,
				"confirmButtonClickHandle")) ? Reflect.field(data, "confirmButtonClickHandle") : null;
		} else {
			this._confirmButtonClickHandle = null;
		}
		if (As3.hasProp(data, "textSelectable")) {
			this._alertText.selectable = As3.truthy(Reflect.field(data, "textSelectable"));
		} else {
			this._alertText.selectable = false;
		}
		if (As3.hasProp(data, "buttonText")) {
			this._confirmButton.text = Reflect.field(data, "buttonText");
		}
		this._confirmButton.x = (this.width - this._confirmButton.width) / 2;
		this._confirmButton.y = this.height - this._confirmButton.height - 15;
		this._confirmButton.visible = true;
		if (titleAlign == Align.CENTER) {
			panelTitle.x = AlignUtil.middle(_width, panelTitle.width);
		}
	}

	// AlertWindow.as:206-227
	private function alertTextLink(param1:TextEvent):Void {
		if (this._textLinkHandle != null) {
			this._textLinkHandle(param1);
		}
		if (param1.text == "gotoWild") {
			BeastAPI.getInstance().showWildStage();
		} else if (param1.text == "wildInfo") {
			if (QQOutlets.available) {
				QQOutlets.call("window.open", "http://blog.qq.com/qzone/1006666002/1293072967.htm");
			}
		} else if (QQOutlets.available) {
			QQOutlets.call("window.open", param1.text);
		}
	}

	// AlertWindow.as:229-254。`getMaterial(...) as Sprite` → isOfType 检查
	private function createIcon():Void {
		if (data == null) {
			return;
		}
		if (Reflect.field(data, "type") == Consts.ALERT_TYPE_SUCCESS) {
			this._icon = as3Sprite(Utils.getMaterial("SuccessIcon"));
		} else if (Reflect.field(data, "type") == Consts.ALERT_TYPE_ERROR) {
			this._icon = as3Sprite(Utils.getMaterial("ErrorIcon"));
		} else {
			if (Reflect.field(data, "type") != Consts.ALERT_TYPE_TIP) {
				return;
			}
			this._icon = as3Sprite(Utils.getMaterial("TipIcon"));
		}
		this._icon.x = AlignUtil.middle(width, this._icon.width);
		this._icon.y = 40;
		addChild(this._icon);
	}

	// `x as Sprite`（isOfType ? cast : null 的局部缩写，仅本文件用）
	private static function as3Sprite(param1:Dynamic):Sprite {
		return Std.isOfType(param1, Sprite) ? cast(param1, Sprite) : null;
	}

	// AlertWindow.as:256-267
	private function confirmButtonClick(param1:MouseEvent = null):Void {
		super.close();
		if (As3.hasProp(data, "gotourl") && Reflect.field(data, "gotourl") != "") {
			NavigateToURL.navigateToURL(new URLRequest(Reflect.field(data, "gotourl")), "_blank");
		}
		if (Reflect.field(data, "confirmButtonClickHandle") != null) {
			this._confirmButtonClickHandle();
		}
	}

	// AlertWindow.as:269-289
	override private function init():Void {
		this._alertText = new TextField();
		this._alertText.selectable = false;
		var _loc1_:TextFormat = new TextFormat("Verdana", 14, 3355443, null, null, null, null, null,
			TextFormatAlign.CENTER);
		_loc1_.leading = 8;
		this._alertText.defaultTextFormat = _loc1_;
		this._alertText.wordWrap = true;
		this._alertText.multiline = true;
		this._alertText.mouseWheelEnabled = false;
		this._alertText.addEventListener(TextEvent.LINK, this.alertTextLink, false, 0, true);
		addChild(this._alertText);
		this._confirmButton = new Button();
		this._confirmButton.defaultSkin = Utils.getClass("ButtonOrange");
		this._confirmButton.width = 65;
		this._confirmButton.height = 25;
		this._confirmButton.text = "确定";
		this._confirmButton.visible = false;
		this._confirmButton.addEventListener(MouseEvent.CLICK, this.confirmButtonClick);
		addChild(this._confirmButton);
	}

	// AlertWindow.as:291-294
	override public function keyEnter(param1:KeyboardEvent):Void {
		this.confirmButtonClick(null);
	}

	// AlertWindow.as:296-314
	private function createPic():Void {
		if (Reflect.field(data, "type") != Consts.ALERT_TYPE_PIC && Reflect.field(data, "type") != Consts.ALERT_TYPE_PIC2) {
			return;
		}
		this._picLoader = new ExtLoader();
		if (Reflect.field(data, "type") != Consts.ALERT_TYPE_PIC2) {
			this._picLoader.x = AlignUtil.middle(width, 346);
		} else {
			this._picLoader.x = AlignUtil.middle(width, 80);
		}
		this._picLoader.y = 35;
		this._picLoader.load(Reflect.field(data, "picUrl"));
		addChild(this._picLoader);
	}

	// AlertWindow.as:316-323
	override private function close():Void {
		super.close();
		if (Reflect.field(data, "confirmButtonClickHandle") != null) {
			this._confirmButtonClickHandle();
		}
	}
}
