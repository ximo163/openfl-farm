package com.minutes.ui.collections;

/**
 * com.minutes.ui.collections.ILipiTileChild —— ILipiTileChild.as 逐句对应
 * （issue #19 Master2 闭包顺手译）。visible 继承自 DisplayObject 的属性行
 * （实现类 Sprite 已满足），接口只补 get/set 访问器签名。
 */
@:keep
interface ILipiTileChild {
	function get_fixedX():Float;
	function set_fixedX(param1:Float):Float;
	function get_fixedY():Float;
	function set_fixedY(param1:Float):Float;
	function get_data():Dynamic;
	function set_data(param1:Dynamic):Dynamic;
}
