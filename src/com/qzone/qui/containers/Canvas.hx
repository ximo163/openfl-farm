package com.qzone.qui.containers;

import com.qzone.qui.skins.ListDefaultSkin;
import com.qzone.qui.styles.Style;
import openfl.display.DisplayObject;

/**
 * com.qzone.qui.containers.Canvas —— Canvas.as 逐句对应（issue #9 qui 子集片）。
 * 画布容器：默认皮肤（ListDefaultSkin.skin）铺底、皮肤随 setSize 拉伸。
 * 注意原文 nativeHeight 用的是 paddingH（:32-35，与 nativeWidth 的对称位
 * 不同），照抄。
 */
class Canvas extends Container {
	// Canvas.as:11-13
	private var _skin:DisplayObject;
	public var defaultSkin:Class<Dynamic>;

	// Canvas.as:15-25
	public function new(param1:Float = 200, param2:Float = 200) {
		super();
		this._width = param1;
		this._height = param2;
		this.defaultSkin = ListDefaultSkin.skin;
		this.borderSizeH = Style.canvasBorderSizeH;
		this.borderSizeV = Style.canvasBorderSizeV;
		this.backgroundColor = Style.canvasBackgroundColor;
		this.backgroundAlpha = Style.canvasBackgroundAlpha;
	}

	// Canvas.as:27-30
	private override function init():Void {
		super.init();
	}

	// Canvas.as:32-35（原文此处用 paddingH，照抄）
	public var nativeHeight(get, never):Int;

	private function get_nativeHeight():Int {
		return Std.int(this._height - this.paddingH * 2 - this.borderSizeV * 2);
	}

	// Canvas.as:37-44
	private override function setSkin():Void {
		if (this.defaultSkin != null) {
			this._skin = Type.createInstance(this.defaultSkin, []);
			this.addChildAt(this._skin, 0);
		}
	}

	// Canvas.as:46-54
	private override function setSize():Void {
		super.setSize();
		if (this._skin != null) {
			this._skin.width = this._width;
			this._skin.height = this._height;
		}
	}

	// Canvas.as:56-59
	private function contentResize(param1:openfl.events.Event):Void {
		this.updateScrollBar();
	}

	// Canvas.as:61-64
	public var nativeWidth(get, never):Int;

	private function get_nativeWidth():Int {
		return Std.int(this._width - this.paddingH * 2 - this.borderSizeH * 2);
	}
}
