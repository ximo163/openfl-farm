package com.qzone.sns;

/**
 * com.qzone.sns.QQPay —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * Q 支付桥（QQPay.as 174 loc）；启动链只写 getInstance().app = farmAPI。
 * 真实支付出口按 deviations（no-qzone-jsapi）本就不发送，stub 恒空。
 */
@:keep
class QQPay {
	private static var _instance:QQPay;

	public static function getInstance():QQPay {
		if (_instance == null) {
			_instance = new QQPay();
		}
		return _instance;
	}

	public function new() {}

	// QQPay.as（app：支付回调挂的宿主 API）
	public var app(get, set):Dynamic;

	private var _app:Dynamic;

	private function get_app():Dynamic {
		return this._app;
	}

	private function set_app(param1:Dynamic):Dynamic {
		this._app = param1;
		return param1;
	}
}
