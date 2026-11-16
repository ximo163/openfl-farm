package common.view.window
{
   import com.qzone.qui.controls.Button;
   import com.qzone.utils.AlignUtil;
   import common.Consts;
   import common.misc.Utils;
   import flash.display.Sprite;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import interfaces.IMsgCenter;
   
   public class ConfirmWindow extends BaseWindow
   {
      
      protected var _confirmButton:Button;
      
      protected var _confirmIcon:Sprite;
      
      protected var _confirmEnable:Boolean;
      
      protected var _errorText:TextField = new TextField();
      
      protected var _confirmFn:Function;
      
      protected var _alertText:TextField = new TextField();
      
      protected var _cancelButton:Button;
      
      protected var _hideIcon:Boolean;
      
      public function ConfirmWindow(param1:IMsgCenter)
      {
         super(param1);
         width = 320;
         height = 240;
         title = "确定";
         windowName = Consts.WINDOW_NAME_CONFIRM;
         mode = true;
         this._hideIcon = false;
         this._confirmEnable = true;
         this._confirmFn = null;
      }
      
      override protected function setSize() : void
      {
         super.setSize();
         if(this._errorText != null)
         {
            this._errorText.x = (width - this._errorText.width) / 2;
            this._errorText.y = height - 70;
         }
         if(this._alertText != null)
         {
            this._alertText.x = (width - this._alertText.width) / 2;
            if(this._hideIcon == true)
            {
               this._alertText.y = 60;
            }
            else if(this._confirmIcon != null)
            {
               this._alertText.y = this._confirmIcon.y + this._confirmIcon.height + 50;
            }
            else
            {
               this._alertText.y = 120;
            }
         }
         if(this._confirmButton != null)
         {
            this._confirmButton.x = width / 2 - this._confirmButton.width - 10;
            this._confirmButton.y = height - 45;
         }
         if(this._cancelButton != null)
         {
            this._cancelButton.x = width / 2 + 10;
            this._cancelButton.y = height - 45;
         }
         if(this._confirmIcon != null && this._hideIcon == false)
         {
            this._confirmIcon.x = (width - this._confirmIcon.width) / 2;
            this._confirmIcon.y = 40;
         }
         if(panelTitle != null)
         {
            panelTitle.x = AlignUtil.middle(width,panelTitle.width);
         }
      }
      
      public function set confirmEnable(param1:Boolean) : void
      {
         if(this._confirmButton != null)
         {
            this._confirmButton.enabled = param1;
            this._confirmButton.mouseEnabled = param1;
            this._confirmButton.mouseChildren = param1;
            this._confirmButton.useHandCursor = param1;
         }
         this._confirmEnable = param1;
      }
      
      override protected function init() : void
      {
         this._alertText = new TextField();
         this._alertText.selectable = false;
         var _loc1_:TextFormat = new TextFormat("Verdana",14,3355443,null,null,null,null,null,TextFormatAlign.CENTER);
         _loc1_.leading = 8;
         this._alertText.defaultTextFormat = _loc1_;
         this._alertText.width = width - 10;
         this._alertText.height = 80;
         this._alertText.wordWrap = true;
         this._alertText.multiline = true;
         addChild(this._alertText);
         this._errorText = new TextField();
         this._errorText.autoSize = TextFieldAutoSize.LEFT;
         this._errorText.selectable = false;
         var _loc2_:TextFormat = new TextFormat("Verdana",12,10027008,null,null,null,null,null,TextFormatAlign.CENTER);
         _loc2_.leading = 8;
         this._errorText.defaultTextFormat = _loc2_;
         this._errorText.height = this._errorText.textHeight + 10;
         this._errorText.htmlText = "";
         addChild(this._errorText);
         this._confirmButton = new Button();
         this._confirmButton.defaultSkin = Utils.getClass("ButtonOrange");
         this._confirmButton.width = 64;
         this._confirmButton.height = 25;
         this._confirmButton.x = width / 2 - this._confirmButton.width - 10;
         this._confirmButton.y = height - 45;
         this._confirmButton.text = "确定";
         this._confirmButton.addEventListener(MouseEvent.CLICK,this.confirmButtonClick);
         addChild(this._confirmButton);
         this._cancelButton = new Button();
         this._cancelButton.defaultSkin = Utils.getClass("ButtonBlue");
         this._cancelButton.width = 64;
         this._cancelButton.height = 25;
         this._cancelButton.x = width / 2 + 10;
         this._cancelButton.y = height - 45;
         this._cancelButton.text = "取消";
         this._cancelButton.addEventListener(MouseEvent.CLICK,this.cancelButtonClick);
         addChild(this._cancelButton);
      }
      
      protected function confirmButtonClick(param1:MouseEvent = null) : void
      {
         if(this._confirmButton.enabled == true)
         {
            super.close();
            if(this._confirmFn != null)
            {
               this._confirmFn();
            }
            this._confirmFn = null;
         }
      }
      
      public function set confirmFn(param1:Function) : void
      {
         this._confirmFn = param1;
      }
      
      protected function cancelButtonClick(param1:MouseEvent) : void
      {
         super.close();
      }
      
      private function customizeIcon() : void
      {
         var _loc1_:Sprite = null;
         if(data["customIcon"] != undefined)
         {
            _loc1_ = Utils.getMaterial(data["customIcon"]) as Sprite;
         }
         if(_loc1_ == null)
         {
            _loc1_ = Utils.getMaterial("ConfirmIcon") as Sprite;
         }
         this._confirmIcon = _loc1_;
         addChild(this._confirmIcon);
      }
      
      private function adjustIcon() : void
      {
         if(this._hideIcon == true)
         {
            if(this._confirmIcon != null && this.contains(this._confirmIcon) == true)
            {
               removeChild(this._confirmIcon);
            }
            this._alertText.height = 110;
         }
         else
         {
            if(this._confirmIcon != null && this.contains(this._confirmIcon) == false)
            {
               addChild(this._confirmIcon);
            }
            this._alertText.height = 80;
         }
      }
      
      public function get confirmFn() : Function
      {
         return this._confirmFn;
      }
      
      public function get confirmEnable() : Boolean
      {
         return this._confirmEnable;
      }
      
      override public function keyEnter(param1:KeyboardEvent) : void
      {
         this.confirmButtonClick();
      }
      
      override protected function setData() : void
      {
         if(data != null)
         {
            this.graphics.clear();
            this._errorText.text = "";
            if(this._errorText != null && data["error"] != undefined)
            {
               this._errorText.text = data["error"] || "";
            }
            if(this._alertText != null && data["text"] != undefined)
            {
               this._alertText.htmlText = data["text"] || "";
               this._alertText.height = this._alertText.textHeight + 10;
            }
            if(this._errorText != null && this._alertText != null)
            {
               this.height = this._errorText.textHeight + this._alertText.height + this._alertText.y + 20 + 45;
            }
            if(data["confirmFn"] != undefined)
            {
               this._confirmFn = data["confirmFn"] as Function;
            }
            else
            {
               this._confirmFn = null;
            }
            if(data["title"] != undefined)
            {
               this.title = data["title"] as String;
            }
            else
            {
               this.title = "确定";
            }
            if(data["width"] != undefined)
            {
               this.width = data["width"] as int;
               this._alertText.width = this.width - 20;
            }
            else
            {
               this.width = 320;
               this._alertText.width = this.width - 20;
            }
            if(data["height"] != undefined)
            {
               this.height = data["height"] as int;
            }
            else
            {
               this.height = 240;
            }
            if(data["confirmEnable"] != undefined)
            {
               this.confirmEnable = data["confirmEnable"] as Boolean;
            }
            else
            {
               this.confirmEnable = true;
            }
            if(data["hideIcon"] != undefined)
            {
               this._hideIcon = data["hideIcon"] as Boolean;
               this.adjustIcon();
            }
            else
            {
               this._hideIcon = false;
               this.customizeIcon();
               this.adjustIcon();
            }
         }
         if(this._confirmButton != null)
         {
            this._confirmButton.enabled = this.confirmEnable;
         }
      }
   }
}

