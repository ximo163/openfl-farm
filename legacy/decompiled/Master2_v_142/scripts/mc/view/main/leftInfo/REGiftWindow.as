package mc.view.main.leftInfo
{
   import com.minutes.ui.control.LipiButton;
   import com.minutes.ui.core.LipiSkin;
   import common.MaterialLib;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import mc.view.common.BaseWindow;
   import mc.view.common.MaterialLoaderProxy;
   import mc.view.farm.GetCropID;
   
   public class REGiftWindow extends BaseWindow
   {
      
      private var _giftItem:Object;
      
      private var _confirmHandler:Function;
      
      private var _directionText:String;
      
      private var directionTextField:TextField;
      
      private var giftSprite:MaterialLoaderProxy;
      
      private var confirmButton:LipiButton;
      
      private var _giftData:Object;
      
      private var _vipText:String = "";
      
      private var giftNameTextField:TextField;
      
      private var tipsTextField:TextField;
      
      public function REGiftWindow()
      {
         super();
         width = 380;
         height = 300;
         mode = true;
         this.init();
      }
      
      public function set giftItem(param1:Object) : void
      {
         this._giftItem = param1;
      }
      
      public function get directionText() : String
      {
         return this._directionText;
      }
      
      override public function init() : void
      {
         this.directionTextField = new TextField();
         this.directionTextField.selectable = false;
         var _loc1_:TextFormat = new TextFormat("Verdana",12,8999699);
         _loc1_.leading = 8;
         this.directionTextField.defaultTextFormat = _loc1_;
         this.directionTextField.width = 340;
         this.directionTextField.wordWrap = true;
         this.directionTextField.multiline = true;
         this.directionTextField.x = 25;
         this.directionTextField.y = 40;
         this.directionTextField.autoSize = TextFieldAutoSize.LEFT;
         addChild(this.directionTextField);
         this.giftSprite = new MaterialLoaderProxy();
         this.giftSprite.x = Math.floor((width - this.giftSprite.width) / 2);
         addChild(this.giftSprite);
         this.giftNameTextField = new TextField();
         this.giftNameTextField.selectable = false;
         this.giftNameTextField.wordWrap = true;
         this.giftNameTextField.multiline = false;
         var _loc2_:TextFormat = new TextFormat("Verdana",12,16711680);
         _loc2_.leading = 5;
         _loc2_.align = TextFormatAlign.CENTER;
         this.giftNameTextField.defaultTextFormat = _loc2_;
         this.giftNameTextField.autoSize = TextFieldAutoSize.LEFT;
         addChild(this.giftNameTextField);
         this.tipsTextField = new TextField();
         this.tipsTextField.selectable = false;
         this.tipsTextField.width = 340;
         this.tipsTextField.x = 25;
         var _loc3_:TextFormat = new TextFormat("Verdana",12,10027008);
         _loc3_.leading = 5;
         this.tipsTextField.defaultTextFormat = _loc3_;
         this.tipsTextField.wordWrap = true;
         this.tipsTextField.multiline = true;
         this.tipsTextField.autoSize = TextFieldAutoSize.LEFT;
         addChild(this.tipsTextField);
         this.confirmButton = new LipiButton();
         this.confirmButton.bgAlpha = 0;
         this.confirmButton.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonOrange"));
         this.confirmButton.width = 65;
         this.confirmButton.height = 25;
         this.confirmButton.x = (width - this.confirmButton.width) / 2;
         this.confirmButton.y = height - 40;
         this.confirmButton.label = "确定";
         this.confirmButton.textColor = 16777215;
         this.confirmButton.addEventListener(MouseEvent.CLICK,this.confirmButtonClick);
         addChild(this.confirmButton);
         if(this.directionText != null && Boolean(this.giftItem))
         {
            this.directionTextField.htmlText = this.directionText;
         }
         if(this.vipText != null)
         {
            this.tipsTextField.htmlText = this.vipText;
         }
         if(this.giftItem)
         {
            this.giftSprite.setContent(this.giftItem["eType"],this.giftItem["eParam"]);
            this.giftNameTextField.text = GetCropID.idToCardName(this.giftItem["eParam"]) || "活动卡片";
         }
         this.setPostion();
      }
      
      public function set confirmHandler(param1:Function) : void
      {
         this._confirmHandler = param1;
      }
      
      private function confirmButtonClick(param1:MouseEvent) : void
      {
         closeHandler();
         if(this._confirmHandler != null)
         {
            this._confirmHandler();
         }
      }
      
      public function set directionText(param1:String) : void
      {
         this._directionText = param1;
         if(this.directionTextField != null)
         {
            this.directionTextField.htmlText = param1;
         }
      }
      
      public function set vipText(param1:String) : void
      {
         this._vipText = param1;
         if(this.tipsTextField != null)
         {
            this.tipsTextField.htmlText = param1;
         }
      }
      
      public function get giftItem() : Object
      {
         return this._giftItem;
      }
      
      private function setPostion() : void
      {
         if(!this._giftItem)
         {
            return;
         }
         this.giftSprite.y = this.directionTextField.y + this.directionTextField.height + 10;
         this.giftNameTextField.x = Math.floor((width - this.giftNameTextField.width) / 2);
         this.giftNameTextField.y = this.giftSprite.y + this.giftSprite.height + 5;
         this.tipsTextField.y = this.giftSprite.y + this.giftSprite.height + 25;
         height = this.tipsTextField.y + this.tipsTextField.height + 50;
         this.confirmButton.y = height - 40;
      }
      
      public function get giftData() : Object
      {
         return this._giftData;
      }
      
      public function get vipText() : String
      {
         return this._vipText;
      }
      
      public function set giftData(param1:Object) : void
      {
         this._giftData = param1;
         this.directionText = param1["direction"];
         this.giftItem = param1["item"];
         if(param1.hasOwnProperty("tipsText"))
         {
            this.vipText = param1["tipsText"];
         }
         this.setPostion();
      }
   }
}

