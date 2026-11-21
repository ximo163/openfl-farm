package framework.api;

import com.qzone.corelib.net.RSLLoader;
import com.qzone.farm.api.interfaces.IPlugin;
import com.qzone.farm.api.interfaces.IPluginProxy;
import common.Settings;
import openfl.display.LoaderInfo;
import openfl.events.Event;
import openfl.system.ApplicationDomain;
import openfl.system.SecurityDomain;
import shim.As3;

/**
 * framework.api.PluginProxy —— PluginProxy.as 逐句对应（issue #18 qui 收尾：
 * 框架片）。插件代理：initialize 校验配置 url，loadResource 用 RSLLoader 拉
 * 插件 swf（独立 ApplicationDomain + 当前 SecurityDomain），onAllLoaded 从
 * LoaderInfo.content 取 IPlugin 实例回填并 load(config.id, PluginManager.api)。
 * PORT-NOTE: `param1["url"] == undefined` —— AS3 null==undefined 宽松等，
 * 等价 Reflect.field(...) == null。
 */
@:keep
class PluginProxy implements IPluginProxy {
	// PluginProxy.as:15-21
	private var m_plugin:IPlugin;

	private var m_loader:RSLLoader;

	private var m_config:Dynamic;

	private var m_loaded:Bool;

	// :23-30
	public function new() {
		this.m_loader = null;
		this.m_plugin = null;
		this.m_config = null;
		this.m_loaded = false;
	}

	// :32-35
	public var config(get, never):Dynamic;

	private function get_config():Dynamic {
		return this.m_config;
	}

	// :37-57（`param1.target as LoaderInfo` / `content as IPlugin`）
	private function onAllLoaded(param1:Event):Void {
		if (param1 == null) {
			return;
		}
		var _loc2_:LoaderInfo = Std.isOfType(param1.target, LoaderInfo) ? cast(param1.target, LoaderInfo) : null;
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:IPlugin = Std.isOfType(_loc2_.content, IPlugin) ? cast(_loc2_.content, IPlugin) : null;
		if (_loc3_ == null) {
			return;
		}
		this.m_plugin = _loc3_;
		this.m_loaded = true;
		_loc3_.load(As3.intOf(Reflect.field(this.m_config, "id")), PluginManager.getInstance().api);
		this.m_loader.reset();
	}

	// :59-71
	public function initialize(param1:Dynamic):Bool {
		if (param1 == null) {
			return false;
		}
		if (Reflect.field(param1, "url") == null || Reflect.field(param1, "url") == "") {
			return false;
		}
		this.m_config = param1;
		return true;
	}

	// :73-76（默认无命令：子类覆写）
	public function executeCommand(param1:Int, param2:Dynamic):Dynamic {
		return null;
	}

	// :78-102
	private function loadResource(param1:String):Void {
		if (param1 == null || param1 == "") {
			return;
		}
		if (this.m_loaded == true) {
			return;
		}
		if (this.m_loader == null) {
			this.m_loader = new RSLLoader();
			this.m_loader.applicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
			this.m_loader.securityDomain = SecurityDomain.currentDomain;
			this.m_loader.listCompleteFn = this.onAllLoaded;
		}
		param1 = Settings.getInstance().replaceAppImg(param1);
		if (param1 == null || param1 == "") {
			return;
		}
		var _loc2_:Array<Dynamic> = [{"url": param1}];
		this.m_loader.load(_loc2_);
	}
}
