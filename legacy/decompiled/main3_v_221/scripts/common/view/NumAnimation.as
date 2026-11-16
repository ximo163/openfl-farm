package common.view
{
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class NumAnimation
   {
      
      private var aObject:Object;
      
      private var timer:Timer;
      
      private var startValue:Number = 0;
      
      private var aAttr:String;
      
      private var endValue:Number = 0;
      
      private var currentValue:Number = 0;
      
      public function NumAnimation(param1:Object, param2:String, param3:Number, param4:Number)
      {
         super();
         this.aObject = param1;
         this.aAttr = param2;
         this.startValue = param3;
         this.endValue = param4;
      }
      
      public function start() : void
      {
         if(this.startValue > 2100000000)
         {
            this.stop();
            return;
         }
         if(this.timer == null)
         {
            this.timer = new Timer(50);
            this.timer.addEventListener(TimerEvent.TIMER,this.onTimer,false,0,true);
            this.currentValue = this.startValue;
         }
         this.timer.start();
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         var _loc2_:Number = this.currentValue;
         _loc2_ += (this.endValue - _loc2_) * 0.2;
         this.currentValue = _loc2_;
         this.aObject[this.aAttr] = int(_loc2_);
         if(Math.abs(this.endValue - _loc2_) < 1)
         {
            this.stop();
         }
      }
      
      public function stop() : void
      {
         if(this.timer != null)
         {
            this.timer.stop();
         }
         if(this.aObject != null)
         {
            this.aObject[this.aAttr] = this.endValue;
         }
      }
      
      public function set end(param1:Number) : void
      {
         this.endValue = param1;
         if(this.endValue > 2100000000)
         {
            this.stop();
            return;
         }
         if(this.timer != null)
         {
            this.timer.start();
         }
      }
   }
}

