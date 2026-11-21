package com.qzone.qui.containers;

import com.qzone.qui.makers.ButtonMaker;
import com.qzone.qui.managers.EffectManager;
import com.qzone.qui.skins.PanelDefaultSkin;
import com.qzone.utils.GraphicsUtil;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;

/**
 * com.qzone.qui.containers.TitleWindow —— TitleWindow.as 逐句对应（issue #18
 * qui 收尾：容器片整类翻译，替换 #8 的闭包 stub）。标题窗：Panel + 头部热区
 * （22px 高透明矩形，尺寸随 setSize 重画）+ 右上关闭按钮。close() 派发
 * Event.CLOSE 并短路调用 closeFn（PreviewDiyWindow/LeftSideToolBar 依赖）。
 * PORT-NOTE: `this.closeButton["toolTip"] = "关闭"`——Sprite 上无 toolTip
 * 属性，按名写走 Reflect.setProperty（js 裸 Dynamic 写只落影子字段），
 * ToolTipLayer 同名读取对得上。
 */
@:keep
class TitleWindow extends Panel {
	// TitleWindow.as:16
	public var closeFn:Dynamic;

	// :18
	public var closeButtonSkin:Class<Dynamic>;

	// :20
	private var closeButton:Sprite;

	// :22
	private var _headArea:Sprite;

	// :24
	private var _showCloseButton:Bool;

	// :26
	public var effect:Dynamic;

	// :28-34
	public function new(param1:String = "Window", param2:Int = 300, param3:Int = 200, param4:Dynamic = null) {
		super(param1, param2, param3);
		this.closeFn = param4;
		this.closeButtonSkin = PanelDefaultSkin.closeButtonSkin;
		this.effect = EffectManager.popUpEffect;
	}

	// :36-48
	private override function setSize():Void {
		super.setSize();
		if (this._headArea != null) {
			GraphicsUtil.draw(this._headArea, 0, 0, new Rectangle(0, 0, this._width, 22), true);
		}
		if (this.closeButton != null) {
			this.closeButton.x = this._width - this.closeButton.width - 3;
			this.closeButton.y = 2;
		}
	}

	// :50-53 + :89-96（AS3 public get/set showCloseButton 对）
	public var showCloseButton(get, set):Bool;

	private function get_showCloseButton():Bool {
		return this._showCloseButton;
	}

	// :55-73
	private override function setSkin():Void {
		super.setSkin();
		if (this._headArea == null) {
			this._headArea = new Sprite();
			this.addChild(this._headArea);
		}
		if (this.closeButton == null) {
			this.closeButton = cast Type.createInstance(this.closeButtonSkin, []);
			ButtonMaker.addTarget(this.closeButton);
			this.closeButton.useHandCursor = false;
			Reflect.setProperty(this.closeButton, "toolTip", "关闭");
			this.closeButton.visible = this._showCloseButton;
			this.addChild(this.closeButton);
			this.closeButton.addEventListener(MouseEvent.CLICK, this.onClose);
		}
	}

	// :75-78
	private function onClose(param1:Event):Void {
		this.close();
	}

	// :80-83
	public var headArea(get, never):Sprite;

	private function get_headArea():Sprite {
		return this._headArea;
	}

	// :85-87（空实现：子类覆写点）
	public function keyEnter(param1:KeyboardEvent):Void {}

	// :89-96
	private function set_showCloseButton(param1:Bool):Bool {
		this._showCloseButton = param1;
		if (this.closeButton != null) {
			this.closeButton.visible = this._showCloseButton;
		}
		return param1;
	}

	// :98-103（`this.closeFn && this.closeFn(_loc1_)`：AS3 短路调用）
	private function close():Void {
		var _loc1_:Event = new Event(Event.CLOSE);
		this.dispatchEvent(_loc1_);
		if (this.closeFn != null) {
			this.closeFn(_loc1_);
		}
	}
}
