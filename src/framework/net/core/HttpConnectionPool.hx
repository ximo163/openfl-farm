package framework.net.core;

// framework.net.core.HttpConnectionPool —— HttpConnectionPool.as 逐句对应。
class HttpConnectionPool {
	// HttpConnectionPool.as:9
	private static var _instance:HttpConnectionPool = null;

	// HttpConnectionPool.as:13
	private var _freeList:Array<Dynamic>;

	// HttpConnectionPool.as:15-18
	public function new() {
		this._freeList = new Array();
	}

	// HttpConnectionPool.as:19-28
	public static function getInstance():HttpConnectionPool {
		if (_instance != null) {
			return _instance;
		}
		_instance = new HttpConnectionPool();
		return _instance;
	}

	// HttpConnectionPool.as:30-33
	public function free(param1:HttpOperationEx):Void {
		this._freeList.push(param1);
	}

	// HttpConnectionPool.as:35-44
	public function borrow():HttpOperationEx {
		trace("http connection " + this._freeList.length);
		if (this._freeList.length == 0) {
			return new HttpOperationEx();
		}
		return cast this._freeList.shift();
	}
}
