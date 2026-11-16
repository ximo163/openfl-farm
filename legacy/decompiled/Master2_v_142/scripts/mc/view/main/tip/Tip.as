package mc.view.main.tip
{
   import flash.display.Sprite;
   
   public class Tip extends Sprite implements ITip
   {
      
      private var _tX:Number = 0;
      
      private var _tY:Number = 0;
      
      private var _data:Object;
      
      private var _mX:Number = 0;
      
      private var _mY:Number = 0;
      
      public function Tip()
      {
         super();
      }
      
      public function set tX(param1:Number) : void
      {
         this._tX = param1;
      }
      
      public function get mY() : Number
      {
         return this._mY;
      }
      
      public function set tY(param1:Number) : void
      {
         this._tY = param1;
      }
      
      public function get mX() : Number
      {
         return this._mX;
      }
      
      public function set mX(param1:Number) : void
      {
         this._mX = param1;
      }
      
      public function set data(param1:Object) : void
      {
         this._data = param1;
      }
      
      public function set mY(param1:Number) : void
      {
         this._mY = param1;
      }
      
      public function get tX() : Number
      {
         return this._tX;
      }
      
      public function get tY() : Number
      {
         return this._tY;
      }
      
      public function get data() : Object
      {
         return this._data;
      }
   }
}

