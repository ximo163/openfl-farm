package mc.view.common
{
   import com.minutes.ui.control.LipiButton;
   import com.minutes.ui.core.LipiSkin;
   import com.qzone.corelib.js.JSProxy;
   import common.MaterialLib;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.external.ExternalInterface;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import mc.api.BeastAPI;
   import mc.control.ViewControl;
   import mc.events.WindowEvent;
   
   public class AlertWindow extends BaseWindow
   {
      
      private var errorIcon:Sprite;
      
      public var confirmFun:Function = null;
      
      private var alertText:TextField;
      
      public var flag:Boolean = false;
      
      private var confirmButton:LipiButton = new LipiButton();
      
      private var successIcon:Sprite;
      
      public function AlertWindow(param1:Number = 320)
      {
         super();
         titleIMG = MaterialLib.getInstance().getClass("AlertWindowTitle");
         width = param1;
         height = 280;
         windowName = "AlertWindow";
         mode = true;
      }
      
      override public function keyEnter() : void
      {
         this.confirmButtonClick();
      }
      
      override protected function closeHandler() : void
      {
         super.closeHandler();
         if(this.flag)
         {
            this.confirmButtonClick();
         }
      }
      
      private function onLinkClicked2(param1:TextEvent) : void
      {
         if(this.data["textLinkHandle"])
         {
            ExternalInterface.call("window.open",param1.text);
         }
      }
      
      private function onLinkClicked(param1:TextEvent) : void
      {
         if(this.data["url"] != undefined && this.data["url"] != "")
         {
            ExternalInterface.call("window.open",this.data["url"]);
         }
         if(param1.text == "gotoWild")
         {
            BeastAPI.getInstance().showWildStage();
         }
         if(param1.text == "wildInfo")
         {
            JSProxy.openWindow("http://blog.qq.com/qzone/1006666002/1293072967.htm");
         }
      }
      
      override public function init() : void
      {
         this.successIcon = MaterialLib.getInstance().getMaterial("SuccessIcon") as Sprite;
         this.errorIcon = MaterialLib.getInstance().getMaterial("ErrorIcon") as Sprite;
         this.successIcon.x = this.errorIcon.x = (width - this.successIcon.width) / 2;
         this.successIcon.y = this.errorIcon.y = 60;
         addChild(this.successIcon);
         addChild(this.errorIcon);
         this.alertText = new TextField();
         this.alertText.selectable = false;
         var _loc1_:TextFormat = new TextFormat("Verdana",14,8999699,null,null,null,null,null,TextFormatAlign.CENTER);
         _loc1_.leading = 8;
         this.alertText.defaultTextFormat = _loc1_;
         this.alertText.width = width - 60;
         this.alertText.multiline = true;
         this.alertText.wordWrap = true;
         this.alertText.autoSize = TextFieldAutoSize.CENTER;
         this.alertText.x = (width - this.alertText.width) / 2;
         this.alertText.y = 170;
         this.alertText.wordWrap = true;
         this.alertText.multiline = true;
         this.alertText.htmlText = "";
         addChild(this.alertText);
         this.confirmButton.bgAlpha = 0;
         this.confirmButton.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonOrange"));
         this.confirmButton.width = 65;
         this.confirmButton.height = 25;
         this.confirmButton.x = (width - this.confirmButton.width) / 2;
         this.confirmButton.y = height - 50;
         this.confirmButton.label = "确定";
         this.confirmButton.textColor = 16777215;
         this.confirmButton.addEventListener(MouseEvent.CLICK,this.confirmButtonClick);
         addChild(this.confirmButton);
         this.setData();
      }
      
      override public function set data(param1:Object) : void
      {
         super.data = param1;
         this.setData();
      }
      
      private function confirmButtonClick(param1:MouseEvent = null) : void
      {
         var _loc2_:WindowEvent = new WindowEvent(WindowEvent.CLOSE);
         _loc2_.window = this;
         ViewControl.getInstance().dispatchEvent(_loc2_);
         if(data.hasOwnProperty("gotourl"))
         {
            ExternalInterface.call("window.open",data["gotourl"]);
         }
         if(this.confirmFun != null)
         {
            this.confirmFun();
         }
      }
      
      private function setData() : void
      {
         if(this.successIcon != null && this.errorIcon != null && data != null)
         {
            if(data.hasOwnProperty("type") && data["type"] == "success")
            {
               this.successIcon.visible = true;
               this.errorIcon.visible = false;
               this.alertText.y = 170;
            }
            else if(data.hasOwnProperty("type") && data["type"] == "error")
            {
               this.successIcon.visible = false;
               this.errorIcon.visible = true;
               this.alertText.y = 170;
            }
            else if(data.hasOwnProperty("type") && data["type"] == "tip")
            {
               this.successIcon.visible = false;
               this.errorIcon.visible = false;
               this.alertText.y = 60;
            }
            else
            {
               this.successIcon.visible = false;
               this.errorIcon.visible = false;
               this.alertText.y = 130;
            }
            if(data.hasOwnProperty("text"))
            {
               this.alertText.htmlText = data["text"];
               this.height = this.alertText.height + this.alertText.y + 70;
               this.confirmButton.y = height - 50;
               this.alertText.addEventListener(TextEvent.LINK,this.onLinkClicked,false,0,true);
               if(data["textLinkHandle"])
               {
                  this.alertText.addEventListener(TextEvent.LINK,this.onLinkClicked2,false,0,true);
               }
            }
         }
      }
   }
}

