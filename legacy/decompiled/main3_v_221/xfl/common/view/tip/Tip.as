package common.view.tip
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import interfaces.ITip;
   
   public class Tip extends Sprite implements ITip
   {
      
      private var _tX:Number;
      
      private var _tY:Number;
      
      protected var _tipName:String;
      
      protected var _data:Object;
      
      private var _mX:Number;
      
      private var _mY:Number;
      
      public function Tip()
      {
         super();
         this._mX = 0;
         this._mY = 0;
         this._tX = 0;
         this._tY = 0;
         this._data = null;
      }
      
      public function set tY(param1:Number) : void
      {
         this._tY = param1;
      }
      
      public function get mY() : Number
      {
         return this._mY;
      }
      
      public function get tipName() : String
      {
         return this._tipName;
      }
      
      public function set tX(param1:Number) : void
      {
         this._tX = param1;
      }
      
      public function set mY(param1:Number) : void
      {
         this._mY = param1;
      }
      
      public function get mX() : Number
      {
         return this._mX;
      }
      
      public function get displayObject() : DisplayObject
      {
         return this as DisplayObject;
      }
      
      public function set data(param1:Object) : void
      {
         this._data = param1;
      }
      
      public function get tX() : Number
      {
         return this._tX;
      }
      
      public function set mX(param1:Number) : void
      {
         this._mX = param1;
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

