package module
{
   import app4.activities.common.ActivityController;
   import app4.activities.common.FarmAdvertisementAPI;
   import app4.activities.common.FarmAppHelper;
   import com.adobe.serialization.json.JSON;
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
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
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
   import module.FreeGift.ModuleFreeGift;
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
   import report.EventRecorder;
   import report.UserActionRecorder;
   
   public class FarmApplication extends Application implements IMsgCenter
   {
      
      public var wildShell:*;
      
      private var m_mainLoop:Timer;
      
      private var m_requestStartTime:int;
      
      private var _redUpResultCache:Object;
      
      private var m_backToHost:Boolean;
      
      private var _blackUpResultCache:Object;
      
      private var m_modules:Array;
      
      private var m_switchUser:Friend;
      
      private var m_dispatcher:EventDispatcher;
      
      public var beastAPI:BeastAPI;
      
      private var m_idleRun:int;
      
      private var _blackUpShareWin:UpgradeBlackWindow;
      
      private var m_farmAPI:FarmAPI;
      
      private var m_gameTime:GameTime;
      
      private var m_requestUpgradeRed:Boolean;
      
      public function FarmApplication(param1:String = "", param2:DisplayObjectContainer = null)
      {
         super(param1,param2);
         this.m_dispatcher = new EventDispatcher();
         this.m_modules = null;
         this.m_mainLoop = null;
         this.m_idleRun = 1 * 100 / Consts.MAIN_TIMER_FREQ;
         this.m_gameTime = null;
         this.m_requestStartTime = 0;
         this.m_requestUpgradeRed = false;
         this.m_switchUser = null;
         this.m_backToHost = false;
         this._blackUpShareWin = null;
      }
      
      private function onMainLoop(param1:TimerEvent) : void
      {
         var _loc3_:IModule = null;
         if(this.m_idleRun > 0)
         {
            --this.m_idleRun;
            return;
         }
         var _loc2_:Number = this.m_gameTime.timeElapsed();
         if(NumberUtil.isZero(_loc2_))
         {
            return;
         }
         for each(_loc3_ in this.m_modules)
         {
            _loc3_.onGameLoop(_loc2_);
         }
      }
      
      public function getModuleByName(param1:String) : IModule
      {
         var _loc2_:Module = null;
         for each(_loc2_ in this.m_modules)
         {
            if(_loc2_.name == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      private function hookFarmStage() : void
      {
         var _loc1_:AppStage = this.view;
         if(_loc1_ != null)
         {
            _loc1_.destory();
            _loc1_ = null;
         }
         this.view = new FarmStage(this);
      }
      
      public function closeWindow(param1:BaseWindow) : void
      {
         if(param1 == null)
         {
            return;
         }
         if(this.farmView != null && this.farmView.winCtrl != null)
         {
            this.farmView.winCtrl.close(param1);
         }
      }
      
      public function useSystemCursor(param1:Boolean) : void
      {
         if(this.farmView != null && this.farmView.cursorCtrl != null)
         {
            this.farmView.cursorCtrl.useSystem(param1);
         }
      }
      
      public function setExpressUser(param1:Object, param2:int) : void
      {
         if(param1["uId"] == Session.getInstance().hostId)
         {
            QzoneJSAPI.toApp(358,"");
         }
         else
         {
            QzoneJSAPI.toApp(358,com.adobe.serialization.json.JSON.encode(param1));
         }
         EventRecorder.recordErrorEvent(EventRecorder.HF_ENTERMUCHANG,1,60 + param2);
      }
      
      private function onFirstShowProfile(param1:CommonEvent) : void
      {
         if(param1 == null || param1.target == null)
         {
            return;
         }
         param1.target.removeEventListener(Consts.MSG_SHOW_PROFILE,this.onFirstShowProfile);
         var _loc2_:IModule = this.getModuleByName(Consts.MODULE_MESSAGES);
         if(_loc2_ != null && _loc2_.loaded == false)
         {
            _loc2_.load(null);
            this.dispatchEvent(new CommonEvent(param1.type,param1.data));
         }
      }
      
      private function onEnterPasture(param1:CommonEvent) : void
      {
         var _loc2_:int = param1.data as int;
         var _loc3_:String = "";
         var _loc4_:Player = Session.getInstance().host;
         if(_loc4_._pf > 0)
         {
            this.setExpressUser(_loc4_.exportObject(),_loc2_);
         }
      }
      
      public function switchUser(param1:Friend) : void
      {
         var _loc2_:Session = Session.getInstance();
         if(_loc2_.harvestAnimationPlaying == true)
         {
            return;
         }
         if(param1 == null || param1["me"] == true)
         {
            if(_loc2_.me == false)
            {
               this.farmView.cursorCtrl.setCursor(Consts.CURSOR_STYLE_ARROW);
               this.useSystemCursor(true);
            }
            Protocol._userUin = "";
            this.m_switchUser = null;
            this.m_backToHost = true;
            this.reloadGameData("0");
         }
         else
         {
            if(!Session.getInstance().isInWildStage)
            {
               this.farmView.cursorCtrl.setCursor(Consts.CURSOR_STYLE_ARROW);
               this.useSystemCursor(true);
            }
            Protocol._userUin = param1._uin.toString();
            this.m_switchUser = param1;
            this.m_backToHost = false;
            this.reloadGameData(param1._uId.toString());
         }
      }
      
      private function onUpgradeLandError(param1:CommandEvent) : void
      {
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         this.openWindowByName(Consts.WINDOW_NAME_ALERT,{
            "type":Consts.ALERT_TYPE_ERROR,
            "text":_loc2_["direction"]
         });
         if(param1.body["cmdID"] == CommandDefs.CMD_BUY_PRECHECK)
         {
            this._blackUpResultCache = null;
         }
      }
      
      private function onWildComplete(param1:Event) : void
      {
         var _loc2_:Class = Utils.getClass("wild.com.Shell.WildShell");
         if(_loc2_)
         {
            this.wildShell = new _loc2_();
            this.wildShell.initConfig(this.beastAPI);
         }
      }
      
      private function upgradeLand(param1:int, param2:int, param3:int = -1, param4:Boolean = false) : void
      {
         var _loc5_:* = null;
         if(param1 == 0)
         {
            if(param2 == 0)
            {
               _loc5_ = Utils.buildRequest(CommandDefs.CMD_UPGRADE_RED,{"confirm":1});
            }
            else
            {
               this._redUpResultCache = null;
               _loc5_ = Utils.buildRequest(CommandDefs.CMD_BUY_PRECHECK,{
                  "shopType":Consts.ITEM_TYPE_RED_UPGRADE,
                  "itemType":Consts.ITEM_TYPE_RED_UPGRADE,
                  "itemId":param3,
                  "itemNum":1
               });
            }
            run(CommandList.SERVICE_REQUEST,_loc5_,"",null,this.onUpgradeLandSuccess,this.onUpgradeLandError);
         }
         else if(param1 == 1)
         {
            if(param4 == false || param2 == 1)
            {
               if(param2 == 0)
               {
                  _loc5_ = Utils.buildRequest(CommandDefs.CMD_UPGRADE_BLACK,{"op":1});
               }
               else
               {
                  this._blackUpResultCache = null;
                  _loc5_ = Utils.buildRequest(CommandDefs.CMD_BUY_PRECHECK,{
                     "shopType":Consts.ITEM_TYPE_BLACK_UPGRADE,
                     "itemType":Consts.ITEM_TYPE_BLACK_UPGRADE,
                     "itemId":param3,
                     "itemNum":1
                  });
               }
               run(CommandList.SERVICE_REQUEST,_loc5_,"",null,this.onUpgradeLandSuccess,this.onUpgradeLandError);
            }
            else
            {
               this.openWindowByName(Consts.WINDOW_NAME_CONFIRM,{
                  "text":"黑土地升级进入冷却期，花费的金币价格翻倍，您确定还要升级么？",
                  "title":"升级黑土地",
                  "confirmFn":this.upgradeBlackInCD
               });
            }
         }
         else if(param1 == 2)
         {
            _loc5_ = Utils.buildRequest(CommandDefs.CMD_UP_GOLD_LAND,{"op":1});
            run(CommandList.SERVICE_REQUEST,_loc5_,"",null,this.onUpgradeLandSuccess,this.onUpgradeLandError);
         }
      }
      
      private function upgradeBlackInCD() : void
      {
         var _loc1_:* = Utils.buildRequest(CommandDefs.CMD_UPGRADE_BLACK,{"op":1});
         run(CommandList.SERVICE_REQUEST,_loc1_,"",null,this.onUpgradeLandSuccess,this.onUpgradeLandError);
      }
      
      public function closeWindowByName(param1:String) : void
      {
         if(param1 == null || param1 == "")
         {
            return;
         }
         if(this.farmView != null && this.farmView.winCtrl != null)
         {
            this.farmView.winCtrl.closeForName(param1);
         }
      }
      
      public function openFloat(param1:String, param2:int = 0, param3:Object = null) : void
      {
         if(param1 == null || param1.length == 0)
         {
            return;
         }
         if(this.farmView != null && this.farmView.floatCtrl != null)
         {
            this.farmView.floatCtrl.open(param1,0,param3);
         }
      }
      
      private function onReloadGameData(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         this.reloadGameData(param1.data["ownerId"]);
      }
      
      private function onUpgradeLandSuccess(param1:CommandEvent) : void
      {
         var _loc3_:* = undefined;
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_["code"] == 1)
         {
            if(param1.body["cmdID"] == CommandDefs.CMD_BUY_PRECHECK)
            {
               _loc3_ = null;
               if(param1.body["__body"]["shopType"] == Consts.ITEM_TYPE_RED_UPGRADE)
               {
                  this._redUpResultCache = _loc2_;
                  _loc3_ = Utils.buildRequest(CommandDefs.CMD_BUY_INGAME_BUY,{
                     "itemId":param1.body["__body"]["itemId"],
                     "itemNum":1,
                     "itemType":Consts.ITEM_TYPE_RED_UPGRADE,
                     "payType":Consts.PAY_QD,
                     "shopType":Consts.ITEM_TYPE_RED_UPGRADE
                  });
                  run(CommandList.SERVICE_REQUEST,_loc3_,"",null,this.onRedUpgradeInGame,this.onRedUpgradeInGame);
               }
               else
               {
                  this._blackUpResultCache = _loc2_;
                  _loc3_ = Utils.buildRequest(CommandDefs.CMD_BUY_INGAME_BUY,{
                     "itemId":param1.body["__body"]["itemId"],
                     "itemNum":1,
                     "itemType":Consts.ITEM_TYPE_BLACK_UPGRADE,
                     "payType":Consts.PAY_QD,
                     "shopType":Consts.ITEM_TYPE_BLACK_UPGRADE
                  });
                  run(CommandList.SERVICE_REQUEST,_loc3_,"",null,this.onBlackUpgradeInGame,this.onBlackUpgradeInGame);
               }
            }
            else if(param1.body["cmdID"] == CommandDefs.CMD_UP_GOLD_LAND)
            {
               --Session.getInstance().upGoldLandTime;
               _loc2_["gold"] = true;
               this.dispatchEvent(new CommonEvent(Consts.MSG_PLAY_UPGRADE_RED_LAND,_loc2_));
               this.dispatchEvent(new CommonEvent(Consts.GOLD_LAND_UPDATE_TIME_CHANGE,Session.getInstance().upGoldLandTime));
            }
            else
            {
               Session.getInstance().updateHostAccount(_loc2_["money"],0,0);
               if(param1.body["cmdID"] == CommandDefs.CMD_UPGRADE_RED)
               {
                  _loc2_["red"] = true;
               }
               if(param1.body["cmdID"] == CommandDefs.CMD_UPGRADE_BLACK)
               {
                  this.showBlackUpgradeShare(_loc2_);
               }
               this.dispatchEvent(new CommonEvent(Consts.MSG_PLAY_UPGRADE_RED_LAND,_loc2_));
            }
         }
         else if(_loc2_["code"] == -30341 || _loc2_["ecode"] == -30341)
         {
            if(param1.body["cmdID"] == CommandDefs.CMD_UPGRADE_BLACK)
            {
               _loc2_["black"] = true;
               _loc2_["error"] = "不是空地，无法升级为黑土地";
               this.dispatchEvent(new CommonEvent(Consts.MSG_PLAY_UPGRADE_RED_LAND,_loc2_));
            }
         }
         else
         {
            this.openWindowByName(Consts.WINDOW_NAME_ALERT,{
               "type":Consts.ALERT_TYPE_ERROR,
               "text":_loc2_["direction"]
            });
         }
      }
      
      public function dispatchEvent(param1:Event) : void
      {
         if(this.m_dispatcher != null)
         {
            this.m_dispatcher.dispatchEvent(param1);
            return;
         }
         throw new Error("Application not initialize");
      }
      
      public function processNetException() : void
      {
         var _loc1_:Module = null;
         this.dispatchEvent(new CommonEvent(Consts.MSG_USER_SWITCH_FLAG,{"showLoading":false}));
         this.startMainLoop();
         if(this.m_requestUpgradeRed == true)
         {
            this.m_requestUpgradeRed = false;
         }
         for each(_loc1_ in this.m_modules)
         {
            _loc1_.onNetRequestStopped();
         }
      }
      
      private function onCheckRequestError(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:* = param1.data;
         if(_loc2_["cmdID"] == CommandDefs.CMD_RELOAD_GAME_DATA)
         {
            this.dispatchEvent(new CommonEvent(Consts.MSG_USER_SWITCH_FLAG,{"showLoading":false}));
            this.startMainLoop();
            this.m_switchUser = null;
            this.m_backToHost = false;
         }
         this.openWindowByName(Consts.WINDOW_NAME_REQUEST_ERROR,{"url":_loc2_["url"]});
      }
      
      private function onShowUpgradeRedWindow(param1:Event) : void
      {
         var _loc4_:Boolean = false;
         var _loc2_:ModuleMainScene = this.getModuleByName(Consts.MODULE_MAINSCENE) as ModuleMainScene;
         if(_loc2_ != null)
         {
            _loc4_ = _loc2_.isAllBlack;
            if(_loc4_ == true)
            {
               this.openWindowByName(Consts.WINDOW_NAME_UPGRADE_RED,{
                  "ecode":-30120,
                  "allBlack":_loc4_,
                  "upGoldTime":Session.getInstance().upGoldLandTime,
                  "confirmFn":this.upgradeLand
               });
               return;
            }
         }
         if(this.m_requestUpgradeRed == true)
         {
            return;
         }
         var _loc3_:* = Utils.buildRequest(CommandDefs.CMD_UPGRADE_RED,null);
         run(CommandList.SERVICE_REQUEST,_loc3_,"",null,this.onUpgradeRedCondition,this.onUpgradeRedConditionError);
         this.m_requestUpgradeRed = true;
      }
      
      public function removeEventListener(param1:String, param2:Function) : void
      {
         if(this.m_dispatcher != null)
         {
            this.m_dispatcher.removeEventListener(param1,param2);
            return;
         }
         throw new Error("Application not initialize");
      }
      
      private function showBlackUpgradeShare(param1:Object) : void
      {
         var _loc2_:int = 0;
         if(param1 == null)
         {
            return;
         }
         param1["black"] = true;
         if(param1["rank"] > 0 && QzoneJSAPI.WB == false && QzoneJSAPI.QPLUS == false)
         {
            _loc2_ = param1["rank"] % 10;
            if(param1["place"] == 0 || _loc2_ == 0 || _loc2_ == 1 || _loc2_ == 5 || _loc2_ == 6 || _loc2_ == 8 || _loc2_ == 9)
            {
               if(this._blackUpShareWin == null)
               {
                  this._blackUpShareWin = new UpgradeBlackWindow(this as IMsgCenter);
               }
               this._blackUpShareWin.data = {
                  "place":param1["place"],
                  "rank":param1["rank"]
               };
               this.openWindow(this._blackUpShareWin);
            }
         }
      }
      
      public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         if(this.m_dispatcher != null)
         {
            this.m_dispatcher.addEventListener(param1,param2,param3,param4,param5);
            return;
         }
         throw new Error("Application not initialize");
      }
      
      private function checkWildDataStatus(param1:Object) : void
      {
         var _loc4_:Array = null;
         var _loc2_:Array = param1["info"];
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length)
         {
            _loc4_ = _loc2_[_loc3_]["attack"];
            if(this.animalAttack(_loc4_) == false && _loc2_[_loc3_]["fid"] != Session.getInstance().host.fid && _loc2_[_loc3_]["status"] != 6)
            {
               return;
            }
            _loc3_++;
         }
         this.dispatchEvent(new CommonEvent(Consts.MSG_WILD_UPDATE_STATUS,{
            "t":0,
            "uId":Session.getInstance().currentUserIdByUinMode
         }));
      }
      
      private function loadWildShell() : void
      {
         var _loc1_:Loader = new Loader();
         var _loc2_:LoaderContext = new LoaderContext();
         _loc2_.applicationDomain = CommonData.applicationDomain;
         _loc1_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onWildComplete);
         var _loc3_:String = Utils.addPrefix(Settings.getInstance().getStringAttribute("beastLoaderUrl"));
         _loc1_.load(new URLRequest(_loc3_),_loc2_);
      }
      
      private function acceptDailyGift(param1:Object) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc2_:Array = [];
         if(param1.hasOwnProperty("item") == true)
         {
            _loc2_ = _loc2_.concat(param1["item"]);
         }
         if(param1.hasOwnProperty("vipItem") == true && param1["vipItem"] != false)
         {
            _loc2_ = _loc2_.concat(param1["vipItem"]);
         }
         Session.getInstance().addReward(_loc2_);
      }
      
      private function initAdvertisement() : void
      {
         var _loc1_:Array = this.model.getData("advertisement") as Array;
         var _loc2_:String = Settings.getInstance().getStringAttribute("agent");
         if(_loc2_ != "weibo")
         {
            _loc2_ = Settings.getInstance().mode;
         }
         ADManager.getInstance().initAdvertisement(_loc2_,"353",new FarmAdvertisementAPI(this.farmView),this.m_dispatcher,new FarmAppHelper(this.m_farmAPI),_loc1_);
      }
      
      private function onReloadGameFailed(param1:CommandEvent) : void
      {
         var _loc3_:String = null;
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         this.dispatchEvent(new CommonEvent(Consts.MSG_USER_SWITCH_FLAG,{"showLoading":false}));
         this.startMainLoop();
         this.m_switchUser = null;
         this.m_backToHost = false;
         if(_loc2_ != null && _loc2_["errorType"] != undefined)
         {
            _loc3_ = _loc2_["errorType"];
            if(_loc3_ == "limitCode")
            {
               this.openWindowByName(Consts.WINDOW_NAME_ALERT,{
                  "type":Consts.ALERT_TYPE_ERROR,
                  "text":Language.L["请求超时，稍后再试"]
               });
            }
            else
            {
               this.openWindowByName(Consts.WINDOW_NAME_ALERT,{
                  "type":Consts.ALERT_TYPE_ERROR,
                  "text":"无法访问服务器"
               });
            }
         }
      }
      
      public function openWindow(param1:BaseWindow) : void
      {
         if(param1 == null)
         {
            return;
         }
         if(this.farmView != null && this.farmView.winCtrl != null)
         {
            this.farmView.winCtrl.open(param1);
         }
      }
      
      private function onReloadGameSuccess(param1:CommandEvent) : void
      {
         var _loc7_:Object = null;
         var _loc2_:StartupData = NetHelper.getVOData(param1) as StartupData;
         if(_loc2_ == null)
         {
            return;
         }
         this.dispatchEvent(new CommonEvent(Consts.MSG_USER_SWITCH_FLAG,{"showLoading":false}));
         this.startMainLoop();
         if(_loc2_._user._healthMode._serverTime != 0)
         {
            CommonData.serverTime = _loc2_._user._healthMode._serverTime;
         }
         var _loc3_:int = getTimer() - this.m_requestStartTime;
         var _loc4_:Session = Session.getInstance();
         _loc4_.m_isDogHungry = _loc2_._dog._isHungry > 0;
         _loc4_.m_welcomeMode = _loc2_._welcome;
         var _loc5_:Object = _loc2_._decors;
         if(_loc5_ != null)
         {
            if(_loc2_._dog != null)
            {
               _loc5_[Consts.DECOR_DOG.toString()] = {"itemId":_loc2_._dog._dogId};
            }
            _loc4_.sceneDecorates = _loc5_;
            if(this.m_backToHost == true)
            {
               model.setData(Consts.MY_FAIRY_OBJECT,_loc5_[Consts.ITEM_TYPE_FAIRY]);
            }
         }
         var _loc6_:Player = null;
         if(this.m_backToHost == true)
         {
            _loc6_ = _loc4_.host;
            if(_loc2_._user != null)
            {
               _loc6_._pf = _loc2_._user._pf;
               _loc6_._healthMode = _loc2_._user._healthMode;
               _loc6_._moralExp = _loc2_._user._moralExp;
               if(_loc2_._user._exp > 0 && !_loc4_.isExpLocked)
               {
                  _loc6_._exp = _loc2_._user._exp;
               }
            }
            _loc4_.host = _loc6_;
         }
         else
         {
            if(this.m_switchUser == null)
            {
               Debugger.log("Exception in app, switch to a null player.");
               return;
            }
            _loc6_ = new Player(null);
            if(_loc2_._user != null)
            {
               _loc6_._pf = _loc2_._user._pf;
               _loc6_._healthMode = _loc2_._user._healthMode;
               _loc6_._moralExp = _loc2_._user._moralExp;
               if(_loc2_._user._exp > 0)
               {
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
         this.dispatchEvent(new CommonEvent(Consts.MSG_RELOAD_GAME_RESULT,_loc2_));
         if(_loc2_.hasOwnProperty("gift") == true)
         {
            _loc7_ = _loc2_["gift"];
            _loc7_["big"] = true;
            this.openWindowByName(Consts.WINDOW_NAME_GIFT,_loc7_);
            this.acceptDailyGift(_loc2_["gift"]);
         }
         if(_loc2_._beast)
         {
            if(!this.beastAPI)
            {
               BeastAPI.app = this;
               this.beastAPI = BeastAPI.getInstance();
               this.beastAPI.beastConfigUrl = Settings.getInstance().wildCfgUrl;
               this.beastAPI.registerEventListeners();
            }
            this.beastAPI.beastBase = _loc2_._beast;
            if(!this.wildShell)
            {
               this.loadWildShell();
            }
            this.checkWildDataStatus(_loc2_._beast);
         }
      }
      
      public function showTip(param1:String, param2:Object) : void
      {
         if(param1 == null || param1.length == 0)
         {
            return;
         }
         if(param2 == null)
         {
            return;
         }
         if(this.farmView != null && this.farmView.tipCtrl != null)
         {
            this.farmView.tipCtrl.show(param1,param2);
         }
      }
      
      private function onUpgradeRedConditionError(param1:CommandEvent) : void
      {
         this.m_requestUpgradeRed = false;
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         this.openWindowByName(Consts.WINDOW_NAME_ALERT,{
            "type":Consts.ALERT_TYPE_ERROR,
            "text":_loc2_["direction"]
         });
      }
      
      private function onSwitchUser(param1:CommonEvent) : void
      {
         var _loc3_:Friend = null;
         if(param1 == null)
         {
            return;
         }
         var _loc2_:* = param1.data;
         if(_loc2_ != null && _loc2_.hasOwnProperty("__reload__") == true && _loc2_["__reload__"] == true)
         {
            if(this.m_switchUser == null)
            {
               this.reloadGameData("0");
            }
            else
            {
               this.reloadGameData(this.m_switchUser._uId.toString());
            }
         }
         else
         {
            _loc3_ = param1.data as Friend;
            this.switchUser(_loc3_);
         }
      }
      
      private function onFirstShowRecall(param1:CommonEvent) : void
      {
         if(param1 == null || param1.target == null)
         {
            return;
         }
         param1.target.removeEventListener(Consts.MSG_SHOW_RECALL,this.onFirstShowRecall);
         var _loc2_:IModule = this.getModuleByName(Consts.MODULE_RECALL);
         if(_loc2_ != null && _loc2_.loaded == false)
         {
            _loc2_.load(null);
            this.dispatchEvent(new CommonEvent(param1.type,param1.data));
         }
      }
      
      private function onUpgradeRedCondition(param1:CommandEvent) : void
      {
         this.m_requestUpgradeRed = false;
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         this.openWindowByName(Consts.WINDOW_NAME_UPGRADE_RED,{
            "text":_loc2_["direction"],
            "money":_loc2_["money"],
            "qd":_loc2_["qd"],
            "yqd":_loc2_["yqd"],
            "place":_loc2_["place"],
            "ecode":_loc2_["ecode"],
            "confirmFn":this.upgradeLand,
            "allBlack":_loc2_["allBlack"],
            "upGoldTime":Session.getInstance().upGoldLandTime
         });
      }
      
      private function onRedUpgradeInGame(param1:CommandEvent) : void
      {
         var onPaySuccess:Function = null;
         var e:CommandEvent = param1;
         onPaySuccess = function(param1:Object):void
         {
            if(_redUpResultCache != null)
            {
               dispatchEvent(new CommonEvent(Consts.MSG_PLAY_UPGRADE_RED_LAND,{
                  "red":true,
                  "place":_redUpResultCache["place"],
                  "output":_redUpResultCache["output"],
                  "leavings":_redUpResultCache["leavings"],
                  "min":_redUpResultCache["min"]
               }));
            }
            _redUpResultCache = null;
         };
         var data:* = NetHelper.getVOData(e);
         if(data == null)
         {
            return;
         }
         if(data["ecode"] == 0)
         {
            QzoneJSAPI.getInGamePay(data["url_params"],onPaySuccess);
         }
         else
         {
            this.openWindowByName(Consts.WINDOW_NAME_ALERT,{
               "type":Consts.ALERT_TYPE_ERROR,
               "text":data["direction"]
            });
         }
      }
      
      private function animalAttack(param1:Array) : Boolean
      {
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            if(param1[_loc2_]["fid"] == Session.getInstance().host.fid)
            {
               return true;
            }
            _loc2_++;
         }
         return false;
      }
      
      private function reloadGameData(param1:String) : void
      {
         var _loc2_:* = {"ownerId":param1};
         if(param1 == "0")
         {
            _loc2_["flag"] = "1";
         }
         this.m_requestStartTime = getTimer();
         var _loc3_:* = Utils.buildRequest(CommandDefs.CMD_RELOAD_GAME_DATA,_loc2_);
         run(CommandList.SERVICE_REQUEST,_loc3_,"",null,this.onReloadGameSuccess,this.onReloadGameFailed);
         this.dispatchEvent(new CommonEvent(Consts.MSG_USER_SWITCH_FLAG,{"showLoading":true}));
         if(this.m_mainLoop != null)
         {
            this.m_mainLoop.stop();
         }
      }
      
      public function hideTip() : void
      {
         if(this.farmView != null && this.farmView.tipCtrl != null)
         {
            this.farmView.tipCtrl.hide();
         }
      }
      
      private function onBlackUpgradeInGame(param1:CommandEvent) : void
      {
         var onPaySuccess:Function = null;
         var e:CommandEvent = param1;
         onPaySuccess = function(param1:Object):void
         {
            if(_blackUpResultCache != null)
            {
               showBlackUpgradeShare(_blackUpResultCache);
               dispatchEvent(new CommonEvent(Consts.MSG_PLAY_UPGRADE_RED_LAND,{
                  "black":true,
                  "place":_blackUpResultCache["place"],
                  "output":0,
                  "leavings":0,
                  "min":0
               }));
            }
            _blackUpResultCache = null;
         };
         var data:* = NetHelper.getVOData(e);
         if(data == null)
         {
            return;
         }
         if(data["ecode"] == 0)
         {
            QzoneJSAPI.getInGamePay(data["url_params"],onPaySuccess);
         }
         else
         {
            this.openWindowByName(Consts.WINDOW_NAME_ALERT,{
               "type":Consts.ALERT_TYPE_ERROR,
               "text":data["direction"]
            });
         }
      }
      
      public function get farmView() : FarmStage
      {
         return this.view as FarmStage;
      }
      
      public function openWindowByName(param1:String, param2:Object) : void
      {
         if(param1 == null || param1.length == 0)
         {
            return;
         }
         if(this.farmView != null && this.farmView.winCtrl != null)
         {
            this.farmView.winCtrl.openForName(param1,param2);
         }
      }
      
      public function startup() : void
      {
         var plugins:Array;
         var ac:ActivityController;
         var addon:XML;
         var addonRes:Resource;
         var m:Module = null;
         var container:BaseLayer = null;
         this.hookFarmStage();
         this.farmView.init();
         this.m_farmAPI = new FarmAPI(this);
         plugins = this.model.getData("plugins") as Array;
         PluginManager.getInstance().loadPlugins(this.m_farmAPI,plugins);
         QQPay.getInstance().app = this.m_farmAPI;
         if(this.m_modules == null)
         {
            this.m_modules = new Array();
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
            this.addEventListener(Consts.MSG_SHOW_PROFILE,this.onFirstShowProfile,false,0,true);
            m = new ModuleTask(this);
            container = this.farmView.getLayerByName(Consts.LAYER_TASK);
            m.load(container);
            this.m_modules.push(m);
            m = new ModuleRecall(this);
            this.m_modules.push(m);
            this.addEventListener(Consts.MSG_SHOW_RECALL,this.onFirstShowRecall,false,0,true);
            m = new LevelUpModule(this);
            m.load(null);
            this.m_modules.push(m);
            m = new ModuleWarehouse(this);
            container = this.farmView.getLayerByName(Consts.LAYER_TOOLS);
            m.loadLater([Consts.MSG_SHOW_PACK,Consts.MSG_SHOW_WAREHOUSE,Consts.MSG_SHOW_WAREHOUSE_SELL],container);
            this.m_modules.push(m);
            m = new ModuleShop(this);
            m.loadLater([Consts.MSG_SHOW_SHOP,Consts.MSG_SHOW_BUY_DOG_FOOD,Consts.MSG_SHOW_BUY_SEED],null);
            this.m_modules.push(m);
            m = new ModuleDecorate(this);
            m.loadLater([Consts.MSG_SHOW_DIY],null);
            this.m_modules.push(m);
            m = new ModuleQuickShoot(this);
            m.loadLater([Consts.MSG_LOAD_QUICKSHOOT,Consts.MSG_CAMERA,Consts.MSG_SHOW_HEALTHMODE],null);
            this.m_modules.push(m);
            m = new ModuleFreeGift(this);
            m.loadLater([Consts.MSG_LOAD_FREEGIFT,Consts.MSG_SHOW_FREEGIFT],null);
            this.m_modules.push(m);
            m = new ModuleCardsGame(this);
            m.loadLater([Consts.MSG_LOAD_CARDSGAME,Consts.MSG_SHOW_CARDSGAMEWINDOW],null);
            this.m_modules.push(m);
            m = new ModuleWater(this);
            m.loadLater([Consts.MSG_LOAD_WATER],null);
            this.m_modules.push(m);
         }
         this.addEventListener(Consts.MSG_SWITCH_USER,this.onSwitchUser,false,0,true);
         this.addEventListener(Consts.MSG_RELOAD_GAME_DATA,this.onReloadGameData,false,0,true);
         this.addEventListener(Consts.MSG_SHOW_UPGRADE_RED,this.onShowUpgradeRedWindow,false,0,true);
         this.addEventListener(Consts.MSG_ENTER_MC,this.onEnterPasture,false,0,true);
         this.addEventListener(Consts.MSG_REQUEST_CHECK_ERROR,this.onCheckRequestError,false,0,true);
         this.m_mainLoop = new Timer(Consts.MAIN_TIMER_FREQ,0);
         this.m_mainLoop.addEventListener(TimerEvent.TIMER,this.onMainLoop);
         this.m_mainLoop.start();
         this.m_gameTime = new GameTime(false);
         this.m_gameTime.start();
         GameGuide.instance().container = this.farmView.getLayerByName(Consts.LAYER_TOPMOST);
         setTimeout(function():void
         {
            dispatchEvent(new CommonEvent(Consts.MSG_LOAD_WATER,null));
         },500);
         setTimeout(function():void
         {
            dispatchEvent(new CommonEvent(Consts.MSG_LOAD_QUICKSHOOT,null));
            dispatchEvent(new CommonEvent(Consts.MSG_LOAD_FREEGIFT,null));
            dispatchEvent(new CommonEvent(Consts.MSG_LOAD_CARDSGAME,null));
         },1400);
         ac = new ActivityController(this.m_farmAPI);
         addonRes = ResourceManager.gi().getResource(Settings.getInstance().addonConfigUrl);
         addon = Utils.loadXMLData(addonRes.data);
         ac.loadConfig(new XML(addon.activity_list),CommonData.serverTime * 1000,Settings.getInstance().appImgPrefix);
         this.initAdvertisement();
         UserActionRecorder.recordAction(UserActionRecorder.HF_GAME_INIT);
      }
      
      private function startMainLoop() : void
      {
         if(this.m_mainLoop != null && this.m_mainLoop.running == false)
         {
            this.m_mainLoop.reset();
            this.m_mainLoop.start();
            if(this.m_gameTime != null)
            {
               this.m_gameTime.start();
            }
         }
      }
   }
}

