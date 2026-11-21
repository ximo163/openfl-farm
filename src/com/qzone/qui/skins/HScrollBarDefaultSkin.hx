package com.qzone.qui.skins;

// com.qzone.qui.skins.HScrollBarDefaultSkin —— HScrollBarDefaultSkin.as
// 逐句对应（issue #9 qui 子集片）。横向滚动条默认皮肤类表（HScrollBar ctor
// 逐项赋给 ScrollBar 的皮肤字段）。静态是 var（运行时可换肤），照抄。
class HScrollBarDefaultSkin {
	// HScrollBarDefaultSkin.as:6-14
	public static var upArrowSkin:Class<Dynamic> = HScrollBarUpArrow;
	public static var downArrowSkin:Class<Dynamic> = HScrollBarDownArrow;
	public static var trackSkin:Class<Dynamic> = HScrollBarTrackSkin;
	public static var thumbSkin:Class<Dynamic> = HScrollBarThumb;
	public static var thumbIconSkin:Class<Dynamic> = HScrollBarThumbIcon;

	// HScrollBarDefaultSkin.as:16-19
	public function new() {}
}
