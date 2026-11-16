package com.minutes.ui.collections
{
   import flash.display.Sprite;
   
   public class LipiListChild extends Sprite implements ILipiTileChild
   {
      
      private var _fixedX:Number;
      
      private var _data:Object;
      
      private var _fixedY:Number;
      
      public function LipiListChild()
      {
         super();
      }
      
      public function set fixedY(param1:Number) : void
      {
         this._fixedY = param1;
      }
      
      public function get fixedY() : Number
      {
         return this._fixedY;
      }
      
      public function set fixedX(param1:Number) : void
      {
         this._fixedX = param1;
      }
      
      public function get fixedX() : Number
      {
         return this._fixedX;
      }
      
      public function get data() : Object
      {
         return this._data;
      }
      
      public function set data(param1:Object) : void
      {
         this._data = param1;
      }
   }
}

