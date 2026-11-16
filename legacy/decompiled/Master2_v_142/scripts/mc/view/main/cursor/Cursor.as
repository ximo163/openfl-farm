package mc.view.main.cursor
{
   import flash.events.Event;
   import flash.utils.setTimeout;
   import mc.control.ViewControl;
   import mc.events.CursorEvent;
   
   public class Cursor
   {
      
      public static var currentCursor:BaseCursor;
      
      public static var cursorArgument:Object;
      
      public static var preName:String = "";
      
      public static var name:String = "";
      
      public static var system:Boolean = false;
      
      public static var useDrag:Boolean = false;
      
      public function Cursor()
      {
         super();
      }
      
      public static function useSystem(param1:Boolean = true) : void
      {
         var _loc2_:CursorEvent = new CursorEvent(CursorEvent.USE_TYPE);
         if(param1)
         {
            _loc2_.cursorName = "system";
         }
         else
         {
            _loc2_.cursorName = "customize";
         }
         ViewControl.getInstance().dispatchEvent(_loc2_);
      }
      
      public static function setAPICurosr(param1:String, param2:Object = null, param3:String = null) : void
      {
         Cursor.setCursorForAPI(param1,param2,param3);
      }
      
      public static function setCursorForAPI(param1:String, param2:Object = null, param3:String = null) : void
      {
         if(name != "")
         {
            preName == name;
         }
         name = param1;
         cursorArgument = param2;
         var _loc4_:CursorEvent = new CursorEvent(CursorEvent.API);
         _loc4_.cursorName = param1;
         _loc4_.cursorArgument = cursorArgument;
         _loc4_.materialName = param3;
         ViewControl.getInstance().dispatchEvent(_loc4_);
      }
      
      public static function delaySetCursor(param1:String, param2:String = "") : void
      {
         setTimeout(Cursor.setCursor,80,param1,param2);
      }
      
      public static function setCursor(param1:String, param2:Object = null) : void
      {
         if(name != "")
         {
            preName == name;
         }
         name = param1;
         cursorArgument = param2;
         var _loc3_:CursorEvent = new CursorEvent(CursorEvent.CURSOR);
         _loc3_.cursorName = param1;
         _loc3_.cursorArgument = cursorArgument;
         ViewControl.getInstance().dispatchEvent(_loc3_);
         if(cursorArgument != null && cursorArgument.hasOwnProperty("type") && cursorArgument["type"] == "7")
         {
            ViewControl.getInstance().dispatchEvent(new Event("animalStop"));
         }
         else
         {
            ViewControl.getInstance().dispatchEvent(new Event("animalMov"));
         }
      }
   }
}

