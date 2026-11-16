package mc.events
{
   import flash.events.Event;
   
   public class CursorEvent extends Event
   {
      
      public static const CURSOR:String = "setCursor";
      
      public static const USE_TYPE:String = "useType";
      
      public static const API:String = "api";
      
      private var _cursorName:String = "";
      
      private var _materialName:String = "";
      
      private var _cursorArgument:Object;
      
      public var disabled:Boolean = false;
      
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
      
      public function set materialName(param1:String) : void
      {
         this._materialName = param1;
      }
      
      public function set cursorArgument(param1:Object) : void
      {
         this._cursorArgument = param1;
      }
      
      public function get materialName() : String
      {
         return this._materialName;
      }
      
      public function get cursorArgument() : Object
      {
         return this._cursorArgument;
      }
   }
}

