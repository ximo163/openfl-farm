package framework.api;

import module.FarmApplication;

/**
 * framework.api.FarmAPI —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * 农场对外插件 API（FarmAPI.as 419 loc，插件/活动/支付拿宿主能力的门面）；
 * 启动链只 new FarmAPI(this) 后转交 PluginManager/QQPay/FarmAppHelper。
 * 行为随插件片接入。
 */
@:keep
class FarmAPI {
	// FarmAPI.as（构造持宿主应用）
	private var _app:FarmApplication;

	public function new(param1:FarmApplication) {
		this._app = param1;
	}

	public var app(get, never):FarmApplication;

	private function get_app():FarmApplication {
		return this._app;
	}
}
