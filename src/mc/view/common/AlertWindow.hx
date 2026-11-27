package mc.view.common;

import com.minutes.ui.control.LipiButton;
import com.minutes.ui.core.LipiSkin;
import com.qzone.corelib.js.JSProxy;
import common.MaterialLib;
import mc.api.BeastAPI;
import mc.control.ViewControl;
import mc.events.WindowEvent;
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
 * mc.view.common.AlertWindow —— AlertWindow.as 逐句对应（issue #87 牧场
 * 「通用视图」片；#19 签名面 stub 充真身）。提示窗：type 四分
 * （success/error/tip/缺省）定图标显隐与文本 y（170/170/60/130），
 * data.text 进来后 height=alertText.height+alertText.y+70、确定钮
 * y=height-50。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/common/AlertWindow.as。
 *
 * PORT-NOTE（ExternalInterface.call("window.open",…) → shim.QQOutlets）：
 * 独立部署无宿主 JS 的统一决策族（deviations no-qzone-jsapi 候选口径，
 * main3 侧 common.view.window.AlertWindow 同款先例）——调用点保持原
 * 形态指向 QQOutlets.call，一律不发、取值 null。
 * PORT-NOTE（`getMaterial(...) as Sprite`，:84-85）：as 失配-null 语义
 * 走 isOfType 门 + 直取（lessons #7：eval 裸 cast 无运行时检查）。原文
 * **无 null 守卫**——素材缺失直取 .x/.y NPE 与原版一致，逐字保留。
 * PORT-NOTE（data 键访问）：data 是 Object/Dynamic，`data["type"]` 串键
 * 下标在 cpp 是编译错误、eval 对匿名结构可用但不同目标不一——统一
 * Reflect.field 取（lessons #8/#37 通道）；hasOwnProperty 走 As3.hasProp。
 */
@:keep
class AlertWindow extends BaseWindow {
	// AlertWindow.as:22-32
	private var errorIcon:Sprite;
	public var confirmFun:Dynamic = null;
	private var alertText:TextField;
	public var flag:Bool = false;
	private var confirmButton:LipiButton = new LipiButton();
	private var successIcon:Sprite;

	// AlertWindow.as:34-42
	public function new(param1:Float = 320) {
		super();
		titleIMG = MaterialLib.getInstance().getClass("AlertWindowTitle");
		width = param1;
		height = 280;
		windowName = "AlertWindow";
		mode = true;
	}

	// AlertWindow.as:44-47
	override public function keyEnter():Void {
		this.confirmButtonClick();
	}

	// AlertWindow.as:49-56（flag 时关窗等同点确定）
	override private function closeHandler():Void {
		super.closeHandler();
		if (this.flag) {
			this.confirmButtonClick();
		}
	}

	// AlertWindow.as:58-64
	private function onLinkClicked2(param1:TextEvent):Void {
		if (As3.truthy(Reflect.field(data, "textLinkHandle"))) {
			QQOutlets.call("window.open", param1.text);
		}
	}

	// AlertWindow.as:66-80
	private function onLinkClicked(param1:TextEvent):Void {
		if (Reflect.field(data, "url") != null && Reflect.field(data, "url") != "") {
			QQOutlets.call("window.open", Reflect.field(data, "url"));
		}
		if (param1.text == "gotoWild") {
			BeastAPI.getInstance().showWildStage();
		}
		if (param1.text == "wildInfo") {
			JSProxy.openWindow("http://blog.qq.com/qzone/1006666002/1293072967.htm");
		}
	}

	// AlertWindow.as:82-116
	override public function init(param1:openfl.geom.Rectangle = null):Void {
		this.successIcon = castAsSprite(MaterialLib.getInstance().getMaterial("SuccessIcon"));
		this.errorIcon = castAsSprite(MaterialLib.getInstance().getMaterial("ErrorIcon"));
		this.successIcon.x = (width - this.successIcon.width) / 2;
		this.errorIcon.x = this.successIcon.x;
		this.successIcon.y = 60;
		this.errorIcon.y = this.successIcon.y;
		addChild(this.successIcon);
		addChild(this.errorIcon);
		this.alertText = new TextField();
		this.alertText.selectable = false;
		var _loc1_:TextFormat = new TextFormat("Verdana", 14, 8999699, null, null, null, null, null, TextFormatAlign.CENTER);
		_loc1_.leading = 8;
		this.alertText.defaultTextFormat = _loc1_;
		this.alertText.width = width - 60;
		this.alertText.multiline = true;
		this.alertText.wordWrap = true;
		this.alertText.autoSize = TextFieldAutoSize.CENTER;
		this.alertText.x = (width - this.alertText.width) / 2;
		this.alertText.y = 170;
		this.alertText.wordWrap = true;
		this.alertText.multiline = true;
		this.alertText.htmlText = "";
		addChild(this.alertText);
		this.confirmButton.bgAlpha = 0;
		this.confirmButton.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonOrange"));
		this.confirmButton.width = 65;
		this.confirmButton.height = 25;
		this.confirmButton.x = (width - this.confirmButton.width) / 2;
		this.confirmButton.y = height - 50;
		this.confirmButton.label = "确定";
		this.confirmButton.textColor = 16777215;
		this.confirmButton.addEventListener(MouseEvent.CLICK, this.confirmButtonClick);
		addChild(this.confirmButton);
		this.setData();
	}

	// AlertWindow.as:118-122
	override private function set_data(param1:Dynamic):Dynamic {
		super.set_data(param1);
		this.setData();
		return param1;
	}

	// AlertWindow.as:124-137
	private function confirmButtonClick(param1:MouseEvent = null):Void {
		var _loc2_:WindowEvent = new WindowEvent(WindowEvent.CLOSE);
		_loc2_.window = this;
		ViewControl.getInstance().dispatchEvent(_loc2_);
		if (As3.hasProp(data, "gotourl")) {
			QQOutlets.call("window.open", Reflect.field(data, "gotourl"));
		}
		if (this.confirmFun != null) {
			this.confirmFun();
		}
	}

	// AlertWindow.as:139-229（type 四分 + 文本驱动的窗口高度重算）
	private function setData():Void {
		if (this.successIcon != null && this.errorIcon != null && data != null) {
			if (As3.hasProp(data, "type") && Reflect.field(data, "type") == "success") {
				this.successIcon.visible = true;
				this.errorIcon.visible = false;
				this.alertText.y = 170;
			} else if (As3.hasProp(data, "type") && Reflect.field(data, "type") == "error") {
				this.successIcon.visible = false;
				this.errorIcon.visible = true;
				this.alertText.y = 170;
			} else if (As3.hasProp(data, "type") && Reflect.field(data, "type") == "tip") {
				this.successIcon.visible = false;
				this.errorIcon.visible = false;
				this.alertText.y = 60;
			} else {
				this.successIcon.visible = false;
				this.errorIcon.visible = false;
				this.alertText.y = 130;
			}
			if (As3.hasProp(data, "text")) {
				this.alertText.htmlText = Reflect.field(data, "text");
				this.height = this.alertText.height + this.alertText.y + 70;
				this.confirmButton.y = height - 50;
				this.alertText.addEventListener(TextEvent.LINK, this.onLinkClicked, false, 0, true);
				if (As3.truthy(Reflect.field(data, "textLinkHandle"))) {
					this.alertText.addEventListener(TextEvent.LINK, this.onLinkClicked2, false, 0, true);
				}
			}
		}
	}

	// `x as Sprite`（isOfType ? cast : null，本文件两处素材通道共用）
	private static function castAsSprite(param1:Dynamic):Sprite {
		return Std.isOfType(param1, Sprite) ? cast(param1, Sprite) : null;
	}
}
