package com.minutes.ui.core;

import openfl.display.DisplayObject;
import openfl.geom.Rectangle;

/**
 * com.minutes.ui.core.LipiPanel —— LipiPanel.as 的签名面 stub（原类
 * 384 loc，minutes UI 片真身待译——#pasture；issue #19 只保窗口族用到的
 * ctor/titleIMG/addChild 通道）。真身的 addChild 把子件投进内容区并按
 * headHeight 排布标题栏。LipiPanel.as:12 extends LipiUIComponent。
 */
@:keep
class LipiPanel extends LipiUIComponent {
	private var _title:String = "";
	private var _titleIMG:Class<Dynamic>;

	public function new(param1:Rectangle = null) {
		super();
	}

	// LipiPanel.as:165/260
	public var title(get, set):String;

	private function get_title():String {
		return this._title;
	}

	private function set_title(param1:String):String {
		this._title = param1;
		return param1;
	}

	// LipiPanel.as:212
	public var titleIMG(get, set):Class<Dynamic>;

	private function get_titleIMG():Class<Dynamic> {
		return this._titleIMG;
	}

	private function set_titleIMG(param1:Class<Dynamic>):Class<Dynamic> {
		this._titleIMG = param1;
		return param1;
	}

	// LipiPanel.as:366（addChild 投内容区；stub 直通）
	public override function addChild(param1:DisplayObject):DisplayObject {
		return super.addChild(param1);
	}

	// LipiPanel.as:234
	public function addChildToSuper(param1:DisplayObject):Void {
		super.addChild(param1);
	}
}
