package plugins.external.mailPromotion
{
   import common.view.window.BaseWindow;
   import flash.display.DisplayObject;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import interfaces.IMsgCenter;
   
   public class ReceivedView extends BaseWindow
   {
      
      private var _receivedText:DisplayObject;
      
      private var ReceivedText:Class = ReceivedView_ReceivedText;
      
      private var KnowBtn:Class = ReceivedView_KnowBtn;
      
      private var _knowBtn:SimpleButton;
      
      private var _titleT:DisplayObject;
      
      private var TitleT:Class = ReceivedView_TitleT;
      
      public function ReceivedView(param1:IMsgCenter = null)
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
         super.close();
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

