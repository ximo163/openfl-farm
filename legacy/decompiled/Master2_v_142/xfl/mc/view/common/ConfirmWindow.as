package mc.view.common
{
   import com.minutes.ui.control.LipiButton;
   import com.minutes.ui.core.LipiSkin;
   import common.MaterialLib;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.external.ExternalInterface;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import mc.view.main.WindowControl.WControl;
   
   public class ConfirmWindow extends BaseWindow
   {
      
      private var _cancelFn:Function;
      
      protected var cancelButton:LipiButton = new LipiButton();
      
      protected var confirmButton:LipiButton;
      
      private var errorText:TextField;
      
      private var alertText:TextField;
      
      private var _confirmEnable:Boolean = true;
      
      private var _confirmFn:Function;
      
      public function ConfirmWindow(param1:Number = 360)
      {
         super();
         this.width = param1;
         height = 320;
         titleIMG = MaterialLib.getInstance().getClass("AlertWindowTitle");
         windowName = "ConfirmWindow";
         mode = true;
         this.alertText = new TextField();
         this.alertText.selectable = false;
         var _loc2_:TextFormat = new TextFormat("Verdana",14,8999699,null,null,null,null,null,TextFormatAlign.CENTER);
         _loc2_.leading = 8;
         this.alertText.defaultTextFormat = _loc2_;
         this.alertText.width = width - 60;
         this.alertText.x = (width - this.alertText.width) / 2;
         this.alertText.y = 170;
         this.alertText.wordWrap = true;
         this.alertText.multiline = true;
         this.alertText.autoSize = TextFieldAutoSize.CENTER;
         this.alertText.htmlText = "";
         addChild(this.alertText);
      }
      
      public function set cancelFn(param1:Function) : void
      {
         this._cancelFn = param1;
      }
      
      public function set confirmEnable(param1:Boolean) : void
      {
         if(this.confirmButton != null)
         {
            this.confirmButton.enable = param1;
            this.confirmButton.mouseChildren = param1;
         }
         this._confirmEnable = param1;
      }
      
      override public function init() : void
      {
         var _loc1_:Sprite = MaterialLib.getInstance().getMaterial("ConfirmIcon") as Sprite;
         _loc1_.x = (width - _loc1_.width) / 2;
         _loc1_.y = 60;
         addChild(_loc1_);
         this.errorText = new TextField();
         this.errorText.autoSize = TextFieldAutoSize.LEFT;
         this.errorText.selectable = false;
         var _loc2_:TextFormat = new TextFormat("Verdana",12,10027008,null,null,null,null,null,TextFormatAlign.CENTER);
         _loc2_.leading = 8;
         this.errorText.defaultTextFormat = _loc2_;
         this.errorText.x = (width - this.errorText.width) / 2;
         this.errorText.y = this.alertText.y + 20;
         this.errorText.htmlText = "";
         this.errorText.wordWrap = true;
         this.errorText.multiline = true;
         this.errorText.autoSize = TextFieldAutoSize.CENTER;
         addChild(this.errorText);
         this.confirmButton = new LipiButton();
         this.confirmButton.bgAlpha = 0;
         this.confirmButton.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonOrange"));
         this.confirmButton.width = 64;
         this.confirmButton.height = 25;
         this.confirmButton.x = width / 2 - this.confirmButton.width - 10;
         this.confirmButton.y = height - 45;
         this.confirmButton.label = "确定";
         this.confirmButton.textColor = 16777215;
         this.confirmButton.addEventListener(MouseEvent.CLICK,this.confirmButtonClick);
         addChild(this.confirmButton);
         this.cancelButton.bgAlpha = 0;
         this.cancelButton.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonBlue"));
         this.cancelButton.width = 64;
         this.cancelButton.height = 25;
         this.cancelButton.x = width / 2 + 10;
         this.cancelButton.y = height - 45;
         this.cancelButton.label = "取消";
         this.cancelButton.textColor = 16777215;
         this.cancelButton.addEventListener(MouseEvent.CLICK,this.cancelButtonClick);
         addChild(this.cancelButton);
         this.setData();
      }
      
      override public function set width(param1:Number) : void
      {
         super.width = param1;
         if(this.alertText)
         {
            this.alertText.width = param1 - 60;
         }
      }
      
      override public function set data(param1:Object) : void
      {
         super.data = param1;
         this.setData();
      }
      
      private function confirmButtonClick(param1:MouseEvent = null) : void
      {
         if(this.confirmButton.enable == true)
         {
            WControl.close(this);
            this.confirmFn();
         }
      }
      
      public function set confirmFn(param1:Function) : void
      {
         this._confirmFn = param1;
      }
      
      public function cancelButtonClick(param1:MouseEvent) : void
      {
         WControl.close(this);
         if(this.cancelFn != null)
         {
            this.cancelFn();
         }
      }
      
      public function get cancelFn() : Function
      {
         return this._cancelFn;
      }
      
      public function get confirmEnable() : Boolean
      {
         return this._confirmEnable;
      }
      
      public function get confirmFn() : Function
      {
         return this._confirmFn;
      }
      
      private function setData() : void
      {
         if(this.confirmButton != null && this.alertText != null && data != null)
         {
            if(data.hasOwnProperty("text"))
            {
               this.alertText.htmlText = data["text"];
               height = this.alertText.height + this.alertText.y + 70;
               this.cancelButton.y = height - 45;
               this.confirmButton.y = height - 45;
               if(data["url"] != undefined && data["url"] != "")
               {
                  this.alertText.addEventListener(TextEvent.LINK,this.onLinkClicked,false,0,true);
               }
            }
            if(data.hasOwnProperty("error"))
            {
               this.errorText.text = data["error"];
               this.errorText.x = (width - this.errorText.width) / 2;
               height = this.errorText.height + this.errorText.y + 70;
               this.cancelButton.y = height - 45;
               this.confirmButton.y = height - 45;
            }
         }
         if(this.confirmButton != null)
         {
            this.confirmButton.enable = this.confirmEnable;
         }
      }
      
      private function onLinkClicked(param1:TextEvent) : void
      {
         if(this.data["url"] != undefined && this.data["url"] != "")
         {
            ExternalInterface.call("window.open",this.data["url"]);
         }
      }
      
      override public function keyEnter() : void
      {
         this.confirmButtonClick();
      }
   }
}

