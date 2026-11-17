package;

import com.adobe.serialization.json.JSON;
import com.qzone.qfa.commands.CmdHttpRequest;
import com.qzone.qfa.commands.CmdLoadFile;
import com.qzone.qfa.data.Resource;
import com.qzone.qfa.events.CommandEvent;
import com.qzone.qfa.events.QFAEvent;
import com.qzone.qfa.managers.CommandManager;
import com.qzone.qfa.managers.ResourceManager;
import common.CommonData;
import common.Settings;
import common.misc.Cookies;
import common.misc.QzoneJSAPI;
import module.lite.FarmLiteModel;
import module.lite.FarmLiteView;
import openfl.Lib.getTimer;
import openfl.display.Sprite;
import openfl.display.StageAlign;
import openfl.display.StageScaleMode;
import openfl.net.URLRequest;
import openfl.system.ApplicationDomain;
import openfl.system.Security;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import report.EventRecorder;
import shim.As3;
import shim.QQOutlets;

// FarmLite.as 逐句对应（预加载器文档类）。原 [SWF(...)] 元数据由 Project.xml
// 的窗口设置承载（860x500 白底 24fps，等值）。
// PORT-NOTE(qq-outlet)：ExternalInterface.available/addCallback 与
// flash.net.sendToURL（openfl 没有）→ shim.QQOutlets no-op 出口，
// spec/deviations.json：no-qzone-jsapi / no-qq-telemetry。
// PORT-NOTE(E4X)：_mainXML 的 AS3 XML → haxe.Xml；startLiteUI 里的
// moduleList.module.(@name=="main") 属性过滤查法按等价遍历改写。
// PORT-NOTE(finally)：onFilesLoadCompleted 的 try/catch/finally——Haxe 无
// finally，两分支的 finally 体（非空才赋值）等价展开为一次赋值。
class FarmLite extends Sprite {
	// FarmLite.as:38
	private var _indexTime:Int;

	// FarmLite.as:40
	private var _settings:Settings;

	// FarmLite.as:42
	private var _text:TextField;

	// FarmLite.as:44
	private var _stepTime1:Int;

	// FarmLite.as:46
	private var _stepTime2:Int;

	// FarmLite.as:48
	private var _bootData:Dynamic;

	// FarmLite.as:50
	private var _liteModel:FarmLiteModel;

	// FarmLite.as:52
	private var _mainXML:Xml;

	// FarmLite.as:54
	private var _liteUI:FarmLiteView;

	// FarmLite.as:56
	private var _timeout:UInt;

	// FarmLite.as:58
	private var _timeoutStep1:UInt;

	// FarmLite.as:60
	private var _timeStamp:Float;

	// FarmLite.as:62-78
	public function new() {
		super();
		this._settings = Settings.getInstance();
		this._settings.loadFromFlashVars(this.stage.loaderInfo);
		Cookies.intialize("FarmWorld2");
		this._text = new TextField();
		this._text.defaultTextFormat = new TextFormat(null, 18, 0, false, false, false, null, null, TextFormatAlign.CENTER);
		this._text.width = 800;
		this._text.height = 100;
		this._text.multiline = true;
		this._text.x = 40;
		this._text.y = 200;
		addChild(this._text);
		this.setup();
		this.boot();
	}

	// FarmLite.as:80-109
	private function onIndexPageSuccess(param1:QFAEvent):Void {
		var _loc2_:String = Std.isOfType(param1.data, String) ? cast(param1.data, String) : null;
		if (_loc2_ == null || _loc2_ == "") {
			this._text.text = "加载农场游戏数据失败(-1)";
			this.setSnowslide();
			return;
		}
		this._bootData = JSON.decode(_loc2_);
		if (this._bootData == null) {
			this._text.text = "加载农场游戏数据失败(-2)";
			this.setSnowslide();
			return;
		}
		if (Reflect.hasField(this._bootData, "ecode")) {
			this._text.text = "加载农场游戏数据失败: " + Reflect.field(this._bootData, "direction");
			this.setSnowslide();
			return;
		}
		Cookies.setObject("snowslide", {
			"counter": 0,
			"time": 0
		}, 0, true);
		this._indexTime = Std.int(getTimer() - (this._timeStamp + 200));
		EventRecorder.recordSueecssEvent(EventRecorder.HF_CGI_ENTER, this._indexTime, "mync.php?mod=user&act=run");
		this.checkStart();
	}

	// FarmLite.as:111-116
	private function onFilesLoadFailed(param1:CommandEvent):Void {
		this._text.text = "加载农场游戏数据失败(-6)，请稍后再刷新！";
		this._stepTime1 = Std.int(getTimer() - this._timeStamp);
		EventRecorder.recordErrorEvent(EventRecorder.HF_SWFLOAD, this._stepTime1, -1, "第1步素材加载失败");
	}

	// FarmLite.as:118-125
	private function onIndexPageError(param1:QFAEvent):Void {
		this._text.text = "加载农场游戏数据失败(-3)";
		this._indexTime = Std.int(getTimer() - this._timeStamp);
		var _loc2_:Int = As3.intOf(param1.data);
		EventRecorder.recordErrorEvent(EventRecorder.HF_CGI_ENTER, this._indexTime, _loc2_, "mync.php?mod=user&act=run");
		this.setSnowslide();
	}

	// FarmLite.as:127-152
	private function startLiteUI():Void {
		var loader:CmdLoadFile;
		var timeout:Int = 0;
		// E4X：moduleList 下 module[@name=="main"] 的 material[i].@url / @url
		var materialUrl = function(idx:Int):String {
			for (moduleList in this._mainXML.elements()) {
				if (moduleList.nodeName != "moduleList") {
					continue;
				}
				for (module in moduleList.elements()) {
					if (module.nodeName == "module" && module.get("name") == "main") {
						var materials:Array<Xml> = [for (n in module.elements()) if (n.nodeName == "material") n];
						return materials[idx].get("url");
					}
				}
			}
			return null;
		};
		var mainUrl = function():String {
			for (moduleList in this._mainXML.elements()) {
				if (moduleList.nodeName != "moduleList") {
					continue;
				}
				for (module in moduleList.elements()) {
					if (module.nodeName == "module" && module.get("name") == "main") {
						return module.get("url");
					}
				}
			}
			return null;
		};
		As3.clearTimeout(this._timeoutStep1);
		this._timeoutStep1 = 0;
		removeChild(this._text);
		this._text = null;
		this._liteModel = new FarmLiteModel(this._bootData);
		this._liteUI = new FarmLiteView(this._liteModel);
		addChild(this._liteUI);
		loader = new CmdLoadFile();
		CommandManager.getInstance().run(loader, {
			"addon": this._settings.addonConfigUrl,
			"res1": this._settings.replaceAppImg(materialUrl(0)),
			"res2": this._settings.replaceAppImg(materialUrl(1)),
			"water": this._settings.replaceAppImg(materialUrl(2)),
			"main": this._settings.replaceAppImg(mainUrl())
		}, this.onMainLoaded, this.onMainFailed);
		this._timeStamp = getTimer();
		timeout = 10 * 1000;
		this._timeout = As3.setTimeout(function():Void {
			EventRecorder.recordErrorEvent("160738", timeout, -1, "第二步加载超时");
		}, timeout);
	}

	// FarmLite.as:154-188
	private function onFilesLoadCompleted(param1:CommandEvent):Void {
		var res:Resource;
		var url:String;
		var xml:Xml = null;
		var e:CommandEvent = param1;
		this._stepTime1 = Std.int(getTimer() - this._timeStamp);
		url = this._settings.getStringAttribute("config_url");
		res = ResourceManager.gi().getResource(url);
		if (res != null && res.loaded == true) {
			try {
				xml = Xml.parse(res.data);
			} catch (te:Dynamic) {
				trace("ERROR: invalid XML file:" + te.message);
			}
			if (xml != null) {
				this._mainXML = xml;
			}
		}
		if (this._mainXML == null) {
			this._text.text = "加载农场主配置文件错误(-5)";
			QzoneJSAPI.reportError("加载农场主配置文件错误！", 3);
			return;
		}
		this.checkStart();
	}

	// FarmLite.as:190-195
	private function onMainFailed(param1:CommandEvent):Void {
		QzoneJSAPI.reportError("加载游戏主模块出错(-8)", 1);
		var _loc2_:Float = getTimer() - this._timeStamp;
		EventRecorder.recordErrorEvent(EventRecorder.HF_SWFLOAD, _loc2_, -2, "第2步素材加载失败");
	}

	// FarmLite.as:197-200
	private function uncaughtErrorHandler(param1:Dynamic):Void {
		QzoneJSAPI.reportError(Reflect.field(param1, "error"), 1);
	}

	// FarmLite.as:202-226
	private function onMainLoaded(param1:CommandEvent):Void {
		var _loc4_:Float = Math.NaN;
		As3.clearTimeout(this._timeout);
		this._timeout = 0;
		var _loc2_:Float = getTimer();
		this._stepTime2 = Std.int(_loc2_ - this._timeStamp);
		if (this._stepTime2 < 10 * 1000) {
			EventRecorder.recordSueecssEvent("160738", this._stepTime2, null);
		}
		var _loc3_:Sprite = Std.isOfType(ResourceManager.gi().getClassInstance("module.Main"), Sprite)
			? cast(ResourceManager.gi().getClassInstance("module.Main"), Sprite)
			: null;
		if (_loc3_ == null) {
			QzoneJSAPI.reportError("游戏主模块启动失败(-7)", 1);
			EventRecorder.recordErrorEvent(EventRecorder.HF_SWFLOAD, this._stepTime2, -3, "主模块启动失败");
		} else {
			EventRecorder.recordSueecssEvent(EventRecorder.HF_SWFLOAD, this._stepTime2, "全部加载成功");
			this.startMain(_loc3_);
			_loc4_ = getTimer() - _loc2_;
			this.reportSpeedIndex(_loc4_);
		}
	}

	// FarmLite.as:228-241
	private function addCallback():Void {
		var _loc1_:String = null;
		if (QQOutlets.available == true) {
			_loc1_ = QzoneJSAPI.getAppParams();
			if (_loc1_ != null && _loc1_ != "") {
				CommonData.useExpressUser = true;
				CommonData.expressUser = JSON.decode(_loc1_);
			}
			QzoneJSAPI.flashInit();
		}
	}

	// FarmLite.as:243-260
	private function setSnowslide():Void {
		var _loc1_:Date = Date.now();
		var _loc2_:Dynamic = Cookies.getObject("snowslide");
		if (_loc2_ != null) {
			Reflect.setField(_loc2_, "count", As3.floatOf(Reflect.field(_loc2_, "count")) + 1);
			Reflect.setField(_loc2_, "time", _loc1_.getTime());
		} else {
			_loc2_ = {
				"count": 1,
				"time": _loc1_.getTime()
			};
		}
		Cookies.setObject("snowslide", _loc2_, 0, true);
	}

	// FarmLite.as:262-283
	private function reportSpeedIndex(param1:Float):Void {
		var _loc2_:String = null;
		var _loc3_:URLRequest = null;
		EventRecorder.initStartupSpeed();
		Reflect.setField(EventRecorder.STARTUP_SPEED_INFO, "1", this._stepTime1);
		Reflect.setField(EventRecorder.STARTUP_SPEED_INFO, "2", this._indexTime);
		Reflect.setField(EventRecorder.STARTUP_SPEED_INFO, "4", param1);
		Reflect.setField(EventRecorder.STARTUP_SPEED_INFO, "11", this._stepTime1 + this._stepTime2);
		Reflect.setField(EventRecorder.STARTUP_SPEED_INFO, "12", this._stepTime2);
		if (Std.int(Math.random() * 60) == 0) {
			_loc2_ = Settings.getInstance().getUrlConfigByName("speedReport");
			if (_loc2_ == "") {
				return;
			}
			_loc3_ = new URLRequest(_loc2_);
			_loc3_.data = EventRecorder.STARTUP_SPEED_INFO;
			QQOutlets.sendToURL(_loc3_);
		}
	}

	// FarmLite.as:285-314
	private var startCGIUrl(get, never):String;

	private function get_startCGIUrl():String {
		var _loc3_:String = null;
		var _loc4_:String = null;
		var _loc1_:Settings = Settings.getInstance();
		var _loc2_:String = "";
		if (_loc1_.getStringAttribute("agent") == "weibo") {
			_loc2_ = "mync.php?mod=user&act=run";
		} else {
			_loc3_ = _loc1_.mode;
			if (_loc3_ == "qplus") {
				_loc3_ = "qzone";
			}
			_loc4_ = _loc3_;
			if (_loc4_ == "qzone") {
				_loc4_ = "qzone.qq";
			} else if (_loc4_ == "") {
				_loc4_ = _loc1_.xymode;
			}
			_loc2_ = "" + _loc4_ + "mync.php?mod=user&act=run";
		}
		return QzoneJSAPI.addGToken(_loc2_);
	}

	// FarmLite.as:316-329
	private function snowSlide():Bool {
		var _loc1_:Dynamic = Cookies.getObject("snowslide");
		if (_loc1_ == null) {
			return true;
		}
		var _loc2_:Date = Date.now();
		if (Reflect.field(_loc1_, "count") < 7 || _loc2_.getTime() - Reflect.field(_loc1_, "time") > 10 * 1000) {
			return true;
		}
		return false;
	}

	// FarmLite.as:331-378
	private function boot():Void {
		var mainXMLUrl:String;
		var uiResUrl:String;
		var load_files:CmdLoadFile;
		var timeout:Int = 0;
		if (this.openByFlashVar()) {
			this._text.text = this._settings.getStringAttribute("index_tips");
			return;
		}
		if (this.snowSlide() == false) {
			this._text.text = "尊敬的用户：由于当前网络请求失败次数过多，建议您过一段时间后再试。";
			EventRecorder.recordErrorEvent("160514", 0, 3);
			return;
		}
		As3.setTimeout(function():Void {
			var _loc1_:CmdHttpRequest = new CmdHttpRequest();
			CommandManager.getInstance().run(_loc1_, {
				"url": this.startCGIUrl,
				"method": "post",
				"params": {
					"farmTime": 0,
					"farmKey": "db03aaa4c6ae8e56943f5dda8791e48b",
					"uIdx": "",
					"uinY": ""
				},
				"complete": this.onIndexPageSuccess,
				"error": this.onIndexPageError
			});
		}, 200);
		load_files = new CmdLoadFile();
		mainXMLUrl = this._settings.replaceAppImg(this._settings.getStringAttribute("config_url"));
		uiResUrl = this._settings.replaceAppImg("module/ui/lite_ui_v_0.swf");
		CommandManager.getInstance().run(load_files, {
			"load_main": mainXMLUrl,
			"lite_ui": uiResUrl,
			"config_data": this._settings.dataConfigUrl
		}, this.onFilesLoadCompleted, this.onFilesLoadFailed);
		this._timeStamp = getTimer();
		timeout = 7 * 1000;
		this._timeoutStep1 = As3.setTimeout(function():Void {
			EventRecorder.recordErrorEvent("160738", timeout, -2, "第一步加载超时");
		}, timeout);
	}

	// FarmLite.as:380-387
	private function checkStart():Void {
		if (this._bootData != null && this._mainXML != null) {
			this.startLiteUI();
			return;
		}
	}

	// FarmLite.as:389-402
	private function startMain(param1:Sprite):Void {
		var main:Sprite = param1;
		this._liteUI.destroy();
		this._liteModel.finalize();
		this._liteModel = null;
		addChild(main);
		Reflect.callMethod(main, Reflect.field(main, "startGame"), [this._bootData]);
		As3.setTimeout(function():Void {
			removeChild(this._liteUI);
			this._liteUI = null;
		}, 5000);
	}

	// FarmLite.as:404-446
	private function setup():Void {
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		stage.showDefaultContextMenu = false;
		Security.allowDomain("appbase.qzone.qq.com");
		Security.allowDomain("appbase.xiaoyou.qq.com");
		Security.allowDomain("appbase.xiaoyou.pengyou.com");
		Security.allowDomain("appimg3.qq.com");
		Security.allowDomain("appimg1.qq.com");
		Security.allowDomain("appimg.qq.com");
		Security.allowDomain(this._settings.getStringAttribute("domian_qz") + ".qq.com");
		Security.allowDomain(this._settings.getStringAttribute("domian_xy") + ".qq.com");
		Security.allowDomain(this._settings.getStringAttribute("domian_xy") + ".pengyou.com");
		Security.allowDomain("hydra.qzone.qq.com");
		Security.allowDomain("hydra.t.qq.com");
		Security.allowDomain("hydra.qplus.qq.com");
		Security.allowDomain("hydra.pengyou.com");
		CommonData._root = this;
		CommonData.swfUrl = stage.loaderInfo.url;
		CommonData.applicationDomain = ApplicationDomain.currentDomain;
		CommonData.APP_DOMAIN = CommonData.applicationDomain;
		CommonData.addCallBackProxy = function(param1:String, param2:Dynamic):Void {
			if (param1 == null || param1.length == 0) {
				return;
			}
			if (param2 == null) {
				return;
			}
			if (QQOutlets.available == true) {
				QQOutlets.addCallback(param1, param2);
			}
		};
		As3.setTimeout(this.addCallback, 100);
		// openfl 的 LoaderInfo 没有 uncaughtErrorEvents 字段，恒走不注册分支
		if (Reflect.hasField(loaderInfo, "uncaughtErrorEvents")) {
			Reflect.field(loaderInfo, "uncaughtErrorEvents").addEventListener("uncaughtError", this.uncaughtErrorHandler, false, 0, true);
		}
	}

	// FarmLite.as:448-453。PORT-NOTE: Haxe 的 % 优先级高于 /（AS3 里同级
	// 左结合），`x/1000%10` 会被解析成 x/(1000%10)，必须显式括号
	private function openByFlashVar():Bool {
		var _loc1_:String = Settings.getInstance().getStringAttribute("useflag");
		var _loc2_:Int = As3.intOf((As3.floatOf(_loc1_) / 1000) % 10);
		return !As3.truthy(_loc2_);
	}
}
