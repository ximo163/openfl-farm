package com.qzone.qui.skins;

// com.qzone.qui.skins.PanelDefaultSkin —— PanelDefaultSkin.as 逐句对应
// （issue #18 qui 收尾：皮肤表片）。面板默认皮肤类表（Panel ctor 装配）。
// 静态是 var（运行时可换肤），照抄。
class PanelDefaultSkin {
	// PanelDefaultSkin.as:6-11
	public static var skin:Class<Dynamic> = PanelSkin;

	public static var controlBarSkin:Class<Dynamic> = PanelControlBarSkin;

	public static var closeButtonSkin:Class<Dynamic> = PanelCloseButton;

	// :13-17
	public function new() {}
}
