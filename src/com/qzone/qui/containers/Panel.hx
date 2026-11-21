package com.qzone.qui.containers;

import com.qzone.qui.controls.UIComponent;

/**
 * com.qzone.qui.containers.Panel —— 签名 stub（issue #9 qui 子集片重定基：
 * 原版 extends UIComponent，UIComponent 本片已全量翻译，stub 从 Sprite 垫底
 * 改为继承真基类）。Panel.as 175 loc > 100 且不在本片清单，面板标题栏/皮肤
 * 装配随后续模块翻译；本片 PreviewDiyWindow 只用 `title` 存取（Panel.as
 * :101-121：_title 落字段、panelTitle 文本随皮肤挂——皮肤片未接，这里只存值）。
 * legacy/decompiled/main3_v_221/scripts/com/qzone/qui/containers/Panel.as
 */
@:keep
class Panel extends UIComponent {
	// Panel.as:24
	private var _title:String;

	// Panel.as:46-53（ctor 形态；_title/_width/_height 落字段（:50-52），
	// margins/defaultSkin 皮肤装配随 qui 片）
	public function new(param1:String = "Panel", param2:Int = 300, param3:Int = 200) {
		super();
		this._title = param1;
		this._height = param3;
		this._width = param2;
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
