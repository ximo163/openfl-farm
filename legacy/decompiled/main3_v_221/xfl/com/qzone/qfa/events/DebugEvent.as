package com.qzone.qfa.events
{
   import flash.events.Event;
   
   public class DebugEvent extends Event
   {
      
      public static const LOG_UPDATED:String = "DEBUG_LOG_UPDATED";
      
      public var log:String;
      
      public function DebugEvent(param1:String, param2:String = "")
      {
         this.log = param2;
         super(param1,false,false);
      }
   }
}

