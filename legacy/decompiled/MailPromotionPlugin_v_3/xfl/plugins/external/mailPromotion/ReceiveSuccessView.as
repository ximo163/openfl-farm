package plugins.external.mailPromotion
{
   import common.CommonData;
   import common.Settings;
   import common.view.window.BaseWindow;
   import flash.display.DisplayObject;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import interfaces.IMsgCenter;
   import report.ClickReportManager;
   
   public class ReceiveSuccessView extends BaseWindow
   {
      
      private var _receivedText:DisplayObject;
      
      private var ReceivedText:Class = ReceiveSuccessView_ReceivedText;
      
      private var KnowBtn:Class = ReceiveSuccessView_KnowBtn;
      
      private var _knowBtn:SimpleButton;
      
      private var _titleT:DisplayObject;
      
      private var TitleT:Class = ReceiveSuccessView_TitleT;
      
      public function ReceiveSuccessView(param1:IMsgCenter = null)
      {
         super(param1);
         title = "";
         windowName = "";
         width = 390;
         height = 230;
         mode = true;
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         var _loc7_:String = null;
         super.close();
         ClickReportManager.reportClick("share.mailBackflow.flash_share_btn_click_nc");
         var _loc2_:String = "哇塞！真是天上掉下宝藏了！50W金币，还有5套12星座的种子，想不炫耀都难，今晚做梦都在笑哦！";
         var _loc3_:String = "";
         var _loc4_:String = "module/ui/icons/mailGift.jpg";
         var _loc5_:String = "";
         _loc5_ = _loc5_ + "%26from%3DmailPresentShare";
         var _loc6_:String = "QQ农场，送豪华礼包";
         CommonData.addCallBackProxy("onSuccess",this.onShareSuccess);
         if(ExternalInterface.available)
         {
            _loc7_ = "fusion2.dialog.share(" + "{title:\'" + _loc6_ + "\',summary:\'" + _loc2_ + "\',pics:\'" + _loc4_ + "\',desc:\'" + _loc3_ + "\',url:\'" + _loc5_ + "\',onSuccess:function (opt){swfAppObject.onSuccess(opt);}" + ",onCancel:function (opt){swfAppObject.onCancel(opt);}" + ",onClose:function (opt){swfAppObject.onClose(opt);}})";
            if(Settings.getInstance().getStringAttribute("agent") == "weibo")
            {
               _loc7_ = "fusion2.dialog.share(" + "{title:\'" + _loc6_ + "\',summary:\'" + _loc2_ + "\',pics:\'" + _loc4_ + "\',desc:\'" + _loc3_ + "\',onSuccess:function (opt){swfAppObject.onSuccess(opt);}" + ",onCancel:function (opt){swfAppObject.onCancel(opt);}" + ",onClose:function (opt){swfAppObject.onClose(opt);}})";
            }
            ExternalInterface.call(_loc7_);
         }
      }
      
      public function onShareSuccess(param1:*) : void
      {
         ClickReportManager.reportClick("share.mailBackflow.page_share_btn_click_nc");
      }
      
      override protected function init() : void
      {
         this._knowBtn = new this.KnowBtn();
         addChild(this._knowBtn);
         this._knowBtn.addEventListener(MouseEvent.CLICK,this.onClick);
         this._knowBtn.x = (width - this._knowBtn.width) / 2;
         this._knowBtn.y = height - (this._knowBtn.height + 11);
         this._receivedText = new this.ReceivedText();
         addChild(this._receivedText);
         this._receivedText.x = 24;
         this._receivedText.y = 48;
         this._titleT = new this.TitleT();
         addChild(this._titleT);
         this._titleT.x = 126;
         this._titleT.y = 1;
      }
   }
}

