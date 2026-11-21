package com.minutes.ui.core;

import openfl.display.Sprite;

/**
 * com.minutes.ui.core.LipiUIComponent —— LipiUIComponent.as 的签名面
 * stub（原类 184 loc，minutes UI 片真身待译——#pasture；issue #19 只保
 * profile 窗族触到的 bgSkin/bgAlpha/宽高/invalidateDisplayList）。
 * legacy/decompiled/Master2_v_142/scripts/com/minutes/ui/core/LipiUIComponent.as。
 */
@:keep
class LipiUIComponent extends Sprite {
	private var _bgSkin:LipiSkin;
	private var _bgAlpha:Float = 1;
	private var _bgColor:UInt = 0xffffff;

	public function new() {
		super();
	}

	// LipiUIComponent.as:37/116
	public var bgSkin(get, set):LipiSkin;

	private function get_bgSkin():LipiSkin {
		return this._bgSkin;
	}

	private function set_bgSkin(param1:LipiSkin):LipiSkin {
		this._bgSkin = param1;
		return param1;
	}

	// LipiUIComponent.as:85/121
	public var bgAlpha(get, set):Float;

	private function get_bgAlpha():Float {
		return this._bgAlpha;
	}

	private function set_bgAlpha(param1:Float):Float {
		this._bgAlpha = param1;
		return param1;
	}

	// LipiUIComponent.as:90/176
	public var bgColor(get, set):UInt;

	private function get_bgColor():UInt {
		return this._bgColor;
	}

	private function set_bgColor(param1:UInt):UInt {
		this._bgColor = param1;
		return param1;
	}

	// LipiUIComponent.as:61-80（width/height 访问器重载；属性本体继承自
	// DisplayObject，Haxe 不允许子类重声明同名属性，只重载访问器）
	private override function get_width():Float {
		return super.get_width();
	}

	private override function set_width(param1:Float):Float {
		super.set_width(param1);
		return param1;
	}

	private override function get_height():Float {
		return super.get_height();
	}

	private override function set_height(param1:Float):Float {
		super.set_height(param1);
		return param1;
	}

	// LipiUIComponent.as:52
	public function invalidateDisplayList():Void {}
}
