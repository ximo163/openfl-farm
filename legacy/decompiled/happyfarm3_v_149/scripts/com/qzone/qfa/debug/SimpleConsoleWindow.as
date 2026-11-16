package com.qzone.qfa.debug
{
   import flash.display.Sprite;
   import flash.text.StyleSheet;
   import flash.text.TextField;
   
   public class SimpleConsoleWindow extends Sprite implements IConsoleWindow
   {
      
      private var _textField:TextField;
      
      private var _logType:int = -1;
      
      public function SimpleConsoleWindow()
      {
         super();
         this.initSkin();
      }
      
      public function get logType() : int
      {
         return this._logType;
      }
      
      public function hide() : void
      {
         if(this.parent)
         {
            this.stage.focus = this.stage;
            this.parent.removeChild(this);
         }
      }
      
      public function set logType(param1:int) : void
      {
         this._logType = param1;
      }
      
      private function initSkin() : void
      {
         this.graphics.clear();
         this.graphics.beginFill(0,0.8);
         this.graphics.drawRoundRectComplex(0,0,700,200,0,0,0,10);
         this.graphics.endFill();
         this._textField = this._textField || new TextField();
         this._textField.width = 700;
         this._textField.height = 200;
         this._textField.multiline = true;
         this._textField.wordWrap = true;
         var _loc1_:StyleSheet = new StyleSheet();
         _loc1_.setStyle("p",{
            "fontFamily":"Lucida Sans Unicode",
            "fontSize":13,
            "color":"#00FF00"
         });
         _loc1_.setStyle(".t",{"leading":-20});
         _loc1_.setStyle(".m",{"marginLeft":90});
         this._textField.styleSheet = _loc1_;
         addChild(this._textField);
      }
      
      public function get isHidden() : Boolean
      {
         return !this.stage;
      }
      
      public function set dataProvider(param1:Array) : void
      {
         if(!param1)
         {
            return;
         }
         this._textField.htmlText = param1.join("");
         this._textField.scrollV = this._textField.maxScrollV;
      }
   }
}

