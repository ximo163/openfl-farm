package mc.view.common
{
   import com.minutes.ui.control.LipiButton;
   import com.minutes.ui.core.LipiSkin;
   import common.MaterialLib;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import mc.control.ViewControl;
   import mc.events.WindowEvent;
   import mc.view.main.cursor.Cursor;
   
   public class InfoWindow extends BaseWindow
   {
      
      private var errorIcon:Sprite;
      
      private var alertText:TextField;
      
      private var successIcon:Sprite;
      
      public function InfoWindow()
      {
         super();
         titleIMG = MaterialLib.getInstance().getClass("AlertWindowTitle");
         width = 300;
         height = 240;
         windowName = "InfoWindow";
         mode = true;
      }
      
      override public function keyEnter() : void
      {
         this.confirmButtonClick();
      }
      
      private function setData() : void
      {
         if(data != null && Boolean(this.alertText))
         {
            if(data.hasOwnProperty("text"))
            {
               this.alertText.htmlText = data["text"];
            }
         }
      }
      
      override public function init() : void
      {
         this.alertText = new TextField();
         this.alertText.selectable = false;
         var _loc1_:TextFormat = new TextFormat("Verdana",14,8999699,null,null,null,null,null,TextFormatAlign.LEFT);
         _loc1_.leading = 8;
         this.alertText.defaultTextFormat = _loc1_;
         this.alertText.width = width - 40;
         this.alertText.height = height - 110;
         this.alertText.border = false;
         this.alertText.x = (width - this.alertText.width) / 2;
         this.alertText.y = 50;
         this.alertText.wordWrap = true;
         this.alertText.multiline = true;
         this.alertText.htmlText = "";
         addChild(this.alertText);
         var _loc2_:LipiButton = new LipiButton();
         _loc2_.bgAlpha = 0;
         _loc2_.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonOrange"));
         _loc2_.width = 65;
         _loc2_.height = 25;
         _loc2_.x = (width - _loc2_.width) / 2;
         _loc2_.y = height - 50;
         _loc2_.label = "确定";
         _loc2_.textColor = 16777215;
         _loc2_.addEventListener(MouseEvent.CLICK,this.confirmButtonClick);
         addChild(_loc2_);
         this.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         this.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         this.setData();
      }
      
      private function onRollOut(param1:MouseEvent) : void
      {
         Cursor.useSystem(false);
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
            navigateToURL(new URLRequest(data["gotourl"]),data["target"]);
         }
      }
      
      private function onRollOver(param1:MouseEvent) : void
      {
         Cursor.useSystem();
      }
   }
}

