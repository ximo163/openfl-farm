package module.FreeGift.widgets2
{
   import com.qzone.qfa.events.CommandEvent;
   import common.CommonData;
   import common.Consts;
   import common.Session;
   import common.Settings;
   import common.misc.QzoneJSAPI;
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
   import module.FreeGift.FreeGiftController;
   
   public class GetGiftThanks extends BaseWindow
   {
      
      public static const THANKS_OK:String = "thanksok";
      
      private var _timer:int = -1;
      
      private var _data:Object;
      
      private var m_controller:FreeGiftController;
      
      private var sendData:Object = {};
      
      private var sendMsgToQQ:Boolean = true;
      
      public function GetGiftThanks(param1:FreeGiftController)
      {
         super(param1.module.app as IMsgCenter);
         this.title = "";
         width = 0;
         height = 0;
         mode = true;
         this.m_controller = param1;
      }
      
      public function createView(param1:Object) : void
      {
         this._data = param1;
         this.sendData = {
            "uins":this._data["uin"],
            "tip":0,
            "id":1
         };
         this.addWindowTimer();
      }
      
      private function changsDataHandler(param1:ViewEvent) : void
      {
         this.sendData = {
            "uins":this._data["uin"],
            "tip":param1.data["tip"],
            "id":param1.data["id"],
            "flag":1
         };
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
      
      private function onThanksFail(param1:CommandEvent) : void
      {
         var _loc3_:MovieClip = null;
         var _loc4_:MovieClip = null;
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_["ecode"] == 100)
         {
            _loc3_ = Utils.getMaterial("freegiftError") as MovieClip;
            _loc3_.name = "__error__";
            this.addChild(_loc3_);
            _loc3_.closeBtn.addEventListener(MouseEvent.CLICK,this.toTopNumHandler);
            _loc3_.thanksBtn.addEventListener(MouseEvent.CLICK,this.toTopNumHandler);
         }
         else
         {
            _loc4_ = this.getChildByName("__HallowThanks__") as MovieClip;
            _loc4_.thanksBtn.mouseEnabled = true;
            this.m_controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":"系统繁忙",
               "parent":this.stage
            });
         }
      }
      
      private function closeWinFun() : void
      {
         var _loc1_:MovieClip = this.getChildByName("__HallowThanks__") as MovieClip;
         if(Boolean(_loc1_) && Boolean(this.contains(_loc1_)))
         {
            this.removeChild(_loc1_);
         }
         close();
      }
      
      override protected function init() : void
      {
         super.init();
      }
      
      private function addWindow() : void
      {
         var _loc1_:MovieClip = null;
         if(this._timer != -1)
         {
            clearTimeout(this._timer);
         }
         _loc1_ = Utils.getMaterial("HallowThanks") as MovieClip;
         _loc1_.name = "__HallowThanks__";
         addChildAt(_loc1_,0);
         var _loc2_:GiftSetFriends = new GiftSetFriends(this,490,320);
         _loc1_.content_mc.addChild(_loc2_);
         if(_loc2_.dataList == null)
         {
            _loc2_.loadingVisible = false;
            _loc2_.dataList = Settings.getInstance().getFreeGiftID();
         }
         _loc1_.thanksNick.text = this._data["nick"];
         _loc1_.thanksBtn.addEventListener(MouseEvent.CLICK,this.thanksHandler,false,0,true);
         _loc2_.addEventListener(BaseTileItem.CHILD_CLICK,this.changsDataHandler,false,0,true);
         _loc2_.addEventListener(BaseTileItem.CHILD_OVER,this.onTileItemOver,true,0,true);
         _loc2_.addEventListener(BaseTileItem.CHILD_OUT,this.onTileItemOut,true,0,true);
         _loc1_.closeBtn.addEventListener(MouseEvent.CLICK,this.closeWindows);
      }
      
      private function onTileItemOut(param1:ViewEvent) : void
      {
         if(param1 == null || param1.target == null)
         {
            return;
         }
         this.m_controller.hideTip();
      }
      
      override protected function onClose(param1:Event) : void
      {
         super.onClose(param1);
      }
      
      private function thanksHandler(param1:MouseEvent) : void
      {
         param1.currentTarget.mouseEnabled = false;
         NetHelper.sendRequest(CommandDefs.CMD_FREE_GIFT,this.sendData,this.onThanksSuccess,this.onThanksFail);
      }
      
      private function addWindowTimer() : void
      {
         this._timer = setTimeout(this.addWindow,10);
      }
      
      private function onThanksSuccess(param1:CommandEvent) : void
      {
         var _loc3_:Object = null;
         var _loc4_:MovieClip = null;
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_["msg"] == "ok")
         {
            CommonData.freeGift["alread"] = int(CommonData.freeGift["alread"]) + _loc2_["exp"] / 2;
            this.m_controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":"恭喜您，赠送成功，获得<font color=\'#ff0000\'>" + _loc2_["exp"] + "点农场经验</font>。",
               "parent":this.stage
            });
            Session.getInstance().addReward([{
               "eType":Consts.ITEM_TYPE_EXP,
               "eNum":_loc2_["exp"]
            }]);
            dispatchEvent(new CommonEvent(ThanksWindow.THANKS_OK,null));
            _loc3_ = Settings.getInstance().getFreeGift(this.sendData["id"]);
            QzoneJSAPI.sendRequestOne(this._data["uin"],_loc3_["url"],"赠送",null,null,_loc3_["name"],"常来看看，别错过收礼唷！",_loc3_["use"]);
            this.closeWinFun();
         }
         else
         {
            _loc4_ = Utils.getMaterial("freegiftError") as MovieClip;
            _loc4_.name = "__error__";
            this.addChild(_loc4_);
            _loc4_.closeBtn.addEventListener(MouseEvent.CLICK,this.toTopNumHandler);
            _loc4_.thanksBtn.addEventListener(MouseEvent.CLICK,this.toTopNumHandler);
         }
      }
      
      private function toTopNumHandler(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = this.getChildByName("__error__") as MovieClip;
         this.removeChild(_loc2_);
         _loc2_ = null;
         dispatchEvent(new CommonEvent(ThanksWindow.THANKS_OK,null));
         this.closeWinFun();
      }
   }
}

