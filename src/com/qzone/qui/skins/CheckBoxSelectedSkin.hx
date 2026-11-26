package com.qzone.qui.skins;

import openfl.display.MovieClip;
import shim.SymbolClass;

// com.qzone.qui.skins.CheckBoxSelectedSkin —— CheckBoxSelectedSkin.as
// （Master2 变体）逐句对应（issue #86 牧场库底座，qui CheckBox 片）。复选钮
// 选中皮肤符号。原版是 Flex 编译期 Embed 的 dynamic Sprite 壳
// （Master2_v_142.swf char#59），同名符号 farmui_full_v_40.swf 也导出
// （char#668，两库位图逐字节相同，md5 对拍 2026-11-26）——按
// RadioButtonSelectedSkin 先例落 MovieClip + SymbolClass.bind。
@:keep
class CheckBoxSelectedSkin extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "com.qzone.qui.skins.CheckBoxSelectedSkin");
	}
}
