package com.minutes.ui.core;

import openfl.display.Sprite;
import openfl.events.Event;

/**
 * com.minutes.ui.core.LipiUIComponent —— LipiUIComponent.as 逐句对应
 * （issue #86 牧场库底座，LipiUI 组件库片）。
 * legacy/decompiled/Master2_v_142/scripts/com/minutes/ui/core/LipiUIComponent.as。
 *
 * PORT-NOTE（AS3 override width/height → Haxe）：Sprite 的同名属性不允许
 * 子类重声明，只重载访问器——SimpleCollection.hx / qui 控件同款形态。
 * _width/_height 是类的私有存储字段，与 Sprite 测量通道脱钩（原版如此：
 * get width 返 _width 而非 super 测量值）。
 * PORT-NOTE（onAdded 里 stage.addEventListener(Event.ENTER_FRAME)）：原版
 * 每帧 ENTER_FRAME 都跑 onRender→_update，仅靠 _isUpdate 早退——帧驱动
 * 语义照抄（CLAUDE.md：帧驱动不许改成时间驱动，反之亦然）。
 */
@:keep
class LipiUIComponent extends Sprite {
	// LipiUIComponent.as:9-29
	private var _bgSkin:LipiSkin;
	private var _height:Float = 100;
	private var _width:Float = 100;
	private var _bgSkinChange:Bool = false;
	private var _heightChange:Bool = true;
	private var _widthChange:Bool = true;
	private var _bgAlpha:Float = 1;
	private var _bgColor:UInt = 16777215;
	private var _bgAlphaChange:Bool = false;
	private var _bgColorChange:Bool = false;
	private var _isUpdate:Bool = false;

	// :31-35
	public function new() {
		super();
		addEventListener(Event.ADDED_TO_STAGE, this.onAdded);
	}

	// :37-50
	public var bgSkin(get, set):LipiSkin;

	private function get_bgSkin():LipiSkin {
		return this._bgSkin;
	}

	private function set_bgSkin(param1:LipiSkin):LipiSkin {
		if (param1 == this._bgSkin) {
			return param1;
		}
		if (this._bgSkin != null && contains(this._bgSkin)) {
			removeChild(this._bgSkin);
		}
		this._bgSkinChange = true;
		this._bgSkin = param1;
		this.invalidateDisplayList();
		return param1;
	}

	// :52-59
	public function invalidateDisplayList():Void {
		this._isUpdate = true;
		if (stage != null) {
			stage.invalidate();
		}
	}

	// :61-64（override 等价面，见类头 PORT-NOTE）
	private override function get_width():Float {
		return this._width;
	}

	// :66-71
	private override function set_height(param1:Float):Float {
		this._height = param1;
		this._heightChange = true;
		this.invalidateDisplayList();
		return param1;
	}

	// :73-78
	private override function set_width(param1:Float):Float {
		this._width = param1;
		this._widthChange = true;
		this.invalidateDisplayList();
		return param1;
	}

	// :80-83
	private function onRender(param1:Event):Void {
		this._update();
	}

	// :85-88
	public var bgAlpha(get, set):Float;

	private function get_bgAlpha():Float {
		return this._bgAlpha;
	}

	// :90-93
	public var bgColor(get, set):UInt;

	private function get_bgColor():UInt {
		return this._bgColor;
	}

	// :95-101
	private function onAdded(param1:Event):Void {
		removeEventListener(Event.ADDED_TO_STAGE, this.onAdded);
		stage.addEventListener(Event.ENTER_FRAME, this.onRender);
		this._isUpdate = true;
		this._update();
	}

	// :103-106
	private override function get_height():Float {
		return this._height;
	}

	// :108-114
	private function _update():Void {
		if (this._isUpdate == true) {
			this.updateDisplayList(this.width, this.height);
		}
	}

	// :121-126
	private function set_bgAlpha(param1:Float):Float {
		this._bgAlpha = param1;
		this._bgAlphaChange = true;
		this.invalidateDisplayList();
		return param1;
	}

	// :128-174
	private function updateDisplayList(param1:Float, param2:Float):Void {
		var _loc3_:UIEvent = null;
		this._isUpdate = false;
		if (this._bgAlphaChange || this._bgColorChange) {
			if (this.bgAlpha == 0) {
				graphics.clear();
			} else {
				graphics.clear();
				graphics.beginFill(this.bgColor, this.bgAlpha);
				graphics.drawRect(0, 0, param1, param2);
				graphics.endFill();
			}
		}
		if (this._widthChange || this._heightChange) {
			_loc3_ = new UIEvent(UIEvent.RESIZE);
			dispatchEvent(_loc3_);
			if (this._bgSkin != null) {
				this._bgSkin.height = this.height;
				this._bgSkin.width = this.width;
			} else {
				graphics.clear();
				graphics.beginFill(this.bgColor, this.bgAlpha);
				graphics.drawRect(0, 0, param1, param2);
				graphics.endFill();
			}
		}
		if (this._bgSkinChange && this._bgSkin != null) {
			this._bgSkin.width = this.width;
			this._bgSkin.height = this.height;
			super.addChildAt(this._bgSkin, 0);
		}
		this._bgSkinChange = false;
		this._bgAlphaChange = false;
		this._bgColorChange = false;
		this._widthChange = false;
		this._heightChange = false;
	}

	// :176-181
	private function set_bgColor(param1:UInt):UInt {
		this._bgColor = param1;
		this._bgColorChange = true;
		this.invalidateDisplayList();
		return param1;
	}
}
