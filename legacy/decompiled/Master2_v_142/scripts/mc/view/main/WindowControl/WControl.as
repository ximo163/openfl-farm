package mc.view.main.WindowControl
{
   import mc.control.ViewControl;
   import mc.events.WindowEvent;
   import mc.view.common.BaseWindow;
   
   public class WControl
   {
      
      public function WControl()
      {
         super();
      }
      
      public static function close(param1:BaseWindow) : void
      {
         var _loc2_:WindowEvent = new WindowEvent(WindowEvent.CLOSE);
         _loc2_.window = param1;
         ViewControl.getInstance().dispatchEvent(_loc2_);
      }
      
      public static function open(param1:BaseWindow) : void
      {
         var _loc2_:WindowEvent = new WindowEvent(WindowEvent.OPEN);
         _loc2_.window = param1;
         ViewControl.getInstance().dispatchEvent(_loc2_);
      }
      
      public static function closeForName(param1:String, param2:Object = null) : void
      {
         var _loc3_:WindowEvent = new WindowEvent(WindowEvent.CLOSE);
         _loc3_.windowName = param1;
         _loc3_.windowArgument = param2;
         ViewControl.getInstance().dispatchEvent(_loc3_);
      }
      
      public static function openForName(param1:String, param2:Object = null) : void
      {
         var _loc3_:WindowEvent = new WindowEvent(WindowEvent.OPEN);
         _loc3_.windowName = param1;
         _loc3_.windowArgument = param2;
         ViewControl.getInstance().dispatchEvent(_loc3_);
      }
   }
}

