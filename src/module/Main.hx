package module;

import com.adobe.crypto.MD5;
import com.greensock.TweenLite;
import com.qzone.corelib.net.RSLLoader;
import com.qzone.corelib.net.RSLManager;
import com.qzone.qfa.data.Resource;
import com.qzone.qfa.debug.DebuggerWindow;
import com.qzone.qfa.events.CommandEvent;
import com.qzone.qfa.managers.ResourceManager;
import com.qzone.qui.controls.scrollClasses.ScrollBar;
import com.qzone.qui.managers.DragManager;
import com.qzone.qui.managers.EffectManager;
import com.qzone.qui.styles.Style;
import com.qzone.qui.utils.FrameTimer;
import com.qzone.utils.RightMenu;
import common.CommonData;
import common.Consts;
import common.GetCropID;
import common.Session;
import common.Settings;
import common.misc.ConfigMerger;
import common.misc.Cookies;
import common.misc.QzoneJSAPI;
import common.misc.Utils;
import common.misc.VersionUtil;
import entities.Friend;
import entities.Player;
import entities.StartupData;
import events.CommonEvent;
import framework.commands.CommandList;
import framework.net.CommandDefs;
import framework.net.NetHelper;
import framework.net.core.RequestChecker;
import framework.net.parsers.StartupDataParser;
import framework.net.vo.ServiceResultVO;
import module.recall.RecallModel;
import openfl.display.Loader;
import openfl.display.MovieClip;
import openfl.display.StageQuality;
import openfl.errors.Error;
import openfl.events.ContextMenuEvent;
import openfl.events.Event;
import openfl.events.TimerEvent;
import openfl.net.URLRequest;
import openfl.net.URLVariables;
import openfl.system.ApplicationDomain;
import openfl.system.LoaderContext;
import openfl.system.Security;
import openfl.system.SecurityDomain;
import openfl.text.Font;
import openfl.utils.Timer;
import report.ClickReportManager;
import report.EventRecorder;
import shim.As3;
import shim.As3.getTimer;
import shim.As3.setTimeout;
import shim.Harness;
import shim.LocalConnection;
import shim.QQOutlets;
import shim.SymbolClass;

// module.Main —— Main.as 逐句对应（main3 文档类：init 建 FarmApplication/
// 合并配置，startGame 解析 FarmLite 传来的 _bootData 后 gameStart →
// theApp.startup）。
//
// PORT-NOTE（本文件的三处平台胶水，均为 shim 注入、不改原调用形态）：
// - 文档类与 main3 根时间轴的绑定：原版由 swf 的 SymbolClass[0] 完成，
//   openfl 里用 SymbolClass.bindRoot 等价挂上（V2 stub 先例，保留）；
//   Harness.markMainFirstFrame 是冒烟约定的 ready 注入点（保留，见
//   shim/Harness.hx）。
// - flash.external.ExternalInterface：QQOutlets（available=false、call 返回
//   null），宿主不可用分支自然走到（connectJS/doMiscThings 与原版 EI 不可用
//   时同路径）。
// - flash.net.LocalConnection：shim/LocalConnection（gc 的 Flash Player 强制
//   GC hack 在 openfl 上无等价通道，空操作）。
//
// [SWF(width="500", height="375", backgroundColor="#869ca7", frameRate="24")]
// （Main.as:56 的 swf 元数据，由 main3_v_221.swf 本体携带，非代码）
//
// PORT-NOTE（extends MovieClip，非原版 Sprite）：Flash 里文档类实例天然就是
// swf 根时间轴的载体（SymbolClass[0] 绑定），类声明写 Sprite 也带帧；openfl
// 里只有 MovieClip 能挂时间轴，故按 V2 stub 先例 extends MovieClip 并在构造
// 器 SymbolClass.bindRoot 挂根（deviations 候选）。原版 Main 未用 Sprite 特有
// 行为，语义不变。
@:keep
class Main extends MovieClip {
	// Main.as:60
	public static var theApp:FarmApplication = null;

	// Main.as:62（EMBED_FONT_A:Class = Main_EMBED_FONT_A，setup 里注册字体）
	private static var EMBED_FONT_A:Class<Dynamic> = Main_EMBED_FONT_A;

	// Main.as:64
	private var _wildShell:Dynamic;

	// Main.as:66
	private var _beastapi:framework.api.beast.BeastAPI;

	// Main.as:68-74（bindRoot/markMainFirstFrame 为 shim 注入，见类头）
	public function new() {
		super();
		SymbolClass.bindRoot(this, "main3_v_221");
		Harness.markMainFirstFrame(this);
		var _loc1_:DebuggerWindow = new DebuggerWindow();
		addChild(_loc1_);
		addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage, false, 0, true);
	}

	// Main.as:76-84。`new Loader()` → LocalSwfLoader（CLAUDE.md 加载映射：
	// 资产已本地化，remote swf 走 Assets 库；调用形态保持 loader.load(req, ctx)
	// 原样）。beastLoaderUrl 是绝对 URL，裸 Loader 在 html5 下发真实请求 →
	// web-smoke 404（WildShellNc_v_5 已入库，走 libraryIdForUrl 映射取库）
	private function loadWildShell():Void {
		var _loc1_:Loader = new shim.LocalSwfLoader();
		var _loc2_:LoaderContext = new LoaderContext();
		_loc2_.applicationDomain = CommonData.applicationDomain;
		_loc1_.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onWildComplete);
		var _loc3_:String = Utils.addPrefix(Settings.getInstance().getStringAttribute("beastLoaderUrl"));
		_loc1_.load(new URLRequest(_loc3_), _loc2_);
	}

	// Main.as:86-95。`new _loc2_()` → Type.createInstance（getDefinitionByName
	// 类引用实例化的 Haxe 等价，FarmStage 同款）。
	private function onWildComplete(param1:Event):Void {
		var _loc2_:Class<Dynamic> = Utils.getClass("wild.com.Shell.WildShell");
		if (_loc2_ != null) {
			this._wildShell = Type.createInstance(_loc2_, []);
			this._wildShell.initConfig(this._beastapi);
			theApp.wildShell = this._wildShell;
		}
	}

	// Main.as:97-112。PORT-NOTE: openfl 没有 flash.ui.ContextMenuItem 类
	//（RightMenu stub 也不建菜单项，本回调不可达）；`ContextMenuItem(target).caption`
	// 按动态字段写保留原结构。
	private function onToggleQaulity(param1:ContextMenuEvent):Void {
		if (this.stage != null) {
			if (this.stage.quality == "LOW") {
				this.stage.quality = StageQuality.HIGH;
				var item:Dynamic = param1.target;
				item.caption = "高速模式(&Q)";
			} else {
				this.stage.quality = StageQuality.LOW;
				var item2:Dynamic = param1.target;
				item2.caption = "正常模式(&Q)";
			}
		}
	}

	// Main.as:114-143
	private function setup():Void {
		var _loc2_:URLVariables = null;
		Font.registerFont(EMBED_FONT_A);
		Style.getButtonFormat().color = 16777215;
		Style.getButtonOverFormat().color = 16777215;
		Style.getDisabledFormat().color = 16777215;
		Style.color = 3355443;
		Style.getLabelFormat().color = 30148;
		DragManager.updateAfterEvent = true;
		EffectManager.tweenerClass = TweenLite;
		ScrollBar.updateAfterEvent = true;
		RightMenu.addMenuItem(this, "高速模式(&Q)", this.onToggleQaulity, true);
		FrameTimer.init(this);
		var _loc1_:Timer = new Timer(120000);
		_loc1_.addEventListener(TimerEvent.TIMER, this.gc);
		_loc1_.start();
		setTimeout(this.connectJS, 200);
		if (this.stage != null && this.stage.stageWidth > 960) {
			if (Std.int(Math.random() * EventRecorder.successRecordProbability) == 0) {
				_loc2_ = new URLVariables();
				Reflect.setField(_loc2_, "flag1", 160451);
				Reflect.setField(_loc2_, "flag2", 0);
				Reflect.setField(_loc2_, "1", EventRecorder.successRecordProbability);
				EventRecorder.record(_loc2_);
			}
		}
	}

	// Main.as:145-149
	private function onAddedToStage(param1:Event):Void {
		removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
		this.init();
	}

	// Main.as:151-158（ExternalInterface → QQOutlets，见类头）
	private function onSessionTimeout(param1:CommonEvent):Void {
		theApp.processNetException();
		if (QQOutlets.available == true) {
			QzoneJSAPI.showLoginBox();
		}
	}

	// Main.as:160-171（LocalConnection → shim，见类头）
	private function gc(param1:TimerEvent):Void {
		var e:TimerEvent = param1;
		try {
			new LocalConnection().connect("MoonSpirit");
			new LocalConnection().connect("MoonSpirit");
		} catch (error:Error) {}
	}

	// Main.as:173-191
	private function loadAsyncWildModule(param1:Dynamic):Void {
		framework.api.beast.BeastAPI.app = theApp;
		if (this._beastapi == null) {
			this._beastapi = framework.api.beast.BeastAPI.getInstance();
			this._beastapi.beastConfigUrl = Settings.getInstance().wildCfgUrl;
			theApp.beastAPI = this._beastapi;
		}
		this._beastapi.registerEventListeners();
		if (param1 != null) {
			this._beastapi.beastBase = param1;
		}
		if (this._wildShell == null) {
			this.loadWildShell();
		}
	}

	// Main.as:193-234
	private function init():Void {
		var addonRes:Resource = null;
		var dataRes:Resource = null;
		var merger:ConfigMerger = null;
		var addon:Xml = null;
		var st:Settings = Settings.getInstance();
		Security.allowDomain("imgcache.qq.com");
		Security.allowDomain("acfs.tencent.com");
		Security.allowDomain("*");
		CommonData.getKey = function():String {
			var _loc1_:String = "OPdfqwn^&*w(281flebnd1##roplaq";
			var _loc2_:String = Std.string(CommonData.serverTime);
			var _loc3_:Int = Std.parseInt(_loc2_.substr(_loc2_.length - 1));
			var _loc4_:String = _loc1_.substr(_loc3_);
			return MD5.hash(_loc2_ + _loc4_);
		};
		CommonData.rslLoader = new RSLLoader();
		CommonData.rslLoader.applicationDomain = ApplicationDomain.currentDomain;
		CommonData.rslLoader.securityDomain = SecurityDomain.currentDomain;
		CommonData.rslManager = RSLManager.getInstance();
		CommonData.rslManager.rslLoader = CommonData.rslLoader;
		RSLManager.applicationDomain = CommonData.applicationDomain;
		theApp = new FarmApplication("qq farm", this);
		Session.getInstance().app = theApp;
		NetHelper.theApp = theApp;
		GetCropID.theApp = theApp;
		theApp.addEventListener(Consts.MSG_SESSION_TIMEOUT, this.onSessionTimeout);
		theApp.addEventListener(Consts.MSG_NEED_VALIDATE_CODE, this.onNeedInputIDCode);
		VersionUtil.setRightMenu(this);
		Session.getInstance().m_buildVersion = VersionUtil.versionString;
		EventRecorder.initStartupSpeed();
		RequestChecker.initialize();
		st.setConfigDataModel(theApp.model);
		dataRes = ResourceManager.gi().getResource(st.dataConfigUrl);
		addonRes = ResourceManager.gi().getResource(st.addonConfigUrl);
		merger = new ConfigMerger(theApp, dataRes.data);
		addon = Utils.loadXMLData(addonRes.data);
		merger.mergeConfig(addon);
		st.loadFromAddon(addon);
	}

	// Main.as:236-242
	private function onValidateConfirmed(param1:String):Void {
		if (param1 != "") {
			NetHelper.reSendRequest({"validatemsg": param1});
		}
	}

	// Main.as:244-288（WB 档走 CGI 补头像昵称；EI 不可用时只派发
	// MSG_SET_QQBROWSER_ALARM——QQOutlets.available=false 与原版 EI 不可用同路）
	private function connectJS():Void {
		var p:Player = null;
		var req:Dynamic = null;
		var mode:String = null;
		p = Session.getInstance().host;
		if (QzoneJSAPI.WB == true) {
			req = Utils.buildRequest(CommandDefs.CMD_WB_PROFILE, {"uids": p._uId});
			theApp.run(CommandList.SERVICE_REQUEST, req, "", null, function(param1:CommandEvent):Void {
				if (param1 == null) {
					return;
				}
				var _loc2_:ServiceResultVO = cast param1.result;
				if (_loc2_ == null) {
					return;
				}
				var _loc3_:Dynamic = Reflect.field(_loc2_.m_extra, "data");
				var _loc4_:Player = Session.getInstance().host;
				// PORT-NOTE: `_loc3_[p._uId] != undefined`（键存在性）→
				// Reflect.hasField（Haxe 无 undefined；数字键按对象键的字符串
				// 形式查）
				if (_loc3_ != null && Reflect.hasField(_loc3_, Std.string(p._uId))) {
					_loc4_._headPic = Reflect.field(Reflect.field(_loc3_, Std.string(p._uId)), "img");
					_loc4_._userName = Reflect.field(Reflect.field(_loc3_, Std.string(p._uId)), "nick");
					theApp.dispatchEvent(new CommonEvent(Consts.MSG_HOST_CHANGED, _loc4_));
				}
			}, null);
		} else if (QQOutlets.available == true) {
			mode = Settings.getInstance().mode;
			if (mode == "qzone" || mode == "qplus") {
				p._headPic = QzoneJSAPI.getHead(Std.string(p.uin), 50);
			}
			if (p._userName == null || p._userName == "") {
				p._userName = QzoneJSAPI.getNickname();
			}
			theApp.dispatchEvent(new CommonEvent(Consts.MSG_HOST_CHANGED, p));
		}
		theApp.dispatchEvent(new CommonEvent(Consts.MSG_SET_QQBROWSER_ALARM, null));
	}

	// Main.as:290-298
	private function gameStart():Void {
		Security.loadPolicyFile("");
		Security.loadPolicyFile("");
		Security.loadPolicyFile("");
		Security.loadPolicyFile("");
		this.setup();
		theApp.startup();
	}

	// Main.as:300-306
	private function onLoadDataError(param1:CommandEvent):Void {
		theApp.openFloat(Consts.FLOAT_TYPE_TEXTTIP, 0, {
			"text": "系统繁忙",
			"parent": this.stage
		});
	}

	// Main.as:308-356（FarmLite.startMain 动态调用的入口）
	public function startGame(param1:Dynamic):Void {
		var _loc7_:Friend = null;
		if (param1 == null) {
			return;
		}
		var _loc2_:StartupDataParser = new StartupDataParser();
		var _loc3_:ServiceResultVO = _loc2_.parse(param1);
		var _loc4_:StartupData = cast _loc3_.m_extra;
		if (_loc4_ == null || _loc4_._user == null) {
			QzoneJSAPI.reportError("游戏基础数据读取失败", 1);
			return;
		}
		if (_loc4_._serverTime != 0) {
			CommonData.serverTime = _loc4_._serverTime;
		}
		var _loc5_:Session = Session.getInstance();
		_loc5_.host = _loc4_._user;
		_loc5_.currentUser = _loc5_.host;
		_loc5_.dog = _loc4_._dog;
		_loc5_.m_isDogHungry = _loc4_._dog._isHungry > 0;
		_loc5_.m_welcomeMode = _loc4_._welcome;
		_loc5_.upGoldLandTime = _loc4_.upGoldLandTime;
		RecallModel.uin = _loc3_.m_extra._user._uinLogin;
		var _loc6_:Dynamic = _loc4_._decors;
		if (_loc6_ != null) {
			if (_loc4_._dog != null) {
				Reflect.setField(_loc6_, Std.string(Consts.DECOR_DOG), {"itemId": _loc4_._dog._dogId});
			}
			_loc5_.sceneDecorates = _loc6_;
			theApp.model.setData(Consts.MY_FAIRY_OBJECT, Reflect.field(_loc6_, Consts.ITEM_TYPE_FAIRY));
		}
		this.gameStart();
		if (CommonData.useExpressUser == true) {
			_loc7_ = new Friend(CommonData.expressUser);
			theApp.dispatchEvent(new CommonEvent(Consts.MSG_SWITCH_USER, _loc7_));
			CommonData.useExpressUser = false;
			return;
		}
		theApp.dispatchEvent(new CommonEvent(Consts.MSG_STARTUP_DATA, _loc4_));
		this.loadAsyncWildModule(_loc4_._beast);
		this.doMiscThings();
	}

	// Main.as:358-412。PORT-NOTE: `Boolean(str.match(s))` → EReg.match（模式串
	// 无元字符，子串命中语义一致）；`ExternalInterface.call(...)` → QQOutlets.call
	//（返回 null → 原版 EI 不可用同样在此早退）。
	private function doMiscThings():Void {
		var _loc3_:Dynamic = null;
		var _loc1_:Settings = Settings.getInstance();
		var _loc2_:String = QQOutlets.call("top.window.location.href.toString");
		if (_loc2_ == null) {
			return;
		}
		if (_loc1_.mode == "qzone") {
			if (new EReg("actiontype=freegift", "").match(_loc2_) || new EReg("actiontype%3Dfreegift", "").match(_loc2_)) {
				theApp.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_FREEGIFT, {"openIndex": 1}));
				theApp.dispatchEvent(new CommonEvent(Consts.CLOSE_RECALL_WINDOW, null));
			} else if (new EReg("jumptoexchange=1005", "").match(_loc2_) || new EReg("jumptoexchange%3D1005", "").match(_loc2_)) {
				Session.getInstance().isFromMail = true;
				ClickReportManager.reportClick("share.mailBackflow.come_from_mai_getBtn_nc_qzone");
			} else if (_loc2_.indexOf("via=QZONE.QQMAIL2") != -1 || _loc2_.indexOf("via%3DQZONE.QQMAIL2") != -1) {
				ClickReportManager.reportClick("share.mailBackflow.come_from_mail_nc_qzone");
			}
		}
		if (_loc2_.indexOf("%26from%3DlevelUpShare") != -1) {
			ClickReportManager.reportClick("share.levelUp.come_from_level_up_share_link_nc");
		} else if (_loc2_.indexOf("%26from%3DmailPresentShare") != -1) {
			ClickReportManager.reportClick("share.mailBackflow.come_from_mail_present_share_link_nc");
		}
		if (As3.truthy(_loc1_.openZhaoHui()) && QzoneJSAPI.QPLUS == false && QzoneJSAPI.WB == false) {
			if (new EReg("actiontype=request", "").match(_loc2_) || new EReg("actiontype%3Drequest", "").match(_loc2_)) {
				if (_loc1_.getStringAttribute("app_request_num") != "0") {
					RecallModel.m_backNum = Std.parseInt(_loc1_.getStringAttribute("app_request_num"));
					theApp.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_RECALL, null));
				} else if (_loc1_.mode == "qzone") {
					_loc3_ = {
						"owner": Session.getInstance().host.fid,
						"appids": Consts.APP_ID,
						"cb": 0
					};
					NetHelper.sendRequest(CommandDefs.CMD_REQUEST_COUNT, _loc3_, this.onGetRequestCount, this.onLoadDataError);
				}
			}
		}
	}

	// Main.as:414-418
	private function onNeedInputIDCode(param1:CommonEvent):Void {
		theApp.processNetException();
		theApp.openWindowByName(Consts.WINDOW_NAME_VALIDATE, {"callback": this.onValidateConfirmed});
	}

	// Main.as:420-467
	private function onGetRequestCount(param1:CommandEvent):Void {
		if (Reflect.field(param1.result, "m_extra") == null) {
			theApp.openFloat(Consts.FLOAT_TYPE_TEXTTIP, 0, {
				"text": "系统繁忙",
				"parent": this.stage
			});
			return;
		}
		if (Reflect.field(Reflect.field(param1.result, "m_extra"), "ret") == null) {
			return;
		}
		if (Reflect.field(Reflect.field(param1.result, "m_extra"), "ret") < 0) {
			theApp.openFloat(Consts.FLOAT_TYPE_TEXTTIP, 0, {
				"text": Reflect.field(Reflect.field(param1.result, "m_extra"), "msg"),
				"parent": this.stage
			});
			return;
		}
		if (Reflect.field(Reflect.field(param1.result, "m_extra"), "requests") != null) {
			if (Reflect.field(Reflect.field(param1.result, "m_extra"), "requests").length != 0) {
				RecallModel.m_backNum = Std.int(Reflect.field(Reflect.field(param1.result, "m_extra"), "requests").length);
				Cookies.setObject("getZhaohui", {"time": CommonData.serverTime});
				theApp.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_RECALL, null));
			}
		} else if (Reflect.field(Reflect.field(param1.result, "m_extra"), "countlist") != null) {
			if (Reflect.field(Reflect.field(param1.result, "m_extra"), "countlist").length != 0) {
				if (Reflect.field(Reflect.field(Reflect.field(param1.result, "m_extra"), "countlist")[0], "unread_num") == null) {
					return;
				}
				if (Reflect.field(Reflect.field(Reflect.field(param1.result, "m_extra"), "countlist")[0], "unread_num") != 0) {
					RecallModel.m_backNum = Std.int(Reflect.field(Reflect.field(Reflect.field(param1.result, "m_extra"), "countlist")[0], "unread_num"));
					Cookies.setObject("getZhaohui", {"time": CommonData.serverTime});
					theApp.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_RECALL, null));
				}
			}
		}
	}
}
