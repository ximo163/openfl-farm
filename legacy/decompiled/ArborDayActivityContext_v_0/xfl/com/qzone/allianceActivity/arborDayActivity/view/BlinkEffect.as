package com.qzone.allianceActivity.arborDayActivity.view
{
   import com.greensock.TweenLite;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.filters.GlowFilter;
   
   public class BlinkEffect extends EventDispatcher
   {
      
      private var _callback:Function;
      
      private var _target:DisplayObject;
      
      private var _loop:uint = 1;
      
      private var _duration:Number = 2;
      
      private var _ease:Function = null;
      
      private var _upperAlpha:Number = 10;
      
      private var _lowerAlpha:Number = 2;
      
      private var _object:TweenObject;
      
      private var _direction:int = 1;
      
      private var _running:Boolean = false;
      
      private var _glowFilter:GlowFilter;
      
      public function BlinkEffect()
      {
         super();
      }
      
      public function apply(param1:DisplayObject, param2:Function = null) : void
      {
         this._target = param1;
         if(!this._target)
         {
            return;
         }
         this._callback = param2;
         this._object = this._object || new TweenObject();
         this._object.value = this._upperAlpha;
         this._object.cacheAsBitmap = this._target.cacheAsBitmap;
         this._object.direction = -1;
         this._object.loopIndex = 0;
         this._running = true;
         this._target.cacheAsBitmap = true;
         this._glowFilter = new GlowFilter(16776960,1);
         this.gotoAlpha(this._lowerAlpha);
      }
      
      public function kill() : void
      {
         if(this._object)
         {
            TweenLite.killTweensOf(this._object);
            if(this._target)
            {
               this._target.filters = null;
               this._target.cacheAsBitmap = this._object.cacheAsBitmap;
            }
         }
         this._running = false;
      }
      
      private function gotoAlpha(param1:Number) : void
      {
         TweenLite.killTweensOf(this._object);
         TweenLite.to(this._object,this._duration / 2,{
            "value":param1,
            "ease":this._ease,
            "onUpdate":this.renderHandler,
            "onComplete":this.completeHandler
         });
      }
      
      private function renderHandler() : void
      {
         this._glowFilter.blurX = this._glowFilter.blurY = this._object.value;
         this._target.filters = [this._glowFilter];
      }
      
      private function completeHandler() : void
      {
         if(++this._object.loopIndex >= this._loop << 1)
         {
            this.kill();
            if(this._callback != null)
            {
               this._callback.call();
            }
            dispatchEvent(new Event(Event.COMPLETE));
            return;
         }
         this._object.direction *= -1;
         this.gotoAlpha(this._object.direction > 0 ? this._upperAlpha : this._lowerAlpha);
      }
      
      public function get upperAlpha() : Number
      {
         return this._upperAlpha;
      }
      
      public function set upperAlpha(param1:Number) : void
      {
         this._upperAlpha = param1;
      }
      
      public function get lowerAlpha() : Number
      {
         return this._lowerAlpha;
      }
      
      public function set lowerAlpha(param1:Number) : void
      {
         this._lowerAlpha = param1;
      }
      
      public function get ease() : Function
      {
         return this._ease;
      }
      
      public function set ease(param1:Function) : void
      {
         this._ease = param1;
      }
      
      public function get duration() : Number
      {
         return this._duration;
      }
      
      public function set duration(param1:Number) : void
      {
         this._duration = param1;
      }
      
      public function get loop() : uint
      {
         return this._loop;
      }
      
      public function set loop(param1:uint) : void
      {
         this._loop = param1;
      }
      
      public function get running() : Boolean
      {
         return this._running;
      }
   }
}

class TweenObject
{
   
   public var loopIndex:int = 0;
   
   public var direction:int = -1;
   
   public var alpha:Number = 0;
   
   public var cacheAsBitmap:Boolean = false;
   
   private var _value:Number = 0;
   
   public function TweenObject()
   {
      super();
   }
   
   public function get value() : Number
   {
      return this._value;
   }
   
   public function set value(param1:Number) : void
   {
      this._value = param1;
   }
}
