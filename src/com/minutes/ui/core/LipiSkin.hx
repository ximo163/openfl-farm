package com.minutes.ui.core;

import openfl.display.Sprite;
import openfl.geom.Rectangle;

/**
 * com.minutes.ui.core.LipiSkin —— LipiSkin.as 的签名面 stub（原类 181 loc，
 * minutes UI 片真身待译——#pasture；issue #19 只保 profile 窗族构造按钮皮肤
 * 用到的 ctor 与 backgroundImage）。真身用 param1 类实例化九宫格底图。
 */
@:keep
class LipiSkin extends Sprite {
	private var _backgroundImage:Class<Dynamic>;

	public function new(param1:Class<Dynamic>, param2:Rectangle = null) {
		super();
		this._backgroundImage = param1;
	}

	// LipiSkin.as:127/137
	public var backgroundImage(get, set):Class<Dynamic>;

	private function get_backgroundImage():Class<Dynamic> {
		return this._backgroundImage;
	}

	private function set_backgroundImage(param1:Class<Dynamic>):Class<Dynamic> {
		this._backgroundImage = param1;
		return param1;
	}
}
