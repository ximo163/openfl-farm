package com.minutes.ui.control
{
   import com.minutes.ui.core.LipiSkin;
   import com.minutes.ui.core.LipiUIComponent;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.filters.ColorMatrixFilter;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   
   public class LipiButton extends LipiUIComponent
   {
      
      private var formatChange:Boolean = false;
      
      private var _textStyleChange:Boolean = false;
      
      private var _enable:Boolean = true;
      
      private var _textSize:int = 12;
      
      private var _sizeChange:Boolean = false;
      
      private var _textBold:Boolean = false;
      
      private var _filters:Array;
      
      private var _textColor:uint = 0;
      
      private var labelText:TextField;
      
      private var _icon:DisplayObject;
      
      private var _textModeChange:Boolean = false;
      
      private var _label:String = "";
      
      private var _textFont:String = null;
      
      private var _iconLeft:int = 0;
      
      public function LipiButton()
      {
         super();
         this.init();
      }
      
      public function get enable() : Boolean
      {
         return this._enable;
      }
      
      public function set enable(param1:Boolean) : void
      {
         this._enable = param1;
         this._textModeChange = true;
         invalidateDisplayList();
      }
      
      override public function set width(param1:Number) : void
      {
         this._sizeChange = true;
         if(this.labelText != null && this.labelText.textWidth > width)
         {
            param1 = this.labelText.textWidth + 12;
         }
         super.width = param1;
      }
      
      private function setTextFormat() : void
      {
         if(this.labelText == null)
         {
            return;
         }
         this.labelText.setTextFormat(new TextFormat(this.textFont,this.textSize,this.textColor,this.textBold));
      }
      
      private function init() : void
      {
         this.height = 30;
         this.width = 100;
         this.bgColor = 16711680;
         this.buttonMode = true;
         this.useHandCursor = true;
      }
      
      protected function setTextPosition() : void
      {
         if(this.labelText == null)
         {
            return;
         }
         if(this._icon != null)
         {
            this._icon.x = this.iconLeft + this._icon.width / 2;
            this._icon.y = (this.height - this._icon.height) / 2;
            this.labelText.x = this.iconLeft + this._icon.width * 2;
            this.labelText.y = (this.height - this.labelText.height) / 2;
         }
         else
         {
            this.labelText.x = (this.width - this.labelText.width) / 2;
            this.labelText.y = (this.height - this.labelText.height) / 2.5;
         }
      }
      
      public function set textSize(param1:int) : void
      {
         this._textSize = param1;
         this.formatChange = true;
         invalidateDisplayList();
      }
      
      public function get iconLeft() : int
      {
         return this._iconLeft;
      }
      
      public function get textFont() : String
      {
         return this._textFont;
      }
      
      public function set textBold(param1:Boolean) : void
      {
         this._textBold = param1;
         this.formatChange = true;
         invalidateDisplayList();
      }
      
      public function get textColor() : uint
      {
         return this._textColor;
      }
      
      private function createTextField() : void
      {
         this.labelText = new TextField();
         this.labelText.mouseEnabled = false;
         this.labelText.autoSize = TextFieldAutoSize.LEFT;
         this.labelText.selectable = false;
         this.labelText.defaultTextFormat = new TextFormat("Verdana");
         addChild(this.labelText);
         this.formatChange = true;
         invalidateDisplayList();
      }
      
      public function set textFont(param1:String) : void
      {
         this._textFont = param1;
         this.formatChange = true;
         invalidateDisplayList();
      }
      
      private function textModeChange() : void
      {
         if(this._enable)
         {
            this.buttonMode = true;
            this.useHandCursor = true;
            this.mouseEnabled = true;
            filters = [];
         }
         else
         {
            this.buttonMode = false;
            this.useHandCursor = false;
            this.mouseEnabled = false;
            filters = [new ColorMatrixFilter([0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0,0,0,1,0])];
         }
         if(bgSkin != null)
         {
            bgSkin.enableMouse = this.enable;
         }
      }
      
      public function set iconLeft(param1:int) : void
      {
         this._iconLeft = param1;
         this._sizeChange = true;
         invalidateDisplayList();
      }
      
      override public function set bgSkin(param1:LipiSkin) : void
      {
         super.bgSkin = param1;
         if(bgSkin != null)
         {
            bgSkin.enableMouse = this.enable;
         }
      }
      
      public function set labelFilters(param1:Array) : void
      {
         this._filters = param1;
         this.labelText.filters = this._filters;
      }
      
      public function get textBold() : Boolean
      {
         return this._textBold;
      }
      
      override public function set height(param1:Number) : void
      {
         this._sizeChange = true;
         super.height = param1;
      }
      
      public function get textSize() : int
      {
         return this._textSize;
      }
      
      public function get labelFilters() : Array
      {
         return this._filters;
      }
      
      public function set label(param1:String) : void
      {
         if(this.labelText == null)
         {
            this.createTextField();
         }
         this._label = param1;
         this.labelText.text = this._label || "";
         this.formatChange = true;
         invalidateDisplayList();
      }
      
      public function set textColor(param1:uint) : void
      {
         this._textColor = param1;
         this.formatChange = true;
         invalidateDisplayList();
      }
      
      public function set icon(param1:DisplayObject) : void
      {
         if(this._icon != null)
         {
            this._icon = null;
            removeChild(this._icon);
         }
         if(param1 != null)
         {
            this._icon = param1;
            if(param1 is Sprite)
            {
               Sprite(param1).mouseEnabled = false;
            }
            addChild(param1);
         }
         this._sizeChange = true;
         invalidateDisplayList();
      }
      
      public function get label() : String
      {
         return this._label;
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         super.updateDisplayList(param1,param2);
         if(this.formatChange)
         {
            this.setTextFormat();
            this.setTextPosition();
            this.formatChange = false;
         }
         if(this._sizeChange)
         {
            this.setTextPosition();
            this._sizeChange = false;
         }
         if(this._textModeChange)
         {
            this.textModeChange();
            this._textModeChange = false;
         }
      }
      
      public function get icon() : DisplayObject
      {
         return this._icon;
      }
   }
}

