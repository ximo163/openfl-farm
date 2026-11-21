package com.qzone.qui.managers;

import com.qzone.qui.controls.ToolTip;
import openfl.display.DisplayObjectContainer;
import openfl.errors.Error;
import openfl.events.EventDispatcher;

/**
 * com.qzone.qui.managers.ToolTipManager —— ToolTipManager.as 逐句对应
 * （issue #18 qui 收尾：管理器片）。工具提示管理器单例：持全局 _stage 与
 * 唯一 ToolTipLayer 实例（挂 stage 顶层），toolTipClass 可替换提示皮肤，
 * flowMouse 控制跟随鼠标模式。
 */
@:keep
class ToolTipManager extends EventDispatcher {
	// ToolTipManager.as:10-16
	private static var instance:ToolTipLayer;

	public static var flowMouse:Bool;

	private static var _stage:DisplayObjectContainer;

	public static var toolTipClass:Class<Dynamic> = ToolTip;

	// :18-25
	public function new() {
		super();
		if (instance != null) {
			throw new Error("实例化单例类出错 - ToolTipManager");
		}
	}

	// :27-31
	public static function init(param1:DisplayObjectContainer):Void {
		_stage = param1;
		getInstance();
	}

	// :33-36
	public static function hide():Void {
		getInstance().hideToolTip();
	}

	// :38-49（`Boolean(_stage) && Boolean(_stage.stage)`：两次非空判）
	public static function getInstance():ToolTipLayer {
		if (instance == null) {
			instance = new ToolTipLayer();
			if (_stage != null && _stage.stage != null) {
				_stage.stage.addChild(instance);
			}
		}
		return instance;
	}
}
