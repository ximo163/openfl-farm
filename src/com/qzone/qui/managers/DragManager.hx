package com.qzone.qui.managers;

/**
 * com.qzone.qui.managers.DragManager —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * qui 拖拽管理器（DragManager.as 112 loc）；Main.setup 只写
 * updateAfterEvent 静态，addTarget/removeTarget 随 qui 片翻译。
 */
@:keep
class DragManager {
	// DragManager.as:17/:25
	public static var updateAfterEvent:Bool;
	public static var autoToFront:Bool;

	public function new() {}

	// DragManager.as:57-（removeTarget：解绑拖拽，qui 片翻译）
	public static function removeTarget(param1:Dynamic, param2:Dynamic = null):Void {}

	// DragManager.as:86-（addTarget：绑定拖拽，qui 片翻译）
	public static function addTarget(param1:Dynamic, param2:Dynamic = null, param3:Dynamic = null, param4:Dynamic = null):Void {}
}
