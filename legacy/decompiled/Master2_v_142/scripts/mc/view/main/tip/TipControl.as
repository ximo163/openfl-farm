package mc.view.main.tip
{
   import mc.control.ViewControl;
   import mc.events.TipEvent;
   
   public class TipControl
   {
      
      public function TipControl()
      {
         super();
      }
      
      public static function hide() : void
      {
         var _loc1_:TipEvent = new TipEvent(TipEvent.TIP_HIDE);
         ViewControl.getInstance().dispatchEvent(_loc1_);
      }
      
      public static function show(param1:String, param2:Object, param3:int = 0, param4:int = 0) : void
      {
         var _loc5_:TipEvent = new TipEvent(TipEvent.TIP_SHOW);
         _loc5_.tipArgument = param2;
         _loc5_.tipType = param1;
         _loc5_.tX = param3;
         _loc5_.tY = param4;
         ViewControl.getInstance().dispatchEvent(_loc5_);
      }
   }
}

