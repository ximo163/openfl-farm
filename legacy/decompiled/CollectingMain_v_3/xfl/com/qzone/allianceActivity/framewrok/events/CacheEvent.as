package com.qzone.allianceActivity.framewrok.events
{
   import flash.events.Event;
   
   public class CacheEvent extends Event
   {
      
      public static const PROPERTY_CHANGE:String = "cache_property_change";
      
      public var propertyName:String;
      
      public var value:*;
      
      public function CacheEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
      
      public static function createChangeEvent(param1:String, param2:*) : CacheEvent
      {
         var _loc3_:CacheEvent = new CacheEvent(PROPERTY_CHANGE);
         _loc3_.propertyName = param1;
         _loc3_.value = param2;
         return _loc3_;
      }
   }
}

