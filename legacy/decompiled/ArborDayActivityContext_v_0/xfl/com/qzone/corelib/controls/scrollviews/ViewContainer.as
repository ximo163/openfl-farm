package com.qzone.corelib.controls.scrollviews
{
   import flash.display.Sprite;
   
   public class ViewContainer extends Sprite
   {
      
      private var _height:Number = 0;
      
      private var _width:Number = 0;
      
      public function ViewContainer()
      {
         super();
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
         this._height = param1;
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = param1;
      }
   }
}

