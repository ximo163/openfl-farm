package mc.fBridge;

/**
 * mc.fBridge.FRequest —— FRequest.as 的签名面 stub（原类 189 loc，issue #87
 * 「网络」片真身待译）。单例 + postRequest/postRequest2/getRequest 三通道
 * 与 httpUrl 转发；成员签名逐字取自反编译原文，方法体随 #87 implement
 * 充真身。legacy/decompiled/Master2_v_142/scripts/mc/FBridge/FRequest.as。
 *
 * PORT-NOTE(命名)：原包 `mc.FBridge` 的 FBridge 段首字母大写，Haxe 包段
 * 必须小写开头，落 `fBridge`（windowControl 同款先例，deviations 候选）。
 */
@:keep
class FRequest {
	// FRequest.as:13
	private static var instance:FRequest;

	// FRequest.as:15-22（单例守卫——原文构造器即完整实现）
	public function new() {
		if (instance != null) {
			throw new openfl.errors.Error("实例化单例类出错-FRequest");
		}
	}

	// FRequest.as:24-31
	public static function getInstance():FRequest {
		if (instance == null) {
			instance = new FRequest();
		}
		return instance;
	}

	// FRequest.as:33-36（postRequest2：timeout 12000）
	public function postRequest2(param1:String, param2:Dynamic, param3:Dynamic->Void, param4:String = null):Void {
		throw new openfl.errors.Error("not implemented");
	}

	// FRequest.as:38-41（postRequest：timeout 60000）
	public function postRequest(param1:String, param2:Dynamic, param3:Dynamic->Void, param4:String = null):Void {
		throw new openfl.errors.Error("not implemented");
	}

	// FRequest.as:48-87
	public function getRequest(param1:String, param2:Dynamic, param3:Dynamic->Void, param4:Int = 60000, param5:Bool = false, param6:String = "text"):Void {
		throw new openfl.errors.Error("not implemented");
	}

	// FRequest.as:43-46/:89-92（httpUrl 转发 HTTPRequest 单例）
	public var httpUrl(get, set):String;

	private function get_httpUrl():String {
		throw new openfl.errors.Error("not implemented");
	}

	private function set_httpUrl(param1:String):String {
		throw new openfl.errors.Error("not implemented");
	}
}
