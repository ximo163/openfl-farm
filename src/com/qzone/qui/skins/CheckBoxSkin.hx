package com.qzone.qui.skins;

import openfl.display.MovieClip;
import shim.SymbolClass;

// com.qzone.qui.skins.CheckBoxSkin —— CheckBoxSkin.as（Master2 变体）逐句
// 对应（issue #86 牧场库底座，qui CheckBox 片）。复选钮默认皮肤符号。
// 原版是 Flex 编译期 Embed 的 dynamic Sprite 壳（Master2_v_142.swf char#57），
// 同名符号 farmui_full_v_40.swf 也导出（char#666，两库位图逐字节相同，
// md5 对拍 2026-11-26）——按 RadioButtonSkin 先例落 MovieClip +
// SymbolClass.bind("farmui_full_v_40")。dynamic class：原版无调用点往实例
// 挂属性，按普通 class 翻（CursorTool 先例）。
@:keep
class CheckBoxSkin extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "com.qzone.qui.skins.CheckBoxSkin");
	}
}
