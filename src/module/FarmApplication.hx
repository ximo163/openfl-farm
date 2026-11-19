package module;

import com.adobe.serialization.json.JSON;
import app4.activities.common.ActivityController;
import app4.activities.common.FarmAdvertisementAPI;
import app4.activities.common.FarmAppHelper;
import com.qzone.allianceActivity.advertisement.ADManager;
import com.qzone.qfa.control.Application;
import com.qzone.qfa.data.Resource;
import com.qzone.qfa.debug.Debugger;
import com.qzone.qfa.events.CommandEvent;
import com.qzone.qfa.managers.ResourceManager;
import com.qzone.qfa.view.AppStage;
import com.qzone.sns.QQPay;
import com.qzone.utils.NumberUtil;
import common.CommonData;
import common.Consts;
import common.Language;
import common.Session;
import common.Settings;
import common.misc.QzoneJSAPI;
import common.misc.Utils;
import common.misc.time.GameTime;
import common.view.window.BaseWindow;
import common.view.window.UpgradeBlackWindow;
import entities.Friend;
import entities.Player;
import entities.StartupData;
import events.CommonEvent;
import framework.api.FarmAPI;
import framework.api.PluginManager;
import framework.api.beast.BeastAPI;
import framework.base.BaseLayer;
import framework.base.Module;
import framework.commands.CommandList;
import framework.net.CommandDefs;
import framework.net.NetHelper;
import framework.net.protocol.Protocol;
import interfaces.IModule;
import interfaces.IMsgCenter;
import module.freegift.ModuleFreeGift; // PORT-NOTE: 原版包 module.FreeGift 大写段 Haxe 解析不了，见 ModuleFreeGift.hx
import module.cardsgame.ModuleCardsGame;
import module.decorate.ModuleDecorate;
import module.friend.ModuleFriends;
import module.levelup.LevelUpModule;
import module.mainScene.ModuleMainScene;
import module.messages.ModuleMessages;
import module.quickshoot.ModuleQuickShoot;
import module.recall.ModuleRecall;
import module.shop.ModuleShop;
import module.task.ModuleTask;
import module.uitools.ModuleUITools;
import module.warehouse.ModuleWarehouse;
import module.water.ModuleWater;
import openfl.display.DisplayObjectContainer;
import openfl.display.Loader;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.TimerEvent;
import openfl.net.URLRequest;
import openfl.system.LoaderContext;
import openfl.utils.Timer;
import report.EventRecorder;
import report.UserActionRecorder;
import shim.As3;
import shim.As3.getTimer;

// module.FarmApplication —— FarmApplication.as 逐句对应（应用本体：自有
// m_dispatcher 转发事件、startup 建 FarmStage/13 个模块、reloadGameData/
// switchUser 换档拉数据、红/黑/金土地升级命令流）。
// PORT-NOTE: AS3 里 FarmApplication 覆写的是 EventDispatcher 的
// add/remove/dispatchEvent（Application 继承链）；Haxe 侧 Application 不继承
// EventDispatcher（见 Application.hx），这三个方法在这里是 IMsgCenter 的
// 普通实现，转发语义（自己的 m_dispatcher）与原版一致。
class FarmApplication extends Application implements IMsgCenter {
	// FarmApplication.as:71
	public var wildShell:Dynamic;

	// FarmApplication.as:73
	private var m_mainLoop:Timer;

	// FarmApplication.as:75
	private var m_requestStartTime:Int;

	// FarmApplication.as:77
	private var _redUpResultCache:Dynamic;

	// FarmApplication.as:79
	private var m_backToHost:Bool;

	// FarmApplication.as:81
	private var _blackUpResultCache:Dynamic;

	// FarmApplication.as:83
	private var m_modules:Array<Dynamic>;

	// FarmApplication.as:85
	private var m_switchUser:Friend;

	// FarmApplication.as:87
	private var m_dispatcher:EventDispatcher;

	// FarmApplication.as:89
	public var beastAPI:BeastAPI;

	// FarmApplication.as:91
	private var m_idleRun:Int;

	// FarmApplication.as:93
	private var _blackUpShareWin:UpgradeBlackWindow;

	// FarmApplication.as:95
	private var m_farmAPI:FarmAPI;

	// FarmApplication.as:97
	private var m_gameTime:GameTime;

	// FarmApplication.as:99
	private var m_requestUpgradeRed:Bool;

	// FarmApplication.as:101-114
	public function new(param1:String = "", param2:DisplayObjectContainer = null) {
		super(param1, param2);
		this.m_dispatcher = new EventDispatcher();
		this.m_modules = null;
		this.m_mainLoop = null;
		// PORT-NOTE: AS3 向 int 赋值截断 → Std.int。
		this.m_idleRun = Std.int(1 * 100 / Consts.MAIN_TIMER_FREQ);
		this.m_gameTime = null;
		this.m_requestStartTime = 0;
		this.m_requestUpgradeRed = false;
		this.m_switchUser = null;
		this.m_backToHost = false;
		this._blackUpShareWin = null;
	}

	// FarmApplication.as:116-133
	private function onMainLoop(param1:TimerEvent):Void {
		var _loc3_:IModule = null;
		if (this.m_idleRun > 0) {
			--this.m_idleRun;
			return;
		}
		var _loc2_:Float = this.m_gameTime.timeElapsed();
		if (NumberUtil.isZero(_loc2_)) {
			return;
		}
		for (_loc3_ in (this.m_modules:Array<Dynamic>)) {
			_loc3_.onGameLoop(_loc2_);
		}
	}

	// FarmApplication.as:135-146
	public function getModuleByName(param1:String):IModule {
		var _loc2_:Module = null;
		for (_loc2_ in (this.m_modules:Array<Dynamic>)) {
			if (_loc2_.name == param1) {
				return _loc2_;
			}
		}
		return null;
	}

	// FarmApplication.as:148-157
	private function hookFarmStage():Void {
		var _loc1_:AppStage = this.view;
		if (_loc1_ != null) {
			_loc1_.destory();
			_loc1_ = null;
		}
		this.view = new FarmStage(this);
	}

	// FarmApplication.as:159-169
	public function closeWindow(param1:BaseWindow):Void {
		if (param1 == null) {
			return;
		}
		if (this.farmView != null && this.farmView.winCtrl != null) {
			this.farmView.winCtrl.close(param1);
		}
	}

	// FarmApplication.as:171-177
	public function useSystemCursor(param1:Bool):Void {
		if (this.farmView != null && this.farmView.cursorCtrl != null) {
			this.farmView.cursorCtrl.useSystem(param1);
		}
	}

	// FarmApplication.as:179-190
	public function setExpressUser(param1:Dynamic, param2:Int):Void {
		if (As3.eqString(Reflect.field(param1, "uId"), Session.getInstance().hostId)) {
			QzoneJSAPI.toApp(358, "");
		} else {
			QzoneJSAPI.toApp(358, JSON.encode(param1));
		}
		EventRecorder.recordErrorEvent(EventRecorder.HF_ENTERMUCHANG, 1, 60 + param2);
	}

	// FarmApplication.as:192-205
	private function onFirstShowProfile(param1:CommonEvent):Void {
		if (param1 == null || param1.target == null) {
			return;
		}
		param1.target.removeEventListener(Consts.MSG_SHOW_PROFILE, this.onFirstShowProfile);
		var _loc2_:IModule = this.getModuleByName(Consts.MODULE_MESSAGES);
		if (_loc2_ != null && _loc2_.loaded == false) {
			_loc2_.load(null);
			this.dispatchEvent(new CommonEvent(param1.type, param1.data));
		}
	}

	// FarmApplication.as:207-216
	private function onEnterPasture(param1:CommonEvent):Void {
		var _loc2_:Int = cast param1.data;
		var _loc4_:Player = Session.getInstance().host;
		if (_loc4_._pf > 0) {
			this.setExpressUser(_loc4_.exportObject(), _loc2_);
		}
	}

	// FarmApplication.as:218-249
	public function switchUser(param1:Friend):Void {
		var _loc2_:Session = Session.getInstance();
		if (_loc2_.harvestAnimationPlaying == true) {
			return;
		}
		if (param1 == null || param1.me == true) {
			if (_loc2_.me == false) {
				this.farmView.cursorCtrl.setCursor(Consts.CURSOR_STYLE_ARROW);
				this.useSystemCursor(true);
			}
			Protocol._userUin = "";
			this.m_switchUser = null;
			this.m_backToHost = true;
			this.reloadGameData("0");
		} else {
			if (!Session.getInstance().isInWildStage) {
				this.farmView.cursorCtrl.setCursor(Consts.CURSOR_STYLE_ARROW);
				this.useSystemCursor(true);
			}
			Protocol._userUin = Std.string(param1._uin);
			this.m_switchUser = param1;
			this.m_backToHost = false;
			this.reloadGameData(Std.string(param1._uId));
		}
	}

	// FarmApplication.as:251-266
	private function onUpgradeLandError(param1:CommandEvent):Void {
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		this.openWindowByName(Consts.WINDOW_NAME_ALERT, {
			"type": Consts.ALERT_TYPE_ERROR,
			"text": Reflect.field(_loc2_, "direction")
		});
		if (Reflect.field(param1.body, "cmdID") == CommandDefs.CMD_BUY_PRECHECK) {
			this._blackUpResultCache = null;
		}
	}

	// FarmApplication.as:268-276
	private function onWildComplete(param1:Event):Void {
		var _loc2_:Class<Dynamic> = Utils.getClass("wild.com.Shell.WildShell");
		if (_loc2_ != null) {
			this.wildShell = Type.createInstance(_loc2_, []);
			this.wildShell.initConfig(this.beastAPI);
		}
	}

	// FarmApplication.as:278-333
	private function upgradeLand(param1:Int, param2:Int, param3:Int = -1, param4:Bool = false):Void {
		var _loc5_:Dynamic = null;
		if (param1 == 0) {
			if (param2 == 0) {
				_loc5_ = Utils.buildRequest(CommandDefs.CMD_UPGRADE_RED, {"confirm": 1});
			} else {
				this._redUpResultCache = null;
				_loc5_ = Utils.buildRequest(CommandDefs.CMD_BUY_PRECHECK, {
					"shopType": Consts.ITEM_TYPE_RED_UPGRADE,
					"itemType": Consts.ITEM_TYPE_RED_UPGRADE,
					"itemId": param3,
					"itemNum": 1
				});
			}
			run(CommandList.SERVICE_REQUEST, _loc5_, "", null, this.onUpgradeLandSuccess, this.onUpgradeLandError);
		} else if (param1 == 1) {
			if (param4 == false || param2 == 1) {
				if (param2 == 0) {
					_loc5_ = Utils.buildRequest(CommandDefs.CMD_UPGRADE_BLACK, {"op": 1});
				} else {
					this._blackUpResultCache = null;
					_loc5_ = Utils.buildRequest(CommandDefs.CMD_BUY_PRECHECK, {
						"shopType": Consts.ITEM_TYPE_BLACK_UPGRADE,
						"itemType": Consts.ITEM_TYPE_BLACK_UPGRADE,
						"itemId": param3,
						"itemNum": 1
					});
				}
				run(CommandList.SERVICE_REQUEST, _loc5_, "", null, this.onUpgradeLandSuccess, this.onUpgradeLandError);
			} else {
				this.openWindowByName(Consts.WINDOW_NAME_CONFIRM, {
					"text": "黑土地升级进入冷却期，花费的金币价格翻倍，您确定还要升级么？",
					"title": "升级黑土地",
					"confirmFn": this.upgradeBlackInCD
				});
			}
		} else if (param1 == 2) {
			_loc5_ = Utils.buildRequest(CommandDefs.CMD_UP_GOLD_LAND, {"op": 1});
			run(CommandList.SERVICE_REQUEST, _loc5_, "", null, this.onUpgradeLandSuccess, this.onUpgradeLandError);
		}
	}

	// FarmApplication.as:335-339
	private function upgradeBlackInCD():Void {
		var _loc1_:Dynamic = Utils.buildRequest(CommandDefs.CMD_UPGRADE_BLACK, {"op": 1});
		run(CommandList.SERVICE_REQUEST, _loc1_, "", null, this.onUpgradeLandSuccess, this.onUpgradeLandError);
	}

	// FarmApplication.as:341-351
	public function closeWindowByName(param1:String):Void {
		if (param1 == null || param1 == "") {
			return;
		}
		if (this.farmView != null && this.farmView.winCtrl != null) {
			this.farmView.winCtrl.closeForName(param1);
		}
	}

	// FarmApplication.as:353-363
	public function openFloat(param1:String, param2:Int = 0, param3:Dynamic = null):Void {
		if (param1 == null || param1.length == 0) {
			return;
		}
		if (this.farmView != null && this.farmView.floatCtrl != null) {
			this.farmView.floatCtrl.open(param1, 0, param3);
		}
	}

	// FarmApplication.as:365-372
	private function onReloadGameData(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		this.reloadGameData(Reflect.field(param1.data, "ownerId"));
	}

	// FarmApplication.as:374-449
	private function onUpgradeLandSuccess(param1:CommandEvent):Void {
		var _loc3_:Dynamic = null;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		if (Reflect.field(_loc2_, "code") == 1) {
			if (Reflect.field(param1.body, "cmdID") == CommandDefs.CMD_BUY_PRECHECK) {
				_loc3_ = null;
				if (Reflect.field(Reflect.field(param1.body, "__body"), "shopType") == Consts.ITEM_TYPE_RED_UPGRADE) {
					this._redUpResultCache = _loc2_;
					_loc3_ = Utils.buildRequest(CommandDefs.CMD_BUY_INGAME_BUY, {
						"itemId": Reflect.field(Reflect.field(param1.body, "__body"), "itemId"),
						"itemNum": 1,
						"itemType": Consts.ITEM_TYPE_RED_UPGRADE,
						"payType": Consts.PAY_QD,
						"shopType": Consts.ITEM_TYPE_RED_UPGRADE
					});
					run(CommandList.SERVICE_REQUEST, _loc3_, "", null, this.onRedUpgradeInGame, this.onRedUpgradeInGame);
				} else {
					this._blackUpResultCache = _loc2_;
					_loc3_ = Utils.buildRequest(CommandDefs.CMD_BUY_INGAME_BUY, {
						"itemId": Reflect.field(Reflect.field(param1.body, "__body"), "itemId"),
						"itemNum": 1,
						"itemType": Consts.ITEM_TYPE_BLACK_UPGRADE,
						"payType": Consts.PAY_QD,
						"shopType": Consts.ITEM_TYPE_BLACK_UPGRADE
					});
					run(CommandList.SERVICE_REQUEST, _loc3_, "", null, this.onBlackUpgradeInGame, this.onBlackUpgradeInGame);
				}
			} else if (Reflect.field(param1.body, "cmdID") == CommandDefs.CMD_UP_GOLD_LAND) {
				--Session.getInstance().upGoldLandTime;
				Reflect.setField(_loc2_, "gold", true);
				this.dispatchEvent(new CommonEvent(Consts.MSG_PLAY_UPGRADE_RED_LAND, _loc2_));
				this.dispatchEvent(new CommonEvent(Consts.GOLD_LAND_UPDATE_TIME_CHANGE, Session.getInstance().upGoldLandTime));
			} else {
				Session.getInstance().updateHostAccount(Reflect.field(_loc2_, "money"), 0, 0);
				if (Reflect.field(param1.body, "cmdID") == CommandDefs.CMD_UPGRADE_RED) {
					Reflect.setField(_loc2_, "red", true);
				}
				if (Reflect.field(param1.body, "cmdID") == CommandDefs.CMD_UPGRADE_BLACK) {
					this.showBlackUpgradeShare(_loc2_);
				}
				this.dispatchEvent(new CommonEvent(Consts.MSG_PLAY_UPGRADE_RED_LAND, _loc2_));
			}
		} else if (Reflect.field(_loc2_, "code") == -30341 || Reflect.field(_loc2_, "ecode") == -30341) {
			if (Reflect.field(param1.body, "cmdID") == CommandDefs.CMD_UPGRADE_BLACK) {
				Reflect.setField(_loc2_, "black", true);
				Reflect.setField(_loc2_, "error", "不是空地，无法升级为黑土地");
				this.dispatchEvent(new CommonEvent(Consts.MSG_PLAY_UPGRADE_RED_LAND, _loc2_));
			}
		} else {
			this.openWindowByName(Consts.WINDOW_NAME_ALERT, {
				"type": Consts.ALERT_TYPE_ERROR,
				"text": Reflect.field(_loc2_, "direction")
			});
		}
	}

	// FarmApplication.as:451-459（IMsgCenter：自有 m_dispatcher 转发）
	public function dispatchEvent(param1:Event):Void {
		if (this.m_dispatcher != null) {
			this.m_dispatcher.dispatchEvent(param1);
			return;
		}
		throw new Error("Application not initialize");
	}

	// FarmApplication.as:461-474
	public function processNetException():Void {
		var _loc1_:Module = null;
		this.dispatchEvent(new CommonEvent(Consts.MSG_USER_SWITCH_FLAG, {"showLoading": false}));
		this.startMainLoop();
		if (this.m_requestUpgradeRed == true) {
			this.m_requestUpgradeRed = false;
		}
		for (_loc1_ in (this.m_modules:Array<Dynamic>)) {
			_loc1_.onNetRequestStopped();
		}
	}

	// FarmApplication.as:476-491
	private function onCheckRequestError(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Dynamic = param1.data;
		if (Reflect.field(_loc2_, "cmdID") == CommandDefs.CMD_RELOAD_GAME_DATA) {
			this.dispatchEvent(new CommonEvent(Consts.MSG_USER_SWITCH_FLAG, {"showLoading": false}));
			this.startMainLoop();
			this.m_switchUser = null;
			this.m_backToHost = false;
		}
		this.openWindowByName(Consts.WINDOW_NAME_REQUEST_ERROR, {"url": Reflect.field(_loc2_, "url")});
	}

	// FarmApplication.as:493-518
	private function onShowUpgradeRedWindow(param1:Event):Void {
		var _loc4_:Bool = false;
		var _loc2_:ModuleMainScene = cast this.getModuleByName(Consts.MODULE_MAINSCENE);
		if (_loc2_ != null) {
			_loc4_ = _loc2_.isAllBlack;
			if (_loc4_ == true) {
				this.openWindowByName(Consts.WINDOW_NAME_UPGRADE_RED, {
					"ecode": -30120,
					"allBlack": _loc4_,
					"upGoldTime": Session.getInstance().upGoldLandTime,
					"confirmFn": this.upgradeLand
				});
				return;
			}
		}
		if (this.m_requestUpgradeRed == true) {
			return;
		}
		var _loc3_:Dynamic = Utils.buildRequest(CommandDefs.CMD_UPGRADE_RED, null);
		run(CommandList.SERVICE_REQUEST, _loc3_, "", null, this.onUpgradeRedCondition, this.onUpgradeRedConditionError);
		this.m_requestUpgradeRed = true;
	}

	// FarmApplication.as:520-528（IMsgCenter）
	public function removeEventListener(param1:String, param2:Dynamic):Void {
		if (this.m_dispatcher != null) {
			this.m_dispatcher.removeEventListener(param1, param2);
			return;
		}
		throw new Error("Application not initialize");
	}

	// FarmApplication.as:530-554
	private function showBlackUpgradeShare(param1:Dynamic):Void {
		var _loc2_:Int = 0;
		if (param1 == null) {
			return;
		}
		Reflect.setField(param1, "black", true);
		if (Reflect.field(param1, "rank") > 0 && QzoneJSAPI.WB == false && QzoneJSAPI.QPLUS == false) {
			_loc2_ = Std.int(Reflect.field(param1, "rank") % 10);
			if (Reflect.field(param1, "place") == 0 || _loc2_ == 0 || _loc2_ == 1 || _loc2_ == 5 || _loc2_ == 6 || _loc2_ == 8 || _loc2_ == 9) {
				if (this._blackUpShareWin == null) {
					this._blackUpShareWin = new UpgradeBlackWindow(cast this);
				}
				this._blackUpShareWin.data = {
					"place": Reflect.field(param1, "place"),
					"rank": Reflect.field(param1, "rank")
				};
				this.openWindow(this._blackUpShareWin);
			}
		}
	}

	// FarmApplication.as:556-563（IMsgCenter）
	public function addEventListener(param1:String, param2:Dynamic, param3:Bool = false, param4:Int = 0, param5:Bool = false):Void {
		if (this.m_dispatcher != null) {
			this.m_dispatcher.addEventListener(param1, param2, param3, param4, param5);
			return;
		}
		throw new Error("Application not initialize");
	}

	// FarmApplication.as:566-584
	private function checkWildDataStatus(param1:Dynamic):Void {
		var _loc4_:Array<Dynamic> = null;
		var _loc2_:Array<Dynamic> = Reflect.field(param1, "info");
		var _loc3_:Int = 0;
		while (_loc3_ < _loc2_.length) {
			_loc4_ = Reflect.field(_loc2_[_loc3_], "attack");
			if (this.animalAttack(_loc4_) == false && Reflect.field(_loc2_[_loc3_], "fid") != Session.getInstance().host.fid && Reflect.field(_loc2_[_loc3_], "status") != 6) {
				return;
			}
			_loc3_++;
		}
		this.dispatchEvent(new CommonEvent(Consts.MSG_WILD_UPDATE_STATUS, {
			"t": 0,
			"uId": Session.getInstance().currentUserIdByUinMode
		}));
	}

	// FarmApplication.as:586-594
	private function loadWildShell():Void {
		var _loc1_:Loader = new Loader();
		var _loc2_:LoaderContext = new LoaderContext();
		_loc2_.applicationDomain = CommonData.applicationDomain;
		_loc1_.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onWildComplete);
		var _loc3_:String = Utils.addPrefix(Settings.getInstance().getStringAttribute("beastLoaderUrl"));
		_loc1_.load(new URLRequest(_loc3_), _loc2_);
	}

	// FarmApplication.as:596-612
	private function acceptDailyGift(param1:Dynamic):Void {
		if (param1 == null) {
			return;
		}
		var _loc2_:Array<Dynamic> = [];
		if (Reflect.hasField(param1, "item") == true) {
			_loc2_ = _loc2_.concat(Reflect.field(param1, "item"));
		}
		if (Reflect.hasField(param1, "vipItem") == true && Reflect.field(param1, "vipItem") != false) {
			_loc2_ = _loc2_.concat(Reflect.field(param1, "vipItem"));
		}
		Session.getInstance().addReward(_loc2_);
	}

	// FarmApplication.as:614-623
	private function initAdvertisement():Void {
		var _loc1_:Array<Dynamic> = cast this.model.getData("advertisement");
		var _loc2_:String = Settings.getInstance().getStringAttribute("agent");
		if (_loc2_ != "weibo") {
			_loc2_ = Settings.getInstance().mode;
		}
		ADManager.getInstance().initAdvertisement(_loc2_, "353", new FarmAdvertisementAPI(this.farmView), this.m_dispatcher, new FarmAppHelper(this.m_farmAPI), _loc1_);
	}

	// FarmApplication.as:625-655。PORT-NOTE: `Reflect.field(_loc2_, "errorType") != undefined`
	// 在 Haxe 里无 undefined，按 null 判等价（JSON 解析出的对象无该键即 null）。
	private function onReloadGameFailed(param1:CommandEvent):Void {
		var _loc3_:String = null;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		this.dispatchEvent(new CommonEvent(Consts.MSG_USER_SWITCH_FLAG, {"showLoading": false}));
		this.startMainLoop();
		this.m_switchUser = null;
		this.m_backToHost = false;
		if (_loc2_ != null && Reflect.field(_loc2_, "errorType") != null) {
			_loc3_ = Reflect.field(_loc2_, "errorType");
			if (_loc3_ == "limitCode") {
				this.openWindowByName(Consts.WINDOW_NAME_ALERT, {
					"type": Consts.ALERT_TYPE_ERROR,
					"text": Reflect.field(Language.L, "请求超时，稍后再试")
				});
			} else {
				this.openWindowByName(Consts.WINDOW_NAME_ALERT, {
					"type": Consts.ALERT_TYPE_ERROR,
					"text": "无法访问服务器"
				});
			}
		}
	}

	// FarmApplication.as:657-667
	public function openWindow(param1:BaseWindow):Void {
		if (param1 == null) {
			return;
		}
		if (this.farmView != null && this.farmView.winCtrl != null) {
			this.farmView.winCtrl.open(param1);
		}
	}

	// FarmApplication.as:669-770。PORT-NOTE: `_loc2_.hasOwnProperty("gift")` →
	// Reflect.hasField（StartupData 无 gift 字段，原版 sealed 类上同样恒 false）；
	// `Reflect.field(_loc2_, "gift")` 在 Haxe 里不能对类型化实例下标，改 Reflect.field。
	private function onReloadGameSuccess(param1:CommandEvent):Void {
		var _loc7_:Dynamic = null;
		var _loc2_:StartupData = cast NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		this.dispatchEvent(new CommonEvent(Consts.MSG_USER_SWITCH_FLAG, {"showLoading": false}));
		this.startMainLoop();
		if (_loc2_._user._healthMode._serverTime != 0) {
			CommonData.serverTime = _loc2_._user._healthMode._serverTime;
		}
		var _loc3_:Int = getTimer() - this.m_requestStartTime;
		var _loc4_:Session = Session.getInstance();
		_loc4_.m_isDogHungry = _loc2_._dog._isHungry > 0;
		_loc4_.m_welcomeMode = _loc2_._welcome;
		var _loc5_:Dynamic = _loc2_._decors;
		if (_loc5_ != null) {
			if (_loc2_._dog != null) {
				Reflect.setField(_loc5_, Std.string(Consts.DECOR_DOG), {"itemId": _loc2_._dog._dogId});
			}
			_loc4_.sceneDecorates = _loc5_;
			if (this.m_backToHost == true) {
				model.setData(Consts.MY_FAIRY_OBJECT, Reflect.field(_loc5_, Consts.ITEM_TYPE_FAIRY));
			}
		}
		var _loc6_:Player = null;
		if (this.m_backToHost == true) {
			_loc6_ = _loc4_.host;
			if (_loc2_._user != null) {
				_loc6_._pf = _loc2_._user._pf;
				_loc6_._healthMode = _loc2_._user._healthMode;
				_loc6_._moralExp = _loc2_._user._moralExp;
				if (_loc2_._user._exp > 0 && !_loc4_.isExpLocked) {
					_loc6_._exp = _loc2_._user._exp;
				}
			}
			_loc4_.host = _loc6_;
		} else {
			if (this.m_switchUser == null) {
				Debugger.log("Exception in app, switch to a null player.");
				return;
			}
			_loc6_ = new Player(null);
			if (_loc2_._user != null) {
				_loc6_._pf = _loc2_._user._pf;
				_loc6_._healthMode = _loc2_._user._healthMode;
				_loc6_._moralExp = _loc2_._user._moralExp;
				if (_loc2_._user._exp > 0) {
					_loc6_._exp = _loc2_._user._exp;
				}
			}
			_loc6_._uId = this.m_switchUser._uId;
			_loc6_.uin = this.m_switchUser._uin;
			_loc6_._uinLogin = this.m_switchUser._uin;
			_loc6_._userName = this.m_switchUser._userName;
			_loc6_._money = this.m_switchUser._money;
			_loc6_._headPic = this.m_switchUser._headPic;
			_loc6_._yellowlevel = this.m_switchUser._yellowlevel;
			_loc6_._yellowstatus = this.m_switchUser._yellowstatus;
			_loc6_.me = false;
		}
		_loc4_.currentUser = _loc6_;
		_loc4_.m_lockFishMouse = false;
		this.dispatchEvent(new CommonEvent(Consts.MSG_RELOAD_GAME_RESULT, _loc2_));
		if (Reflect.hasField(_loc2_, "gift") == true) {
			_loc7_ = Reflect.field(_loc2_, "gift");
			Reflect.setField(_loc7_, "big", true);
			this.openWindowByName(Consts.WINDOW_NAME_GIFT, _loc7_);
			this.acceptDailyGift(Reflect.field(_loc2_, "gift"));
		}
		if (As3.truthy(_loc2_._beast)) {
			if (this.beastAPI == null) {
				BeastAPI.app = this;
				this.beastAPI = BeastAPI.getInstance();
				this.beastAPI.beastConfigUrl = Settings.getInstance().wildCfgUrl;
				this.beastAPI.registerEventListeners();
			}
			this.beastAPI.beastBase = _loc2_._beast;
			if (this.wildShell == null) {
				this.loadWildShell();
			}
			this.checkWildDataStatus(_loc2_._beast);
		}
	}

	// FarmApplication.as:772-786
	public function showTip(param1:String, param2:Dynamic):Void {
		if (param1 == null || param1.length == 0) {
			return;
		}
		if (param2 == null) {
			return;
		}
		if (this.farmView != null && this.farmView.tipCtrl != null) {
			this.farmView.tipCtrl.show(param1, param2);
		}
	}

	// FarmApplication.as:788-800
	private function onUpgradeRedConditionError(param1:CommandEvent):Void {
		this.m_requestUpgradeRed = false;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		this.openWindowByName(Consts.WINDOW_NAME_ALERT, {
			"type": Consts.ALERT_TYPE_ERROR,
			"text": Reflect.field(_loc2_, "direction")
		});
	}

	// FarmApplication.as:802-826
	private function onSwitchUser(param1:CommonEvent):Void {
		var _loc3_:Friend = null;
		if (param1 == null) {
			return;
		}
		var _loc2_:Dynamic = param1.data;
		if (_loc2_ != null && Reflect.hasField(_loc2_, "__reload__") == true && Reflect.field(_loc2_, "__reload__") == true) {
			if (this.m_switchUser == null) {
				this.reloadGameData("0");
			} else {
				this.reloadGameData(Std.string(this.m_switchUser._uId));
			}
		} else {
			_loc3_ = cast param1.data;
			this.switchUser(_loc3_);
		}
	}

	// FarmApplication.as:828-841
	private function onFirstShowRecall(param1:CommonEvent):Void {
		if (param1 == null || param1.target == null) {
			return;
		}
		param1.target.removeEventListener(Consts.MSG_SHOW_RECALL, this.onFirstShowRecall);
		var _loc2_:IModule = this.getModuleByName(Consts.MODULE_RECALL);
		if (_loc2_ != null && _loc2_.loaded == false) {
			_loc2_.load(null);
			this.dispatchEvent(new CommonEvent(param1.type, param1.data));
		}
	}

	// FarmApplication.as:843-862
	private function onUpgradeRedCondition(param1:CommandEvent):Void {
		this.m_requestUpgradeRed = false;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		this.openWindowByName(Consts.WINDOW_NAME_UPGRADE_RED, {
			"text": Reflect.field(_loc2_, "direction"),
			"money": Reflect.field(_loc2_, "money"),
			"qd": Reflect.field(_loc2_, "qd"),
			"yqd": Reflect.field(_loc2_, "yqd"),
			"place": Reflect.field(_loc2_, "place"),
			"ecode": Reflect.field(_loc2_, "ecode"),
			"confirmFn": this.upgradeLand,
			"allBlack": Reflect.field(_loc2_, "allBlack"),
			"upGoldTime": Session.getInstance().upGoldLandTime
		});
	}

	// FarmApplication.as:864-898
	private function onRedUpgradeInGame(param1:CommandEvent):Void {
		var onPaySuccess:Dynamic->Void = null;
		var e:CommandEvent = param1;
		onPaySuccess = function(param1:Dynamic):Void {
			if (_redUpResultCache != null) {
				dispatchEvent(new CommonEvent(Consts.MSG_PLAY_UPGRADE_RED_LAND, {
					"red": true,
					"place": Reflect.field(_redUpResultCache, "place"),
					"output": Reflect.field(_redUpResultCache, "output"),
					"leavings": Reflect.field(_redUpResultCache, "leavings"),
					"min": Reflect.field(_redUpResultCache, "min")
				}));
			}
			_redUpResultCache = null;
		};
		var data:Dynamic = NetHelper.getVOData(e);
		if (data == null) {
			return;
		}
		if (Reflect.field(data, "ecode") == 0) {
			QzoneJSAPI.getInGamePay(Reflect.field(data, "url_params"), onPaySuccess);
		} else {
			this.openWindowByName(Consts.WINDOW_NAME_ALERT, {
				"type": Consts.ALERT_TYPE_ERROR,
				"text": Reflect.field(data, "direction")
			});
		}
	}

	// FarmApplication.as:900-912
	private function animalAttack(param1:Array<Dynamic>):Bool {
		var _loc2_:Int = 0;
		while (_loc2_ < param1.length) {
			if (Reflect.field(param1[_loc2_], "fid") == Session.getInstance().host.fid) {
				return true;
			}
			_loc2_++;
		}
		return false;
	}

	// FarmApplication.as:914-929
	private function reloadGameData(param1:String):Void {
		var _loc2_:Dynamic = {"ownerId": param1};
		if (param1 == "0") {
			Reflect.setField(_loc2_, "flag", "1");
		}
		this.m_requestStartTime = getTimer();
		var _loc3_:Dynamic = Utils.buildRequest(CommandDefs.CMD_RELOAD_GAME_DATA, _loc2_);
		run(CommandList.SERVICE_REQUEST, _loc3_, "", null, this.onReloadGameSuccess, this.onReloadGameFailed);
		this.dispatchEvent(new CommonEvent(Consts.MSG_USER_SWITCH_FLAG, {"showLoading": true}));
		if (this.m_mainLoop != null) {
			this.m_mainLoop.stop();
		}
	}

	// FarmApplication.as:931-937
	public function hideTip():Void {
		if (this.farmView != null && this.farmView.tipCtrl != null) {
			this.farmView.tipCtrl.hide();
		}
	}

	// FarmApplication.as:939-974
	private function onBlackUpgradeInGame(param1:CommandEvent):Void {
		var onPaySuccess:Dynamic->Void = null;
		var e:CommandEvent = param1;
		onPaySuccess = function(param1:Dynamic):Void {
			if (_blackUpResultCache != null) {
				showBlackUpgradeShare(_blackUpResultCache);
				dispatchEvent(new CommonEvent(Consts.MSG_PLAY_UPGRADE_RED_LAND, {
					"black": true,
					"place": Reflect.field(_blackUpResultCache, "place"),
					"output": 0,
					"leavings": 0,
					"min": 0
				}));
			}
			_blackUpResultCache = null;
		};
		var data:Dynamic = NetHelper.getVOData(e);
		if (data == null) {
			return;
		}
		if (Reflect.field(data, "ecode") == 0) {
			QzoneJSAPI.getInGamePay(Reflect.field(data, "url_params"), onPaySuccess);
		} else {
			this.openWindowByName(Consts.WINDOW_NAME_ALERT, {
				"type": Consts.ALERT_TYPE_ERROR,
				"text": Reflect.field(data, "direction")
			});
		}
	}

	// FarmApplication.as:976-979。PORT-NOTE: AS3 `this.view as FarmStage` 类型
	// 不符时得 null（各调用点靠 farmView != null 短路），Haxe 裸 cast 不为 null，
	// 这里用 isOfType 判型保持「非 FarmStage 即 null」的原版语义。
	public var farmView(get, never):FarmStage;

	private function get_farmView():FarmStage {
		if (Std.isOfType(this.view, FarmStage)) {
			return cast this.view;
		}
		return null;
	}

	// FarmApplication.as:981-991
	public function openWindowByName(param1:String, param2:Dynamic):Void {
		if (param1 == null || param1.length == 0) {
			return;
		}
		if (this.farmView != null && this.farmView.winCtrl != null) {
			this.farmView.winCtrl.openForName(param1, param2);
		}
	}

	// FarmApplication.as:993-1085。PORT-NOTE: `new XML(addon.activity_list)` 的
	// E4X 子节点访问按等价遍历取 <activity_list> 节点（FarmLite/Module 先例）；
	// `serverTime * 1000` 写 *1000.0 防 eval 的 Int32 回绕（同 FarmLand._goldLand
	// 注）。
	public function startup():Void {
		var plugins:Array<Dynamic> = null;
		var ac:ActivityController = null;
		var addon:Xml = null;
		var addonRes:Resource = null;
		var m:Module = null;
		var container:BaseLayer = null;
		this.hookFarmStage();
		this.farmView.init();
		this.m_farmAPI = new FarmAPI(this);
		plugins = cast this.model.getData("plugins");
		PluginManager.getInstance().loadPlugins(this.m_farmAPI, plugins);
		QQPay.getInstance().app = this.m_farmAPI;
		if (this.m_modules == null) {
			this.m_modules = new Array<Dynamic>();
			m = new ModuleMainScene(this);
			container = this.farmView.getLayerByName(Consts.LAYER_SCENE_CONTENT);
			m.load(container);
			this.m_modules.push(m);
			m = new ModuleUITools(this);
			container = this.farmView.getLayerByName(Consts.LAYER_TOOLS);
			m.load(container);
			this.m_modules.push(m);
			m = new ModuleFriends(this);
			container = this.farmView.getLayerByName(Consts.LAYER_FRIEND);
			m.load(container);
			this.m_modules.push(m);
			m = new ModuleMessages(this);
			this.m_modules.push(m);
			this.addEventListener(Consts.MSG_SHOW_PROFILE, this.onFirstShowProfile, false, 0, true);
			m = new ModuleTask(this);
			container = this.farmView.getLayerByName(Consts.LAYER_TASK);
			m.load(container);
			this.m_modules.push(m);
			m = new ModuleRecall(this);
			this.m_modules.push(m);
			this.addEventListener(Consts.MSG_SHOW_RECALL, this.onFirstShowRecall, false, 0, true);
			m = new LevelUpModule(this);
			m.load(null);
			this.m_modules.push(m);
			m = new ModuleWarehouse(this);
			container = this.farmView.getLayerByName(Consts.LAYER_TOOLS);
			m.loadLater([Consts.MSG_SHOW_PACK, Consts.MSG_SHOW_WAREHOUSE, Consts.MSG_SHOW_WAREHOUSE_SELL], container);
			this.m_modules.push(m);
			m = new ModuleShop(this);
			m.loadLater([Consts.MSG_SHOW_SHOP, Consts.MSG_SHOW_BUY_DOG_FOOD, Consts.MSG_SHOW_BUY_SEED], null);
			this.m_modules.push(m);
			m = new ModuleDecorate(this);
			m.loadLater([Consts.MSG_SHOW_DIY], null);
			this.m_modules.push(m);
			m = new ModuleQuickShoot(this);
			m.loadLater([Consts.MSG_LOAD_QUICKSHOOT, Consts.MSG_CAMERA, Consts.MSG_SHOW_HEALTHMODE], null);
			this.m_modules.push(m);
			m = new ModuleFreeGift(this);
			m.loadLater([Consts.MSG_LOAD_FREEGIFT, Consts.MSG_SHOW_FREEGIFT], null);
			this.m_modules.push(m);
			m = new ModuleCardsGame(this);
			m.loadLater([Consts.MSG_LOAD_CARDSGAME, Consts.MSG_SHOW_CARDSGAMEWINDOW], null);
			this.m_modules.push(m);
			m = new ModuleWater(this);
			m.loadLater([Consts.MSG_LOAD_WATER], null);
			this.m_modules.push(m);
		}
		this.addEventListener(Consts.MSG_SWITCH_USER, this.onSwitchUser, false, 0, true);
		this.addEventListener(Consts.MSG_RELOAD_GAME_DATA, this.onReloadGameData, false, 0, true);
		this.addEventListener(Consts.MSG_SHOW_UPGRADE_RED, this.onShowUpgradeRedWindow, false, 0, true);
		this.addEventListener(Consts.MSG_ENTER_MC, this.onEnterPasture, false, 0, true);
		this.addEventListener(Consts.MSG_REQUEST_CHECK_ERROR, this.onCheckRequestError, false, 0, true);
		this.m_mainLoop = new Timer(Consts.MAIN_TIMER_FREQ, 0);
		this.m_mainLoop.addEventListener(TimerEvent.TIMER, this.onMainLoop);
		this.m_mainLoop.start();
		this.m_gameTime = new GameTime(false);
		this.m_gameTime.start();
		GameGuide.instance().container = this.farmView.getLayerByName(Consts.LAYER_TOPMOST);
		As3.setTimeout(function():Void {
			dispatchEvent(new CommonEvent(Consts.MSG_LOAD_WATER, null));
		}, 500);
		As3.setTimeout(function():Void {
			dispatchEvent(new CommonEvent(Consts.MSG_LOAD_QUICKSHOOT, null));
			dispatchEvent(new CommonEvent(Consts.MSG_LOAD_FREEGIFT, null));
			dispatchEvent(new CommonEvent(Consts.MSG_LOAD_CARDSGAME, null));
		}, 1400);
		ac = new ActivityController(this.m_farmAPI);
		addonRes = ResourceManager.gi().getResource(Settings.getInstance().addonConfigUrl);
		addon = Utils.loadXMLData(addonRes.data);
		var activityList:Xml = null;
		for (addonChild in addon.elements()) {
			if (addonChild.nodeName == "activity_list") {
				activityList = addonChild;
				break;
			}
		}
		ac.loadConfig(activityList, CommonData.serverTime * 1000.0, Settings.getInstance().appImgPrefix);
		this.initAdvertisement();
		UserActionRecorder.recordAction(UserActionRecorder.HF_GAME_INIT);
	}

	// FarmApplication.as:1087-1098
	private function startMainLoop():Void {
		if (this.m_mainLoop != null && this.m_mainLoop.running == false) {
			this.m_mainLoop.reset();
			this.m_mainLoop.start();
			if (this.m_gameTime != null) {
				this.m_gameTime.start();
			}
		}
	}
}
