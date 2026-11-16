package com.qzone.qui.utils
{
   import flash.events.Event;
   
   public final class EventUtil
   {
      
      public function EventUtil()
      {
         super();
      }
      
      public static function preventDefault(param1:Event) : void
      {
         param1.preventDefault();
      }
      
      public static function stopPropagation(param1:Event) : void
      {
         param1.stopPropagation();
      }
      
      public static function stopImmediatePropagation(param1:Event) : void
      {
         param1.stopImmediatePropagation();
      }
      
      public static function stopAll(param1:Event) : void
      {
         param1.stopPropagation();
         param1.stopImmediatePropagation();
         param1.preventDefault();
      }
   }
}

