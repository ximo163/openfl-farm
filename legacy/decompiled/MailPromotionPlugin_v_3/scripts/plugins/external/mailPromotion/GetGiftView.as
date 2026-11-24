package plugins.external.mailPromotion
{
   import com.qzone.allianceActivity.common.ActivityRequestAPI;
   import common.Consts;
   import common.Session;
   import common.view.window.BaseWindow;
   import events.CommonEvent;
   import flash.display.DisplayObject;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import framework.api.FarmAPI;
   import interfaces.IMsgCenter;
   import report.ClickReportManager;
   
   public class GetGiftView extends BaseWindow
   {
      
      private var GetNow:Class = GetGiftView_GetNow;
      
      private var _getBtn:SimpleButton;
      
      private var _title:DisplayObject;
      
      private var GiftContent:Class = GetGiftView_GiftContent;
      
      private var _contentS:DisplayObject;
      
      private var TitleT:Class = GetGiftView_TitleT;
      
      private var _plugin:MailPromotionPlugin;
      
      public function GetGiftView(param1:IMsgCenter, param2:MailPromotionPlugin)
      {
         this._plugin = param2;
         super(param1);
         title = "";
         windowName = "";
         width = 495;
         height = 365;
         mode = true;
      }
      
      private function onGetGiftBag(param1:Object = null) : void
      {
         if(param1["ret"] != 0)
         {
            this._plugin.showGiftBagHaveGot();
         }
         else
         {
            (this._plugin.api as FarmAPI).app.dispatchEvent(new CommonEvent(Consts.DATA_CROP_RELOAD_FLAG,null));
            (this._plugin.api as FarmAPI).app.dispatchEvent(new CommonEvent(Consts.DATA_BAG_RELOAD_FLAG,null));
            Session.getInstance().updateHostAccount(500000);
            this._plugin.showReceiveSuccess();
         }
      }
      
      private function onShare(param1:MouseEvent) : void
      {
         super.close();
         ClickReportManager.reportClick("mailPromotion_Click_getBtn");
         ActivityRequestAPI.exchangeGift(1005,MailPromotionPlugin.APP_ID,MailPromotionPlugin.GIFTBAG_ID,this.onGetGiftBag);
      }
      
      override protected function init() : void
      {
         super.init();
         this._contentS = new this.GiftContent();
         this._getBtn = new this.GetNow();
         addChild(this._contentS);
         this._contentS.x = 26;
         this._contentS.y = 29;
         addChild(this._getBtn);
         this._getBtn.x = (width - this._getBtn.width) / 2;
         this._getBtn.y = height - (this._getBtn.height + 10);
         this._getBtn.addEventListener(MouseEvent.CLICK,this.onShare);
         this._title = new this.TitleT();
         addChild(this._title);
         this._title.x = 170;
         this._title.y = 1;
      }
   }
}

