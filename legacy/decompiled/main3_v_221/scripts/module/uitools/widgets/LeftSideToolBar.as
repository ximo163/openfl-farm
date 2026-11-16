package module.uitools.widgets
{
   import com.qzone.qfa.events.CommandEvent;
   import com.qzone.qui.containers.VBox;
   import com.qzone.qui.core.Align;
   import common.CommonData;
   import common.Consts;
   import common.Language;
   import common.Settings;
   import common.misc.Cookies;
   import common.misc.Utils;
   import common.view.window.PostWindow;
   import entities.Player;
   import events.CommonEvent;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import framework.net.CommandDefs;
   import framework.net.NetHelper;
   import module.uitools.UIController;
   import module.uitools.UIToolsModel;
   import module.uitools.vo.OfflineData;
   import report.ClickReportManager;
   import report.EventRecorder;
   import report.UserActionRecorder;
   
   public class LeftSideToolBar extends VBox
   {
      
      private var m_postWindow:PostWindow;
      
      private var m_controller:UIController;
      
      public function LeftSideToolBar(param1:UIController, param2:Number = 200, param3:Number = 200)
      {
         this.m_controller = param1;
         super(param2,param3);
         backgroundAlpha = 0;
         defaultSkin = null;
         enableValidate = false;
         alignH = Align.LEFT;
         alignV = Align.TOP;
         this.mouseEnabled = false;
         this.mouseChildren = true;
         this.addListener();
         this.creatIcon();
      }
      
      private function set post(param1:Boolean) : void
      {
         var _loc2_:MovieClip = content.getChildByName("__post__") as MovieClip;
         if(param1 == true)
         {
            if(_loc2_ == null)
            {
               _loc2_ = Utils.getMaterial("PostIcon") as MovieClip;
               _loc2_.name = "__post__";
               _loc2_.gotoAndStop(1);
               _loc2_.mouseChildren = false;
               _loc2_.buttonMode = true;
               addElement(_loc2_);
            }
            this.m_controller.model.loadPostData();
         }
         else if(_loc2_ != null)
         {
            removeElement(_loc2_);
         }
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         if(Boolean(param1) && Boolean(param1.target))
         {
            _loc2_ = param1.target.name;
            switch(_loc2_)
            {
               case "__info__":
                  this.m_controller.showTip(Consts.TIP_NAME_MOUSE,"消息");
                  break;
               case "__post__":
                  this.m_controller.showTip(Consts.TIP_NAME_MOUSE,"公告");
                  break;
               case "__cards__":
                  this.m_controller.showTip(Consts.TIP_NAME_MOUSE,"点击签到赢奖励");
                  break;
               case "__freegift__":
                  if(CommonData.freeGift["unread"] == 0)
                  {
                     this.m_controller.showTip(Consts.TIP_NAME_MOUSE,"免费送礼");
                  }
                  else
                  {
                     this.m_controller.showTip(Consts.TIP_NAME_MOUSE,"您有新的礼物！");
                  }
            }
         }
      }
      
      private function creatIcon() : void
      {
         var _loc1_:MovieClip = null;
         _loc1_ = Utils.getMaterial("InformationIcon") as MovieClip;
         if(_loc1_ != null)
         {
            _loc1_.name = "__info__";
            _loc1_.buttonMode = true;
            _loc1_.stop();
            addElement(_loc1_);
         }
         validateNow();
      }
      
      private function onRemoveIcon(param1:CommonEvent) : void
      {
         var _loc2_:DisplayObjectContainer = param1.data as DisplayObjectContainer;
         if(Boolean(_loc2_) && _loc2_.parent == this.content)
         {
            removeElement(_loc2_);
         }
      }
      
      private function onCardsGameUpdated(param1:CommonEvent) : void
      {
         var _loc2_:Boolean = param1.data as Boolean;
         if(_loc2_ == true)
         {
            this.cardsGame = true;
         }
         else
         {
            this.cardsGame = false;
         }
      }
      
      private function openFreeGift() : void
      {
         if(int(CommonData.freeGift["unread"]) >= 1)
         {
            this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_FREEGIFT,{"openIndex":1}));
         }
         else
         {
            this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_FREEGIFT,{"openIndex":0}));
         }
         ClickReportManager.reportClick("left.banner.icon_free_gift.click");
      }
      
      private function set cardsGame(param1:Boolean) : void
      {
         var _loc3_:Boolean = false;
         var _loc2_:MovieClip = content.getChildByName("__cards__") as MovieClip;
         if(param1 == true)
         {
            if(_loc2_ == null)
            {
               _loc3_ = this.m_controller.isCardGameActivity();
               if(_loc3_)
               {
                  _loc2_ = Utils.getMaterial("CardsGameActivityIcon") as MovieClip;
               }
               else
               {
                  _loc2_ = Utils.getMaterial("CardsGameIcon") as MovieClip;
               }
               _loc2_.name = "__cards__";
               _loc2_.mouseChildren = false;
               _loc2_.buttonMode = true;
               addElement(_loc2_);
            }
         }
         else if(_loc2_ != null)
         {
            removeElement(_loc2_);
         }
      }
      
      private function onDataChanged(param1:CommonEvent) : void
      {
         var _loc2_:OfflineData = null;
         if(Boolean(param1) && Boolean(param1.data))
         {
            _loc2_ = param1.data as OfflineData;
            if(_loc2_)
            {
               this.information = _loc2_.m_infoNum > 0 ? true : false;
               this.post = _loc2_.m_postNum > 0 ? true : false;
            }
         }
      }
      
      private function onCurrentUserChanged(param1:CommonEvent) : void
      {
         var _loc2_:Player = null;
         if(Boolean(param1) && Boolean(param1.data))
         {
            _loc2_ = param1.data as Player;
            if(Boolean(_loc2_) && _loc2_.me)
            {
               this.visible = true;
            }
            else
            {
               this.visible = false;
            }
         }
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         if(Boolean(param1) && Boolean(param1.target))
         {
            _loc2_ = param1.target.name;
            switch(_loc2_)
            {
               case "__info__":
                  this.m_controller.model.clearUnReadMsgFlag();
                  this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_PROFILE,{"index":0}));
                  UserActionRecorder.recordAction(UserActionRecorder.HF_SHORTCUTBAR_INFO_CLICKED);
                  ClickReportManager.reportClick("left.banner.icon_message.click");
                  break;
               case "__freegift__":
                  this.openFreeGift();
                  ClickReportManager.reportClick("left.banner.icon_free_gift.click");
                  break;
               case "__post__":
                  this.openPostWindow();
                  UserActionRecorder.recordAction(UserActionRecorder.HF_SHORTCUTBAR_POST_CLICKED);
                  ClickReportManager.reportClick("left.banner.icon_announcement.click");
                  break;
               case "__cards__":
                  this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_CARDSGAMEWINDOW,null));
                  UserActionRecorder.recordAction(UserActionRecorder.HF_SHORTCUTBAR_CARDS_CLICKED);
            }
         }
      }
      
      private function openPostWindow() : void
      {
         var resetMouseCursor:Function = null;
         var postIcon:MovieClip = null;
         var postText:String = null;
         var url:String = null;
         resetMouseCursor = function():void
         {
            m_controller.module.app.useSystemCursor(false);
         };
         var post:* = this.m_controller.model.loadPostData();
         if(post != null)
         {
            if(post["content"] != undefined)
            {
               postText = post["content"] as String;
               if(postText == "" || postText == null)
               {
                  return;
               }
               if(this.m_postWindow == null)
               {
                  this.m_postWindow = new PostWindow(null,Language.L["确定"]);
                  this.m_postWindow.title = "";
                  this.m_postWindow.closeFn = resetMouseCursor;
               }
               this.m_postWindow.text = postText;
               this.m_controller.module.app.farmView.winCtrl.open(this.m_postWindow);
               this.m_controller.module.app.useSystemCursor(true);
               Cookies.setObject("postText",postText);
               Cookies.setObject("postClicked",true);
            }
            else if(post["imageurl"] != undefined)
            {
               url = post["imageurl"] as String;
               if(url == "" || url == null)
               {
                  return;
               }
               if(this.m_postWindow == null)
               {
                  this.m_postWindow = new PostWindow(null,Language.L["确定"]);
                  this.m_postWindow.title = "";
                  this.m_postWindow.closeFn = resetMouseCursor;
               }
               this.m_postWindow.imgUrl = url;
               this.m_controller.module.app.farmView.winCtrl.open(this.m_postWindow);
               this.m_controller.module.app.useSystemCursor(true);
               Cookies.setObject("postImage",url);
               Cookies.setObject("postImageClicked",true);
            }
            EventRecorder.recordSueecssEvent(EventRecorder.HF_POSTVIEW,0);
            postIcon = content.getChildByName("__post__") as MovieClip;
            postIcon.gotoAndStop(1);
         }
      }
      
      private function addListener() : void
      {
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         addEventListener(MouseEvent.MOUSE_OUT,this.onOut);
         addEventListener(MouseEvent.CLICK,this.onClick);
         this.m_controller.module.app.addEventListener(Consts.MSG_FREEGIFT_COUNT_OUT,this.freeGiftCountOut,false,0,true);
         this.m_controller.module.app.addEventListener(Consts.MSG_REFRESH_CARDSGAME,this.onCardsGameUpdated,false,0,true);
         this.m_controller.module.app.addEventListener(Consts.MSG_REMOVE_SHORTCUT_ICON,this.onRemoveIcon,false,0,true);
         this.m_controller.module.app.addEventListener(Consts.MSG_CURRENT_USER_CHANGED,this.onCurrentUserChanged,false,0,true);
         var _loc1_:EventDispatcher = this.m_controller.model as EventDispatcher;
         _loc1_.addEventListener(UIToolsModel.EVENT_OFFLINE_DATA_CHANGED,this.onDataChanged,false,0,true);
         _loc1_.addEventListener(UIToolsModel.EVENT_SYSTEM_POST_LOADED,this.onSystemPostLoaded,false,0,true);
         _loc1_.addEventListener(UIToolsModel.GET_FREE_GIFT,this.getFreeGiftHandler,false,0,true);
      }
      
      private function onOut(param1:MouseEvent) : void
      {
         this.m_controller.hideTip();
      }
      
      private function getFreeGiftHandler(param1:CommonEvent) : void
      {
         var _loc2_:FreeGiftIcon = null;
         if(param1.data["show"] == 1)
         {
            _loc2_ = new FreeGiftIcon();
            if(_loc2_ != null)
            {
               _loc2_.name = "__freegift__";
               _loc2_.buttonMode = true;
               _loc2_.stop();
               addElement(_loc2_);
               _loc2_.init(param1.data);
            }
            CommonData.freeGift = param1.data;
            this.checkFreeGiftAutoPop(_loc2_);
         }
      }
      
      private function onSystemPostLoaded(param1:CommonEvent) : void
      {
         var _loc3_:String = null;
         var _loc4_:Boolean = false;
         var _loc5_:String = null;
         var _loc6_:Boolean = false;
         var _loc7_:MovieClip = null;
         var _loc8_:String = null;
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:Object = param1.data;
         if(_loc2_["content"] != undefined || _loc2_["imageurl"] != undefined)
         {
            _loc3_ = null;
            _loc4_ = false;
            if(_loc2_["content"] != undefined)
            {
               _loc3_ = _loc2_["content"] as String;
               _loc4_ = true;
            }
            if(_loc2_["imageurl"] != undefined)
            {
               _loc3_ = _loc2_["imageurl"] as String;
            }
            _loc5_ = Cookies.getObject(_loc4_ ? "postText" : "postImage") as String;
            _loc6_ = Cookies.getObject(_loc4_ ? "postClicked" : "postImageClicked") as Boolean;
            _loc7_ = content.getChildByName("__post__") as MovieClip;
            _loc8_ = null;
            if(_loc3_ != null && _loc3_ != "" && _loc5_ != _loc3_)
            {
               if(_loc7_ != null)
               {
                  _loc7_.play();
               }
               Cookies.setObject(_loc4_ ? "postClicked" : "postImageClicked",false);
               _loc8_ = _loc2_["force_flag"] as String;
               if(_loc8_ == "1")
               {
                  this.openPostWindow();
               }
            }
            if(!_loc6_ && _loc8_ != "1")
            {
               if(_loc7_ != null)
               {
                  _loc7_.play();
               }
            }
         }
      }
      
      private function freeGiftCountOut(param1:Event) : void
      {
         var _loc2_:MovieClip = content.getChildByName("__freegift__") as MovieClip;
         _loc2_.init(CommonData.freeGift);
      }
      
      private function checkFreeGiftAutoPop(param1:FreeGiftIcon) : void
      {
         var arr:Array = null;
         var start:Date = null;
         var end:Date = null;
         var now:Number = NaN;
         var callBack:Function = null;
         var freeIcon:FreeGiftIcon = param1;
         callBack = function(param1:CommandEvent):void
         {
            var _loc2_:* = NetHelper.getVOData(param1);
            if(_loc2_ == null)
            {
               return;
            }
            if(_loc2_ != null && _loc2_["bit_flag"] != null && _loc2_["bit_flag"] == true)
            {
               openFreeGift();
            }
         };
         var autopop:String = Settings.getInstance().getStringAttribute("freeGiftAutopop");
         if(autopop == null || autopop == "")
         {
            return;
         }
         arr = autopop.split("-");
         start = new Date(arr[0]);
         end = new Date(arr[1]);
         now = CommonData.serverTime * 1000;
         if(now < start.time || now > end.time)
         {
            return;
         }
         freeIcon.showAnimation();
         NetHelper.sendRequest(CommandDefs.AUTO_POP,{"bitpos":29},callBack);
      }
      
      private function set information(param1:Boolean) : void
      {
         var _loc2_:MovieClip = content.getChildByName("__info__") as MovieClip;
         if(_loc2_ == null)
         {
            return;
         }
         if(param1 == true)
         {
            _loc2_.play();
         }
         else
         {
            _loc2_.gotoAndStop(1);
         }
      }
   }
}

