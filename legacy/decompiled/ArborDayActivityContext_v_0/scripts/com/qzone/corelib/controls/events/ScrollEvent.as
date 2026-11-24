package com.qzone.corelib.controls.events
{
   import flash.events.Event;
   
   public class ScrollEvent extends Event
   {
      
      public static const STOP_SCROLLING:String = "stopScrolling";
      
      public static const START_SCROLLING:String = "startScrolling";
      
      private var _data:* = null;
      
      public function ScrollEvent(param1:String, param2:* = null, param3:Boolean = false, param4:Boolean = false)
      {
         super(param1,param3,param4);
         this._data = param2;
      }
      
      override public function clone() : Event
      {
         return new ScrollEvent(type,this._data,bubbles,cancelable);
      }
      
      override public function toString() : String
      {
         return formatToString("ScrollEvent","" + this._data,"type","bubbles","cancelable","eventPhase");
      }
      
      public function get data() : *
      {
         return this._data;
      }
   }
}

