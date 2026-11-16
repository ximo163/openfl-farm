package com.qzone.qfa.debug
{
   import flash.events.EventDispatcher;
   
   public class Debugger extends EventDispatcher
   {
      
      public function Debugger()
      {
         super();
      }
      
      public static function log(param1:*) : void
      {
         QFAConsole.log(param1);
      }
      
      public static function clear() : void
      {
         QFAConsole.clear();
      }
   }
}

