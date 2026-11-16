package com.qzone.qui.makers
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.FocusEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class TipInputMaker extends EventDispatcher
   {
      
      public var tipText:String = "按名称查找";
      
      private var textInFormat:TextFormat;
      
      public var tipTextColor:uint = 11184810;
      
      private var _textFiled:TextField;
      
      private var textOutFormat:TextFormat;
      
      public function TipInputMaker()
      {
         super();
      }
      
      public function set target(param1:TextField) : void
      {
         this.removeEvent();
         if(param1)
         {
            this._textFiled = param1;
            this.textInFormat = this._textFiled.defaultTextFormat;
            this.textOutFormat = new TextFormat();
            this.textOutFormat.color = this.tipTextColor;
            this.addEvent();
            this._FOCUS_OUT(null);
         }
      }
      
      private function _FOCUS_IN(param1:Event) : void
      {
         if(this._textFiled.text == this.tipText)
         {
            this._textFiled.text = "";
            this._textFiled.setTextFormat(this.textInFormat);
         }
      }
      
      public function get text() : String
      {
         if(!this._textFiled)
         {
            return "";
         }
         return this._textFiled.text != this.tipText ? this._textFiled.text : "";
      }
      
      private function _FOCUS_OUT(param1:Event) : void
      {
         if(this._textFiled.text == "")
         {
            this._textFiled.text = this.tipText;
            this._textFiled.setTextFormat(this.textOutFormat);
         }
      }
      
      protected function removeEvent() : void
      {
         if(this._textFiled)
         {
            this._textFiled.removeEventListener(FocusEvent.FOCUS_IN,this._FOCUS_IN);
            this._textFiled.removeEventListener(FocusEvent.FOCUS_OUT,this._FOCUS_OUT);
         }
      }
      
      protected function addEvent() : void
      {
         this._textFiled.addEventListener(FocusEvent.FOCUS_IN,this._FOCUS_IN);
         this._textFiled.addEventListener(FocusEvent.FOCUS_OUT,this._FOCUS_OUT);
      }
   }
}

