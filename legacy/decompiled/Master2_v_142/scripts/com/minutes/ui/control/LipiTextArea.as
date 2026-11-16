package com.minutes.ui.control
{
   import com.minutes.ui.core.LipiUIComponent;
   import com.minutes.ui.core.UIEvent;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.TextEvent;
   import flash.text.TextField;
   import flash.text.TextFieldType;
   import flash.text.TextFormat;
   import flash.utils.getTimer;
   
   public class LipiTextArea extends LipiUIComponent
   {
      
      private var _textField:TextField;
      
      private var _preScroll:int = 0;
      
      public var vLipiScrollBar:LipiScrollBar;
      
      public function LipiTextArea()
      {
         super();
         this.textField = new TextField();
         this.textField.defaultTextFormat = new TextFormat("Verdana");
         this.textField.type = TextFieldType.INPUT;
         this.textField.wordWrap = true;
         this.textField.multiline = true;
         this.textField.addEventListener(KeyboardEvent.KEY_UP,this.keyUpHandler);
         this.textField.addEventListener(Event.SCROLL,this.textFieldScrollHandler);
         this.vLipiScrollBar = new LipiScrollBar();
         if(this.textField.getLineLength(this.textField.numLines - 1) == 0)
         {
            this.vLipiScrollBar.pageHeight = this.textField.numLines;
         }
         else
         {
            this.vLipiScrollBar.pageHeight = this.textField.numLines;
         }
         this.vLipiScrollBar.visibleHeight = this.textField.bottomScrollV - this.textField.scrollV + 1;
         this.reChildPosition();
         addChild(this.textField);
         addChild(this.vLipiScrollBar);
         addEventListener(UIEvent.RESIZE,this.onResize);
         addEventListener(UIEvent.TEXT_CHANGE,this.textChangeHandler);
         this.vLipiScrollBar.addEventListener(LipiScrollBar.SCROLL,this.onScroll);
      }
      
      public function set textField(param1:TextField) : void
      {
         this._textField = param1;
      }
      
      public function set text(param1:String) : void
      {
         this.textField.text = param1;
         var _loc2_:UIEvent = new UIEvent(UIEvent.TEXT_CHANGE);
         dispatchEvent(_loc2_);
      }
      
      public function get text() : String
      {
         return this.textField.text;
      }
      
      public function appendText(param1:String) : void
      {
         this.textField.appendText(param1);
         var _loc2_:UIEvent = new UIEvent(UIEvent.TEXT_CHANGE);
         dispatchEvent(_loc2_);
      }
      
      public function get type() : String
      {
         return this.textField.type;
      }
      
      private function onResize(param1:UIEvent) : void
      {
         this.reChildPosition();
      }
      
      private function onScroll(param1:UIEvent) : void
      {
         this.textField.scrollV = Number(param1.data) * this.textField.numLines + 1;
         this._preScroll = getTimer();
      }
      
      private function textInputHandler(param1:TextEvent) : void
      {
         var _loc2_:UIEvent = new UIEvent(UIEvent.TEXT_CHANGE);
         dispatchEvent(_loc2_);
      }
      
      public function get textField() : TextField
      {
         return this._textField;
      }
      
      private function keyUpHandler(param1:KeyboardEvent) : void
      {
         var _loc2_:UIEvent = new UIEvent(UIEvent.TEXT_CHANGE);
         dispatchEvent(_loc2_);
      }
      
      private function reChildPosition() : void
      {
         this.textField.width = this.width - this.vLipiScrollBar.width;
         this.textField.height = this.height;
         this.vLipiScrollBar.y = 0;
         this.vLipiScrollBar.x = this.width - this.vLipiScrollBar.width;
         this.vLipiScrollBar.height = this.height;
      }
      
      private function textFieldScrollHandler(param1:Event) : void
      {
         if(getTimer() - this._preScroll > 100)
         {
            this.enforceScrollPosition();
         }
      }
      
      private function enforceScrollPosition() : void
      {
         var _loc1_:Number = (this.textField.scrollV - 1) / this.textField.numLines;
         this.vLipiScrollBar.enforceScrollPosition(_loc1_);
      }
      
      public function set type(param1:String) : void
      {
         this.textField.type = param1;
      }
      
      private function textChangeHandler(param1:UIEvent) : void
      {
         this.vLipiScrollBar.pageHeight = this.textField.numLines;
         this.vLipiScrollBar.visibleHeight = this.textField.bottomScrollV - this.textField.scrollV + 1;
         this.enforceScrollPosition();
      }
      
      public function get htmlText() : String
      {
         return this.textField.htmlText;
      }
      
      public function set htmlText(param1:String) : void
      {
         this.textField.htmlText = param1;
         var _loc2_:UIEvent = new UIEvent(UIEvent.TEXT_CHANGE);
         dispatchEvent(_loc2_);
      }
   }
}

