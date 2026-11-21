package mc.view.main.tip;

/**
 * mc.view.main.tip.ITip —— ITip.as 逐句对应（issue #19 Master2 闭包顺手译）。
 * Haxe 接口属性行转 get_/set_ 访问器对，实现类同签名满足。
 */
@:keep
interface ITip {
	function get_tX():Float;
	function set_tX(param1:Float):Float;
	function get_tY():Float;
	function set_tY(param1:Float):Float;
	function get_data():Dynamic;
	function set_data(param1:Dynamic):Dynamic;
	function get_mX():Float;
	function set_mX(param1:Float):Float;
	function get_mY():Float;
	function set_mY(param1:Float):Float;
}
