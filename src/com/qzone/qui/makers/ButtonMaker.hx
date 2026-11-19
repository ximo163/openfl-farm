package com.qzone.qui.makers;

import openfl.display.Sprite;

/**
 * com.qzone.qui.makers.ButtonMaker —— V3b 闭包 stub（issue #8）。qui 按钮
 * 状态机（ButtonMaker.as 104 loc > 100，闭包规则走 stub，qui 组件片翻译）。
 * 本片 BackgroundScreen._navButton 只走 addTarget(:25-38：挂进目标表 +
 * setSelected/setEnabled/buttonMode/mouseChildren 三连)；stub no-op，按钮
 * 点按态随 qui 片接入。
 * legacy/decompiled/main3_v_221/scripts/com/qzone/qui/makers/ButtonMaker.as
 */
@:keep
class ButtonMaker {
	public function new() {}

	// ButtonMaker.as:25-38（addTarget，qui 片翻译）
	public static function addTarget(param1:Sprite, param2:Bool = true, param3:Bool = false):Void {}

	// ButtonMaker.as:39-48（removeTarget，qui 片翻译）
	public static function removeTarget(param1:Sprite):Void {}

	// ButtonMaker.as:76-82（setSelected，qui 片翻译）
	public static function setSelected(param1:Sprite, param2:Bool = true):Void {}

	// ButtonMaker.as:84-102（setEnabled，qui 片翻译）
	public static function setEnabled(param1:Sprite, param2:Bool = false):Void {}
}
