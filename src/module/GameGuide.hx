package module;

import openfl.display.DisplayObjectContainer;

/**
 * module.GameGuide —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * 新手引导（GameGuide.as 282 loc）；FarmApplication.startup 只写
 * instance().container = LAYER_TOPMOST 层。引导步骤/遮罩随引导片接入。
 */
@:keep
class GameGuide {
	// GameGuide.as:22-32（issue #35 闭包成员补齐：ShopView/ShopController/
	// 买入窗口的鱼苗引导步骤号；其余常量随引导片翻译）
	public static final WATER_FISH_TAB:Int = 1;

	// GameGuide.as:24
	public static final WATER_FISH_ITEM:Int = 2;

	// GameGuide.as:26
	public static final WATER_UNLOCK_FISH:Int = 3;

	// GameGuide.as:28
	public static final WATER_FISH_ITEM_AGAIN:Int = 4;

	// GameGuide.as:30
	public static final WATER_BUY_FISH:Int = 5;

	// GameGuide.as:32
	public static final WATER_BAG_ICON_FISH:Int = 6;

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

	// GameGuide.as:163-（issue #35 闭包成员补齐：引导遮罩/箭头随引导片翻译，
	// 商店调用点先保可调不抛）
	public function showStep(param1:Int, param2:Int = 0, param3:Int = 0, param4:String = ""):Void {}

	// GameGuide.as:127-（引导片翻译；sec<=0 分支的 hide 同片）
	public function autoHide(param1:Int):Void {}

	// GameGuide.as:148-（引导片翻译）
	public function hide():Void {}
}
