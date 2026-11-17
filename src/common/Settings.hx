package common;

/**
 * write-tests 阶段的最小 stub（issue #3）：只列测试用到的纯逻辑 API，签名按
 * legacy/decompiled/happyfarm3_v_149/scripts/common/Settings.as，函数体未实现。
 * 其余方法（loadFromFlashVars、config 数据模型相关 getter）由实现阶段按原版补齐。
 */
class Settings {
	public static final TIP_VALUE:String = "value";
	public static final TIP_URL:String = "url";

	private static var _instance:Settings;

	private var m_params:Dynamic;
	private var m_appImgPrefix:String;
	private var m_resolveUrl:String;
	private var m_mcCommUrl:String;
	private var m_ncCommUrl:String;

	public function new() {
		throw new haxe.Exception("not implemented");
	}

	public static function getInstance():Settings {
		throw new haxe.Exception("not implemented");
	}

	// Settings.as:483-488
	public function loadLocalSettings(param1:Dynamic):Void {
		throw new haxe.Exception("not implemented");
	}

	// Settings.as:360-374
	public function getStringAttribute(param1:String):String {
		throw new haxe.Exception("not implemented");
	}

	// Settings.as:85-88
	public var appImgPrefix(get, never):String;

	private function get_appImgPrefix():String {
		throw new haxe.Exception("not implemented");
	}

	// Settings.as:445-448
	public var resolveUrl(get, never):String;

	private function get_resolveUrl():String {
		throw new haxe.Exception("not implemented");
	}

	// Settings.as:266-274
	public var app_key(get, never):String;

	private function get_app_key():String {
		throw new haxe.Exception("not implemented");
	}

	// Settings.as:112-132
	public var mode(get, never):String;

	private function get_mode():String {
		throw new haxe.Exception("not implemented");
	}

	// Settings.as:134-146
	public var xymode(get, never):String;

	private function get_xymode():String {
		throw new haxe.Exception("not implemented");
	}

	// Settings.as:290-301
	public var domain(get, never):String;

	private function get_domain():String {
		throw new haxe.Exception("not implemented");
	}

	// Settings.as:285-288
	public var dataConfigUrl(get, never):String;

	private function get_dataConfigUrl():String {
		throw new haxe.Exception("not implemented");
	}

	// Settings.as:529-532
	public var addonConfigUrl(get, never):String;

	private function get_addonConfigUrl():String {
		throw new haxe.Exception("not implemented");
	}

	// Settings.as:209-222
	public function replaceAppImg(param1:String):String {
		throw new haxe.Exception("not implemented");
	}
}
