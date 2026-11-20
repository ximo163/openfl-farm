package com.qzone.qui.containers;

import openfl.display.Sprite;

/**
 * com.qzone.qui.containers.Panel —— V3b 闭包 stub（issue #8）。qui 面板基类
 * （Panel.as 175 loc > 100，闭包规则走 stub，qui 组件片翻译）。原版继承
 * UIComponent（该链同样 >100 loc，随 qui 片接入）；stub 以 Sprite 垫底。
 * 本片 PreviewDiyWindow 只用 `title` 存取（Panel.as:101-121：_title 落字段、
 * panelTitle 文本随皮肤挂——皮肤片未接，这里只存值）。
 * legacy/decompiled/main3_v_221/scripts/com/qzone/qui/containers/Panel.as
 */
@:keep
class Panel extends Sprite {
	// Panel.as:24
	private var _title:String;

	// Panel.as:46-53（ctor 形态；panelTitle 皮肤装配随 qui 片）
	public function new(param1:String = "Panel", param2:Int = 300, param3:Int = 200) {
		super();
		this._title = param1;
	}

	// Panel.as:101-104
	public var title(get, set):String;

	private function get_title():String {
		return this._title;
	}

	// Panel.as:114-121（set：存值；panelTitle 文本渲染随 qui 皮肤片）
	private function set_title(param1:String):String {
		this._title = param1;
		return param1;
	}
}
