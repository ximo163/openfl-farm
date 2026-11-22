package common.cache;

import openfl.errors.Error;

/**
 * common.cache.SimpleFactory —— issue #37 write-tests 签名 stub
 * （SimpleFactory.as 24 loc，pool_v_13 特有的公共库本地副本）。
 * 持一个 Class、create 时 new：ObjectPool.allocate(size, cls) 内部就是
 * new SimpleFactory(cls)（ObjectPool.as:219）。
 * 字段与方法签名照抄 AS3，体 throw not implemented；构造器零位（:14-18 的
 * _class 赋值）是本类实现内容，stub 不写（ShopModel stub 同口径）。
 */
class SimpleFactory implements IObjectPoolFactory {
	// SimpleFactory.as:8
	private var _class:Class<Dynamic>;

	// SimpleFactory.as:10-14（构造器零位是实现内容，stub 只保可构造）
	public function new(param1:Class<Dynamic>) {
		this._class = param1;
	}

	// SimpleFactory.as:16-22
	public function create():Dynamic {
		throw new Error("not implemented");
	}
}
