package com.qzone.qui.controls
{
   import com.qzone.qui.styles.Style;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   
   public class Label extends UIComponent
   {
      
      protected var _text:String;
      
      protected var _textField:TextField;
      
      protected var paddingH:int;
      
      public var textDisabledFormat:TextFormat;
      
      protected var paddingV:int;
      
      public var textDefaultFormat:TextFormat;
      
      protected var _clickFn:Function;
      
      public function Label(param1:String = "Label", param2:Function = null, param3:String = "")
      {
         super();
         _width = 100;
         _height = 20;
         this.paddingH = Style.labelPaddingH;
         this.paddingV = 0;
         this._text = param1;
         this._clickFn = param2;
         if(param2 == null)
         {
            mouseEnabled = false;
         }
         this.textDefaultFormat = Style.getLabelFormat();
         this.textDisabledFormat = Style.getDisabledFormat();
         this._textField = new TextField();
         this._textField.selectable = false;
         this._textField.multiline = true;
         if(param3 == "")
         {
            this._textField.autoSize = TextFieldAutoSize.NONE;
         }
         else
         {
            this._textField.autoSize = param3;
         }
         this.useHandCursor = false;
         this.mouseChildren = false;
      }
      
      override protected function setSize() : void
      {
         if(this._textField == null)
         {
            return;
         }
         if(_resized == false)
         {
            _width = this._textField.textWidth + 8 + this.paddingH * 2;
         }
         this._textField.width = _width - this.paddingH * 2;
         this._textField.height = Math.max(25,this._textField.textHeight);
         this._textField.x = this.paddingH;
         this._textField.y = this.paddingV;
      }
      
      protected function textChanged() : void
      {
         var _loc1_:Number = _width;
         var _loc2_:Number = _height;
         this.setSize();
         if(_loc1_ != _width || _loc2_ != _height)
         {
            this.dispatchEvent(new Event(Event.RESIZE));
         }
      }
      
      public function get textField() : TextField
      {
         return this._textField;
      }
      
      override protected function init() : void
      {
         this.text = this._text;
         this.clickFn = this._clickFn;
         addChild(this._textField);
         super.init();
      }
      
      public function set padingV(param1:int) : void
      {
         this.paddingV = param1;
      }
      
      public function set text(param1:String) : void
      {
         this._textField.defaultTextFormat = this.textDefaultFormat;
         this._text = param1 || "";
         this._textField.htmlText = this._text;
         this.textChanged();
      }
      
      public function set embedFonts(param1:Boolean) : void
      {
         if(this._textField != null)
         {
            this._textField.embedFonts = param1;
         }
      }
      
      public function set clickFn(param1:Function) : void
      {
         this.removeClickEvent();
         if(param1 != null)
         {
            this._clickFn = param1;
            this.addEventListener(MouseEvent.CLICK,this._clickFn,false,0,true);
            this.buttonMode = true;
         }
      }
      
      public function get text() : String
      {
         if(this._textField != null)
         {
            return this._textField.text;
         }
         return "";
      }
      
      public function get embedFonts() : Boolean
      {
         if(this._textField != null)
         {
            return this._textField.embedFonts;
         }
         return false;
      }
      
      private function removeClickEvent() : void
      {
         if(this._clickFn != null)
         {
            this.removeEventListener(MouseEvent.CLICK,this._clickFn);
            this.buttonMode = false;
            this._clickFn = null;
         }
      }
      
      public function set padingH(param1:int) : void
      {
         this.paddingH = param1;
      }
      
      override protected function setEnabled() : void
      {
         if(this._textField != null)
         {
            if(_enabled == false)
            {
               this._textField.setTextFormat(this.textDisabledFormat);
            }
            else
            {
               this._textField.setTextFormat(this.textDefaultFormat);
            }
         }
         this.mouseEnabled = _enabled;
      }
   }
}

