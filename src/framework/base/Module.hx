package framework.base;

import com.qzone.qfa.data.Resource;
import com.qzone.qfa.managers.ResourceManager;
import common.CommonData;
import common.Settings;
import common.misc.Utils;
import events.CommonEvent;
import interfaces.IModule;
import module.FarmApplication;
import openfl.errors.Error;
import report.EventRecorder;
import shim.As3.getTimer; // PORT-NOTE: openfl 的 getTimer 在 eval 上纪元溢出为负，见 shim/As3.hx

// framework.base.Module —— Module.as 逐句对应。
// PORT-NOTE: `x is Object`/hasOwnProperty → Reflect 判空/判键；E4X
// `xml.moduleList.module.(@name==name).@url` 按等价遍历改写（FarmLite 先例），
// 未命中时 E4X 空列表转 String 是 ""，这里保持 ""。
class Module implements IModule {
	// Module.as:16
	private var m_app:FarmApplication; // AS3 protected → Haxe private

	// Module.as:18
	private var _loadEvent:CommonEvent; // AS3 protected → Haxe private

	// Module.as:20
	private var _triggers:Array<Dynamic>;

	// Module.as:22
	private var _loaded:Bool;

	// Module.as:24
	private var _downloadTS:Float; // AS3 protected → Haxe private

	// Module.as:26
	private var _reportID:String; // AS3 protected → Haxe private

	// Module.as:28
	private var m_container:BaseLayer; // AS3 protected → Haxe private

	// Module.as:30
	private var _loading:Bool;

	// Module.as:32-37
	public function new(param1:FarmApplication) {
		this.m_app = param1;
		this.m_container = null;
		this._loaded = false;
	}

	// Module.as:39-42
	public var container(get, never):BaseLayer;

	private function get_container():BaseLayer {
		return this.m_container;
	}

	// Module.as:44-57
	private function onDownloadSuccess(param1:Dynamic):Void {
		var _loc3_:String = null;
		var _loc2_:Float = getTimer();
		EventRecorder.recordSueecssEvent(this._reportID, _loc2_ - this._downloadTS);
		for (_loc3_ in (this._triggers:Array<Dynamic>)) {
			this.m_app.removeEventListener(_loc3_, this.onLoadModuleFile);
		}
		this._loading = false;
		this._loaded = true;
		this.onModuleLoadSuccess();
		if (this._loadEvent != null) {
			this.app.dispatchEvent(new CommonEvent(this._loadEvent.type, this._loadEvent.data));
		}
	}

	// Module.as:59-72
	private function onDownloadFail(param1:Dynamic):Void {
		var _loc2_:Float = getTimer();
		if (param1 != null && Reflect.hasField(param1, "404") == true) {
			EventRecorder.recordErrorEvent(this._reportID, _loc2_ - this._downloadTS, 2, null);
		} else {
			EventRecorder.recordErrorEvent(this._reportID, _loc2_ - this._downloadTS, 3, null);
		}
		this._loading = false;
		this._loaded = false;
	}

	// Module.as:74-90
	public function loadLater(param1:Array<Dynamic>, param2:BaseLayer):Void {
		var _loc3_:String = null;
		if (param1 == null || param1.length == 0) {
			this.load(param2);
			return;
		}
		if (this.m_app == null) {
			throw new Error("Application\'s not initialized in advance!");
		}
		this._triggers = param1;
		for (_loc3_ in (param1:Array<Dynamic>)) {
			this.m_app.addEventListener(_loc3_, this.onLoadModuleFile, false, 0, true);
		}
		this.m_container = param2;
		this._loaded = false;
	}

	// Module.as:92-95
	public var name(get, never):String;

	private function get_name():String {
		return "";
	}

	// Module.as:97-99
	private function onModuleLoadSuccess():Void {}

	// Module.as:101-127
	private function onLoadModuleFile(param1:CommonEvent):Void {
		var e:CommonEvent = param1;
		if (this._loading == true) {
			return;
		}
		var st:Settings = Settings.getInstance();
		var res:Resource = ResourceManager.gi().getResource(st.getStringAttribute("config_url"));
		if (res == null) {
			return;
		}
		var xml:Xml = Utils.loadXMLData(res.data);
		if (xml == null) {
			return;
		}
		// E4X moduleList 下 module[@name==name] 的 @url，按等价遍历改写
		//（FarmLite 同款注）；未命中保持 ""（E4X 空 XMLList 转 String 即 ""）
		var url:String = "";
		for (moduleListNode in xml.elements()) {
			if (moduleListNode.nodeName != "moduleList") {
				continue;
			}
			for (moduleNode in moduleListNode.elements()) {
				if (moduleNode.get("name") == this.name) {
					var attrUrl:String = moduleNode.get("url");
					if (attrUrl != null) {
						url = attrUrl;
					}
					break;
				}
			}
		}
		url = st.replaceAppImg(url);
		if (url == null || url == "") {
			return;
		}
		CommonData.rslManager.requestFile(url, this.onDownloadSuccess, this.onDownloadFail);
		e.target.removeEventListener(e.type, this.onLoadModuleFile);
		this._loading = true;
		this._loadEvent = e;
		this._downloadTS = getTimer();
	}

	// Module.as:129-132
	public var loaded(get, never):Bool;

	private function get_loaded():Bool {
		return this._loaded;
	}

	// Module.as:134-137
	public var app(get, never):FarmApplication;

	private function get_app():FarmApplication {
		return this.m_app;
	}

	// Module.as:139-141
	public function onNetRequestStopped():Void {}

	// Module.as:143-149
	public function load(param1:BaseLayer):Void {
		if (this._loaded == true) {
			return;
		}
		this.m_container = param1;
		this._loaded = true;
	}

	// Module.as:151-153
	public function onGameLoop(param1:Float):Void {}

	// Module.as:155-158
	public function unload():Void {
		this._loaded = false;
	}
}
