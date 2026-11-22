package common.cache;

/**
 * common.cache.SimpleFactory —— SimpleFactory.as 逐句对应（issue #37 功能 swf
 * 翻译：鱼塘 pool_v_13；pool_v_13 特有的公共库本地副本）。持一个 Class、
 * create 时 new：ObjectPool.allocate(size, cls) 内部就是 new SimpleFactory(cls)
 * （ObjectPool.as:219）。
 */
class SimpleFactory implements IObjectPoolFactory {
	// SimpleFactory.as:8
	private var _class:Class<Dynamic>;

	// SimpleFactory.as:10-14
	public function new(param1:Class<Dynamic>) {
		this._class = param1;
	}

	// SimpleFactory.as:16-22
	public function create():Dynamic {
		if (this._class == null) {
			return null;
		}
		return Type.createInstance(this._class, []);
	}
}
