package plugins.external.fairy
{
   import com.greensock.TweenLite;
   import com.greensock.plugins.TintPlugin;
   import com.greensock.plugins.TweenPlugin;
   import com.qzone.farm.api.interfaces.IFarmAPI;
   import com.qzone.farm.api.interfaces.IPlugin;
   import common.CommonData;
   import common.Consts;
   import entities.Player;
   import events.CommonEvent;
   import flash.display.DisplayObjectContainer;
   import flash.display.InteractiveObject;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.filters.GlowFilter;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.system.Security;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   import module.Main;
   import report.ClickReportManager;
   
   [SWF(width="500", height="375", backgroundColor="#869ca7", frameRate="24")]
   public class FairyPlugin extends Sprite implements IPlugin
   {
      
      internal static const BASE_ID:uint = 92001;
      
      internal static const MAX_DONATE:Array = [0,150000,300000,1000000];
      
      private var _toOpen:int;
      
      private var _xianHuangIcon:Class = FairyPlugin__xianHuangIcon;
      
      private var _stage:DisplayObjectContainer;
      
      private var _buyWin:BuyWindowWrapper;
      
      private var _mainWin:MainWindowWrapper;
      
      private var _iconEntrance:MovieClip;
      
      private var _model:FairyModel;
      
      private var _iconCls:Class = FairyPlugin__iconCls;
      
      private var _discountIcon:Boolean;
      
      private var _id:int;
      
      private var _xianHuangEntrace:MovieClip;
      
      private var _filters:Array;
      
      private var _loader:Loader;
      
      private var _xianhuangWin:XianHuangWindowWrapper;
      
      private var _rebuyWin:ReBuyWindowWrapper;
      
      private var _fairy:MovieClip;
      
      private var _moneyWin:MoneyWindowWrapper;
      
      private var _friends:FriendsModel;
      
      private var _flagCls:Class = FairyPlugin__flagCls;
      
      private var _config:Object;
      
      private var _api:IFarmAPI;
      
      private var _activeDonate:uint;
      
      private var _activeTimeout:uint;
      
      public function FairyPlugin()
      {
         super();
         Security.allowDomain("happyfarm.qzone.qq.com");
         Security.allowDomain("happyfarm.xiaoyou.qq.com");
         Security.allowDomain("appimg1.qq.com");
         Security.allowDomain("appimg.qq.com");
         Security.allowDomain("imgcache.qq.com");
         TweenPlugin.activate([TintPlugin]);
         var _loc1_:Array = new Array();
         _loc1_ = _loc1_.concat([1.1,0,0,0,0]);
         _loc1_ = _loc1_.concat([0,1.1,0,0,0]);
         _loc1_ = _loc1_.concat([0,0,1.1,0,0]);
         _loc1_ = _loc1_.concat([0,0,0,1,0]);
         this._filters = [new GlowFilter(13434624,1,10,10),new ColorMatrixFilter(_loc1_)];
         this._activeDonate = 0;
         this._activeTimeout = 0;
         this._discountIcon = false;
      }
      
      private function openReBuyWindow() : void
      {
         var leftSec:Number;
         if(this._rebuyWin == null)
         {
            this._rebuyWin = new ReBuyWindowWrapper(this);
         }
         leftSec = this._model.myExpireTime - CommonData.serverTime;
         leftSec /= 24 * 60 * 60;
         leftSec = Math.floor(leftSec) as int;
         if(leftSec == 1 || leftSec == 3 || leftSec == 5 || leftSec == 7)
         {
            if(this._model.fairyItem["itemId"] - BASE_ID == 3 && this.model.canBuySprite4 == false)
            {
               return;
            }
            this.callProxy(2009,true);
            this._rebuyWin.show(this._model.fairyItem["itemId"] - BASE_ID,leftSec,this._model.myName,this._model.discount);
            this._rebuyWin.addEventListener("buy",function(param1:CommonEvent):void
            {
               if(param1 == null || param1.data == null)
               {
                  return;
               }
               var _loc2_:int = param1.data["month"] as int;
               _model.buySprite(param1.data["index"] + BASE_ID,_loc2_);
               api.reportReturnCode("160611",_loc2_.toString());
            });
         }
      }
      
      private function onAvatarLoadFailed(param1:IOErrorEvent) : void
      {
         this.callProxy(2007,false);
      }
      
      private function onUserChanged(param1:CommonEvent) : void
      {
         var _loc2_:Player = param1.data as Player;
         if(_loc2_ == null)
         {
            return;
         }
         if(this._model.player.uin == _loc2_.uin && this._model.player._uId == _loc2_._uId)
         {
            return;
         }
         this._model.player = _loc2_;
         var _loc3_:Object = this.callProxy(2001,null);
         if(_loc3_ != null)
         {
            _loc3_["id"] = _loc3_["itemId"];
            _loc3_["rate"] *= 10;
         }
         this.updateFairy(_loc3_,false);
         if(this._activeTimeout > 0)
         {
            clearTimeout(this._activeTimeout);
         }
         if(_loc2_.me == false && this._activeDonate != 0 && _loc2_._uId == this._activeDonate)
         {
            if(_loc3_ != null)
            {
               this._activeTimeout = setTimeout(this.onAutoShowMoneyWin,400);
            }
            else
            {
               this._activeDonate = 0;
            }
         }
      }
      
      public function confirmBuySprite(param1:int, param2:int) : void
      {
         var docontainer:DisplayObjectContainer = null;
         var index:int = param1;
         var containerType:int = param2;
         if(index == 3 && this.model.canBuySprite4 == false)
         {
            return;
         }
         if(this._buyWin == null)
         {
            this._buyWin = new BuyWindowWrapper();
         }
         switch(containerType)
         {
            case 0:
               docontainer = this._moneyWin.container;
               break;
            case 1:
               docontainer = this._mainWin.container;
               break;
            case 2:
               docontainer = this._xianhuangWin.container;
         }
         this._buyWin.show(index,docontainer,this._model.discount);
         this._buyWin.addEventListener("buy",function(param1:CommonEvent):void
         {
            if(param1 == null || param1.data == null)
            {
               return;
            }
            var _loc2_:int = param1.data["month"] as int;
            _model.buySprite(param1.data["index"] + BASE_ID,_loc2_);
            api.reportReturnCode("160564",_loc2_.toString());
         });
      }
      
      public function updateFairy(param1:Object, param2:Boolean) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         if(param1 != null)
         {
            if(param2 == true)
            {
               _loc4_ = {
                  "itemId":param1["id"],
                  "lv":param1["lv"],
                  "rate":param1["rate"]
               };
               this.callProxy(2000,_loc4_);
            }
            _loc3_ = 0;
            if(this.model.fairyItem != null)
            {
               _loc3_ = int(this.model.fairyItem["itemId"]);
            }
            else
            {
               this.model.fairyItem = {};
            }
            this.model.fairyItem["itemId"] = param1["id"];
            this.model.fairyItem["lv"] = param1["lv"];
            this.model.fairyItem["rate"] = param1["rate"];
            if(_loc3_ != param1["id"])
            {
               this.createFairy(param1["id"],param1["lv"]);
            }
         }
         else
         {
            this.createFairy(0,0);
            this.model.fairyItem = null;
         }
      }
      
      private function removeXianHuangIcon(param1:CommonEvent) : void
      {
         if(param1.data.id == 92004)
         {
            this._model.removeEventListener(FairyModel.MSG_PAIRY_BOUGHT,this.removeXianHuangIcon);
            Main.theApp.dispatchEvent(new CommonEvent(Consts.MSG_REMOVE_SHORTCUT_ICON,this._xianHuangEntrace.parent));
         }
      }
      
      public function executeCommand(param1:int, param2:Object) : Object
      {
         var _loc3_:DisplayObjectContainer = null;
         switch(param1)
         {
            case 1000:
               if(param2 != null && param2 is DisplayObjectContainer)
               {
                  _loc3_ = param2 as DisplayObjectContainer;
                  if(_loc3_ != null)
                  {
                     while(_loc3_.numChildren > 0)
                     {
                        _loc3_.removeChildAt(0);
                     }
                  }
                  if(this._iconEntrance != null && this._model.fairyItem["itemId"] != 92004)
                  {
                     this._xianHuangEntrace = new this._xianHuangIcon() as MovieClip;
                     this._xianHuangEntrace.y += 4;
                     this._xianHuangEntrace.buttonMode = true;
                     this._xianHuangEntrace.mouseChildren = false;
                     _loc3_.addChild(this._xianHuangEntrace);
                     this._xianHuangEntrace.addEventListener(MouseEvent.CLICK,this.onMouseEvent,false,0,true);
                     this._xianHuangEntrace.addEventListener(MouseEvent.ROLL_OUT,this.onMouseEvent,false,0,true);
                     this._xianHuangEntrace.addEventListener(MouseEvent.ROLL_OVER,this.onMouseEvent,false,0,true);
                     this._model.addEventListener(FairyModel.MSG_PAIRY_BOUGHT,this.removeXianHuangIcon,false,0,true);
                  }
                  if(this._iconEntrance == null)
                  {
                     this._iconEntrance = new this._iconCls() as MovieClip;
                     this._iconEntrance.buttonMode = true;
                     this._iconEntrance.stop();
                     this._iconEntrance.mouseChildren = false;
                     _loc3_.addChild(this._iconEntrance);
                     this._iconEntrance.addEventListener(MouseEvent.CLICK,this.onMouseEvent,false,0,true);
                     this._iconEntrance.addEventListener(MouseEvent.ROLL_OUT,this.onMouseEvent,false,0,true);
                     this._iconEntrance.addEventListener(MouseEvent.ROLL_OVER,this.onMouseEvent,false,0,true);
                     this.processDiscountIcon();
                  }
               }
               break;
            case 2100:
               if(this.model.player._uId == param2 as uint)
               {
                  if(this._activeTimeout > 0)
                  {
                     clearTimeout(this._activeTimeout);
                  }
                  this.onAutoShowMoneyWin();
                  break;
               }
               this._activeDonate = param2 as uint;
               break;
            case 2101:
               return this._model.queryDonate(param2 as uint);
            case 2102:
               return this._flagCls;
            case 2103:
               this._model.updateReward(param2);
         }
         return null;
      }
      
      public function updateFriendStatus() : void
      {
         var _loc1_:uint = this._model.currentUserIdByUinMode;
         this.callProxy(2008,_loc1_);
         this._model.markDonated(_loc1_);
      }
      
      private function onChangeMyFairy(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:Object = param1.data["fairy"];
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:Object = {
            "itemId":_loc2_["id"],
            "lv":_loc2_["lv"],
            "rate":_loc2_["rate"]
         };
         this.callProxy(2000,_loc3_);
         if(param1.data["update"] == true)
         {
            this.createFairy(_loc2_["id"],_loc2_["lv"]);
         }
      }
      
      private function openXianHuangWindow() : void
      {
         if(this._xianhuangWin == null)
         {
            this._xianhuangWin = new XianHuangWindowWrapper(this);
         }
         this._xianhuangWin.show();
      }
      
      public function get api() : IFarmAPI
      {
         return this._api;
      }
      
      private function openMoneyWindow() : void
      {
         if(this._moneyWin == null)
         {
            this._moneyWin = new MoneyWindowWrapper(this);
         }
         this.callProxy(2009,true);
         this._moneyWin.show(this._model.player.me);
      }
      
      private function mainFaceAutoPopup(param1:int, param2:*) : void
      {
         if(Boolean(param2) && Boolean(param2["bit_flag"]))
         {
            if(this._model.fairyList != null)
            {
               this.openMainWindow(this._model.fairyList);
            }
            else
            {
               this._toOpen = 1;
               this._model.init();
               this._model.addEventListener(FairyModel.DATA_INITIALIZED,this.onFairyInitialized,false,0,true);
            }
         }
      }
      
      public function createMainUI(param1:Object) : Sprite
      {
         this._config = param1["config"];
         this._stage = param1["container"];
         this._model.player = param1["player"];
         this._model.myName = this._model.player._userName;
         this._model.config = this._config;
         this._friends.hostId = this._model.player._uId;
         MoneyWindowWrapper.REWARDS = this._config["rewards"] as Array;
         var _loc2_:Object = param1["fairy"];
         if(_loc2_ != null)
         {
            _loc2_["rate"] *= 10;
            this._model.fairyItem = {
               "itemId":_loc2_["itemId"],
               "rate":_loc2_["rate"],
               "lv":_loc2_["lv"]
            };
            this.createFairy(_loc2_["itemId"],_loc2_["lv"]);
         }
         this._toOpen = -1;
         this._model.init();
         this._model.addEventListener(FairyModel.DATA_INITIALIZED,this.onFairyInitialized,false,0,true);
         return null;
      }
      
      private function onFairyRefreshed(param1:CommonEvent) : void
      {
         var _loc6_:* = undefined;
         var _loc7_:String = null;
         if(param1.data == null || param1.data["error"] != undefined)
         {
            _loc7_ = "刷新小仙失败，请您稍后再试。";
            if(param1.data["error"] != undefined)
            {
               _loc7_ = param1.data["error"];
            }
            this.api.alert(2,"失败",_loc7_,0,0,null);
            return;
         }
         var _loc2_:Boolean = false;
         var _loc3_:Boolean = false;
         var _loc4_:Array = param1.data["list"] as Array;
         var _loc5_:Object = this._model.fairyItem;
         for each(_loc6_ in _loc4_)
         {
            if(_loc6_["lv"] == 3 && (_loc5_ == null || _loc5_ != null && _loc5_["itemId"] != _loc6_["id"]))
            {
               if(_loc6_["id"] == BASE_ID + 3)
               {
                  _loc2_ = true;
               }
               else if(this._model.isXianHuangWinOpen == false)
               {
                  _loc3_ = true;
               }
            }
         }
         if(_loc2_)
         {
            _loc3_ = false;
            this.api.alert(3,"恭喜您","恭喜您刷新出了3星仙皇，赶快雇佣到您的农场里面吧~",0,0,null);
         }
         if(_loc3_)
         {
            this.api.alert(3,"恭喜您","恭喜您刷新出了3星小仙，赶快雇佣到您的农场里面吧~",0,0,null);
         }
         this.callProxy(2002,param1.data["cost"]);
      }
      
      public function get friends() : FriendsModel
      {
         return this._friends;
      }
      
      private function onMouseEvent(param1:MouseEvent) : void
      {
         var _loc2_:InteractiveObject = param1.target as InteractiveObject;
         var _loc3_:String = param1.type;
         switch(_loc3_)
         {
            case MouseEvent.CLICK:
               if(_loc2_ == this._iconEntrance)
               {
                  this.api.reportSuccessError("160574",null);
                  ClickReportManager.reportClick("left.banner.icon_god.click");
                  if(this._model.fairyList != null)
                  {
                     this.openMainWindow(this._model.fairyList);
                  }
                  else
                  {
                     this._toOpen = 1;
                     this._model.init();
                     this._model.addEventListener(FairyModel.DATA_INITIALIZED,this.onFairyInitialized,false,0,true);
                  }
               }
               else if(_loc2_ == this._xianHuangEntrace)
               {
                  this.api.reportSuccessError("160574",null);
                  ClickReportManager.reportClick("left.banner.icon_god.click");
                  this.openXianHuangWindow();
               }
               else if(_loc2_ == this._fairy)
               {
                  if(this._model.player.me == true)
                  {
                     if(this._model.fairyList == null)
                     {
                        this._toOpen = 2;
                        this._model.init();
                        this._model.addEventListener(FairyModel.DATA_INITIALIZED,this.onFairyInitialized,false,0,true);
                        break;
                     }
                  }
                  this.openMoneyWindow();
               }
               break;
            case MouseEvent.ROLL_OVER:
               if(_loc2_ == this._iconEntrance)
               {
                  this._api.popMouseTip(this.toolTip());
               }
               else if(_loc2_ == this._fairy)
               {
                  _loc2_.filters = this._filters;
                  this._api.popMouseTip(this._model.tipName);
                  this._api.useSystemCursor(true);
               }
               break;
            case MouseEvent.ROLL_OUT:
               if(_loc2_ == this._iconEntrance)
               {
                  this._api.hideMouseTip();
               }
               else if(_loc2_ == this._fairy)
               {
                  _loc2_.filters = null;
                  this._api.hideMouseTip();
                  this._api.useSystemCursor(false);
               }
         }
      }
      
      public function callProxy(param1:int, param2:*) : Object
      {
         return this._api.executeCommand(this._id,param1,param2);
      }
      
      public function get model() : FairyModel
      {
         return this._model;
      }
      
      private function createFairy(param1:int, param2:int) : void
      {
         if(this._fairy != null && this._stage != null)
         {
            this._fairy.stop();
            this._stage.removeChild(this._fairy);
            this._fairy = null;
         }
         if(param1 == 0 || param2 == 0)
         {
            return;
         }
         var _loc3_:Object = this.model.getFairyConfig(param1);
         if(_loc3_ == null)
         {
            return;
         }
         var _loc4_:String = _loc3_["url"];
         _loc4_ = this.callProxy(2006,_loc4_) as String;
         if(_loc4_ == null || _loc4_ == "")
         {
            return;
         }
         if(this._loader == null)
         {
            this._loader = new Loader();
         }
         else
         {
            this._loader.unload();
         }
         this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onAvatarLoaded,false,0,true);
         this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onAvatarLoadFailed,false,0,true);
         this._loader.load(new URLRequest(_loc4_),new LoaderContext(false,ApplicationDomain.currentDomain));
      }
      
      private function onFairyInitialized(param1:CommonEvent) : void
      {
         this._model.removeEventListener(FairyModel.DATA_INITIALIZED,this.onFairyInitialized);
         if(param1 == null || param1.data == null)
         {
            this.api.alert(2,"错误","加载小仙信息出错，请稍后再试。",0,0,null);
            return;
         }
         if(this._toOpen == 1)
         {
            this.openMainWindow(param1.data as Array);
         }
         else if(this._toOpen == 2)
         {
            this.openMoneyWindow();
         }
         else
         {
            setTimeout(this.openReBuyWindow,1500);
         }
         this.processDiscountIcon();
         this.autoPopupCheck();
      }
      
      private function autoPopupCheck() : void
      {
         this._model.sendCheckAutoPopupRequest(this.mainFaceAutoPopup);
      }
      
      private function onAvatarLoaded(param1:Event) : void
      {
         var _loc2_:LoaderInfo = param1.target as LoaderInfo;
         if(_loc2_ == null)
         {
            return;
         }
         this._fairy = _loc2_.content as MovieClip;
         this._fairy = this._fairy.getChildAt(0) as MovieClip;
         if(this._fairy != null && this._stage != null)
         {
            this._fairy.buttonMode = true;
            this._fairy.mouseChildren = false;
            this._fairy.cacheAsBitmap = true;
            this._fairy.addEventListener(MouseEvent.CLICK,this.onMouseEvent,false,0,true);
            this._fairy.addEventListener(MouseEvent.ROLL_OUT,this.onMouseEvent,false,0,true);
            this._fairy.addEventListener(MouseEvent.ROLL_OVER,this.onMouseEvent,false,0,true);
            this._stage.addChild(this._fairy);
            TweenLite.from(this._fairy,1.5,{
               "tint":16777215,
               "scaleY":1.25
            });
         }
      }
      
      private function toolTip() : String
      {
         var _loc2_:* = undefined;
         if(this._config == null || this._config["amount"] == undefined)
         {
            return "";
         }
         var _loc1_:Array = this._config["amount"] as Array;
         for each(_loc2_ in _loc1_)
         {
            if(_loc2_["type"] == 5)
            {
               return _loc2_["tip"];
            }
         }
         return "";
      }
      
      public function load(param1:int, param2:IFarmAPI) : Boolean
      {
         trace("INFO> [Fairy] plugin module loaded!");
         this._id = param1;
         this._api = param2;
         this._toOpen = -1;
         this._model = new FairyModel(param2);
         this._model.addEventListener(FairyModel.DATA_FAIRY_CHANGED,this.onFairyRefreshed,false,0,true);
         this._model.addEventListener(FairyModel.MSG_CHANGE_MY_FAIRY,this.onChangeMyFairy,false,0,true);
         this._friends = new FriendsModel(param2);
         this._api.messageCenter.addEventListener("CurrentUserChanged",this.onUserChanged,false,0,true);
         return true;
      }
      
      private function processDiscountIcon() : void
      {
         if(this._iconEntrance != null && this._model.discount > 0)
         {
            if(this._discountIcon == true)
            {
               return;
            }
            this._discountIcon = true;
            this._iconEntrance.gotoAndPlay(2);
            this._iconEntrance.addEventListener(Event.ENTER_FRAME,function(param1:Event):void
            {
               var _loc2_:MovieClip = param1.target as MovieClip;
               if(_loc2_.currentFrame == _loc2_.totalFrames)
               {
                  _loc2_.gotoAndPlay(2);
               }
               param1.stopImmediatePropagation();
            });
         }
      }
      
      private function onAutoShowMoneyWin() : void
      {
         this.openMoneyWindow();
         this._activeDonate = 0;
         this._activeTimeout = 0;
      }
      
      private function openMainWindow(param1:Array) : void
      {
         if(this._mainWin == null)
         {
            this._mainWin = new MainWindowWrapper(this);
         }
         this._mainWin.show(param1);
      }
      
      public function enableMc(param1:InteractiveObject, param2:Boolean) : void
      {
         if(param1 != null)
         {
            if(param2 == true)
            {
               param1.mouseEnabled = true;
               param1.filters = [];
            }
            else
            {
               param1.mouseEnabled = false;
               param1.filters = [new ColorMatrixFilter([0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0,0,0,1,0])];
            }
         }
      }
      
      public function unload() : void
      {
      }
   }
}

