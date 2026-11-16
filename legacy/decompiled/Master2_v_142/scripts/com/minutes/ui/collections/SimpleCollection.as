package com.minutes.ui.collections
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   
   public class SimpleCollection extends Sprite
   {
      
      private var _bg:DisplayObject;
      
      private var _width:Number = 100;
      
      private var _height:Number = 100;
      
      public function SimpleCollection()
      {
         super();
      }
      
      public function get bg() : DisplayObject
      {
         return this._bg;
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      public function set bg(param1:DisplayObject) : void
      {
         if(this._bg == null)
         {
            this._bg = param1;
            this._bg.width = this.width;
            this._bg.height = this.height;
            addChild(this._bg);
         }
         else
         {
            removeChild(this._bg);
            this._bg = param1;
            this._bg.width = this.width;
            this._bg.height = this.height;
            addChild(this._bg);
         }
      }
      
      override public function set height(param1:Number) : void
      {
         this._height = param1;
         if(this._bg != null)
         {
            this._bg.width = this.width;
            this._bg.height = this.height;
         }
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = param1;
         if(this._bg != null)
         {
            this._bg.width = this.width;
            this._bg.height = this.height;
         }
      }
   }
}

