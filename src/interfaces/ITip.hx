package interfaces;

import openfl.display.DisplayObject;

/**
 * interfaces.ITip —— ITip.as 逐句对应（issue #18 接口片）。
 * 浮动提示的公共面（common/view/tip/Tip 实现它）。AS3 接口 getter/setter →
 * Haxe 接口属性声明（get/set），实现类走 `public var x(get, set)` +
 * get_x/set_x 约定（Label 同款）。
 */
interface ITip {
	// ITip.as:7-27
	var displayObject(get, never):DisplayObject;

	var tX(get, set):Float;

	var tY(get, set):Float;

	var tipName(get, never):String;

	var data(get, set):Dynamic;

	var mX(get, set):Float;

	var mY(get, set):Float;
}
