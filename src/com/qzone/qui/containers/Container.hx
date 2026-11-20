package com.qzone.qui.containers;

import com.qzone.qui.controls.scrollClasses.ScrollBase;
import com.qzone.qui.styles.Style;
import com.qzone.utils.DisplayUtil;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Graphics;
import openfl.display.Sprite;

/**
 * com.qzone.qui.containers.Container —— Container.as 逐句对应（issue #9
 * qui 子集片）。滚动容器：背景绘制（drawBackGround 经 content["graphics"]
 * 动态取——DisplayObjectContainer 类型面没有 graphics，运行实例是 Sprite）、
 * 延迟校验开关、content 的懒建/替换。
 */
class Container extends ScrollBase {
	// Container.as:14-20
	private var m_enableValidate:Bool;
	public var backgroundAlpha:Float;
	public var autoLayout:Bool;
	public var backgroundColor:UInt;

	// Container.as:22-30
	public function new() {
		super();
		this._width = 200;
		this._height = 200;
		this.backgroundColor = Style.canvasBackgroundColor;
		this.backgroundAlpha = Style.canvasBackgroundAlpha;
		this.m_enableValidate = true;
	}

	// Container.as:32-35
	public var enableValidate(get, set):Bool;

	private function set_enableValidate(param1:Bool):Bool {
		this.m_enableValidate = param1;
		return param1;
	}

	// Container.as:37-40
	private function removeSkin(param1:Sprite):DisplayObject {
		return super.removeChild(param1);
	}

	// Container.as:42-47
	private function updateBackGround():Void {
		var _loc1_:Int = Std.int(Math.max(this.content.width + this.paddingH * 2 - this.borderSizeH * 2, this._width
			- this._scrollW));
		var _loc2_:Int = Std.int(Math.max(this.content.height + this.paddingV * 2 - this.borderSizeV * 2, this._height
			- this._scrollH));
		this.drawBackGround(_loc1_, _loc2_);
	}

	// Container.as:49-59
	public function validateNow():Void {
		if (this.m_enableValidate == false) {
			return;
		}
		this.checkScrollBar();
		this.updateBackGround();
		this.updateScrollBar();
		this.setSize();
	}

	// Container.as:61-70（content 懒建：Sprite + scrollRect/边框内缩）。属性声明
	// 在 ScrollBase（get,set；Haxe 属性不重复声明覆写，只覆写 accessor——见
	// ScrollBase.hx content 的 PORT-NOTE）
	private override function get_content():DisplayObjectContainer {
		if (this._content == null) {
			this._content = new Sprite();
			this.setContent();
			this.addChild(this._content);
		}
		return this._content;
	}

	// Container.as:72-77
	private function setContent():Void {
		this._content.scrollRect = this._scrollRect;
		this._content.y = this.borderSizeV;
		this._content.x = this.borderSizeH;
	}

	// Container.as:79-94
	private override function set_content(param1:DisplayObjectContainer):DisplayObjectContainer {
		DisplayUtil.removeChild(this, this._content);
		this._content = param1;
		this.setContent();
		this.addChild(this._content);
		if (this.autoLayout) {
			this._width = param1.width + Style.panelPaddingH * 2;
			this._height = param1.height + Style.panelHeadHeight + Style.panelPaddingV;
		}
		if (this._added) {
			this.validateNow();
		}
		return param1;
	}

	// Container.as:96-107（content["graphics"]：动态取 Sprite 的 graphics）
	private function drawBackGround(param1:Int, param2:Int):Void {
		if (this.backgroundAlpha == 0) {
			return;
		}
		var _loc3_:Graphics = cast Reflect.field(this.content, "graphics");
		_loc3_.clear();
		_loc3_.beginFill(this.backgroundColor, this.backgroundAlpha);
		_loc3_.drawRect(0, 0, param1, param2);
		_loc3_.endFill();
	}

	// Container.as:109-112
	private override function init():Void {
		super.init();
	}

	// Container.as:114-117
	private function get_enableValidate():Bool {
		return this.m_enableValidate;
	}

	// Container.as:119-122
	private function addSkin(param1:Sprite):DisplayObject {
		return super.addChild(param1);
	}
}
