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
      
      public var textDisabledFormat:TextFormat;
      
      protected var paddingV:int;
      
      public var textDefaultFormat:TextFormat;
      
      protected var _text:String;
      
      protected var _clickFn:Function;
      
      protected var _textField:TextField;
      
      protected var paddingH:int;
      
      public function Label(param1:String = "Label", param2:Function = null)
      {
         super();
         _width = 100;
         _height = 20;
         this.paddingH = Style.labelPaddingH;
         this._text = param1;
         this._clickFn = param2;
         this.textDefaultFormat = Style.getLabelFormat();
         this.textDisabledFormat = Style.getDisabledFormat();
         this._textField = new TextField();
         this._textField.selectable = false;
         this._textField.autoSize = TextFieldAutoSize.NONE;
         this.useHandCursor = false;
         this.mouseChildren = false;
      }
      
      override protected function setSize() : void
      {
         this._textField.height = Math.max(20,this._textField.textHeight);
         if(!_resized)
         {
            _width = this._textField.textWidth + 8 + this.paddingH * 2;
         }
         this._textField.width = _width - this.paddingH * 2;
         this._textField.x = this.paddingH;
         this._textField.y = Math.floor(_height - this._textField.height) / 2;
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
      
      override protected function init() : void
      {
         this.text = this._text;
         this.clickFn = this._clickFn;
         addChild(this._textField);
         super.init();
      }
      
      public function get text() : String
      {
         return this._textField.text;
      }
      
      public function set text(param1:String) : void
      {
         this._textField.defaultTextFormat = this.textDefaultFormat;
         this._text = param1 || "";
         this._textField.htmlText = this._text;
         this.textChanged();
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
      
      override protected function setEnabled() : void
      {
         if(false == _enabled)
         {
            this._textField.setTextFormat(this.textDisabledFormat);
         }
         else
         {
            this._textField.setTextFormat(this.textDefaultFormat);
         }
         this.mouseEnabled = _enabled;
      }
   }
}

