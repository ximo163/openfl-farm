package com.qzone.qfa.managers.events
{
   import flash.events.Event;
   
   public class RequestEvent extends Event
   {
      
      public static const FAULT:String = "RequestFault";
      
      public static const RESULT:String = "RequestResult";
      
      protected var _data:Object;
      
      public function RequestEvent(param1:String, param2:Object = null, param3:Boolean = false, param4:Boolean = false)
      {
         this._data = param2;
         super(param1,param3,param4);
      }
      
      public function get data() : Object
      {
         return this._data;
      }
      
      public function set data(param1:Object) : void
      {
         this._data = param1;
      }
   }
}

