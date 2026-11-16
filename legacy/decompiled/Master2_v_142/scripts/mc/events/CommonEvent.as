package mc.events
{
   import flash.events.Event;
   
   public class CommonEvent extends Event
   {
      
      private var _data:*;
      
      public function CommonEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
      
      public function set data(param1:*) : void
      {
         this._data = param1;
      }
      
      public function get data() : *
      {
         return this._data;
      }
   }
}

