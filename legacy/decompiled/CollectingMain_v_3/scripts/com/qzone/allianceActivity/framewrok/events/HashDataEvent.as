package com.qzone.allianceActivity.framewrok.events
{
   import flash.events.Event;
   import flash.utils.Dictionary;
   
   public class HashDataEvent extends Event
   {
      
      private var _dataMap:Dictionary;
      
      public function HashDataEvent(param1:String, param2:Dictionary = null)
      {
         super(param1,false,true);
         this._dataMap = param2;
         if(this._dataMap == null)
         {
            this._dataMap = new Dictionary(true);
         }
      }
      
      public function getData(param1:*) : *
      {
         return this._dataMap[param1];
      }
      
      public function containsValue(param1:*) : Boolean
      {
         var _loc2_:* = undefined;
         for(_loc2_ in this._dataMap)
         {
            if(this._dataMap[_loc2_] == param1)
            {
               return true;
            }
         }
         return false;
      }
      
      public function delKey(param1:*) : Boolean
      {
         var _loc2_:* = undefined;
         for(_loc2_ in this._dataMap)
         {
            if(_loc2_ == param1)
            {
               delete this._dataMap[param1];
               return true;
            }
         }
         return false;
      }
      
      public function containsKey(param1:*) : Boolean
      {
         var _loc2_:* = undefined;
         for(_loc2_ in this._dataMap)
         {
            if(_loc2_ == param1)
            {
               return true;
            }
         }
         return false;
      }
      
      override public function clone() : Event
      {
         return new HashDataEvent(this.type,this._dataMap);
      }
      
      public function put(param1:*, param2:*) : *
      {
         this._dataMap[param1] = param2;
      }
   }
}

