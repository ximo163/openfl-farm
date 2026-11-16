package mc.view.main.floating
{
   import mc.control.ViewControl;
   import mc.events.FloatingEvent;
   
   public class Float
   {
      
      public function Float()
      {
         super();
      }
      
      public static function close(param1:FloatingBase) : void
      {
         var _loc2_:FloatingEvent = new FloatingEvent(FloatingEvent.FLOATING_CLOSE);
         _loc2_.floating = param1;
         ViewControl.getInstance().dispatchEvent(_loc2_);
      }
      
      public static function open(param1:FloatingBase) : void
      {
         var _loc2_:FloatingEvent = new FloatingEvent(FloatingEvent.FLOATING_OPEN);
         _loc2_.floating = param1;
         ViewControl.getInstance().dispatchEvent(_loc2_);
      }
   }
}

