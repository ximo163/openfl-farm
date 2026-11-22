package com.qzone.qui.skins;

// com.qzone.qui.skins.ListItemDefaultSkin —— ListItemDefaultSkin.as 逐句
// 对应（issue #36 功能 swf 翻译：仓库）。列表条目默认/选中皮肤类表
// （skin 引 ListItemOverSkin 符号，selectedSkin 引 ListItemSelectedSkin——
// ListDefaultSkin/ListSkin 先例，纯表类无时间轴）。
class ListItemDefaultSkin {
	// ListItemDefaultSkin.as:6
	public static var skin:Class<Dynamic> = ListItemOverSkin;

	// ListItemDefaultSkin.as:8
	public static var selectedSkin:Class<Dynamic> = ListItemSelectedSkin;

	// ListItemDefaultSkin.as:10-13
	public function new() {}
}
