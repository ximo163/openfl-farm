package module
{
   import com.cbmland.ui.RightMenu;
   import com.minutes.ui.control.LipiDefaultSkin;
   import com.minutes.ui.control.LipiScrollBarSkin;
   import com.minutes.ui.control.NUmbericStepperSkin;
   import com.qzone.allianceActivity.framewrok.manager.ClickReportManager;
   import com.qzone.corelib.js.JSProxy;
   import com.qzone.corelib.net.RSLManager;
   import com.qzone.qui.managers.PopUpManager;
   import common.CatchError;
   import common.CommonData;
   import common.INI;
   import common.LocalData;
   import common.MaterialLib;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.display.StageQuality;
   import flash.events.ContextMenuEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.external.ExternalInterface;
   import flash.geom.Point;
   import flash.net.LocalConnection;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLVariables;
   import flash.text.Font;
   import flash.ui.ContextMenuItem;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   import mc.FBridge.FRequest;
   import mc.control.Command;
   import mc.control.ViewControl;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.NewIconTip.NewIconTipController;
   import mc.view.NewIconTip.NewIconTipLayer;
   import mc.view.common.AlertWindow;
   import mc.view.farm.GetCropID;
   import mc.view.main.OutSwf.HelpWindow;
   import mc.view.main.TaskLayer;
   import mc.view.main.WindowControl.WControl;
   import mc.view.main.WindowControl.WindowClassLib;
   import mc.view.main.WindowLayer;
   import mc.view.main.cursor.Cursor;
   import mc.view.main.cursor.CursorLayer;
   import mc.view.main.floating.FloatingLayer;
   import mc.view.main.friend.FriendLayer;
   import mc.view.main.head.HeadBar;
   import mc.view.main.leftInfo.GiftWindow;
   import mc.view.main.leftInfo.LeftInfo;
   import mc.view.main.levelup.LevelUpModule;
   import mc.view.main.shield.InitLoading;
   import mc.view.main.shield.UserChanging;
   import mc.view.main.tip.TipLayer;
   import module.allianceActivitys.ActivityController;
   
   [SWF(width="500", height="375", backgroundColor="#ffffff", frameRate="24")]
   public class Master2 extends Sprite
   {
      
      private var initLoading:InitLoading;
      
      private var _ld:Loader = new Loader();
      
      private var EMBED_FONT_A:Class = Master2_EMBED_FONT_A;
      
      private var _head:HeadBar;
      
      private var addComp:Boolean = false;
      
      private var leftInfo:LeftInfo;
      
      private var dataComp:Boolean = false;
      
      private var moduleContent:Pasture;
      
      public function Master2()
      {
         super();
         trace("================================");
      }
      
      private function completeHandler2(param1:Event) : void
      {
         var _loc2_:XML = XML(param1.currentTarget.data);
         INI.getInstance().data.appendChild(_loc2_.elements());
      }
      
      private function onhelpMouseRoll(param1:MouseEvent) : void
      {
         Cursor.useSystem();
      }
      
      private function getMoneyOk(param1:Event) : void
      {
         if(contains(this._ld))
         {
            removeChild(this._ld);
            this._ld.unload();
         }
      }
      
      private function onMouseOver() : void
      {
         Cursor.useSystem(false);
      }
      
      private function getMoney(param1:Event) : void
      {
         Command.getInstance().mainCommand.getMoney();
      }
      
      public function init() : void
      {
         LocalData.parameters["speedInfo"] = new URLVariables();
         LocalData.parameters["speedInfo"]["flag1"] = 7721;
         LocalData.parameters["speedInfo"]["flag2"] = 2;
         LocalData.parameters["speedInfo"]["flag3"] = 1;
         LocalData.parameters["speedInfo"][1] = getTimer();
         trace("master init time :" + getTimer());
         LocalData.parameters["speedInfo"][3] = getTimer();
         LocalData.parameters["speedInfo"][5] = getTimer();
         CatchError.catchError(this.onUncaughtError,null,this.loaderInfo);
         Font.registerFont(this.EMBED_FONT_A);
         VersionUtil.setRightMenu(this);
         RSLManager.applicationDomain = CommonData.applicationDomain;
         CommonData.rslManager = RSLManager.getInstance();
         CommonData.rslManager.rslLoader = CommonData.rslLoader;
         CommonData.rslManager.rslLoader.ignoreError = true;
         this.setDefaultSkin();
         this.setRequestUrl();
         this.registerWindow();
         this.moduleContent = new Pasture();
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         var _loc1_:Timer = new Timer(120000);
         _loc1_.addEventListener(TimerEvent.TIMER,this.gc);
         _loc1_.start();
         RightMenu.addMenuItem(this,"高速模式(&Q)",this.toggleQaulity,true);
      }
      
      private function onUncaughtError(param1:*) : void
      {
         param1.preventDefault();
      }
      
      private function addLeftInfo() : void
      {
         this.leftInfo = new LeftInfo();
         this.leftInfo.y = 80;
         this.leftInfo.x = 15;
         addChild(this.leftInfo);
      }
      
      private function setDefaultSkin() : void
      {
         LipiDefaultSkin.WindowBg = MaterialLib.getInstance().getClass("WindowBg");
         LipiDefaultSkin.WindowCloseBg = MaterialLib.getInstance().getClass("CloseButton");
         LipiScrollBarSkin.BarIcon = MaterialLib.getInstance().getClass("ScrollBarIcon");
         LipiScrollBarSkin.BarSkin = MaterialLib.getInstance().getClass("ScrollBarSkin");
         LipiScrollBarSkin.UpSkin = MaterialLib.getInstance().getClass("ScrollUpSkin");
         LipiScrollBarSkin.DownSkin = MaterialLib.getInstance().getClass("ScrollDownSkin");
         NUmbericStepperSkin.BgSkin = MaterialLib.getInstance().getClass("StepperBg");
         NUmbericStepperSkin.IncSkin = MaterialLib.getInstance().getClass("RightButton");
         NUmbericStepperSkin.DecSkin = MaterialLib.getInstance().getClass("LeftButton");
      }
      
      private function gameStart() : void
      {
         var _loc1_:MainData = null;
         var _loc2_:MovieClip = null;
         var _loc3_:Point = null;
         if(this.dataComp && this.addComp)
         {
            this.loadCardXML();
            this.loadActivityXML();
            addChild(this.moduleContent);
            this.addHead();
            this.addLeftInfo();
            this.addTask();
            this.addFriend();
            this.addNewIconTip();
            this.addFloatingLayer();
            this.addWindowLayer();
            this.addTipLayer();
            this.addCursorLayer();
            this.addTopLayer();
            this.addLevelUpModule();
            Cursor.setCursor("CursorArrow");
            MData.getInstance().mainData.addEventListener(MainData.WELCOME,this.welcome);
            removeChild(this.initLoading);
            MData.getInstance().mainData.addEventListener(MainData.LEVEL_REWARD,this.levelReward,false,0,true);
            MData.getInstance().mainData.addEventListener(MainData.HOUSE_DATA_CHANGE,this.houseDataChange,false,0,true);
            ViewControl.getInstance().addEventListener("get_money_ok",this.getMoneyOk,false,0,true);
            this.dataComp = this.addComp = false;
            stage.addEventListener(Event.MOUSE_LEAVE,this.onMouseLeave);
            stage.addEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
            _loc1_ = MData.getInstance().mainData;
            if(GetCropID.canSellCubTip())
            {
               if(LocalData.getInstance().getObject("SellCubTip" + MData.getInstance().mainData.host["uId"]) != "1")
               {
                  _loc2_ = this._head.headToolBar.getChildByName("warehouse") as MovieClip;
                  _loc3_ = _loc2_.localToGlobal(new Point(_loc2_.stage.x,_loc2_.stage.y));
                  _loc3_ = new Point(_loc3_.x - 30,_loc3_.y + 50);
                  NewIconTipController.show(_loc3_,"可回收幼仔啦！");
                  LocalData.getInstance().setObject("SellCubTip" + MData.getInstance().mainData.host["uId"],"1");
               }
            }
            this.findLoginFrom();
         }
      }
      
      private function loadCardXML() : void
      {
         var _loc1_:URLLoader = new URLLoader();
         _loc1_.addEventListener(Event.COMPLETE,this.completeHandler2);
         _loc1_.addEventListener(IOErrorEvent.IO_ERROR,this.ioErrorHandler);
         if(LocalData.cardMaterialConfig)
         {
            _loc1_.load(new URLRequest(LocalData.cardMaterialConfig));
         }
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this.executeRun();
         this.initLoading = new InitLoading();
         this.initLoading.x = (stage.stageWidth - this.initLoading.width) / 2;
         this.initLoading.y = (stage.stageHeight - this.initLoading.height) / 2;
         addChild(this.initLoading);
         this.addComp = true;
         this.gameStart();
         CommonData.root = this;
      }
      
      private function addNewIconTip() : void
      {
         var _loc1_:NewIconTipLayer = new NewIconTipLayer();
         addChild(_loc1_);
      }
      
      private function __onQuickShoot(param1:Event) : void
      {
         Command.getInstance().toolCommand.quickShoot(this.moduleContent.rollCollection,this._head,MData.getInstance().mainData.currentUser.me ? null : this.leftInfo);
      }
      
      private function addFriend() : void
      {
         var _loc1_:FriendLayer = new FriendLayer();
         addChild(_loc1_);
      }
      
      private function addHead() : void
      {
         this._head = new HeadBar();
         this._head.width = stage.stageWidth;
         this._head.height = 68;
         addChild(this._head);
      }
      
      private function onHouseDataLoaded(param1:Event) : void
      {
         addChild(this._ld);
         var _loc2_:MovieClip = param1.target.content as MovieClip;
         MovieClip(_loc2_).addEventListener("getmoney",this.getMoney);
         var _loc3_:Object = MData.getInstance().mainData.houseChangeData;
         _loc2_["olv1"].text = _loc3_["lw"];
         _loc2_["olv2"].text = _loc3_["lp"];
         _loc2_["nlv1"].text = _loc3_["xw"];
         _loc2_["nlv2"].text = _loc3_["xp"];
         _loc2_["om"].text = _loc3_["lq"];
         _loc2_["nm"].text = _loc3_["xq"];
         _loc2_["bm"].text = _loc3_["bq"];
         MovieClip(_loc2_).x = Math.floor((stage.stageWidth - _loc2_["plan"].width) / 2);
      }
      
      private function loadAnimalXML() : void
      {
         var _loc1_:URLLoader = new URLLoader();
         _loc1_.addEventListener(Event.COMPLETE,this.completeHandler);
         _loc1_.addEventListener(IOErrorEvent.IO_ERROR,this.ioErrorHandler);
         if(LocalData.animalConfig)
         {
            _loc1_.load(new URLRequest(LocalData.animalConfig));
         }
      }
      
      private function runCompHandler(param1:Event) : void
      {
         this.dataComp = true;
         this.gameStart();
      }
      
      private function houseDataChange(param1:Event) : void
      {
         var _loc2_:XML = null;
         var _loc3_:String = "";
         if(_loc2_ == null)
         {
            _loc2_ = INI.getInstance().data;
         }
         _loc3_ = GetCropID.getSwfUrl() + "main/plan.swf";
         this._ld.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onHouseDataLoaded);
         this._ld.addEventListener(MouseEvent.ROLL_OVER,this.onLoaderMouseOver);
         this._ld.addEventListener(MouseEvent.ROLL_OUT,this.onLoaderMouseOver);
         this._ld.load(new URLRequest(_loc3_));
         this._ld.y = 10;
      }
      
      private function runError(param1:Event) : void
      {
         if(this.initLoading != null)
         {
            this.initLoading.errorText = MData.getInstance().mainData.runError;
         }
      }
      
      private function addTipLayer() : void
      {
         var _loc1_:TipLayer = new TipLayer();
         addChild(_loc1_);
      }
      
      private function addCursorLayer() : void
      {
         var _loc1_:CursorLayer = new CursorLayer();
         addChild(_loc1_);
      }
      
      private function loadActivityXML() : void
      {
         var _loc1_:XML = INI.getInstance().data.activity_list[0];
         var _loc2_:ActivityController = new ActivityController();
         _loc2_.loadConfig(_loc1_,CommonData.serverTime * 1000,LocalData.parameters.appImgPrefix);
      }
      
      private function addTopLayer() : void
      {
         addChild(new UserChanging());
      }
      
      private function addTask() : void
      {
         addChild(new TaskLayer());
      }
      
      private function addFloatingLayer() : void
      {
         var _loc1_:FloatingLayer = new FloatingLayer();
         addChild(_loc1_);
      }
      
      private function toggleQaulity(param1:ContextMenuEvent) : void
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
      
      private function completeHandler(param1:Event) : void
      {
         var _loc2_:XML = XML(param1.currentTarget.data);
         INI.getInstance().data.appendChild(_loc2_.elements());
         trace("animals 合并后节点数：",INI.getInstance().data.elements("animals").length());
         Command.getInstance().mainCommand.run();
         this.stage.addEventListener("expressUser",this.expressUserChange);
         ViewControl.getInstance().addEventListener("onquickshoot",this.__onQuickShoot);
      }
      
      private function levelReward(param1:Event) : void
      {
         var _loc3_:GiftWindow = null;
         var _loc2_:Object = MData.getInstance().mainData.levelReward;
         if(_loc2_ != null)
         {
            _loc3_ = new GiftWindow();
            _loc3_.giftData = _loc2_;
            WControl.open(_loc3_);
         }
      }
      
      private function executeRun() : void
      {
         MData.getInstance().mainData.addEventListener(MainData.RUN_COMP,this.runCompHandler);
         MData.getInstance().mainData.addEventListener(MainData.SESSION_TIMEOUT,this.sessionTimeout);
         MData.getInstance().mainData.addEventListener(MainData.RUN_ERROR,this.runError);
         trace("animals 原节点数：",INI.getInstance().data.elements("animals").length());
         if(INI.getInstance().data.elements("animals").length())
         {
            this.stage.addEventListener("expressUser",this.expressUserChange);
            ViewControl.getInstance().addEventListener("onquickshoot",this.__onQuickShoot);
            Command.getInstance().mainCommand.run();
         }
      }
      
      private function setCursor() : void
      {
         Cursor.useSystem();
      }
      
      private function onLoaderMouseOut(param1:MouseEvent) : void
      {
         Cursor.useSystem(false);
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
      
      private function onMouseLeave(param1:Event) : void
      {
         Cursor.useSystem(true);
      }
      
      private function welcome(param1:Event = null) : void
      {
         var _loc2_:HelpWindow = null;
         if(MData.getInstance().mainData.welcome == true)
         {
            _loc2_ = new HelpWindow();
            setTimeout(this.setCursor,500);
            addChild(_loc2_);
            MData.getInstance().mainData.removeEventListener(MainData.WELCOME,this.welcome);
            _loc2_.addEventListener(MouseEvent.ROLL_OVER,this.onhelpMouseRoll);
         }
      }
      
      private function onLoaderMouseOver(param1:MouseEvent) : void
      {
         Cursor.useSystem();
      }
      
      private function ioErrorHandler(param1:IOErrorEvent) : void
      {
         MData.getInstance().mainData.runError = "登录超时，请重新登录。";
      }
      
      private function setRequestUrl() : void
      {
         FRequest.getInstance().httpUrl = INI.getInstance().getPostUrl();
         MainData.commonUrlFarm = GetCropID.getCommonUrlFarm();
         MainData.commonUrlNc = GetCropID.getCommonUrlNc();
      }
      
      private function addLevelUpModule() : void
      {
         new LevelUpModule();
      }
      
      private function sessionTimeout(param1:Event) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc2_:Object = JSProxy.showLoginWindow();
         if(!_loc2_)
         {
            WindowClassLib.register("AlertWindow",AlertWindow);
            _loc3_ = INI.getInstance().data.version.@loginurl;
            _loc4_ = "_top";
            WControl.openForName("AlertWindow",{
               "type":"error",
               "text":MData.getInstance().mainData.sessionTimeout,
               "gotourl":_loc3_,
               "target":_loc4_
            });
         }
      }
      
      private function addWindowLayer() : void
      {
         var _loc1_:WindowLayer = new WindowLayer();
         ViewControl.getInstance().windowsLayer = _loc1_;
         addChild(_loc1_);
         PopUpManager.init(this);
         addChild(PopUpManager.getInstance());
      }
      
      private function expressUserChange(param1:Event) : void
      {
         if(LocalData.useExpressUser)
         {
            Command.getInstance().mainCommand.setUser(LocalData.expressUser);
            LocalData.useExpressUser = false;
         }
      }
      
      private function registerWindow() : void
      {
         WindowClassLib.register("AlertWindow",AlertWindow);
      }
      
      private function findLoginFrom() : void
      {
         var _loc1_:String = ExternalInterface.call("top.window.location.href.toString");
         if(_loc1_ == null)
         {
            return;
         }
         if(_loc1_.indexOf("%26from%3DlevelUpShare") != -1)
         {
            ClickReportManager.reportClick("share.levelup.come_from_level_up_share_link_mc");
         }
      }
   }
}

import mc.view.main.floating.FloatingBase;

FloatingBase;

