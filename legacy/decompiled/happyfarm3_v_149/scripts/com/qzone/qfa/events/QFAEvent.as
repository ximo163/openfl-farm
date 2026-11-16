package com.qzone.qfa.events
{
   import flash.events.Event;
   
   public class QFAEvent extends Event
   {
      
      public static const READY:String = "qfa_ready";
      
      public static const UNLOAD:String = "qfa_unload";
      
      public static const ERROR:String = "qfa_error";
      
      public static const PROGRESS:String = "qfa_progress";
      
      public static const REQUEST:String = "qfa_request";
      
      public static const COMPLETE:String = "qfa_complete";
      
      public static const START:String = "qfa_start";
      
      public var data:*;
      
      public function QFAEvent(param1:String, param2:* = null, param3:Boolean = false, param4:Boolean = false)
      {
         if(param2 != null)
         {
            this.data = param2;
         }
         super(param1,param3,param4);
      }
      
      override public function clone() : Event
      {
         return new QFAEvent(type,this.data,bubbles,cancelable);
      }
   }
}

