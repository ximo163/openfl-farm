package com.qzone.qui.skins;

// com.qzone.qui.skins.RadioButtonDefaultSkin —— RadioButtonDefaultSkin.as
// 逐句对应（issue #18 qui 收尾：皮肤表片）。单选钮默认皮肤类表
// （RadioButton ctor 装配）。
class RadioButtonDefaultSkin {
	// RadioButtonDefaultSkin.as:6-10
	public static var skin:Class<Dynamic> = RadioButtonSkin;

	public static var selectedSkin:Class<Dynamic> = RadioButtonSelectedSkin;

	// :12-16
	public function new() {}
}
