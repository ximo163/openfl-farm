package module.uitools.widgets
{
   import com.qzone.qui.containers.HBox;
   import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
   import com.qzone.qui.core.Align;
   import com.qzone.qui.makers.ButtonMaker;
   import com.qzone.utils.DateUtil;
   import common.CommonData;
   import common.Consts;
   import common.Session;
   import common.Settings;
   import common.misc.Cookies;
   import common.misc.QzoneJSAPI;
   import common.misc.Utils;
   import entities.Player;
   import events.CommonEvent;
   import events.ViewEvent;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   import module.uitools.UIController;
   import report.ClickReportManager;
   import report.EventRecorder;
   import report.UserActionRecorder;
   
   public class NavigationBar extends HBox
   {
      
      private static const NAV_FARM:int = 0;
      
      private static const NAV_MC:int = 1;
      
      private static const NAV_SUPERMARKET:int = 3;
      
      private static const NAV_RESTAURANT:int = 2;
      
      private static const NAV_MILL:int = 4;
      
      private static const NAV_WAREHOUSE:int = 5;
      
      private static const NAV_SHOP:int = 6;
      
      private static const NAV_DECOREATE:int = 7;
      
      private static const NAV_APP_SHOW_MAX:int = 4;
      
      private static const NAV_APP_TOTAL:int = 5;
      
      private var NAV_MAX:int = 8;
      
      private var leftArrow:*;
      
      private var showBtnIndex:int;
      
      private var rightArrow:*;
      
      private var BUTTONS_TIP:Array;
      
      private const BUTTONS:Array;
      
      private var supermarketTime:uint;
      
      private var BUTTONS_NAME:Array;
      
      private var m_controller:UIController;
      
      private var m_buttons:Array;
      
      public function NavigationBar(param1:UIController)
      {
         var btn:*;
         var i:int;
         var scale:Number;
         var _arrow:MovieClip = null;
         var controller:UIController = param1;
         this.BUTTONS = ["ButtonFarm","ButtonMC","ButtonRestaurant","ButtonSuperMarket","ButtonMill1","ButtonWarehouse","ButtonShop","ButtonDecorate"];
         this.BUTTONS_NAME = ["farm","mc","restaurant","supermarket","mill","warehouse","shop","decorate"];
         this.BUTTONS_TIP = ["我的农场","我的牧场","我的餐厅","我的超市","加工坊（可加工化肥、罐头等）","仓库（收获的果子会在这里）","农场商店（来这里买种子）","装饰农场"];
         super(430,64);
         this.m_controller = controller;
         alignH = Align.RIGHT;
         alignV = Align.MIDDLE;
         gapH = 8;
         gapV = 12;
         borderSizeH = 0;
         borderSizeV = 2;
         autoLayout = true;
         verticalScrollPolicy = ScrollPolicy.OFF;
         horizontalScrollPolicy = ScrollPolicy.OFF;
         defaultSkin = null;
         specialGapHIndex = 3;
         specialGapH = 27;
         scale = 1;
         btn = null;
         this.m_buttons = new Array();
         this.showBtnIndex = 0;
         i = 0;
         for(; i < this.NAV_MAX; i++)
         {
            if(QzoneJSAPI.QPLUS == true || QzoneJSAPI.WB == true)
            {
               if(i == NAV_MC || i == NAV_RESTAURANT || i == NAV_MILL || i == NAV_SUPERMARKET)
               {
                  continue;
               }
            }
            btn = Utils.getMaterial(this.BUTTONS[i]);
            ButtonMaker.addTarget(btn);
            btn.name = this.BUTTONS_NAME[i];
            btn.tipText = this.BUTTONS_TIP[i];
            btn.addEventListener(MouseEvent.CLICK,this.buttonClickHandler);
            btn.addEventListener(MouseEvent.ROLL_OVER,this.toolRollOver);
            btn.addEventListener(MouseEvent.ROLL_OUT,this.toolRollOut);
            btn.scaleX = btn.scaleY = scale;
            this.m_buttons.push(btn);
            if(!(i >= this.showBtnIndex + NAV_APP_SHOW_MAX && i < NAV_APP_TOTAL))
            {
               addElement(btn);
               if(this.BUTTONS_NAME[i] == "supermarket")
               {
                  if(isSupermarketNeedTip())
                  {
                     _arrow = this.getChildByName("__supermarketarrow__") as MovieClip;
                     if(_arrow == null)
                     {
                        _arrow = Utils.getMaterial("monthEndArrow") as MovieClip;
                        _arrow.name = "__supermarketarrow__";
                        _arrow.tipMc.tip.text = "全新游戏，精彩无限！";
                        this.addChild(_arrow);
                     }
                     _arrow.mouseEnabled = false;
                     this.addEventListener(Event.ENTER_FRAME,this.supermarketMove);
                     this.supermarketTime = setTimeout(function():void
                     {
                        removeSupermarketTip();
                     },8000);
                     Cookies.setObject("supermarket_new_" + Session.getInstance().host._uId,"true");
                  }
               }
            }
         }
         if(QzoneJSAPI.QPLUS == false && QzoneJSAPI.WB == false)
         {
            this.leftArrow = Utils.getMaterial("NavigationLeftArrow");
            this.leftArrow.name = "leftArrow";
            this.leftArrow.addEventListener(MouseEvent.CLICK,this.onScrollBar);
            addChild(this.leftArrow);
            this.rightArrow = Utils.getMaterial("NavigationRightArrow");
            this.rightArrow.name = "rightArrow";
            this.rightArrow.addEventListener(MouseEvent.CLICK,this.onScrollBar);
            addChild(this.rightArrow);
         }
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
      }
      
      public static function isSupermarketNeedTip() : Boolean
      {
         var _loc1_:String = Settings.getInstance().getStringAttribute("supermarketTip");
         if(CommonData.serverTime > DateUtil.getDateFromString(_loc1_).time / 1000)
         {
            return false;
         }
         var _loc2_:uint = Session.getInstance().host._uId;
         if(Cookies.getObject("supermarket_new_" + _loc2_) == null)
         {
            return true;
         }
         return false;
      }
      
      private function switchIcons() : void
      {
         var _loc1_:Player = Session.getInstance().host;
         if(_loc1_._yellowlevel >= parseInt(Settings.getInstance().getStringAttribute("QQSuperMarketVip")) || _loc1_.level >= parseInt(Settings.getInstance().getStringAttribute("QQSuperMarketLvl")))
         {
            this.m_buttons[NAV_SUPERMARKET].gotoAndStop(1);
         }
         else
         {
            this.m_buttons[NAV_SUPERMARKET].gotoAndStop(2);
         }
      }
      
      private function removeSupermarketTip() : void
      {
         var _loc1_:MovieClip = this.getChildByName("__supermarketarrow__") as MovieClip;
         if(_loc1_)
         {
            if(_loc1_.parent)
            {
               _loc1_.parent.removeChild(_loc1_);
               _loc1_ = null;
            }
         }
         clearTimeout(this.supermarketTime);
         this.removeEventListener(Event.ENTER_FRAME,this.supermarketMove);
      }
      
      private function adjustPosition() : void
      {
         this.x = stage.stageWidth - this.width - gapH;
         this.y = 0;
         if(Boolean(this.leftArrow) && Boolean(this.rightArrow))
         {
            this.leftArrow.y = this.rightArrow.y = 22;
            this.leftArrow.x = -10;
            this.rightArrow.x = 239;
         }
      }
      
      private function toolRollOut(param1:MouseEvent) : void
      {
         this.m_controller.hideTip();
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this.adjustPosition();
         this.currentUserChanged();
         this.switchIcons();
         if(QzoneJSAPI.QPLUS == false && QzoneJSAPI.WB == false)
         {
            Session.getInstance().m_millOpen = true;
            if(this.m_buttons[NAV_RESTAURANT].iconNO != undefined)
            {
               this.m_buttons[NAV_RESTAURANT].iconNO.visible = false;
            }
            if(this.m_buttons[NAV_MILL].iconNO != undefined)
            {
               this.m_buttons[NAV_MILL].iconNO.visible = false;
            }
         }
      }
      
      private function onScrollBar(param1:MouseEvent) : void
      {
         var _loc2_:int = this.showBtnIndex;
         if(param1.currentTarget.name == "leftArrow")
         {
            --this.showBtnIndex;
         }
         else if(param1.currentTarget.name == "rightArrow")
         {
            ++this.showBtnIndex;
         }
         if(this.showBtnIndex >= NAV_APP_TOTAL || this.showBtnIndex <= -NAV_APP_TOTAL)
         {
            this.showBtnIndex = 0;
         }
         removeAllElements();
         var _loc3_:int = 0;
         var _loc4_:int = this.showBtnIndex;
         while(_loc4_ < this.NAV_MAX)
         {
            if(_loc3_ >= NAV_APP_SHOW_MAX)
            {
               _loc3_ = -1;
               _loc4_ = NAV_APP_TOTAL;
               addElement(this.m_buttons[_loc4_]);
            }
            else if(_loc4_ < 0)
            {
               addElement(this.m_buttons[_loc4_ + NAV_APP_TOTAL]);
               _loc3_++;
            }
            else if(_loc4_ >= NAV_APP_TOTAL && _loc3_ < NAV_APP_SHOW_MAX && _loc3_ != -1)
            {
               _loc4_ -= NAV_APP_TOTAL;
               addElement(this.m_buttons[_loc4_]);
               _loc3_++;
            }
            else
            {
               addElement(this.m_buttons[_loc4_]);
               if(_loc3_ != -1)
               {
                  _loc3_++;
               }
            }
            _loc4_++;
         }
      }
      
      private function supermarketMove(param1:Event) : void
      {
         var _loc2_:MovieClip = this.getChildByName("__supermarketarrow__") as MovieClip;
         var _loc3_:* = this.content.getChildByName("supermarket");
         if(_loc3_)
         {
            _loc2_.x = _loc3_.x + 35;
            _loc2_.y = _loc3_.y + 30;
         }
         else
         {
            this.removeSupermarketTip();
         }
      }
      
      public function currentUserChanged() : void
      {
         var _loc1_:Session = Session.getInstance();
         if(_loc1_.host != null)
         {
            this.m_buttons[NAV_MC].enabled = _loc1_.host.pf2 || _loc1_.host._pf;
         }
      }
      
      private function buttonClickHandler(param1:MouseEvent) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:ViewEvent = null;
         var _loc2_:String = param1.currentTarget.name;
         if(_loc2_ == "mc")
         {
            this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_ENTER_MC,0));
            UserActionRecorder.recordAction(UserActionRecorder.HF_MYPASTURE_CLICKED);
            ClickReportManager.reportClick("up.banner.icon_pasture.click");
         }
         else if(_loc2_ == "mill")
         {
            QzoneJSAPI.toApp(376,"");
            UserActionRecorder.recordAction(UserActionRecorder.HF_MYMILL_CLICKED);
         }
         else if(_loc2_ == "restaurant")
         {
            QzoneJSAPI.toApp(Consts.RESTAURANT_APPID,"");
            UserActionRecorder.recordAction(UserActionRecorder.HF_MYRESTAURANT_CLICKED);
            ClickReportManager.reportClick("up.banner.icon_restaurant.click");
         }
         else if(_loc2_ == "supermarket")
         {
            if(this.m_buttons[NAV_SUPERMARKET].currentFrame == 2)
            {
               _loc4_ = "";
               if(parseInt(Settings.getInstance().getStringAttribute("QQSuperMarketVip")) > 0)
               {
                  _loc4_ = "VIP Lv" + Settings.getInstance().getStringAttribute("QQSuperMarketVip") + "及以上的用户";
               }
               else
               {
                  _loc4_ = Settings.getInstance().getStringAttribute("QQSuperMarketLvl") + "级及以上的用户和VIP用户";
               }
               _loc3_ = "<br/><p align=\'center\'><font size=\'12\'>" + "农场QQ超市入口暂时只对" + _loc4_ + "点亮！其他用户请通过空间应用中心进入游戏。" + "</font></p><br/><br/>";
               this.m_controller.openWindow(Consts.WINDOW_NAME_ALERT,{
                  "title":"QQ超市",
                  "type":Consts.ALERT_TYPE_TEXT,
                  "text":_loc3_,
                  "width":350,
                  "height":190
               });
            }
            else
            {
               if(Settings.getInstance().getStringAttribute("pgvClickEnable").toString() == "1")
               {
                  EventRecorder.pgvSendClick(EventRecorder.PGVID_TOSUPERMARKET);
               }
               QzoneJSAPI.toApp(21641,"fromapp=353&via=QQ.SHOP.FROMFARM");
               ClickReportManager.reportClick("up.banner.icon_market.click");
            }
         }
         else
         {
            _loc5_ = new ViewEvent(ViewEvent.CHILD_CLICK);
            _loc5_.data = {
               "target":param1.currentTarget,
               "name":_loc2_
            };
            dispatchEvent(_loc5_);
         }
      }
      
      private function toolRollOver(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         if(param1 != null && param1.target != null)
         {
            if(param1.currentTarget.hasOwnProperty("tipText") == true && param1.currentTarget["tipText"] != "")
            {
               this.m_controller.showTip(Consts.TIP_NAME_MOUSE,param1.currentTarget["tipText"]);
            }
            else
            {
               _loc2_ = 0;
               while(_loc2_ < this.NAV_MAX)
               {
                  if(param1.target.name == this.BUTTONS_NAME[_loc2_])
                  {
                     this.m_controller.showTip(Consts.TIP_NAME_MOUSE,this.BUTTONS_TIP[_loc2_] as String);
                     break;
                  }
                  _loc2_++;
               }
            }
         }
      }
      
      public function addIcon(param1:String, param2:String, param3:String) : void
      {
         var url:String = param1;
         var name:String = param2;
         var tip:String = param3;
         this.BUTTONS_NAME.push(name);
         this.BUTTONS_TIP.push(tip);
         this.NAV_MAX = this.BUTTONS_TIP.length;
         CommonData.rslManager.requestFile(url,function(param1:*):void
         {
            var _loc3_:Sprite = null;
            var _loc2_:DisplayObject = param1 as DisplayObject;
            if(_loc2_ != null)
            {
               _loc2_.x = _loc2_.y = 0;
               _loc3_ = new Sprite();
               _loc3_.name = name;
               _loc3_.mouseChildren = false;
               _loc3_.buttonMode = true;
               _loc3_.addEventListener(MouseEvent.CLICK,buttonClickHandler);
               _loc3_.addEventListener(MouseEvent.ROLL_OVER,toolRollOver);
               _loc3_.addEventListener(MouseEvent.ROLL_OUT,toolRollOut);
               _loc3_.addChild(_loc2_);
               m_buttons.push(_loc3_);
               addElement(_loc3_);
               width = 480;
               adjustPosition();
            }
         });
      }
   }
}

