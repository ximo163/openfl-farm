package module;

import openfl.display.DisplayObjectContainer;

/**
 * module.GameGuide —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * 新手引导（GameGuide.as 282 loc）；FarmApplication.startup 只写
 * instance().container = LAYER_TOPMOST 层。引导步骤/遮罩随引导片接入。
 */
@:keep
class GameGuide {
	private static var _instance:GameGuide;

	public function new() {}

	// GameGuide.as:117-（instance 单例）
	public static function instance():GameGuide {
		if (_instance == null) {
			_instance = new GameGuide();
		}
		return _instance;
	}

	// GameGuide.as:271-（container：引导挂的容器层）
	public var container(get, set):DisplayObjectContainer;

	private var _container:DisplayObjectContainer;

	private function get_container():DisplayObjectContainer {
		return this._container;
	}

	private function set_container(param1:DisplayObjectContainer):DisplayObjectContainer {
		this._container = param1;
		return param1;
	}
}
