package framework.net.core;

/**
 * framework.net.core.HttpConnectionPool —— write-tests stub（issue #7）：签名与
 * legacy/decompiled/main3_v_221/scripts/framework/net/core/HttpConnectionPool.as
 * 一致，方法体 `throw new Error("not implemented")`，实现在翻译阶段完成
 * （getInstance :19-28、free :30-33、borrow :35-44）。
 */
class HttpConnectionPool {
	// HttpConnectionPool.as:9
	private static var _instance:HttpConnectionPool = null;

	// HttpConnectionPool.as:13
	private var _freeList:Array<Dynamic>;

	public function new() {
		throw new openfl.errors.Error("not implemented");
	}

	// HttpConnectionPool.as:19-28
	public static function getInstance():HttpConnectionPool {
		throw new openfl.errors.Error("not implemented");
	}

	// HttpConnectionPool.as:30-33
	public function free(param1:HttpOperationEx):Void {
		throw new openfl.errors.Error("not implemented");
	}

	// HttpConnectionPool.as:35-44
	public function borrow():HttpOperationEx {
		throw new openfl.errors.Error("not implemented");
	}
}
