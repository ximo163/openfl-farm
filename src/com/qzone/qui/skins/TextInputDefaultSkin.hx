package com.qzone.qui.skins;

// com.qzone.qui.skins.TextInputDefaultSkin —— TextInputDefaultSkin.as
// 逐句对应（issue #18 qui 收尾：皮肤表片）。文本输入框默认皮肤类表
// （TextInput ctor 装配；selectedSkin 指向聚焦皮肤 TextInputFocusSkin）。
class TextInputDefaultSkin {
	// TextInputDefaultSkin.as:6-10
	public static var skin:Class<Dynamic> = TextInputSkin;

	public static var selectedSkin:Class<Dynamic> = TextInputFocusSkin;

	// :12-16
	public function new() {}
}
