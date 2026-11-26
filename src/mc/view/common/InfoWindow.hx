package mc.view.common;

import openfl.display.Sprite;
import openfl.errors.Error;
import openfl.events.MouseEvent;
import openfl.text.TextField;

/**
 * mc.view.common.InfoWindow —— InfoWindow.as 的签名面 stub（原类 110 loc，
 * issue #87「通用视图」片充真身）。信息窗：data.text 进来后排文本与确定
 * 钮（y=height-85）。成员签名逐字取自反编译原文，方法体随 implement
 * 充真身。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/common/InfoWindow.as。
 */
@:keep
class InfoWindow extends BaseWindow {
	// InfoWindow.as:20-24
	private var errorIcon:Sprite;
	private var alertText:TextField;
	private var successIcon:Sprite;

	// InfoWindow.as:26-34（ctor 原文即完整：300 宽/240 高/"InfoWindow"/
	// mode=true——AlertWindow.hx 同款入 stub）
	public function new() {
		super();
		this.titleIMG = common.MaterialLib.getInstance().getClass("AlertWindowTitle");
		this.width = 300;
		this.height = 240;
		this.windowName = "InfoWindow";
		this.mode = true;
	}

	// InfoWindow.as:36-39
	override public function keyEnter():Void {
		throw new Error("not implemented");
	}

	// InfoWindow.as:41-50
	private function setData():Void {
		throw new Error("not implemented");
	}

	// InfoWindow.as:52-82
	override public function init(param1:openfl.geom.Rectangle = null):Void {
		throw new Error("not implemented");
	}

	// InfoWindow.as:84-87
	private function onRollOut(param1:MouseEvent):Void {
		throw new Error("not implemented");
	}

	// InfoWindow.as:89-93
	override private function set_data(param1:Dynamic):Dynamic {
		throw new Error("not implemented");
	}

	// InfoWindow.as:95-104
	private function confirmButtonClick(param1:MouseEvent = null):Void {
		throw new Error("not implemented");
	}

	// InfoWindow.as:106-109
	private function onRollOver(param1:MouseEvent):Void {
		throw new Error("not implemented");
	}
}
