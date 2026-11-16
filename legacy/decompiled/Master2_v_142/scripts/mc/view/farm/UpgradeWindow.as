package mc.view.farm
{
   import com.minutes.ui.control.LipiButton;
   import com.minutes.ui.core.LipiSkin;
   import common.INI;
   import common.MaterialLib;
   import flash.display.Bitmap;
   import flash.display.Loader;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import mc.view.common.BaseWindow;
   import mc.view.main.WindowControl.WControl;
   
   public class UpgradeWindow extends BaseWindow
   {
      
      private var _upPic1:Loader;
      
      private var _upPic3:Bitmap;
      
      private var _upPic2:Loader;
      
      private var confirmButton:LipiButton;
      
      private var errorText:TextField;
      
      private var _confirmFn:Function;
      
      private var _confirmEnable:Boolean = true;
      
      private var alertText:TextField;
      
      private var alertText2:TextField;
      
      public function UpgradeWindow()
      {
         super();
         width = 390;
         height = 310;
         titleIMG = MaterialLib.getInstance().getClass("AlertWindowTitle");
         windowName = "ConfirmWindow";
         mode = true;
      }
      
      public function set confirmEnable(param1:Boolean) : void
      {
         if(this.confirmButton != null)
         {
            this.confirmButton.enable = param1;
         }
         this._confirmEnable = param1;
      }
      
      override public function init() : void
      {
         var _loc1_:TextFormat = null;
         this.alertText = new TextField();
         this.alertText.selectable = false;
         _loc1_ = new TextFormat("Verdana",14,8999699,null,null,null,null,null,TextFormatAlign.CENTER);
         _loc1_.leading = 8;
         this.alertText.defaultTextFormat = _loc1_;
         this.alertText.width = width - 60;
         this.alertText.height = 80;
         this.alertText.x = (width - this.alertText.width) / 2;
         this.alertText.y = 220;
         this.alertText.wordWrap = true;
         this.alertText.multiline = true;
         this.alertText.htmlText = "";
         addChild(this.alertText);
         this.alertText2 = new TextField();
         this.alertText2.selectable = false;
         _loc1_ = new TextFormat("Verdana",12,8999699,null,null,null,null,null,TextFormatAlign.CENTER);
         _loc1_.leading = 8;
         this.alertText2.defaultTextFormat = _loc1_;
         this.alertText2.width = width;
         this.alertText2.height = 80;
         this.alertText2.x = (width - this.alertText2.width) / 2;
         this.alertText2.y = 165;
         this.alertText2.wordWrap = true;
         this.alertText2.multiline = true;
         this.alertText2.htmlText = "";
         addChild(this.alertText2);
         this.errorText = new TextField();
         this.errorText.autoSize = TextFieldAutoSize.LEFT;
         this.errorText.selectable = false;
         var _loc2_:TextFormat = new TextFormat("Verdana",12,10027008,null,null,null,null,null,TextFormatAlign.CENTER);
         _loc2_.leading = 8;
         this.errorText.defaultTextFormat = _loc2_;
         this.errorText.height = 80;
         this.errorText.x = (width - this.errorText.width) / 2;
         this.errorText.y = 240;
         this.errorText.htmlText = "";
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
         var _loc3_:LipiButton = new LipiButton();
         _loc3_.bgAlpha = 0;
         _loc3_.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonBlue"));
         _loc3_.width = 64;
         _loc3_.height = 25;
         _loc3_.x = width / 2 + 10;
         _loc3_.y = height - 45;
         _loc3_.label = "取消";
         _loc3_.textColor = 16777215;
         _loc3_.addEventListener(MouseEvent.CLICK,this.cancelButtonClick);
         addChild(_loc3_);
         this.setData();
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
      
      private function cancelButtonClick(param1:MouseEvent) : void
      {
         WControl.close(this);
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
         var _loc1_:XML = null;
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:Class = null;
         if(this.alertText != null && data != null)
         {
            if(data.hasOwnProperty("text"))
            {
               this.alertText.htmlText = data["text"];
               this.alertText2.htmlText = data["text2"];
            }
            if(data.hasOwnProperty("error"))
            {
               this.errorText.text = data["error"];
               this.errorText.x = (width - this.errorText.width) / 2;
               this.alertText2.htmlText = data["text2"];
            }
            if(Boolean(this._upPic1) && contains(this._upPic1))
            {
               removeChild(this._upPic1);
               this._upPic1.unload();
               this._upPic1 = null;
            }
            if(Boolean(this._upPic2) && contains(this._upPic2))
            {
               removeChild(this._upPic2);
               this._upPic2.unload();
               this._upPic2 = null;
            }
            if(Boolean(this._upPic3) && contains(this._upPic3))
            {
               removeChild(this._upPic3);
               this._upPic3 = null;
            }
            _loc1_ = INI.getInstance().data;
            _loc2_ = GetCropID.getSwfUrl() + "farm/diy/" + data["pic1"] + ".jpg";
            _loc3_ = GetCropID.getSwfUrl() + "farm/diy/" + data["pic2"] + ".jpg";
            if(data["pic1"] != null)
            {
               _loc4_ = MaterialLib.getInstance().getClass("up_jiantou") as Class;
               this._upPic1 = new Loader();
               this._upPic1.load(new URLRequest(_loc2_));
               addChild(this._upPic1);
               this._upPic1.x = 40;
               this._upPic1.y = 40;
               this._upPic2 = new Loader();
               this._upPic2.load(new URLRequest(_loc3_));
               addChild(this._upPic2);
               this._upPic2.x = 230;
               this._upPic2.y = 40;
               this._upPic3 = new Bitmap(new _loc4_(144,14));
               addChild(this._upPic3);
               this._upPic3.x = 125;
               this._upPic3.y = 195;
            }
            else
            {
               this._upPic2 = new Loader();
               this._upPic2.load(new URLRequest(_loc3_));
               addChild(this._upPic2);
               this._upPic2.x = 125;
               this._upPic2.y = 40;
            }
         }
         if(this.confirmButton != null)
         {
            this.confirmButton.enable = this.confirmEnable;
         }
      }
      
      override public function keyEnter() : void
      {
         this.confirmButtonClick();
      }
   }
}

