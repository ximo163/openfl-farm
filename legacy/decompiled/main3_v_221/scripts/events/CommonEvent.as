package events
{
   import flash.events.Event;
   
   public class CommonEvent extends Event
   {
      
      private var _data:*;
      
      private var _result:*;
      
      public function CommonEvent(param1:String, param2:*, param3:* = null, param4:Boolean = false, param5:Boolean = false)
      {
         super(param1,param4,param5);
         this._data = param2;
         this._result = param3;
      }
      
      public function set result(param1:*) : void
      {
         this._result = param1;
      }
      
      public function set data(param1:*) : void
      {
         this._data = param1;
      }
      
      public function get data() : *
      {
         return this._data;
      }
      
      public function get result() : *
      {
         return this._result;
      }
   }
}

