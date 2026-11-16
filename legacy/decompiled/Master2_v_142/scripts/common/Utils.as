package common
{
   import flash.events.TimerEvent;
   import flash.utils.ByteArray;
   import flash.utils.Timer;
   
   public class Utils
   {
      
      public function Utils()
      {
         super();
      }
      
      public static function clearTimeout(param1:Timer) : void
      {
         if(param1)
         {
            if(param1.running)
            {
               param1.stop();
            }
            param1 = null;
         }
      }
      
      public static function objectCopy(param1:Object) : Object
      {
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeObject(param1);
         _loc2_.position = 0;
         return _loc2_.readObject();
      }
      
      public static function setTimeout(param1:int, param2:Function) : Timer
      {
         var delay:int = param1;
         var fn:Function = param2;
         var timer:Timer = new Timer(delay,1);
         timer.addEventListener(TimerEvent.TIMER,function(param1:TimerEvent):void
         {
            fn();
            param1.target.removeEventListener(TimerEvent.TIMER,arguments.callee);
         });
         timer.start();
         return timer;
      }
   }
}

