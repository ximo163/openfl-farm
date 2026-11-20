package com.qzone.qui.controls;

import openfl.display.Sprite;

/**
 * com.qzone.qui.controls.Button —— V3b 闭包 stub（issue #8）。qui 按钮
 * （Button.as 202 loc > 100，闭包规则走 stub，qui 组件片翻译）。原版继承
 * Label（Label.as 179 loc 同走 stub 链，随 qui 片接入）；stub 以 Sprite 垫底。
 * 本片只有 AddButtonWindow.addButton 的返回类型引用（PreviewDiyWindow 不用
 * 返回值）；皮肤/文本/点按态随 qui 片接入。
 * legacy/decompiled/main3_v_221/scripts/com/qzone/qui/controls/Button.as
 */
@:keep
class Button extends Sprite {
	// Button.as:33（ctor 签名；super(param1,param2) 的 Label 链随 qui 片，
	// 皮肤/格式装配同理。Function → Dynamic）
	public function new(param1:String = "Button", param2:Dynamic = null) {
		super();
	}
}
