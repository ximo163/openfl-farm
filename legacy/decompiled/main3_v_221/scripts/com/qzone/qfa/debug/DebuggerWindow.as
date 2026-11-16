package com.qzone.qfa.debug
{
   import com.qzone.qfa.events.DebugEvent;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class DebuggerWindow extends Sprite
   {
      
      private var _initialized:Boolean = false;
      
      private var _textField:TextField;
      
      public function DebuggerWindow()
      {
         super();
         this.mouseEnabled = false;
         this.addEventListener(Event.ADDED_TO_STAGE,this.handleAddToStage);
      }
      
      private function handleDebug(param1:DebugEvent) : void
      {
         if(Boolean(this._textField) && Boolean(this.stage))
         {
            this._textField.appendText(param1.log + "\n");
            this._textField.scrollV = this._textField.maxScrollV;
         }
      }
      
      override public function set visible(param1:Boolean) : void
      {
         super.visible = param1;
         if(visible)
         {
            this.mouseChildren = true;
         }
      }
      
      private function handleAddToStage(param1:Event) : void
      {
         if(!this._initialized)
         {
            this._initialized = true;
            this.initSkin();
         }
      }
      
      private function keyHandler(param1:KeyboardEvent) : void
      {
         trace(param1.keyCode);
         if(param1.keyCode == 191 && param1.ctrlKey)
         {
            this.visible = !this.visible;
            if(this.parent)
            {
               this.parent.setChildIndex(this,this.parent.numChildren - 1);
            }
         }
         else if(param1.keyCode == 88)
         {
            if(this._textField)
            {
               this._textField.text = "";
            }
         }
         if(this.visible == false)
         {
            return;
         }
         switch(param1.keyCode)
         {
            case 27:
               this.mouseChildren = !this.mouseChildren;
         }
      }
      
      private function initSkin() : void
      {
         this.graphics.clear();
         this.graphics.beginFill(0,0.6);
         this.graphics.drawRoundRectComplex(0,0,600,200,0,0,0,10);
         this.graphics.endFill();
         this._textField = this._textField || new TextField();
         this._textField.width = 600;
         this._textField.height = 200;
         this._textField.multiline = true;
         this._textField.wordWrap = true;
         this._textField.defaultTextFormat = new TextFormat("Lucida Sans Unicode",13,65280);
         addChild(this._textField);
         stage.addEventListener(KeyboardEvent.KEY_UP,this.keyHandler);
         this.visible = false;
      }
   }
}

