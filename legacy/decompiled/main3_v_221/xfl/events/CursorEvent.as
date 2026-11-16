package events
{
   import flash.events.Event;
   
   public class CursorEvent extends Event
   {
      
      public static const SET_CURSOR:String = "SetCursor";
      
      public static const SWITCH_CURSOR:String = "SwitchCursor";
      
      private var _cursorName:String = "";
      
      private var _cursorArgument:String = "";
      
      public function CursorEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
      
      public function get cursorName() : String
      {
         return this._cursorName;
      }
      
      public function set cursorName(param1:String) : void
      {
         this._cursorName = param1;
      }
      
      public function set cursorArgument(param1:String) : void
      {
         this._cursorArgument = param1;
      }
      
      public function get cursorArgument() : String
      {
         return this._cursorArgument;
      }
   }
}

