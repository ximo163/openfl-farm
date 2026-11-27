package mc.view.common;

import com.minutes.ui.control.LipiButton;
import com.minutes.ui.core.LipiSkin;
import common.MaterialLib;
import mc.control.ViewControl;
import mc.events.WindowEvent;
import mc.view.main.cursor.Cursor;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.net.URLRequest;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import shim.As3;
import shim.NavigateToURL;

/**
 * mc.view.common.InfoWindow —— InfoWindow.as 逐句对应（issue #87 牧场
 * 「通用视图」片；#19 签名面 stub 充真身）。信息窗：data.text 进来后
 * 排文本与确定钮（_loc2_.y=height-50），悬停切系统光标（ROLL_OVER/
 * ROLL_OUT → Cursor.useSystem）。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/common/InfoWindow.as。
 *
 * PORT-NOTE（flash.net.navigateToURL → shim.NavigateToURL）：openfl 对
 * navigateToURL 支持不完整，CLAUDE.md 指定等价物进 shim——目标相关
 * 封装（html5 window.open、非浏览器目标留痕不抛），调用点保持原形态。
 * PORT-NOTE（`data["target"]` 串键下标）：Reflect.field 通道（lessons
 * #8/#37）；hasOwnProperty 走 As3.hasProp。
 * PORT-NOTE（confirmButtonClick 的 data 无 null 守卫，:97-101）：
 * `data.hasOwnProperty("gotourl")` 在 data 为 null 时 NPE 与原版一致
 * （确定钮仅在 data 已置的语境可用）。
 */
@:keep
class InfoWindow extends BaseWindow {
	// InfoWindow.as:20-24
	private var errorIcon:Sprite;
	private var alertText:TextField;
	private var successIcon:Sprite;

	// InfoWindow.as:26-34
	public function new() {
		super();
		titleIMG = MaterialLib.getInstance().getClass("AlertWindowTitle");
		width = 300;
		height = 240;
		windowName = "InfoWindow";
		mode = true;
	}

	// InfoWindow.as:36-39
	override public function keyEnter():Void {
		this.confirmButtonClick();
	}

	// InfoWindow.as:41-50（`Boolean(this.alertText)` 对象真值——非 null
	// 即真，alertText != null 等价）
	private function setData():Void {
		if (data != null && this.alertText != null) {
			if (As3.hasProp(data, "text")) {
				this.alertText.htmlText = Reflect.field(data, "text");
			}
		}
	}

	// InfoWindow.as:52-82
	override public function init(param1:openfl.geom.Rectangle = null):Void {
		this.alertText = new TextField();
		this.alertText.selectable = false;
		var _loc1_:TextFormat = new TextFormat("Verdana", 14, 8999699, null, null, null, null, null, TextFormatAlign.LEFT);
		_loc1_.leading = 8;
		this.alertText.defaultTextFormat = _loc1_;
		this.alertText.width = width - 40;
		this.alertText.height = height - 110;
		this.alertText.border = false;
		this.alertText.x = (width - this.alertText.width) / 2;
		this.alertText.y = 50;
		this.alertText.wordWrap = true;
		this.alertText.multiline = true;
		this.alertText.htmlText = "";
		addChild(this.alertText);
		var _loc2_:LipiButton = new LipiButton();
		_loc2_.bgAlpha = 0;
		_loc2_.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonOrange"));
		_loc2_.width = 65;
		_loc2_.height = 25;
		_loc2_.x = (width - _loc2_.width) / 2;
		_loc2_.y = height - 50;
		_loc2_.label = "确定";
		_loc2_.textColor = 16777215;
		_loc2_.addEventListener(MouseEvent.CLICK, this.confirmButtonClick);
		addChild(_loc2_);
		this.addEventListener(MouseEvent.ROLL_OVER, this.onRollOver);
		this.addEventListener(MouseEvent.ROLL_OUT, this.onRollOut);
		this.setData();
	}

	// InfoWindow.as:84-87
	private function onRollOut(param1:MouseEvent):Void {
		Cursor.useSystem(false);
	}

	// InfoWindow.as:89-93
	override private function set_data(param1:Dynamic):Dynamic {
		super.set_data(param1);
		this.setData();
		return param1;
	}

	// InfoWindow.as:95-104
	private function confirmButtonClick(param1:MouseEvent = null):Void {
		var _loc2_:WindowEvent = new WindowEvent(WindowEvent.CLOSE);
		_loc2_.window = this;
		ViewControl.getInstance().dispatchEvent(_loc2_);
		if (As3.hasProp(data, "gotourl")) {
			NavigateToURL.navigateToURL(new URLRequest(Reflect.field(data, "gotourl")), Reflect.field(data, "target"));
		}
	}

	// InfoWindow.as:106-109
	private function onRollOver(param1:MouseEvent):Void {
		Cursor.useSystem();
	}
}
