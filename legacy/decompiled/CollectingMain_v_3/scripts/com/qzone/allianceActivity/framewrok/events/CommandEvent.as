package com.qzone.allianceActivity.framewrok.events
{
   import flash.events.Event;
   
   public class CommandEvent extends Event
   {
      
      public static const COMMAND_COMPLETE:String = "command_complete";
      
      public static const COMMAND_ERROR:String = "command_error";
      
      public function CommandEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
   }
}

