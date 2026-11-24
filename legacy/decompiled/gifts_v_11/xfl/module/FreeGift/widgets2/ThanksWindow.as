package module.FreeGift.widgets2
{
   import com.qzone.qfa.events.CommandEvent;
   import common.CommonData;
   import common.Consts;
   import common.Settings;
   import common.misc.Utils;
   import common.view.MaterialProxy;
   import common.view.window.BaseWindow;
   import events.CommonEvent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   import framework.net.CommandDefs;
   import framework.net.NetHelper;
   import interfaces.IMsgCenter;
   import module.FreeGift.FreeGiftController;
   
   public class ThanksWindow extends BaseWindow
   {
      
      public static const THANKS_OK:String = "thanksok";
      
      private var _timer:int = -1;
      
      private var _data:Object;
      
      private var m_controller:FreeGiftController;
      
      private var sendMsgToQQ:Boolean = true;
      
      public function ThanksWindow(param1:FreeGiftController)
      {
         super(param1.module.app as IMsgCenter);
         this.title = "";
         width = 0;
         height = 0;
         mode = true;
         showCloseButton = false;
         this.m_controller = param1;
      }
      
      public function createView(param1:Object) : void
      {
         this._data = param1;
         this.addWindowTimer();
      }
      
      private function closeWinFun() : void
      {
         var _loc1_:MovieClip = this.getChildByName("__freeWin__") as MovieClip;
         _loc1_.selectBox.removeEventListener(MouseEvent.CLICK,this.selectHandler);
         _loc1_.thanksBtn.removeEventListener(MouseEvent.CLICK,this.thanksHandler);
         this.removeChild(_loc1_);
         close();
      }
      
      private function thanksHandler(param1:MouseEvent) : void
      {
         param1.currentTarget.mouseEnabled = false;
         NetHelper.sendRequest(CommandDefs.CMD_FREE_GIFT,{
            "uins":this._data["uin"],
            "tip":int(this.sendMsgToQQ)
         },this.onThanksOneSuccess,this.onThanksFail);
      }
      
      private function onThanksOneSuccess(param1:CommandEvent) : void
      {
         var _loc3_:MovieClip = null;
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_["msg"] == "ok")
         {
            this.m_controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":"恭喜您，赠送成功",
               "parent":this.stage
            });
            dispatchEvent(new CommonEvent(ThanksWindow.THANKS_OK,null));
            this.closeWinFun();
         }
         else
         {
            _loc3_ = Utils.getMaterial("freegiftError") as MovieClip;
            _loc3_.name = "__error__";
            this.addChild(_loc3_);
            _loc3_.closeBtn.addEventListener(MouseEvent.CLICK,this.toTopNumHandler);
            _loc3_.thanksBtn.addEventListener(MouseEvent.CLICK,this.toTopNumHandler);
         }
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
            _loc4_ = this.getChildByName("__freeWin__") as MovieClip;
            _loc4_.thanksBtn.mouseEnabled = true;
            this.m_controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":"系统繁忙",
               "parent":this.stage
            });
         }
      }
      
      override protected function init() : void
      {
         super.init();
      }
      
      private function addWindow() : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:TextField = null;
         var _loc6_:TextField = null;
         var _loc1_:Object = Settings.getInstance().getFreeGift(CommonData.freeGift["gift"]);
         if(this._timer != -1)
         {
            clearTimeout(this._timer);
         }
         _loc2_ = Utils.getMaterial("setfreeGiftWindow") as MovieClip;
         _loc2_.name = "__freeWin__";
         addChildAt(_loc2_,0);
         _loc3_ = new TextField();
         _loc3_.x = -55;
         _loc3_.y = -135;
         _loc3_.selectable = false;
         _loc3_.autoSize = TextFieldAutoSize.LEFT;
         _loc3_.htmlText = "<font color=\'#0099ff\'>" + "答谢好友：" + "</font><font color=\'#ff6600\'>" + this._data["nick"] + "</font>";
         var _loc4_:TextFormat = new TextFormat("SimSun");
         _loc4_.size = 14;
         _loc4_.bold = true;
         _loc4_.leading = 0;
         _loc3_.setTextFormat(_loc4_);
         _loc2_.addChild(_loc3_);
         var _loc5_:MaterialProxy = new MaterialProxy("big");
         _loc5_.setContent(_loc1_["type"],_loc1_["cId"]);
         _loc5_.x = -60;
         _loc5_.y = -23;
         _loc2_.addChild(_loc5_);
         _loc6_ = new TextField();
         _loc6_.x = -96;
         _loc6_.y = 105;
         _loc6_.width = 190;
         _loc6_.selectable = false;
         _loc6_.autoSize = TextFieldAutoSize.CENTER;
         _loc6_.htmlText = "<font color=\'#0099ff\'>" + _loc1_["name"] + "X" + _loc1_["num"] + "</font>";
         _loc4_.align = TextFormatAlign.CENTER;
         _loc6_.setTextFormat(_loc4_);
         _loc2_.addChild(_loc6_);
         _loc2_.selectBox.buttonMode = true;
         _loc2_.selectBox.addEventListener(MouseEvent.CLICK,this.selectHandler,false,0,true);
         _loc2_.thanksBtn.addEventListener(MouseEvent.CLICK,this.thanksHandler,false,0,true);
         _loc2_.closeBtn.addEventListener(MouseEvent.CLICK,this.closeWindows);
      }
      
      private function selectHandler(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = this.getChildByName("__freeWin__") as MovieClip;
         if(this.sendMsgToQQ)
         {
            this.sendMsgToQQ = false;
            _loc2_.selectBox.gotoAndStop(2);
         }
         else
         {
            this.sendMsgToQQ = true;
            _loc2_.selectBox.gotoAndStop(1);
         }
      }
      
      override protected function onClose(param1:Event) : void
      {
         super.onClose(param1);
      }
      
      private function addWindowTimer() : void
      {
         this._timer = setTimeout(this.addWindow,10);
      }
      
      private function toTopNumHandler(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = this.getChildByName("__error__") as MovieClip;
         this.removeChild(_loc2_);
         _loc2_ = null;
         this.closeWinFun();
      }
   }
}

