package framework.api;

/**
 * framework.api.PluginManager —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * 插件管理器（PluginManager.as 280 loc：解析 plugins 配置、装载插件代理）；
 * 启动链只调 loadPlugins(api, plugins) 和 amountPlugins(PLUGIN_AMOUNT_BG,
 * container, null)。行为随插件片接入。
 */
@:keep
class PluginManager {
	private static var _instance:PluginManager;

	public static function getInstance():PluginManager {
		if (_instance == null) {
			_instance = new PluginManager();
		}
		return _instance;
	}

	public function new() {}

	// PluginManager.as（loadPlugins：按 plugins 配置装载插件，插件片翻译）
	public function loadPlugins(param1:Dynamic, param2:Array<Dynamic>):Void {}

	// PluginManager.as（amountPlugins：向容器铺某类插件位，插件片翻译）
	public function amountPlugins(param1:String, param2:Dynamic, param3:Dynamic = null):Void {}
}
