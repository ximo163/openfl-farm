package com.qzone.qui.utils
{
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   
   public class FrameTimer extends EventDispatcher
   {
      
      private static var handles:Dictionary;
      
      private static var count:uint;
      
      private static var index:uint;
      
      private static var _stage:DisplayObject;
      
      private var _running:Boolean;
      
      private var _delay:Number;
      
      private var _currentCount:int;
      
      private var _id:uint;
      
      public var repeatCount:int;
      
      public function FrameTimer(param1:Number, param2:int = 0)
      {
         super();
         this._delay = param1;
         this.repeatCount = param2;
      }
      
      private static function setDelay(param1:uint, param2:uint) : void
      {
         handles[param1].delay = Math.ceil((param2 || 1000) / 1000 * _stage.stage.frameRate);
      }
      
      public static function setTimeout(param1:Function, param2:Number, ... rest) : uint
      {
         return addTimer({
            "closure":param1,
            "delay":param2,
            "arguments":rest,
            "timeOut":true,
            "frameCount":1
         });
      }
      
      public static function setInterval(param1:Function, param2:Number, ... rest) : uint
      {
         return addTimer({
            "closure":param1,
            "delay":param2,
            "arguments":rest,
            "frameCount":1
         });
      }
      
      public static function clear(param1:uint) : void
      {
         if(handles.hasOwnProperty(param1))
         {
            delete handles[param1];
            --count;
            if(count == 0)
            {
               _stage.stage.removeEventListener(Event.ENTER_FRAME,onEnterFrame);
            }
         }
      }
      
      public static function init(param1:DisplayObject) : void
      {
         if(_stage == null)
         {
            _stage = param1;
            handles = new Dictionary();
         }
      }
      
      public static function clearInterval(param1:uint) : void
      {
         clear(param1);
      }
      
      private static function addTimer(param1:Object) : uint
      {
         param1.delay = Math.ceil((param1.delay || 1000) / 1000 * _stage.stage.frameRate);
         ++index;
         handles[index] = param1;
         if(count == 0)
         {
            _stage.stage.addEventListener(Event.ENTER_FRAME,onEnterFrame);
         }
         ++count;
         return index;
      }
      
      public static function clearTimeout(param1:uint) : void
      {
         clear(param1);
      }
      
      private static function onEnterFrame(param1:Event) : void
      {
         var _loc2_:* = undefined;
         var _loc3_:Object = null;
         for(_loc2_ in handles)
         {
            _loc3_ = handles[_loc2_];
            if(_loc3_["frameCount"] % _loc3_["delay"] == 0)
            {
               if(_loc3_["timeOut"])
               {
                  clearTimeout(_loc2_);
               }
               _loc3_["closure"].apply(null,_loc3_["arguments"]);
            }
            ++_loc3_["frameCount"];
         }
      }
      
      public function start() : void
      {
         if(this._running == false)
         {
            this._running = true;
            this._id = FrameTimer.addTimer({
               "closure":this.closure,
               "delay":this._delay,
               "arguments":arguments,
               "frameCount":1
            });
         }
      }
      
      public function get delay() : Number
      {
         return this._delay;
      }
      
      public function set delay(param1:Number) : void
      {
         this._delay = param1;
         if(this._running)
         {
            FrameTimer.setDelay(this._id,this._delay);
         }
      }
      
      public function stop() : void
      {
         if(this._running == true)
         {
            this._running = false;
            FrameTimer.clear(this._id);
         }
      }
      
      public function get currentCount() : int
      {
         return this._currentCount;
      }
      
      private function closure(... rest) : void
      {
         ++this._currentCount;
         this.dispatchEvent(new TimerEvent(TimerEvent.TIMER));
         if(this.repeatCount > 0 && this._currentCount >= this.repeatCount)
         {
            FrameTimer.clear(this._id);
            this.dispatchEvent(new TimerEvent(TimerEvent.TIMER_COMPLETE));
         }
      }
      
      public function reset() : void
      {
         this._currentCount = 0;
         this.stop();
      }
      
      public function get running() : Boolean
      {
         return this._running;
      }
   }
}

