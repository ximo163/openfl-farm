package mc.view.farm.animals
{
   import common.MaterialLib;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Timer;
   import mc.control.ViewControl;
   
   public class Fly extends Sprite
   {
      
      private var _movx:Number;
      
      private var _movy:Number;
      
      private var _flyMC:MovieClip;
      
      private var _flyTimer:Timer = new Timer(10);
      
      private var _movPoint:Point;
      
      public function Fly()
      {
         super();
         this._flyMC = MaterialLib.getInstance().getMaterial("FlyMC") as MovieClip;
         addChild(this._flyMC);
      }
      
      public function onTimer(param1:TimerEvent = null) : void
      {
         this.x += this._movx;
         this.y += this._movy;
         if(Math.abs(this._movPoint.x - this.x) < 10)
         {
            ViewControl.getInstance().dispatchEvent(new Event("updateFly"));
            this.distory();
         }
      }
      
      public function flyTo(param1:Point) : void
      {
         this._movPoint = param1;
         this._movx = (this._movPoint.x - this.x) / 100;
         this._movy = (this._movPoint.y - this.y) / 100;
         if(this._movPoint.x > this.x)
         {
            this._flyMC.getChildAt(0).visible = false;
            this._flyMC.getChildAt(1).visible = true;
         }
         else
         {
            this._flyMC.getChildAt(1).visible = false;
            this._flyMC.getChildAt(0).visible = true;
         }
         this._flyTimer.reset();
         this._flyTimer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this._flyTimer.start();
      }
      
      public function distory() : void
      {
         this.visible = false;
         if(parent)
         {
            parent.removeChild(this);
         }
         if(this._flyTimer)
         {
            this._flyTimer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this._flyTimer.stop();
            this._flyTimer = null;
         }
      }
   }
}

