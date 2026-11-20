package com.qzone.qui.skins;

// com.qzone.qui.skins.VScrollBarDefaultSkin —— VScrollBarDefaultSkin.as
// 逐句对应（issue #9 qui 子集片）。纵向滚动条默认皮肤类表（VScrollBar ctor
// 逐项赋给 ScrollBar 的皮肤字段）。
class VScrollBarDefaultSkin {
	// VScrollBarDefaultSkin.as:6-14
	public static var upArrowSkin:Class<Dynamic> = VScrollBarUpArrow;
	public static var downArrowSkin:Class<Dynamic> = VScrollBarDownArrow;
	public static var trackSkin:Class<Dynamic> = VScrollBarTrackSkin;
	public static var thumbSkin:Class<Dynamic> = VScrollBarThumb;
	public static var thumbIconSkin:Class<Dynamic> = VScrollBarThumbIcon;

	// VScrollBarDefaultSkin.as:16-19
	public function new() {}
}
