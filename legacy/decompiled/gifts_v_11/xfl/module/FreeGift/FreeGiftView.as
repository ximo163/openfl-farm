package module.FreeGift
{
   import com.qzone.corelib.net.RSLManager;
   import com.qzone.qfa.events.CommandEvent;
   import com.qzone.utils.DisplayUtil;
   import common.CommonData;
   import common.Consts;
   import common.Session;
   import common.Settings;
   import common.misc.Utils;
   import common.view.window.BaseWindow;
   import events.CommonEvent;
   import events.ViewEvent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   import framework.base.BaseTileItem;
   import framework.net.CommandDefs;
   import framework.net.NetHelper;
   import interfaces.IMsgCenter;
   import module.FreeGift.widgets2.GetGiftItem;
   import module.FreeGift.widgets2.GetGiftThanks;
   import module.FreeGift.widgets2.SetPage;
   import module.FreeGift.widgets2.ThanksWindow;
   import module.FreeGift.widgets2.getGiftPage;
   
   public class FreeGiftView extends BaseWindow
   {
      
      private var _window:MovieClip;
      
      private var m_freePage:getGiftPage;
      
      private var m_controller:FreeGiftController;
      
      private var _getGiftID:int;
      
      private var _timer:int = -1;
      
      private var unreadNum:int;
      
      private var sendGift:SetPage;
      
      private var recallData:Array;
      
      private var _currentGetGiftItem:GetGiftItem;
      
      private var _currentPageIndex:int;
      
      private var _getGiftUin:String;
      
      private var m_nick:String;
      
      public function FreeGiftView(param1:FreeGiftController)
      {
         super(param1.module.app as IMsgCenter);
         windowName = Consts.WINDOW_NAME_FREEGIFT;
         this.title = "";
         width = 0;
         height = 0;
         mode = true;
         showCloseButton = false;
         this._getGiftID = -1;
         this.m_controller = param1;
      }
      
      private function onLoadFailed(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:int = param1.data["index"] as int;
         var _loc3_:String = param1.data["error"] as String;
         if(_loc2_ <= 0)
         {
            if(this.m_freePage != null)
            {
               this.m_freePage.errText = _loc3_;
            }
         }
      }
      
      private function onGetGiftFail(param1:CommandEvent) : void
      {
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            this._getGiftID = -1;
            return;
         }
         if(_loc2_["ecode"] == 200)
         {
            this.m_controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":_loc2_["direction"] || "系统繁忙",
               "parent":this.stage
            });
         }
         else if(_loc2_["ecode"] == -30001)
         {
            if(_loc2_["key"] != undefined)
            {
               this.acceptGift(_loc2_["key"].toString());
               this._getGiftID = -1;
               return;
            }
         }
         else
         {
            this.m_controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":"系统繁忙",
               "parent":this.stage
            });
         }
         if(this._currentGetGiftItem != null)
         {
            this._currentGetGiftItem.enableGetButton = true;
            this._currentGetGiftItem = null;
         }
         this._getGiftID = -1;
      }
      
      private function getGiftClick(param1:ViewEvent) : void
      {
         var _loc2_:GetGiftItem = param1.target as GetGiftItem;
         if(_loc2_ == null)
         {
            return;
         }
         if(this._getGiftID != -1)
         {
            _loc2_.enableGetButton = true;
            return;
         }
         this._getGiftID = parseInt(param1.data["id"].toString());
         this._currentGetGiftItem = _loc2_;
         NetHelper.sendRequest(CommandDefs.CMD_FREE_GIFT_RECV,{"seq":param1.data["id"]},this.onGetGiftSuccess,this.onGetGiftFail);
      }
      
      public function get currentPageIndex() : int
      {
         return this._currentPageIndex;
      }
      
      private function onDataLoaded(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         this.recallData = param1.data;
         if(this.m_freePage != null)
         {
            this.m_freePage.loadingVisible = false;
            this.m_freePage.dataList = param1.data;
         }
      }
      
      override protected function init() : void
      {
         super.init();
         var _loc1_:FreeGiftModel = this.m_controller.model;
         if(_loc1_ != null)
         {
            _loc1_.addEventListener(FreeGiftModel.EVENT_FREE_DATA_LOADED,this.onDataLoaded,false,0,true);
            _loc1_.addEventListener(FreeGiftModel.EVENT_FREE_DATA_FAILED,this.onLoadFailed,false,0,true);
            _loc1_.addEventListener(FreeGiftModel.EVENT_FREE_DATA_LOADING,this.onDataLoading,false,0,true);
         }
      }
      
      private function getGiftBtnHandler(param1:MouseEvent) : void
      {
         this.getGiftWindow();
      }
      
      public function set currentPageIndex(param1:int) : void
      {
         this._currentPageIndex = param1;
      }
      
      public function get controller() : FreeGiftController
      {
         return this.m_controller;
      }
      
      private function setGiftBtnHandler(param1:MouseEvent) : void
      {
         this.setGiftWindow();
      }
      
      private function closeWinFun() : void
      {
         if(this.m_freePage)
         {
            this.m_freePage.dataList = null;
            DisplayUtil.removeChild(this._window.content_mc,this.m_freePage);
            this.m_freePage = null;
         }
         if(this.sendGift)
         {
            DisplayUtil.removeChild(this._window.content_mc,this.sendGift);
            this.sendGift = null;
         }
         this._window.getGiftBtn.removeEventListener(MouseEvent.CLICK,this.getGiftBtnHandler);
         this._window.setGiftBtn.removeEventListener(MouseEvent.CLICK,this.setGiftBtnHandler);
         removeChild(this._window);
         this._window = null;
         this.m_controller.module.app.dispatchEvent(new CommandEvent(Consts.CLOSE_FREEGIFT_WINDOW));
         close();
      }
      
      private function clearAllInWindow() : void
      {
         if(this.m_freePage)
         {
            this._window.content_mc.removeChild(this.m_freePage);
            this.m_freePage = null;
         }
         if(this.sendGift)
         {
            this._window.content_mc.removeChild(this.sendGift);
            this.sendGift = null;
         }
      }
      
      private function getGiftWindow() : void
      {
         this._window.setGiftBtn.mouseEnabled = true;
         this._window.setGiftBtn.gotoAndStop(1);
         this._window.getGiftBtn.mouseEnabled = false;
         this._window.getGiftBtn.gotoAndStop(2);
         if(this.sendGift)
         {
            DisplayUtil.removeChild(this._window.content_mc,this.sendGift);
            this.sendGift = null;
         }
         this.m_freePage = new getGiftPage(this,490,320);
         this._window.content_mc.addChild(this.m_freePage);
         this.m_freePage.x = -3;
         this.m_freePage.addEventListener(GetGiftItem.THANKS_OVER,this.thanksOver,false,0,true);
         this.m_freePage.addEventListener(GetGiftItem.THANKS_OUT,this.thanksOut,false,0,true);
         this.m_freePage.addEventListener(BaseTileItem.CHILD_CLICK,this.thanksClick,false,0,true);
         this.m_freePage.addEventListener(BaseTileItem.CHILD_OVER,this.onTileItemOver,true,0,true);
         this.m_freePage.addEventListener(BaseTileItem.CHILD_OUT,this.onTileItemOut,true,0,true);
         this.m_freePage.addEventListener(GetGiftItem.GET_GIFT_CLICK,this.getGiftClick,false,0,true);
         if(this.m_freePage.dataList == null)
         {
            this.m_freePage.loadingVisible = false;
            this.m_freePage.dataList = this.recallData;
         }
         if(this.unreadNum <= 0)
         {
            this._window.numBox.visible = false;
         }
      }
      
      private function onGetGiftSuccess(param1:CommandEvent) : void
      {
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            this._getGiftID = -1;
            return;
         }
         this.acceptGift(_loc2_["key"]);
         this._getGiftID = -1;
      }
      
      private function thanksOver(param1:ViewEvent) : void
      {
         if(param1 == null || param1.target == null)
         {
            return;
         }
         if(param1.data["errorType"] == "count")
         {
            this.m_controller.showTip(Consts.TIP_NAME_MOUSE,"每天只能发送20条礼物，明天再来吧！");
         }
         else if(param1.data["errorType"] == "repeat")
         {
            this.m_controller.showTip(Consts.TIP_NAME_MOUSE,"每天只能给同1好友发送1次礼物，明天再来吧！");
         }
      }
      
      private function thanksClick(param1:ViewEvent) : void
      {
         this._getGiftUin = param1.data["uin"];
         var _loc2_:GetGiftThanks = new GetGiftThanks(this.m_controller);
         _loc2_.addEventListener(ThanksWindow.THANKS_OK,this.thanksHandler,false,0,true);
         this.m_controller.module.app.farmView.winCtrl.open(_loc2_);
         _loc2_.createView(param1.data);
      }
      
      public function createView() : void
      {
         var _loc1_:RSLManager = RSLManager.getInstance();
         var _loc2_:String = Settings.getInstance().getSecondUrl("freegift");
         _loc1_.requestClass(this.m_controller.model.FREE_BG,this.addWindowTimer,_loc2_);
      }
      
      private function thanksOut(param1:ViewEvent) : void
      {
         if(param1 == null || param1.target == null)
         {
            return;
         }
         this.m_controller.hideTip();
      }
      
      private function thanksHandler(param1:CommonEvent) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = int(this.recallData.length);
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            if(this.recallData[_loc3_]["uin"] == this._getGiftUin)
            {
               this.recallData[_loc3_]["alread"] = true;
            }
            _loc3_++;
         }
         this.m_freePage.dataList = this.recallData;
      }
      
      private function setGiftWindow() : void
      {
         this._window.getGiftBtn.mouseEnabled = true;
         this._window.getGiftBtn.gotoAndStop(1);
         this._window.setGiftBtn.mouseEnabled = false;
         this._window.setGiftBtn.gotoAndStop(2);
         if(this.m_freePage)
         {
            this.m_freePage.dataList = null;
            DisplayUtil.removeChild(this._window.content_mc,this.m_freePage);
            this.m_freePage = null;
         }
         this.sendGift = new SetPage(this,490,320);
         this.sendGift.addEventListener(FreeGiftModel.SEND_FREE_GIFT,this.sendFreeGiftHandler,false,0,true);
         this._window.content_mc.addChild(this.sendGift);
         this.sendGift.addEventListener(BaseTileItem.CHILD_OVER,this.onTileItemOver,true,0,true);
         this.sendGift.addEventListener(BaseTileItem.CHILD_OUT,this.onTileItemOut,true,0,true);
         if(this.sendGift.dataList == null)
         {
            this.sendGift.loadingVisible = false;
            this.sendGift.dataList = Settings.getInstance().getFreeGiftID();
         }
      }
      
      private function sendFreeGiftHandler(param1:CommonEvent) : void
      {
         NetHelper.sendRequest(CommandDefs.CMD_FREE_GIFT,param1.data,this.onThanksSuccess,this.onThanksFail);
      }
      
      private function onTileItemOut(param1:ViewEvent) : void
      {
         if(param1 == null || param1.target == null)
         {
            return;
         }
         this.m_controller.hideTip();
      }
      
      private function onDataLoading(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:int = param1.data["index"] as int;
         var _loc3_:Boolean = param1.data["show"] as Boolean;
         if(_loc2_ == 0)
         {
            if(this.m_freePage != null)
            {
               this.m_freePage.loadingVisible = _loc3_;
            }
         }
      }
      
      private function addWindowTimer() : void
      {
         this._timer = setTimeout(this.addWindow,10);
      }
      
      private function onThanksFail(param1:CommandEvent) : void
      {
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_["ecode"] == 100)
         {
            this.m_controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":"每天只能赠送20位好友免费礼物唷！今天已达到送礼上限！",
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
      
      override protected function onClose(param1:Event) : void
      {
         if(this.m_freePage != null)
         {
            this.m_freePage.dataList = null;
         }
         super.onClose(param1);
      }
      
      private function acceptGift(param1:String) : void
      {
         var _loc5_:int = 0;
         var _loc2_:Object = Settings.getInstance().getFreeGift(param1);
         var _loc3_:String = "接收成功！";
         switch(_loc2_["type"])
         {
            case "1":
               if(_loc2_["name"] == "牧草果实")
               {
                  _loc3_ = _loc3_ + "<font color=\'#ff0000\'>" + _loc2_["num"] + "个" + _loc2_["name"] + "</font>果实已放入";
                  _loc3_ = _loc3_ + "<font color=\'#ff0000\'>" + "\"" + _loc2_["store"] + "\"" + "</font>";
               }
               else
               {
                  _loc3_ = _loc3_ + "<font color=\'#ff0000\'>" + _loc2_["ground"] + "</font>土地稀有";
                  _loc3_ = _loc3_ + "<font color=\'#ff0000\'>" + _loc2_["name"] + "种子" + _loc2_["num"] + "个</font>已放入";
                  _loc3_ = _loc3_ + "<font color=\'#ff0000\'>" + "\"" + _loc2_["store"] + "\"" + "</font>";
               }
               Session.getInstance().addReward([{"eType":Consts.ITEM_TYPE_SEED}]);
               break;
            case "7":
               _loc3_ += "已为您增加";
               _loc3_ = _loc3_ + "<font color=\'#ff0000\'>" + _loc2_["num"] + "</font>";
               _loc3_ += "经验";
               Session.getInstance().addReward([{
                  "eType":Consts.ITEM_TYPE_EXP,
                  "eNum":int(_loc2_["num"])
               }]);
               break;
            case "10":
               _loc3_ = _loc3_ + "<font color=\'#ff0000\'>" + _loc2_["num"] + "个" + _loc2_["name"] + "</font>已放入";
               _loc3_ = _loc3_ + "<font color=\'#ff0000\'>" + "\"" + _loc2_["store"] + "\"" + "</font>";
               Session.getInstance().addReward([{"eType":Consts.ITEM_TYPE_TOOL}]);
               break;
            case "24":
               _loc3_ = _loc3_ + "<font color=\'#ff0000\'>" + _loc2_["num"] + "个" + _loc2_["name"] + "</font>鱼食已放入";
               _loc3_ = _loc3_ + "<font color=\'#ff0000\'>" + "\"" + _loc2_["store"] + "\"" + "</font>";
               Session.getInstance().addReward([{"eType":Consts.ITEM_TYPE_TOOL}]);
         }
         this.m_controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
            "text":_loc3_,
            "parent":this.stage
         });
         var _loc4_:int = int(this.recallData.length);
         _loc5_ = 0;
         while(_loc5_ < _loc4_)
         {
            if(this.recallData[_loc5_]["id"] == this._getGiftID)
            {
               this.recallData[_loc5_]["status"] = 1;
               this.m_freePage.dataList = this.recallData;
               break;
            }
            _loc5_++;
         }
         --this.unreadNum;
         if(this.unreadNum > 50)
         {
            this._window.numBox.num_txt.text = "50+";
         }
         else
         {
            this._window.numBox.num_txt.text = this.unreadNum.toString();
         }
         if(this.unreadNum <= 0)
         {
            this._window.numBox.visible = false;
         }
      }
      
      private function onThanksSuccess(param1:CommandEvent) : void
      {
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_["msg"] == "ok")
         {
            CommonData.freeGift["alread"] = int(CommonData.freeGift["alread"]) + _loc2_["exp"] / 2;
            Session.getInstance().addReward([{
               "eType":Consts.ITEM_TYPE_EXP,
               "eNum":_loc2_["exp"]
            }]);
         }
      }
      
      private function onTileItemOver(param1:ViewEvent) : void
      {
         if(param1 == null || param1.target == null)
         {
            return;
         }
         this.m_controller.showTip(Consts.TIP_NAME_MOUSE,"物品名称：" + param1.data["name"] + "\n物品用途：" + param1.data["use"]);
      }
      
      private function closeWindows(param1:MouseEvent) : void
      {
         this.closeWinFun();
      }
      
      private function addWindow() : void
      {
         var _loc1_:String = null;
         if(this._timer != -1)
         {
            clearTimeout(this._timer);
         }
         this._window = Utils.getMaterial(this.m_controller.model.FREE_BG) as MovieClip;
         if(this._window != null)
         {
            addChildAt(this._window,0);
            this._window.getGiftBtn.buttonMode = true;
            this._window.setGiftBtn.buttonMode = true;
            this._window.getGiftBtn.addEventListener(MouseEvent.CLICK,this.getGiftBtnHandler,false,0,true);
            this._window.setGiftBtn.addEventListener(MouseEvent.CLICK,this.setGiftBtnHandler,false,0,true);
            this._window["time"].text = Settings.getInstance().getStringAttribute("freeGiftTime");
         }
         switch(this.currentPageIndex)
         {
            case 0:
               this._window.numBox.visible = false;
               this.setGiftWindow();
               break;
            case 1:
               this._window.numBox.visible = true;
               if(int(CommonData.freeGift["unread"]) > 50)
               {
                  _loc1_ = "50+";
               }
               else
               {
                  _loc1_ = CommonData.freeGift["unread"];
               }
               if(CommonData.freeGift["unread"] <= 0)
               {
                  this._window.numBox.visible = false;
               }
               this._window.numBox.num_txt.text = _loc1_;
               this.getGiftWindow();
         }
         this.unreadNum = CommonData.freeGift["unread"];
         if(this.unreadNum <= 0)
         {
            this._window.numBox.visible = false;
         }
         CommonData.freeGift["unread"] = 0;
         this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_FREEGIFT_COUNT_OUT,null));
         this._window.closeBtn.addEventListener(MouseEvent.CLICK,this.closeWindows);
      }
   }
}

