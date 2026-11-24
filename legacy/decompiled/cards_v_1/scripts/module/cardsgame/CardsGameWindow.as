package module.cardsgame
{
   import com.qzone.corelib.net.RSLManager;
   import common.Consts;
   import common.Session;
   import common.Settings;
   import common.misc.Utils;
   import common.view.MaterialProxy;
   import common.view.cursor.CursorControl;
   import common.view.window.BaseWindow;
   import events.CommonEvent;
   import events.ViewEvent;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.system.System;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   import interfaces.IMsgCenter;
   
   public class CardsGameWindow extends BaseWindow
   {
      
      private static const cardsGameWindowClass:String = "CardsGameWindow";
      
      private static const closeCardsGameWindow:String = "closeCardsGameWindow";
      
      private static const openVipLink:String = "openVipLink";
      
      private static const E_SUCCESSD:int = 1;
      
      private static const LENGTHID:String = "9999";
      
      private var _itemNow:int = -1;
      
      private const _ActivityDays:Array = [30,60,100];
      
      private var itemArray:Array = new Array();
      
      private var _window:MovieClip;
      
      private var dhWindow:MovieClip;
      
      private var dhID:int;
      
      private var _itemNow2:int = -1;
      
      private var _gift3IDMaterialProxy:MaterialProxy;
      
      private var _tempArr:Array;
      
      private var _cursorControl:CursorControl;
      
      private var _mc:IMsgCenter;
      
      private var m_controller:CardsGameController;
      
      private var itemPos:Array = [{
         "x":-213,
         "y":-46
      },{
         "x":-119,
         "y":-46
      },{
         "x":-25,
         "y":-46
      },{
         "x":-213,
         "y":42
      },{
         "x":-119,
         "y":42
      },{
         "x":-25,
         "y":42
      },{
         "x":-213,
         "y":128
      },{
         "x":-119,
         "y":128
      },{
         "x":-25,
         "y":128
      }];
      
      private var _timer:int = -1;
      
      private var _gift2IDMaterialProxy:MaterialProxy;
      
      private const _ActivityLinks:Array = ["http://app.photo.qq.com/cgi-bin/app/cgi_redict_kadang?from=hd-farmOne-120229","http://app.photo.qq.com/cgi-bin/app/cgi_redict_kadang?from=hd-farmTwo-120229","http://app.photo.qq.com/cgi-bin/app/cgi_redict_kadang?from=hd-farmThree-120229"];
      
      private const _ActivityNames:Array = ["飞行棋鼠标垫","创意纸巾包装盒","微盆栽"];
      
      private var _gift1IDMaterialProxy:MaterialProxy;
      
      private var _clickLocked:Boolean = false;
      
      private var _cursorMc:Sprite;
      
      public function CardsGameWindow(param1:CardsGameController)
      {
         this.m_controller = param1;
         this._mc = this.m_controller.module.app;
         super(this._mc);
         this._cursorControl = new CursorControl(this._mc);
         windowName = Consts.WINDOW_NAME_CARDSGAME_WINDOW;
         this.title = "";
         this.width = 0;
         this.height = 0;
         this.mode = true;
         this.showCloseButton = false;
         this.m_controller.model.addEventListener(CardsGameModel.CARDSGAME_ACTIVITY,this.cardsgameActivity,false,0,true);
      }
      
      private function cardsgameActivity(param1:CommonEvent) : void
      {
         var _loc2_:Object = param1.data;
         if(_loc2_["code"] == 1)
         {
            this.ActivityDHWindow(_loc2_);
         }
         else if(_loc2_.hasOwnProperty("direction"))
         {
            this.m_controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":_loc2_["direction"],
               "parent":this.stage
            });
         }
         else
         {
            this.m_controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":"系统繁忙",
               "parent":this.stage
            });
         }
      }
      
      private function onItemOver(param1:ViewEvent) : void
      {
         var _loc2_:CardsGameWindowItem = param1.currentTarget as CardsGameWindowItem;
         var _loc3_:int = this.itemArray.indexOf(_loc2_);
         var _loc4_:Boolean = _loc3_ == this._itemNow || _loc3_ == this._itemNow2 ? true : false;
         this.m_controller.showTip(Consts.TIP_NAME_MOUSE,_loc2_.returnTips(_loc4_));
      }
      
      private function ActivityGiftRollOver(param1:MouseEvent) : void
      {
         if(param1.currentTarget.type == "has")
         {
            this.m_controller.showTip(Consts.TIP_NAME_MOUSE,"已兑换");
         }
         else if(param1.currentTarget.type == "noin")
         {
            this.m_controller.showTip(Consts.TIP_NAME_MOUSE,"连续签到天数不足");
         }
      }
      
      private function onOpenVipLink(param1:Event) : void
      {
         var _loc2_:String = "";
         if(Session.getInstance().host._yellowstatus != 0)
         {
            _loc2_ = Settings.getInstance().getStringAttribute("CardsGameRenewalVip");
         }
         else
         {
            _loc2_ = Settings.getInstance().getStringAttribute("CardsGameOpenVip");
         }
         ExternalInterface.call("window.open",_loc2_);
      }
      
      private function ActivityGiftRollOut(param1:MouseEvent) : void
      {
         this.m_controller.hideTip();
      }
      
      private function onCloseWindow(param1:Event) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < 9)
         {
            if(this.itemArray[_loc2_] != null)
            {
               removeChild(this.itemArray[_loc2_]);
            }
            this.itemArray[_loc2_] = null;
            _loc2_++;
         }
         removeChild(this._gift3IDMaterialProxy);
         this._gift3IDMaterialProxy = null;
         removeChild(this._gift2IDMaterialProxy);
         this._gift2IDMaterialProxy = null;
         removeChild(this._gift1IDMaterialProxy);
         this._gift1IDMaterialProxy = null;
         removeChild(this._window);
         this.m_controller.model.removeEventListener(CardsGameModel.CARDSGAME_LOADED,this.onReward);
         this.m_controller.removeIcon();
         close();
      }
      
      override public function initalize(param1:Event) : void
      {
         super.initalize(param1);
         if(this.m_controller.isCardGameActivity())
         {
            this.itemPos = [{
               "x":-313,
               "y":-46
            },{
               "x":-219,
               "y":-46
            },{
               "x":-125,
               "y":-46
            },{
               "x":-313,
               "y":42
            },{
               "x":-219,
               "y":42
            },{
               "x":-125,
               "y":42
            },{
               "x":-313,
               "y":128
            },{
               "x":-219,
               "y":128
            },{
               "x":-125,
               "y":128
            }];
         }
         this._tempArr = new Array();
         var _loc2_:int = 0;
         while(_loc2_ < 9)
         {
            this.drawItems(_loc2_);
            _loc2_++;
         }
         this.resetTempArray();
         this.m_controller.model.addEventListener(CardsGameModel.CARDSGAME_LOADED,this.onReward);
         var _loc3_:RSLManager = RSLManager.getInstance();
         if(this.m_controller.isCardGameActivity())
         {
            _loc3_.requestClass(cardsGameWindowClass,this.addWindowTimer,Settings.getInstance().getSecondUrl("CardsGameActivityWindow"));
         }
         else
         {
            _loc3_.requestClass(cardsGameWindowClass,this.addWindowTimer,Settings.getInstance().getSecondUrl("CardsGameWindow"));
         }
      }
      
      private function ActivityDHWindow(param1:Object) : void
      {
         this.dhWindow = Utils.getMaterial("CardsGameActivityDH") as MovieClip;
         addChild(this.dhWindow);
         this.dhWindow.giftNameMc1.loginDays.htmlText = this.m_controller.model.loginDays;
         if(this.m_controller.model.isGetDraw[this.dhID - 1] == 0)
         {
            this.dhWindow.giftNameMc1.visible = true;
            this.dhWindow.giftNameMc2.visible = false;
            this.dhWindow.giftNameMc1.giftNameMc.gotoAndStop(this.dhID);
         }
         else
         {
            this.dhWindow.giftNameMc1.visible = false;
            this.dhWindow.giftNameMc2.visible = true;
            this.dhWindow.giftNameMc2.gotoAndStop(this.dhID);
         }
         this.dhWindow.giftMc.gotoAndStop(this.dhID);
         this.dhWindow.dhNum.htmlText = param1["cdkey"];
         this.dhWindow.copyBtn.addEventListener(MouseEvent.CLICK,this.copyDHNumHandler);
         this.dhWindow.dhBtn.addEventListener(MouseEvent.CLICK,this.dhBtnHandler);
         this.dhWindow.closeBtn.addEventListener(MouseEvent.CLICK,this.closeDHHandler);
      }
      
      private function getRandomReward() : String
      {
         var _loc1_:int = Math.floor(Math.random() * this._tempArr.length);
         var _loc2_:int = int(this._tempArr[_loc1_]);
         this._tempArr.splice(_loc1_,1);
         return _loc2_.toString();
      }
      
      private function showShopHandler(param1:MouseEvent) : void
      {
         navigateToURL(new URLRequest("http://blog.qq.com/qzone/1006666001/1312167689.htm"),"_blank");
      }
      
      private function ActivityGiftClick(param1:MouseEvent) : void
      {
         var _loc2_:int = int(param1.currentTarget.ID);
         this.dhID = _loc2_;
         this.m_controller.model.ActivityClickGet(_loc2_);
      }
      
      private function addWindowTimer() : void
      {
         this._timer = setTimeout(this.addWindow,10);
      }
      
      private function resetTempArray() : void
      {
         this._tempArr = Settings.getInstance().getCardsGameRewardIDs().concat();
         this._tempArr.splice(this._tempArr.indexOf(parseInt(Consts.CARDS_GAME_GIFT_1)),1);
         this._tempArr.splice(this._tempArr.indexOf(parseInt(Consts.CARDS_GAME_GIFT_2)),1);
         this._tempArr.splice(this._tempArr.indexOf(parseInt(Consts.CARDS_GAME_GIFT_3)),1);
      }
      
      private function closeDHHandler(param1:MouseEvent) : void
      {
         if(this.dhWindow)
         {
            this.dhWindow.copyBtn.removeEventListener(MouseEvent.CLICK,this.copyDHNumHandler);
            this.dhWindow.dhBtn.removeEventListener(MouseEvent.CLICK,this.dhBtnHandler);
            this.dhWindow.closeBtn.removeEventListener(MouseEvent.CLICK,this.closeDHHandler);
            removeChild(this.dhWindow);
            this.dhWindow = null;
         }
      }
      
      private function onClick(param1:ViewEvent) : void
      {
         var _loc2_:CardsGameWindowItem = null;
         if(!this._clickLocked)
         {
            this._clickLocked = true;
            _loc2_ = param1.currentTarget as CardsGameWindowItem;
            this._itemNow = parseInt(_loc2_.name);
            this.m_controller.model.getReward();
         }
      }
      
      private function onReward(param1:CommonEvent) : void
      {
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc2_:Object = param1.data;
         var _loc3_:int = int(_loc2_["code"]);
         if(_loc3_ == E_SUCCESSD)
         {
            this._tempArr.splice(this._tempArr.indexOf(parseInt(_loc2_["id"])),1);
            this.itemArray[this._itemNow].addTurnOverBg(2);
            this.itemArray[this._itemNow].setMatetialContent(_loc2_["id"]);
            this.itemArray[this._itemNow].removeEventListener(CardsGameWindowItem.CHILD_CLICK,this.onClick);
            this.itemArray[this._itemNow].addEventListener(CardsGameWindowItem.CHILD_OVER,this.onItemOver);
            this.itemArray[this._itemNow].addEventListener(CardsGameWindowItem.CHILD_OUT,this.onItemOut);
            this.m_controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":"您获得了" + this.itemArray[this._itemNow].returnTips(true),
               "parent":this
            });
            if(this.m_controller.model.remainPlays > 0)
            {
               if(this._itemNow2 == -1)
               {
                  this._itemNow2 = this._itemNow;
               }
               this._window.yellowText.htmlText = "您还可以翻<font color = \'#FF6600\'> " + this.m_controller.model.remainPlays + " </font>张牌哟";
               this._clickLocked = false;
               return;
            }
            this._window.yellowText.htmlText = "明天再来碰碰运气吧！";
            _loc4_ = 0;
            while(_loc4_ < 9)
            {
               if(!(_loc4_ == this._itemNow || _loc4_ == this._itemNow2))
               {
                  this.itemArray[_loc4_].removeEventListener(CardsGameWindowItem.CHILD_CLICK,this.onClick);
                  this.itemArray[_loc4_].addEventListener(CardsGameWindowItem.CHILD_OVER,this.onItemOver);
                  this.itemArray[_loc4_].addEventListener(CardsGameWindowItem.CHILD_OUT,this.onItemOut);
                  this.itemArray[_loc4_].addTurnOverBg(1);
                  this.itemArray[_loc4_].setMatetialContent(this.getRandomReward());
               }
               _loc4_++;
            }
         }
         else
         {
            _loc5_ = _loc2_["direction"] || "系统繁忙，请稍后重试";
            this.m_controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":_loc5_,
               "parent":this
            });
         }
         this._clickLocked = false;
      }
      
      private function hdBtnHandler(param1:MouseEvent) : void
      {
         navigateToURL(new URLRequest("http://blog.qq.com/qzone/1006666001/1331087399.htm"),"_blank");
      }
      
      private function dhBtnHandler(param1:MouseEvent) : void
      {
         navigateToURL(new URLRequest(this._ActivityLinks[this.dhID - 1]),"_blank");
      }
      
      private function onItemOut(param1:ViewEvent) : void
      {
         this.m_controller.hideTip();
      }
      
      private function addWindow() : void
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         if(this._timer != -1)
         {
            clearTimeout(this._timer);
         }
         this._window = Utils.getMaterial(cardsGameWindowClass) as MovieClip;
         this._window.loginDays.htmlText = this.m_controller.model.loginDays;
         var _loc1_:int = this.m_controller.model.remainPlays;
         if(Session.getInstance().host._yellowstatus != 0 && _loc1_ == 1)
         {
            this._window.yellowText.htmlText = "您还可以翻<font color = \'#FF6600\'> " + _loc1_ + " </font>张牌哟";
         }
         else
         {
            this._window.yellowText.htmlText = "VIP用户可翻<font color = \'#FF6600\'> 2 </font>张牌哟";
         }
         this._window.yellowText.selectable = false;
         if(Session.getInstance().host._yellowstatus != 0)
         {
            this._window.removeChild(this._window.yellowBtn);
         }
         else
         {
            this._window.removeChild(this._window.yellowBtn_vip);
         }
         _loc2_ = Settings.getInstance().getCardsGameReward(Consts.CARDS_GAME_GIFT_1);
         this._window.giftText1.htmlText = _loc2_["name"];
         this._window.giftText1.selectable = false;
         this._gift1IDMaterialProxy = new MaterialProxy();
         this._gift1IDMaterialProxy.x = 163;
         this._gift1IDMaterialProxy.y = -78;
         this._gift1IDMaterialProxy.setContent(_loc2_["type"],parseInt(_loc2_["cId"]));
         addChild(this._gift1IDMaterialProxy);
         _loc3_ = Settings.getInstance().getCardsGameReward(Consts.CARDS_GAME_GIFT_2);
         this._window.giftText2.htmlText = _loc3_["name"];
         this._window.giftText2.selectable = false;
         this._gift2IDMaterialProxy = new MaterialProxy();
         this._gift2IDMaterialProxy.x = 163;
         this._gift2IDMaterialProxy.y = 20;
         this._gift2IDMaterialProxy.setContent(_loc3_["type"],parseInt(_loc3_["cId"]));
         addChild(this._gift2IDMaterialProxy);
         _loc4_ = Settings.getInstance().getCardsGameReward(Consts.CARDS_GAME_GIFT_3);
         this._window.giftText3.htmlText = _loc4_["name"];
         this._window.giftText3.selectable = false;
         this._gift3IDMaterialProxy = new MaterialProxy();
         this._gift3IDMaterialProxy.x = 163;
         this._gift3IDMaterialProxy.y = 114;
         this._gift3IDMaterialProxy.setContent(_loc4_["type"],parseInt(_loc4_["cId"]));
         addChild(this._gift3IDMaterialProxy);
         addChildAt(this._window,0);
         this._window.addEventListener(closeCardsGameWindow,this.onCloseWindow);
         this._window.addEventListener(openVipLink,this.onOpenVipLink);
         _loc5_ = 0;
         while(_loc5_ < 9)
         {
            this.itemArray[_loc5_].addButton();
            _loc5_++;
         }
         if(this.m_controller.isCardGameActivity())
         {
            this._gift1IDMaterialProxy.x = 63;
            this._gift2IDMaterialProxy.x = 63;
            this._gift3IDMaterialProxy.x = 63;
            this._window.x = -100;
            _loc5_ = 0;
            while(_loc5_ < this._ActivityDays.length)
            {
               if(this.m_controller.model.isGetDraw[_loc5_])
               {
                  this._window.Activity["giftBtn" + (_loc5_ + 1)].gotoAndStop(1);
                  this._window.Activity["giftBtn" + (_loc5_ + 1)].buttonMode = true;
                  this._window.Activity["giftBtn" + (_loc5_ + 1)].ID = _loc5_ + 1;
                  this._window.Activity["giftBtn" + (_loc5_ + 1)].addEventListener(MouseEvent.CLICK,this.ActivityGiftClick);
               }
               else if(this.m_controller.model.loginDays >= this._ActivityDays[_loc5_])
               {
                  this._window.Activity["giftBtn" + (_loc5_ + 1)].gotoAndStop(1);
                  this._window.Activity["giftBtn" + (_loc5_ + 1)].buttonMode = true;
                  this._window.Activity["giftBtn" + (_loc5_ + 1)].ID = _loc5_ + 1;
                  this._window.Activity["giftBtn" + (_loc5_ + 1)].addEventListener(MouseEvent.CLICK,this.ActivityGiftClick);
               }
               else
               {
                  this._window.Activity["giftBtn" + (_loc5_ + 1)].gotoAndStop(2);
                  this._window.Activity["giftBtn" + (_loc5_ + 1)].type = "noin";
                  this._window.Activity["giftBtn" + (_loc5_ + 1)].addEventListener(MouseEvent.ROLL_OVER,this.ActivityGiftRollOver);
                  this._window.Activity["giftBtn" + (_loc5_ + 1)].addEventListener(MouseEvent.ROLL_OUT,this.ActivityGiftRollOut);
               }
               _loc5_++;
            }
            this._window.Activity.hd_btn.addEventListener(MouseEvent.CLICK,this.hdBtnHandler);
         }
      }
      
      private function copyDHNumHandler(param1:MouseEvent) : void
      {
         System.setClipboard(this.dhWindow.dhNum.text);
         this.m_controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
            "text":"已复制了您的兑换码！",
            "parent":this
         });
      }
      
      private function drawItems(param1:int) : void
      {
         this.itemArray[param1] = new CardsGameWindowItem();
         this.itemArray[param1].name = param1.toString();
         this.itemArray[param1].x = this.itemPos[param1].x;
         this.itemArray[param1].y = this.itemPos[param1].y;
         this.itemArray[param1].addEventListener(CardsGameWindowItem.CHILD_CLICK,this.onClick);
         addChild(this.itemArray[param1]);
      }
   }
}

