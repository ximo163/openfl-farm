package com.minutes.ui.control;

import com.minutes.ui.core.LipiContainer;
import openfl.display.DisplayObject;
import openfl.display.Sprite;

/**
 * com.minutes.ui.control.JerryNavigation —— JerryNavigation.as 的签名面
 * stub（原类约 280 loc，minutes UI 片真身待译——#pasture；issue #19 只保
 * JerryTabNavigation.menu 的 getItem 通道——ProfileWindow.addedToLayer 用
 * getItem(3)/(4).visible 开关消费/系统页签）。真身 addItem 造 ToggleButton。
 * JerryNavigation.as:10 extends LipiContainer。
 */
@:keep
class JerryNavigation extends LipiContainer {
	private var _items:Array<DisplayObject> = [];

	public function new() {
		super();
	}

	// JerryNavigation.as:80
	public function getItem(param1:Int):DisplayObject {
		return this._items[param1];
	}

	// JerryNavigation.as:206（addItem：label/宽高/滤镜；真身造导航钮并排布，
	// stub 以占位 Sprite 入列保证 getItem 可用）
	public function addItem(param1:String, param2:Float = 0, param3:Float = 0, param4:Array<Dynamic> = null):Void {
		var _loc5_:Sprite = new Sprite();
		this._items.push(_loc5_);
		addChild(_loc5_);
	}
}
