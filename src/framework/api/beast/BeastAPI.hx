package framework.api.beast;

import module.FarmApplication;
import openfl.display.DisplayObjectContainer;
import openfl.events.Event;
import openfl.events.EventDispatcher;

/**
 * framework.api.beast.BeastAPI —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * 牧场（野兽）插件 API（BeastAPI.as 605 loc：野场数据/水晶/驯兽命令 + 与
 * WildShell 模块的桥）。启动链只碰：静态 app、getInstance、beastConfigUrl、
 * registerEventListeners、beastBase、三个容器属性、EvtAPI 事件监听
 * （FarmStage/FarmApplication/Main 的装载点）。其余行为随牧场片接入。
 */
@:keep
class BeastAPI extends EventDispatcher {
	// BeastAPI.as:30
	public static var app:FarmApplication;

	// BeastAPI.as:32
	private static var instance:BeastAPI;

	// BeastAPI.as:34-37
	public static final FARM_STAGE:String = "wild_show_farmstage";
	public static final WILD_STAGE:String = "wild_show_wildstage";

	// BeastAPI.as:39
	private var _wildStageContainer:DisplayObjectContainer;

	public function new() {
		super();
	}

	// BeastAPI.as（getInstance 单例）
	public static function getInstance():BeastAPI {
		if (instance == null) {
			instance = new BeastAPI();
		}
		return instance;
	}

	// BeastAPI.as（beastConfigUrl：牧场配置地址）
	public var beastConfigUrl(get, set):String;

	private var _beastConfigUrl:String = "";

	private function get_beastConfigUrl():String {
		return this._beastConfigUrl;
	}

	private function set_beastConfigUrl(param1:String):String {
		this._beastConfigUrl = param1;
		return param1;
	}

	// BeastAPI.as（beastBase：野场基础数据）
	public var beastBase(get, set):Dynamic;

	private var _beastBase:Dynamic;

	private function get_beastBase():Dynamic {
		return this._beastBase;
	}

	private function set_beastBase(param1:Dynamic):Dynamic {
		this._beastBase = param1;
		return param1;
	}

	// FarmStage.buildLayers 挂的三个容器
	public var wildStageContainer(get, set):DisplayObjectContainer;

	private function get_wildStageContainer():DisplayObjectContainer {
		return this._wildStageContainer;
	}

	private function set_wildStageContainer(param1:DisplayObjectContainer):DisplayObjectContainer {
		this._wildStageContainer = param1;
		return param1;
	}

	private var _animalContainer:DisplayObjectContainer;

	public var animalContainer(get, set):DisplayObjectContainer;

	private function get_animalContainer():DisplayObjectContainer {
		return this._animalContainer;
	}

	private function set_animalContainer(param1:DisplayObjectContainer):DisplayObjectContainer {
		this._animalContainer = param1;
		return param1;
	}

	private var _wildToolBarContainer:DisplayObjectContainer;

	public var wildToolBarContainer(get, set):DisplayObjectContainer;

	private function get_wildToolBarContainer():DisplayObjectContainer {
		return this._wildToolBarContainer;
	}

	private function set_wildToolBarContainer(param1:DisplayObjectContainer):DisplayObjectContainer {
		this._wildToolBarContainer = param1;
		return param1;
	}

	// BeastAPI.as:61（issue #9：UIController 挂工具条为野兽背包容器）
	private var _beastPackContainer:DisplayObjectContainer;

	// BeastAPI.as:296-298/:386-388
	public var beastPackContainer(get, set):DisplayObjectContainer;

	private function get_beastPackContainer():DisplayObjectContainer {
		return this._beastPackContainer;
	}

	private function set_beastPackContainer(param1:DisplayObjectContainer):DisplayObjectContainer {
		this._beastPackContainer = param1;
		return param1;
	}

	// BeastAPI.as:137（hideBeastPack：收起野兽背包 UI，牧场片接入时翻译）
	public function hideBeastPack():Void {}

	// BeastAPI.as（showBeastPack：展开野兽背包 UI，ToolBar 工具箱/野兽按钮
	// 调用，牧场片接入时翻译）
	public function showBeastPack():Void {}

	// BeastAPI.as:561（showFarmStage：从牧场切回农场场景，牧场片接入时翻译）
	public function showFarmStage():Void {}

	// BeastAPI.as:522（showWildStage：进野兽/野生动物场景，好友列表
	// FriendItemRender.onItemClicked 的 Status_u 分支调用，牧场片接入时翻译）
	public function showWildStage():Void {}

	// BeastAPI.as（registerEventListeners：挂牧场相关全局监听，牧场片翻译）
	public function registerEventListeners():Void {}
}
