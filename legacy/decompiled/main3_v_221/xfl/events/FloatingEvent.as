package events
{
   import flash.events.Event;
   
   public class FloatingEvent extends Event
   {
      
      public static const FLOATING_CLOSE:String = "floatingClose";
      
      public static const FLOATING_OPEN:String = "floatingOpen";
      
      private var _fid:int;
      
      private var _floating:String;
      
      private var _data:Object;
      
      public function FloatingEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
         this._fid = -1;
         this._data = null;
         this._floating = null;
      }
      
      public function get fid() : int
      {
         return this._fid;
      }
      
      public function get floating() : String
      {
         return this._floating;
      }
      
      public function get data() : Object
      {
         return this._data;
      }
      
      public function set floating(param1:String) : void
      {
         this._floating = param1;
      }
      
      public function set data(param1:Object) : void
      {
         this._data = param1;
      }
      
      public function set fid(param1:int) : void
      {
         this._fid = param1;
      }
   }
}

