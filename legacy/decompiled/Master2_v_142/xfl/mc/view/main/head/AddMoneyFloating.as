package mc.view.main.head
{
   import common.MaterialLib;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.utils.getTimer;
   import mc.view.main.floating.Float;
   import mc.view.main.floating.FloatingBase;
   
   public class AddMoneyFloating extends FloatingBase
   {
      
      private var preTime:int = 0;
      
      private var addAddAnimation:MovieClip;
      
      public function AddMoneyFloating()
      {
         super();
         this.addAddAnimation = MaterialLib.getInstance().getMaterial("AddAnimation") as MovieClip;
         this.addAddAnimation.addValueBox.addValue.width = 100;
         addChild(this.addAddAnimation);
      }
      
      override public function start() : void
      {
         if(this.preTime == 0)
         {
            this.preTime = getTimer();
            addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         }
         this.addAddAnimation.gotoAndPlay(2);
      }
      
      public function get data() : String
      {
         return this.addAddAnimation.addValueBox.addValue.text;
      }
      
      public function set data(param1:String) : void
      {
         if(int(param1) >= 0)
         {
            this.addAddAnimation.addValueBox.addValue.text = "+" + param1;
         }
         else
         {
            this.addAddAnimation.addValueBox.addValue.text = param1;
         }
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         if(getTimer() - this.preTime > 5000)
         {
            removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
            this.preTime = 0;
            Float.close(this);
         }
      }
   }
}

