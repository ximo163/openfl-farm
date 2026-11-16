package module
{
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
   import common.*;
   import common.misc.ConfigMerger;
   import common.misc.Cookies;
   import common.misc.QzoneJSAPI;
   import common.misc.Utils;
   import common.misc.VersionUtil;
   import entities.Friend;
   import entities.Player;
   import entities.StartupData;
   import events.CommonEvent;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.display.StageQuality;
   import flash.events.ContextMenuEvent;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.external.ExternalInterface;
   import flash.net.LocalConnection;
   import flash.net.URLRequest;
   import flash.net.URLVariables;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.system.Security;
   import flash.system.SecurityDomain;
   import flash.text.Font;
   import flash.ui.ContextMenuItem;
   import flash.utils.Timer;
   import flash.utils.setTimeout;
   import framework.api.beast.BeastAPI;
   import framework.commands.CommandList;
   import framework.net.CommandDefs;
   import framework.net.NetHelper;
   import framework.net.core.RequestChecker;
   import framework.net.parsers.StartupDataParser;
   import framework.net.vo.ServiceResultVO;
   import module.recall.RecallModel;
   import report.ClickReportManager;
   import report.EventRecorder;
   
   [SWF(width="500", height="375", backgroundColor="#869ca7", frameRate="24")]
   public class Main extends Sprite
   {
      
      public static var theApp:FarmApplication = null;
      
      private static var EMBED_FONT_A:Class = Main_EMBED_FONT_A;
      
      private var _wildShell:*;
      
      private var _beastapi:BeastAPI;
      
      public function Main()
      {
         super();
         var _loc1_:DebuggerWindow = new DebuggerWindow();
         addChild(_loc1_);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
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
      
      private function onWildComplete(param1:Event) : void
      {
         var _loc2_:Class = Utils.getClass("wild.com.Shell.WildShell");
         if(_loc2_)
         {
            this._wildShell = new _loc2_();
            this._wildShell.initConfig(this._beastapi);
            theApp.wildShell = this._wildShell;
         }
      }
      
      private function onToggleQaulity(param1:ContextMenuEvent) : void
      {
         if(this.stage)
         {
            if(this.stage.quality == "LOW")
            {
               this.stage.quality = StageQuality.HIGH;
               ContextMenuItem(param1.target).caption = "高速模式(&Q)";
            }
            else
            {
               this.stage.quality = StageQuality.LOW;
               ContextMenuItem(param1.target).caption = "正常模式(&Q)";
            }
         }
      }
      
      private function setup() : void
      {
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
         RightMenu.addMenuItem(this,"高速模式(&Q)",this.onToggleQaulity,true);
         FrameTimer.init(this);
         var _loc1_:Timer = new Timer(120000);
         _loc1_.addEventListener(TimerEvent.TIMER,this.gc);
         _loc1_.start();
         setTimeout(this.connectJS,200);
         if(stage != null && stage.stageWidth > 960)
         {
            if(int(Math.random() * EventRecorder.successRecordProbability) == 0)
            {
               _loc2_ = new URLVariables();
               _loc2_["flag1"] = 160451;
               _loc2_["flag2"] = 0;
               _loc2_["1"] = EventRecorder.successRecordProbability;
               EventRecorder.record(_loc2_);
            }
         }
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this.init();
      }
      
      private function onSessionTimeout(param1:CommonEvent) : void
      {
         theApp.processNetException();
         if(ExternalInterface.available == true)
         {
            QzoneJSAPI.showLoginBox();
         }
      }
      
      private function gc(param1:TimerEvent) : void
      {
         var e:TimerEvent = param1;
         try
         {
            new LocalConnection().connect("MoonSpirit");
            new LocalConnection().connect("MoonSpirit");
         }
         catch(error:Error)
         {
         }
      }
      
      private function loadAsyncWildModule(param1:Object) : void
      {
         BeastAPI.app = theApp;
         if(!this._beastapi)
         {
            this._beastapi = BeastAPI.getInstance();
            this._beastapi.beastConfigUrl = Settings.getInstance().wildCfgUrl;
            theApp.beastAPI = this._beastapi;
         }
         this._beastapi.registerEventListeners();
         if(param1)
         {
            this._beastapi.beastBase = param1;
         }
         if(!this._wildShell)
         {
            this.loadWildShell();
         }
      }
      
      private function init() : void
      {
         var addonRes:Resource;
         var dataRes:Resource;
         var merger:ConfigMerger;
         var addon:XML;
         var st:Settings = Settings.getInstance();
         Security.allowDomain("imgcache.qq.com");
         Security.allowDomain("acfs.tencent.com");
         Security.allowDomain("*");
         CommonData.getKey = function():String
         {
            var _loc1_:String = "OPdfqwn^&*w(281flebnd1##roplaq";
            var _loc2_:String = CommonData.serverTime.toString();
            var _loc3_:int = parseInt(_loc2_.substr(_loc2_.length - 1),10);
            var _loc4_:String = _loc1_.substr(_loc3_);
            return MD5.hash(_loc2_ + _loc4_);
         };
         CommonData.rslLoader = new RSLLoader();
         CommonData.rslLoader.applicationDomain = ApplicationDomain.currentDomain;
         CommonData.rslLoader.securityDomain = SecurityDomain.currentDomain;
         CommonData.rslManager = RSLManager.getInstance();
         CommonData.rslManager.rslLoader = CommonData.rslLoader;
         RSLManager.applicationDomain = CommonData.applicationDomain;
         theApp = new FarmApplication("qq farm",this);
         Session.getInstance().app = theApp;
         NetHelper.theApp = theApp;
         GetCropID.theApp = theApp;
         theApp.addEventListener(Consts.MSG_SESSION_TIMEOUT,this.onSessionTimeout);
         theApp.addEventListener(Consts.MSG_NEED_VALIDATE_CODE,this.onNeedInputIDCode);
         VersionUtil.setRightMenu(this);
         Session.getInstance().m_buildVersion = VersionUtil.versionString;
         EventRecorder.initStartupSpeed();
         RequestChecker.initialize();
         st.setConfigDataModel(theApp.model);
         dataRes = ResourceManager.gi().getResource(st.dataConfigUrl);
         addonRes = ResourceManager.gi().getResource(st.addonConfigUrl);
         merger = new ConfigMerger(theApp,dataRes.data);
         addon = Utils.loadXMLData(addonRes.data);
         merger.mergeConfig(addon);
         st.loadFromAddon(addon);
      }
      
      private function onValidateConfirmed(param1:String) : void
      {
         if(param1 != "")
         {
            NetHelper.reSendRequest({"validatemsg":param1});
         }
      }
      
      private function connectJS() : void
      {
         var p:Player = null;
         var req:Object = null;
         var mode:String = null;
         p = Session.getInstance().host;
         if(QzoneJSAPI.WB == true)
         {
            req = Utils.buildRequest(CommandDefs.CMD_WB_PROFILE,{"uids":p._uId});
            theApp.run(CommandList.SERVICE_REQUEST,req,"",null,function(param1:CommandEvent):void
            {
               if(param1 == null)
               {
                  return;
               }
               var _loc2_:ServiceResultVO = param1.result as ServiceResultVO;
               if(_loc2_ == null)
               {
                  return;
               }
               var _loc3_:Object = _loc2_.m_extra["data"] as Object;
               var _loc4_:Player = Session.getInstance().host;
               if(_loc3_ != null && _loc3_[p._uId] != undefined)
               {
                  _loc4_._headPic = _loc3_[p._uId]["img"];
                  _loc4_._userName = _loc3_[p._uId]["nick"];
                  theApp.dispatchEvent(new CommonEvent(Consts.MSG_HOST_CHANGED,_loc4_));
               }
            },null);
         }
         else if(ExternalInterface.available == true)
         {
            mode = Settings.getInstance().mode;
            if(mode == "qzone" || mode == "qplus")
            {
               p._headPic = QzoneJSAPI.getHead(p.uin.toString(),50);
            }
            if(p._userName == null || p._userName == "")
            {
               p._userName = QzoneJSAPI.getNickname();
            }
            theApp.dispatchEvent(new CommonEvent(Consts.MSG_HOST_CHANGED,p));
         }
         theApp.dispatchEvent(new CommonEvent(Consts.MSG_SET_QQBROWSER_ALARM,null));
      }
      
      private function gameStart() : void
      {
         Security.loadPolicyFile("");
         Security.loadPolicyFile("");
         Security.loadPolicyFile("");
         Security.loadPolicyFile("");
         this.setup();
         theApp.startup();
      }
      
      private function onLoadDataError(param1:CommandEvent) : void
      {
         theApp.openFloat(Consts.FLOAT_TYPE_TEXTTIP,0,{
            "text":"系统繁忙",
            "parent":this.stage
         });
      }
      
      public function startGame(param1:Object) : void
      {
         var _loc7_:Friend = null;
         if(param1 == null)
         {
            return;
         }
         var _loc2_:StartupDataParser = new StartupDataParser();
         var _loc3_:ServiceResultVO = _loc2_.parse(param1);
         var _loc4_:StartupData = _loc3_.m_extra as StartupData;
         if(_loc4_ == null || _loc4_._user == null)
         {
            QzoneJSAPI.reportError("游戏基础数据读取失败",1);
            return;
         }
         if(_loc4_._serverTime != 0)
         {
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
         var _loc6_:Object = _loc4_._decors;
         if(_loc6_ != null)
         {
            if(_loc4_._dog != null)
            {
               _loc6_[Consts.DECOR_DOG.toString()] = {"itemId":_loc4_._dog._dogId};
            }
            _loc5_.sceneDecorates = _loc6_;
            theApp.model.setData(Consts.MY_FAIRY_OBJECT,_loc6_[Consts.ITEM_TYPE_FAIRY]);
         }
         this.gameStart();
         if(CommonData.useExpressUser == true)
         {
            _loc7_ = new Friend(CommonData.expressUser);
            theApp.dispatchEvent(new CommonEvent(Consts.MSG_SWITCH_USER,_loc7_));
            CommonData.useExpressUser = false;
            return;
         }
         theApp.dispatchEvent(new CommonEvent(Consts.MSG_STARTUP_DATA,_loc4_));
         this.loadAsyncWildModule(_loc4_._beast);
         this.doMiscThings();
      }
      
      private function doMiscThings() : void
      {
         var _loc3_:Object = null;
         var _loc1_:Settings = Settings.getInstance();
         var _loc2_:String = ExternalInterface.call("top.window.location.href.toString");
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc1_.mode == "qzone")
         {
            if(Boolean(_loc2_.match("actiontype=freegift")) || Boolean(_loc2_.match("actiontype%3Dfreegift")))
            {
               theApp.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_FREEGIFT,{"openIndex":1}));
               theApp.dispatchEvent(new CommonEvent(Consts.CLOSE_RECALL_WINDOW,null));
            }
            else if(Boolean(_loc2_.match("jumptoexchange=1005")) || Boolean(_loc2_.match("jumptoexchange%3D1005")))
            {
               Session.getInstance().isFromMail = true;
               ClickReportManager.reportClick("share.mailBackflow.come_from_mai_getBtn_nc_qzone");
            }
            else if(_loc2_.indexOf("via=QZONE.QQMAIL2") != -1 || _loc2_.indexOf("via%3DQZONE.QQMAIL2") != -1)
            {
               ClickReportManager.reportClick("share.mailBackflow.come_from_mail_nc_qzone");
            }
         }
         if(_loc2_.indexOf("%26from%3DlevelUpShare") != -1)
         {
            ClickReportManager.reportClick("share.levelUp.come_from_level_up_share_link_nc");
         }
         else if(_loc2_.indexOf("%26from%3DmailPresentShare") != -1)
         {
            ClickReportManager.reportClick("share.mailBackflow.come_from_mail_present_share_link_nc");
         }
         if(Boolean(_loc1_.openZhaoHui()) && QzoneJSAPI.QPLUS == false && QzoneJSAPI.WB == false)
         {
            if(Boolean(_loc2_.match("actiontype=request")) || Boolean(_loc2_.match("actiontype%3Drequest")))
            {
               if(_loc1_.getStringAttribute("app_request_num") != "0")
               {
                  RecallModel.m_backNum = parseInt(_loc1_.getStringAttribute("app_request_num"));
                  theApp.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_RECALL,null));
               }
               else if(_loc1_.mode == "qzone")
               {
                  _loc3_ = {
                     "owner":Session.getInstance().host.fid,
                     "appids":Consts.APP_ID,
                     "cb":0
                  };
                  NetHelper.sendRequest(CommandDefs.CMD_REQUEST_COUNT,_loc3_,this.onGetRequestCount,this.onLoadDataError);
               }
            }
         }
      }
      
      private function onNeedInputIDCode(param1:CommonEvent) : void
      {
         theApp.processNetException();
         theApp.openWindowByName(Consts.WINDOW_NAME_VALIDATE,{"callback":this.onValidateConfirmed});
      }
      
      private function onGetRequestCount(param1:CommandEvent) : void
      {
         if(param1.result["m_extra"] == null)
         {
            theApp.openFloat(Consts.FLOAT_TYPE_TEXTTIP,0,{
               "text":"系统繁忙",
               "parent":this.stage
            });
            return;
         }
         if(param1.result["m_extra"]["ret"] == null)
         {
            return;
         }
         if(param1.result["m_extra"]["ret"] < 0)
         {
            theApp.openFloat(Consts.FLOAT_TYPE_TEXTTIP,0,{
               "text":param1.result["m_extra"]["msg"],
               "parent":this.stage
            });
            return;
         }
         if(param1.result["m_extra"]["requests"] != null)
         {
            if(param1.result["m_extra"]["requests"].length != 0)
            {
               RecallModel.m_backNum = int(param1.result["m_extra"]["requests"].length);
               Cookies.setObject("getZhaohui",{"time":CommonData.serverTime});
               theApp.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_RECALL,null));
            }
         }
         else if(param1.result["m_extra"]["countlist"] != null)
         {
            if(param1.result["m_extra"]["countlist"].length != 0)
            {
               if(param1.result["m_extra"]["countlist"][0]["unread_num"] == null)
               {
                  return;
               }
               if(param1.result["m_extra"]["countlist"][0]["unread_num"] != 0)
               {
                  RecallModel.m_backNum = int(param1.result["m_extra"]["countlist"][0]["unread_num"]);
                  Cookies.setObject("getZhaohui",{"time":CommonData.serverTime});
                  theApp.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_RECALL,null));
               }
            }
         }
      }
   }
}

