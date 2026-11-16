package module.uitools
{
   import com.qzone.allianceActivity.AllianceActivityManager;
   import com.qzone.allianceActivity.interfaces.IAllianceActivityContext;
   import com.qzone.utils.DisplayUtil;
   import common.CommonData;
   import common.Consts;
   import common.Session;
   import common.Settings;
   import common.misc.Cookies;
   import common.misc.Utils;
   import entities.Item;
   import entities.Player;
   import entities.StartupData;
   import events.CommonEvent;
   import events.ViewEvent;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import framework.api.beast.BeastAPI;
   import framework.base.Controller;
   import interfaces.IModule;
   import interfaces.IMsgCenter;
   import module.uitools.widgets.*;
   import report.ClickReportManager;
   import report.UserActionRecorder;
   
   public class UIController extends Controller
   {
      
      private var m_toolBoxBar:ToolBoxBar;
      
      private var m_shortcuts:ShortcutBar;
      
      private var m_navbar:NavigationBar;
      
      private var m_toolbar:ToolBar;
      
      private var m_headerBG:Sprite;
      
      private var healthFirst:Boolean = true;
      
      private var _planeBtn:MovieClip;
      
      private var m_playerbar:PersonInfo;
      
      private var _api:BeastAPI = BeastAPI.getInstance();
      
      private var m_friendbar:PersonInfo;
      
      private var _leftSideBar:LeftSideToolBar;
      
      private var m_poolInfo:SimpleButton;
      
      public function UIController(param1:IModule)
      {
         super(param1);
      }
      
      private function onHostDataChanged(param1:Event) : void
      {
         this.model.updateHostInfo();
      }
      
      private function onRefreshPoolInfo(param1:CommonEvent) : void
      {
         var tfSize:TextField = null;
         var e:CommonEvent = param1;
         var data:* = e.data;
         if(data["size"] >= 0)
         {
            if(this.m_poolInfo == null)
            {
               this.m_poolInfo = Utils.getMaterial("PoolInfoBtn") as SimpleButton;
               if(this.m_poolInfo != null)
               {
                  this.m_poolInfo.x = m_module.container.stage.stageWidth - 64;
                  this.m_poolInfo.y = m_module.container.stage.stageHeight - 40;
                  m_module.container.addChild(this.m_poolInfo);
                  this.m_poolInfo.addEventListener(MouseEvent.CLICK,function(param1:MouseEvent):void
                  {
                     m_module.app.dispatchEvent(new Event(Consts.MSG_SHOW_POOLINFO));
                  });
               }
               if(this.m_poolInfo != null && this.m_poolInfo["tfSize"] == null)
               {
                  tfSize = new TextField();
                  tfSize.defaultTextFormat = new TextFormat("Arial",12,16120557);
                  tfSize.filters = [new GlowFilter(3342336,1,2,2,10,1)];
                  tfSize.selectable = false;
                  tfSize.multiline = false;
                  tfSize.mouseEnabled = false;
                  this.m_poolInfo["tfSize"] = tfSize;
                  tfSize.x = this.m_poolInfo.x;
                  tfSize.y = this.m_poolInfo.y;
                  m_module.container.addChild(tfSize);
               }
            }
            if(this.m_poolInfo != null && this.m_poolInfo["tfSize"] != null)
            {
               this.m_poolInfo["tfSize"].text = data["size"] + "/" + Consts.FISH_MAX_SIZE;
            }
         }
         else if(this.m_poolInfo != null)
         {
            if(this.m_poolInfo["tfSize"] != null)
            {
               DisplayUtil.removeChild(m_module.container,this.m_poolInfo["tfSize"]);
               this.m_poolInfo["tfSize"] = null;
            }
            DisplayUtil.removeChild(m_module.container,this.m_poolInfo);
            this.m_poolInfo = null;
         }
      }
      
      override public function initialze() : void
      {
         super.initialze();
         if(m_module.container == null)
         {
            return;
         }
         if(m_model == null)
         {
            m_model = new UIToolsModel(this);
         }
         this.registerListeners();
         if(this.m_toolbar == null)
         {
            this.m_toolbar = new ToolBar(this);
            m_module.container.addChild(this.m_toolbar);
            this.m_toolbar.addEventListener(ToolBar.MODULE_EVENT_CLICK_PACK,this.onPackClicked);
            this.m_toolbar.addEventListener(ToolBar.MODULE_EVENT_CLICK_TOOLBOX,this.onToolBoxClicked);
            this.m_toolbar.addEventListener("hidebeast",this.onHidebeast);
         }
         if(this.m_headerBG == null)
         {
            this.m_headerBG = Utils.getMaterial("HeadBg") as Sprite;
            this.m_headerBG.width = m_module.app.farmView.stage.stageWidth;
            m_module.container.addChild(this.m_headerBG);
         }
         if(this.m_navbar == null)
         {
            this.m_navbar = new NavigationBar(this);
            this.m_navbar.addEventListener(ViewEvent.CHILD_CLICK,this.onNavigateBarClicked,false,0,true);
            m_module.container.addChild(this.m_navbar);
         }
         if(this._planeBtn == null)
         {
         }
         if(this.m_playerbar == null)
         {
            this.m_playerbar = new PersonInfo(this,true);
            this.m_playerbar.x = 15;
            this.m_playerbar.name = "__playerbar__";
            m_module.container.addChild(this.m_playerbar);
         }
         if(this.m_shortcuts == null)
         {
            this.m_shortcuts = new ShortcutBar(this);
            this.m_shortcuts.name = "__shortcuts__";
            m_module.container.addChild(this.m_shortcuts);
            this.m_shortcuts.x = 45;
         }
         this.creatLeftSideBar();
         this.m_poolInfo = null;
         this.m_friendbar = null;
         this.m_toolBoxBar = null;
         this._api.beastPackContainer = this.m_toolbar;
         this._api.addEventListener(EvtAPI.SHOW_BEAST_PACK,this.hideOtherBar);
         m_module.app.addEventListener(Consts.GOLD_LAND_UPDATE_TIME_CHANGE,this.onGoldLandTimeChange,false,0,true);
      }
      
      private function onHealthModeOpenClose(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:Boolean = param1.data["open"] as Boolean;
         if(this.m_toolBoxBar != null)
         {
            this.m_toolBoxBar.toggleHealthMode(_loc2_);
         }
      }
      
      private function onCurrentUserChanged(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:Player = param1.data;
         if(_loc2_ == null)
         {
            return;
         }
         if(this.m_navbar != null)
         {
            this.m_navbar.currentUserChanged();
         }
         if(_loc2_.me == true)
         {
            if(this.m_friendbar != null && this.m_friendbar.parent != null)
            {
               this.m_friendbar.parent.removeChild(this.m_friendbar);
            }
            m_module.container.addChild(this.m_shortcuts);
         }
         else
         {
            if(this.m_shortcuts.parent != null)
            {
               this.m_shortcuts.parent.removeChild(this.m_shortcuts);
            }
            if(this.m_friendbar == null)
            {
               this.m_friendbar = new PersonInfo(this,false);
               this.m_friendbar.x = 15;
               this.m_friendbar.y = 80;
               this.m_friendbar.name = "__friendbar__";
            }
            m_module.container.addChild(this.m_friendbar);
            this.m_friendbar.setFriendInfo(_loc2_);
         }
      }
      
      private function onCheckLevelUp(param1:CommonEvent) : void
      {
         this.model.checkLevelup(param1.data as int);
      }
      
      override public function finalize() : void
      {
         super.finalize();
      }
      
      private function onNavigateBarClicked(param1:ViewEvent) : void
      {
         var _loc3_:IAllianceActivityContext = null;
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:String = param1.data["name"];
         if(_loc2_ == "warehouse")
         {
            m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_WAREHOUSE,null));
            UserActionRecorder.recordAction(UserActionRecorder.HF_WAREHOUSE_CLICKED);
            ClickReportManager.reportClick("up.banner.icon_warehouse.click");
         }
         else if(_loc2_ == "shop")
         {
            m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_SHOP,null));
            UserActionRecorder.recordAction(UserActionRecorder.HF_SHOP_CLICKED);
            ClickReportManager.reportClick("up.banner.icon_shop.click");
         }
         else if(_loc2_ == "farm")
         {
            BeastAPI.getInstance().showFarmStage();
            m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_SWITCH_USER,null));
            UserActionRecorder.recordAction(UserActionRecorder.HF_MYFARM_CLICKED);
            ClickReportManager.reportClick("up.banner.icon_farm.click");
         }
         else if(_loc2_ == "decorate")
         {
            if(Session.getInstance().me == false)
            {
               m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_SWITCH_USER,null));
               m_module.app.dispatchEvent(new Event(Consts.MSG_OPEN_WAREHOUSE_AFTER_BACK));
            }
            else
            {
               m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_DIY,null));
            }
            UserActionRecorder.recordAction(UserActionRecorder.HF_DECORATE_CLICKED);
            ClickReportManager.reportClick("up.banner.icon_decoration.click");
         }
         else if(_loc2_ == "collecting")
         {
            _loc3_ = AllianceActivityManager.getInstance().getActivityContext("collecting");
            if(_loc3_ != null)
            {
               _loc3_.execute("openActivityWin");
               ClickReportManager.reportClick("up.banner.icon_collecting.click");
            }
         }
      }
      
      public function isCardGameActivity() : Boolean
      {
         var _loc1_:String = Settings.getInstance().getStringAttribute("cardActivityStart");
         var _loc2_:String = Settings.getInstance().getStringAttribute("cardActivityEnd");
         var _loc3_:Number = new Date(_loc1_).time;
         var _loc4_:Number = new Date(_loc2_).time;
         var _loc5_:Number = CommonData.serverTime * 1000;
         if(_loc3_ < _loc5_ && _loc5_ < _loc4_)
         {
            return true;
         }
         return false;
      }
      
      private function onGetDogValidTime(param1:int) : void
      {
         var _loc3_:Item = null;
         if(param1 != 7 && param1 != 3 && param1 != 1)
         {
            return;
         }
         var _loc2_:int = Cookies.getObject("dogValidTipsDaysShow" + Session.getInstance().hostId) as int;
         if(_loc2_ == param1)
         {
            return;
         }
         Cookies.setObject("dogValidTipsDaysShow" + Session.getInstance().hostId,param1);
         _loc3_ = new Item(null);
         _loc3_._id = 10;
         _loc3_._type = 4;
         _loc3_._name = "藏獒";
         _loc3_._buy_1 = 100;
         _loc3_._buy_6 = 550;
         _loc3_._buy_12 = 1000;
         _loc3_._Ybuy_1 = 80;
         _loc3_._Ybuy_6 = 440;
         _loc3_._Ybuy_12 = 800;
         _loc3_._fb = 100;
         _loc3_._yfb = 80;
         _loc3_._price = 0;
         _loc3_._desc = "";
         _loc3_._isQDDog = true;
         _loc3_._renew = true;
         _loc3_._timeLimit = param1;
         m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_BUY_DOG_FOOD,_loc3_));
      }
      
      private function onAcceptNewGift(param1:Event) : void
      {
         this.model.loadEveryDayGift();
      }
      
      private function onPlaneClicked(param1:MouseEvent) : void
      {
         m_module.app.dispatchEvent(new Event(Consts.MSG_CALL_PLANE));
         if(this._planeBtn != null)
         {
            this._planeBtn.gotoAndStop(41);
         }
         hideTip();
      }
      
      private function onPlaneOver(param1:MouseEvent) : void
      {
         showTip(Consts.TIP_NAME_MOUSE,"飞机施肥，一键全熟");
      }
      
      private function onWaterPoolOpened(param1:CommonEvent) : void
      {
         this.m_toolbar.refresh();
      }
      
      private function onHidebeast(param1:Event) : void
      {
         if(this._api)
         {
            this._api.hideBeastPack();
         }
      }
      
      public function get model() : UIToolsModel
      {
         return m_model as UIToolsModel;
      }
      
      private function hideOtherBar(param1:EvtAPI) : void
      {
         if(this.m_toolBoxBar)
         {
            this.m_toolBoxBar.close();
         }
      }
      
      private function removeNewIconTip(param1:CommonEvent) : void
      {
         var _loc2_:MovieClip = m_module.container.getChildByName("__newicontip__") as MovieClip;
         if(_loc2_)
         {
            m_module.container.removeChild(_loc2_);
            _loc2_ = null;
         }
         this.m_toolbar.removeWildText();
      }
      
      private function onPlaneOut(param1:MouseEvent) : void
      {
         hideTip();
      }
      
      private function onGameDataReloaded(param1:CommonEvent) : void
      {
         if(Session.getInstance().me == true)
         {
            this.onStartupData(param1);
         }
         var _loc2_:Player = Session.getInstance().currentUser;
         if(this.m_toolbar != null)
         {
            this.m_toolbar.myHome = _loc2_.me == true ? true : false;
         }
         m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_PACK,{"close":true}));
         if(this.m_toolBoxBar != null)
         {
            this.m_toolBoxBar.close();
         }
         if(this._planeBtn != null)
         {
            this._planeBtn.visible = _loc2_.me == true ? true : false;
         }
      }
      
      private function onToolBoxClicked(param1:Event) : void
      {
         var _loc2_:Player = null;
         if(this.m_toolBoxBar == null)
         {
            this.m_toolBoxBar = new ToolBoxBar(this);
            m_module.container.addChild(this.m_toolBoxBar);
         }
         else
         {
            this.m_toolBoxBar.toggleVisible();
         }
         if(this.m_toolBoxBar.visible == true)
         {
            m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_PACK,{"close":true}));
         }
         if(this.healthFirst)
         {
            _loc2_ = Session.getInstance().host;
            this.m_toolBoxBar.toggleHealthMode(_loc2_._healthMode._set == 1 || _loc2_._healthMode._valid == 1);
            this.healthFirst = false;
         }
      }
      
      private function registerListeners() : void
      {
         if(m_module == null || m_module.app == null)
         {
            return;
         }
         var _loc1_:IMsgCenter = m_module.app as IMsgCenter;
         if(_loc1_ != null)
         {
            _loc1_.addEventListener(Consts.MSG_STARTUP_DATA,this.onStartupData,false,0,true);
            _loc1_.addEventListener(Consts.MSG_RELOAD_GAME_RESULT,this.onGameDataReloaded,false,0,true);
            _loc1_.addEventListener(Consts.MSG_HOST_CHANGED,this.onHostDataChanged,false,0,true);
            _loc1_.addEventListener(Consts.MSG_CURRENT_USER_CHANGED,this.onCurrentUserChanged,false,0,true);
            _loc1_.addEventListener(Consts.MSG_HEALTH_MODE_OPEN_CHANGED,this.onHealthModeOpenClose,false,0,true);
            _loc1_.addEventListener(Consts.MSG_ACCEPT_NEW_GIFT,this.onAcceptNewGift,false,0,true);
            _loc1_.addEventListener(Consts.MSG_TRUNK_SYSTEM_TOOLBAR,this.onChangeToolBar,false,0,true);
            _loc1_.addEventListener(Consts.MSG_CHECK_LEVELUP,this.onCheckLevelUp,false,0,true);
            _loc1_.addEventListener(Consts.MSG_LEVELUP,this.onLevelUp,false,0,true);
            _loc1_.addEventListener(Consts.DELEVE_NEW_ICON,this.removeNewIconTip,false,0,true);
            _loc1_.addEventListener(Consts.MSG_POOL_OPEN,this.onWaterPoolOpened,false,0,true);
            _loc1_.addEventListener(Consts.MSG_REFRESH_POOLINFO,this.onRefreshPoolInfo,false,0,true);
            _loc1_.addEventListener(Consts.MSG_ADD_COLLECTING_ICON,this.onAddCollectingIcon,false,0,true);
         }
         this.model.addEventListener(UIToolsModel.EVENT_EVERYDAY_GIFT_ACCEPTED,this.onDayGiftAcceptedByServer,false,0,true);
         this.model.addEventListener(UIToolsModel.EVENT_LEVELUP_GIFTS,this.onLevelUpGiftAccepted,false,0,true);
      }
      
      private function onLevelUp(param1:CommonEvent) : void
      {
         this.model.addLevelUp(param1.data);
      }
      
      public function openCameraShootWindow() : void
      {
         var _loc1_:IMsgCenter = m_module.app as IMsgCenter;
         if(_loc1_ != null)
         {
            _loc1_.dispatchEvent(new CommonEvent(Consts.MSG_CAMERA,true));
         }
      }
      
      private function onStartupData(param1:CommonEvent) : void
      {
         var _loc5_:int = 0;
         var _loc2_:StartupData = param1.data as StartupData;
         if(_loc2_ != null)
         {
            this.model.initializeMyProfile();
            this.model.updateOfflineStatus(_loc2_._unread);
         }
         var _loc3_:Player = Session.getInstance().host;
         if(_loc3_ != null && _loc3_._healthMode != null)
         {
            if(this.m_toolBoxBar != null)
            {
               this.m_toolBoxBar.toggleHealthMode(_loc3_._healthMode._set == 1 || _loc3_._healthMode._valid == 1);
            }
         }
         var _loc4_:Array = _loc2_._user._levelup;
         if(_loc4_ != null && _loc4_.length > 0)
         {
            this.model.addLevelUp(_loc4_);
         }
         if(_loc2_._dog._dogId == Consts.DOG_TIBETAN_MASTIFF_ID && _loc2_._dog._validTime >= 0)
         {
            _loc5_ = (_loc2_._dog._validTime - CommonData.serverTime) / 86400;
            this.onGetDogValidTime(_loc5_);
         }
      }
      
      private function onChangeToolBar(param1:CommonEvent) : void
      {
         var _loc2_:Boolean = param1.data as Boolean;
         if(_loc2_)
         {
            this.m_toolbar.visible = false;
            if(this.m_poolInfo != null)
            {
               this.m_poolInfo.visible = false;
               if(this.m_poolInfo["tfSize"] != null)
               {
                  this.m_poolInfo["tfSize"]["visible"] = false;
               }
            }
            if(this._planeBtn != null)
            {
               this._planeBtn.visible = false;
            }
         }
         else
         {
            this.m_toolbar.visible = true;
            if(this.m_poolInfo != null)
            {
               this.m_poolInfo.visible = true;
               if(this.m_poolInfo["tfSize"] != null)
               {
                  this.m_poolInfo["tfSize"]["visible"] = true;
               }
            }
         }
      }
      
      private function onGoldLandTimeChange(param1:CommonEvent) : void
      {
         this.m_toolbar.updateGoldLandTime(param1.data);
      }
      
      public function switchBigMode(param1:Boolean) : void
      {
         Cookies.Set("bigmode",param1 ? "1" : "0");
         var _loc2_:IMsgCenter = m_module.app as IMsgCenter;
         if(_loc2_ != null)
         {
            _loc2_.dispatchEvent(new CommonEvent(Consts.MSG_ZOOM,param1));
         }
      }
      
      private function onDayGiftAcceptedByServer(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:* = param1.data;
         var _loc3_:Array = [];
         if(_loc2_["item"] != undefined && _loc2_["item"] != null && _loc2_["item"] is Array)
         {
            _loc3_ = _loc3_.concat(_loc2_["item"]);
         }
         if(_loc2_.hasOwnProperty("vipItem") == true && _loc2_["vipItem"] != undefined && _loc2_["vipItem"] is Array)
         {
            _loc3_ = _loc3_.concat(_loc2_["vipItem"]);
         }
         if(_loc2_.hasOwnProperty("packagetime"))
         {
            Cookies.setObject("new_user_" + Session.getInstance().host._uId,_loc2_["packagetime"]);
         }
         Session.getInstance().addReward(_loc3_);
      }
      
      private function onLevelUpGiftAccepted(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:Array = [];
         var _loc3_:* = param1.data;
         if(_loc3_.hasOwnProperty("item") == true)
         {
            _loc3_["big"] = false;
            m_module.app.openWindowByName(Consts.WINDOW_NAME_GIFT,_loc3_);
            _loc2_ = _loc2_.concat(_loc3_["item"]);
         }
         if(_loc3_.hasOwnProperty("vipItem") == true && _loc3_["vipItem"] != false)
         {
            _loc2_ = _loc2_.concat(_loc3_["vipItem"]);
         }
         Session.getInstance().addReward(_loc2_);
      }
      
      private function onAddCollectingIcon(param1:CommonEvent) : void
      {
         var _loc2_:String = param1.data["url"] as String;
         var _loc3_:String = param1.data["tip"] as String;
         this.m_navbar.addIcon(_loc2_,"collecting",_loc3_);
      }
      
      private function creatLeftSideBar() : void
      {
         if(!this._leftSideBar)
         {
            this._leftSideBar = new LeftSideToolBar(this,60,250);
            this.m_shortcuts.name = "__leftSideBar__";
            m_module.container.addChild(this._leftSideBar);
            this._leftSideBar.y = 75;
         }
      }
      
      private function onPackClicked(param1:Event) : void
      {
         m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_PACK,null));
         if(this.m_toolBoxBar != null)
         {
            this.m_toolBoxBar.close();
         }
      }
      
      private function showNewIconTip(param1:String, param2:Point) : void
      {
         var _loc3_:MovieClip = Utils.getMaterial("newIconTip") as MovieClip;
         _loc3_.name = "__newicontip__";
         _loc3_.tipMc.tip.text = param1;
         _loc3_.gotoAndPlay(1);
         _loc3_.x = param2.x;
         _loc3_.y = param2.y;
         m_module.container.addChild(_loc3_);
      }
   }
}

