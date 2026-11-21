package com.qzone.qui.skins;

// com.qzone.qui.skins.ButtonDefaultSkin —— ButtonDefaultSkin.as 逐句对应
// （issue #18 qui 收尾：皮肤表片）。按钮默认皮肤类表（Button ctor 装配）。
class ButtonDefaultSkin {
	// ButtonDefaultSkin.as:6-10
	public static var skin:Class<Dynamic> = ButtonSkin;

	public static var selectedSkin:Class<Dynamic> = ButtonSelectedSkin;

	// :12-16
	public function new() {}
}
