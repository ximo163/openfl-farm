package mc.view.main.head
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
         this.start();
      }
      
      private function start() : void
      {
         if(this.timer)
         {
            this.timer.stop();
            this.timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.timer = null;
         }
         this.timer = new Timer(50);
         this.timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.timer.start();
         this.currentValue = this.startValue;
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         this.execute();
      }
      
      private function execute() : void
      {
         var _loc1_:Number = this.currentValue;
         _loc1_ += (this.endValue - _loc1_) * 0.2;
         this.currentValue = _loc1_;
         this.aObject[this.aAttr] = _loc1_.toFixed(0);
         if(Math.abs(this.endValue - _loc1_) < 1)
         {
            this.aObject[this.aAttr] = this.endValue;
            this.timer.stop();
            this.timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.aObject = null;
            this.aAttr = null;
         }
      }
      
      public function distory() : void
      {
         if(this.timer)
         {
            if(this.aObject)
            {
               this.aObject[this.aAttr] = this.endValue;
               this.aObject = null;
               this.aAttr = null;
            }
            this.timer.stop();
            this.timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.timer = null;
         }
      }
   }
}

