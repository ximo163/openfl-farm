package mc.events
{
   import flash.events.Event;
   import mc.view.main.floating.FloatingBase;
   
   public class FloatingEvent extends Event
   {
      
      public static const FLOATING_OPEN:String = "floatingOpen";
      
      public static const FLOATING_CLOSE:String = "floatingClose";
      
      private var _floating:FloatingBase;
      
      public function FloatingEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
      
      public function set floating(param1:FloatingBase) : void
      {
         this._floating = param1;
      }
      
      public function get floating() : FloatingBase
      {
         return this._floating;
      }
   }
}

