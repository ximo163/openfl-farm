package mc.model
{
   import flash.events.Event;
   
   public class ModelEvent extends Event
   {
      
      private var _data:Object;
      
      public function ModelEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
      
      public function set data(param1:Object) : void
      {
         this._data = param1;
      }
      
      public function get data() : Object
      {
         return this._data;
      }
   }
}

