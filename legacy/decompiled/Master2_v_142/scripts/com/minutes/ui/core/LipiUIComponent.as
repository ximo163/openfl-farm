package com.minutes.ui.core
{
   import flash.display.Sprite;
   import flash.events.Event;
   
   public class LipiUIComponent extends Sprite
   {
      
      private var _bgSkin:LipiSkin;
      
      private var _height:Number = 100;
      
      private var _width:Number = 100;
      
      private var _bgSkinChange:Boolean = false;
      
      private var _heightChange:Boolean = true;
      
      private var _widthChange:Boolean = true;
      
      private var _bgAlpha:Number = 1;
      
      private var _bgColor:uint = 16777215;
      
      private var _bgAlphaChange:Boolean = false;
      
      private var _bgColorChange:Boolean = false;
      
      private var _isUpdate:Boolean = false;
      
      public function LipiUIComponent()
      {
         super();
         addEventListener(Event.ADDED_TO_STAGE,this.onAdded);
      }
      
      public function set bgSkin(param1:LipiSkin) : void
      {
         if(param1 == this._bgSkin)
         {
            return;
         }
         if(this._bgSkin != null && contains(this._bgSkin))
         {
            removeChild(this._bgSkin);
         }
         this._bgSkinChange = true;
         this._bgSkin = param1;
         this.invalidateDisplayList();
      }
      
      public function invalidateDisplayList() : void
      {
         this._isUpdate = true;
         if(stage != null)
         {
            stage.invalidate();
         }
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set height(param1:Number) : void
      {
         this._height = param1;
         this._heightChange = true;
         this.invalidateDisplayList();
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = param1;
         this._widthChange = true;
         this.invalidateDisplayList();
      }
      
      private function onRender(param1:Event) : void
      {
         this._update();
      }
      
      public function get bgAlpha() : Number
      {
         return this._bgAlpha;
      }
      
      public function get bgColor() : uint
      {
         return this._bgColor;
      }
      
      private function onAdded(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.onAdded);
         stage.addEventListener(Event.ENTER_FRAME,this.onRender);
         this._isUpdate = true;
         this._update();
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      private function _update() : void
      {
         if(this._isUpdate == true)
         {
            this.updateDisplayList(this.width,this.height);
         }
      }
      
      public function get bgSkin() : LipiSkin
      {
         return this._bgSkin;
      }
      
      public function set bgAlpha(param1:Number) : void
      {
         this._bgAlpha = param1;
         this._bgAlphaChange = true;
         this.invalidateDisplayList();
      }
      
      protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         var _loc3_:UIEvent = null;
         this._isUpdate = false;
         if(this._bgAlphaChange || this._bgColorChange)
         {
            if(this.bgAlpha == 0)
            {
               graphics.clear();
            }
            else
            {
               graphics.clear();
               graphics.beginFill(this.bgColor,this.bgAlpha);
               graphics.drawRect(0,0,param1,param2);
               graphics.endFill();
            }
         }
         if(this._widthChange || this._heightChange)
         {
            _loc3_ = new UIEvent(UIEvent.RESIZE);
            dispatchEvent(_loc3_);
            if(this._bgSkin != null)
            {
               this._bgSkin.height = this.height;
               this._bgSkin.width = this.width;
            }
            else
            {
               graphics.clear();
               graphics.beginFill(this.bgColor,this.bgAlpha);
               graphics.drawRect(0,0,param1,param2);
               graphics.endFill();
            }
         }
         if(this._bgSkinChange && this._bgSkin != null)
         {
            this._bgSkin.width = this.width;
            this._bgSkin.height = this.height;
            super.addChildAt(this._bgSkin,0);
         }
         this._bgSkinChange = false;
         this._bgAlphaChange = false;
         this._bgColorChange = false;
         this._widthChange = false;
         this._heightChange = false;
      }
      
      public function set bgColor(param1:uint) : void
      {
         this._bgColor = param1;
         this._bgColorChange = true;
         this.invalidateDisplayList();
      }
   }
}

