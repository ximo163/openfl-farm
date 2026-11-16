package mc.view.farm.land
{
   import common.LocalData;
   import common.MaterialLib;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Timer;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.farm.animals.Animal;
   import mc.view.main.floating.Float;
   import mc.view.main.floating.FloatingBase;
   
   public class ClockOperateFloating extends FloatingBase
   {
      
      public var animal:Animal;
      
      private var bg:MovieClip;
      
      private var _timer:Timer;
      
      private var _t:Number = 10;
      
      private var _animal:Animal;
      
      public var animalX:int;
      
      public function ClockOperateFloating(param1:Number, param2:Animal)
      {
         super();
         this.bg = MaterialLib.getInstance().getMaterial("Clock15") as MovieClip;
         addChild(this.bg);
         MData.getInstance().mainData.addEventListener(MainData.CURRENT_USER_CHANGE,this.onChange);
         this.bg.sec.text = param1;
         this._animal = param2;
         this._t = param1;
      }
      
      override public function start() : void
      {
         if(this._timer == null && this._t > 0)
         {
            this._timer = new Timer(100);
            this._timer.addEventListener(TimerEvent.TIMER,this.onTimer);
            this._timer.start();
         }
         else
         {
            Float.close(this);
            this._animal = null;
         }
      }
      
      public function updatePos() : void
      {
         if(!this.animal)
         {
            return;
         }
         var _loc1_:Point = new Point(this.animal.x,this.animal.childBounds.y);
         var _loc2_:Point = this.animal.localToGlobal(_loc1_);
         var _loc3_:Object = LocalData.rollCollection;
         var _loc4_:Number = this.animal.x - LocalData.rollCollection.scrollRect.x;
         var _loc5_:Number = _loc2_.y;
         this.x = _loc4_;
         this.y = _loc5_ + 10;
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         if(Boolean(this._timer) && (this._animal.data["growTimeNext"] == 0 || this._animal.data["growTimeNext"] > 15))
         {
            this._timer.stop();
            this._timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this._timer = null;
            this._animal = null;
            Float.close(this);
            return;
         }
         this.bg.sec.text = this._animal.data["growTimeNext"];
      }
      
      private function onChange(param1:Event) : void
      {
         Float.close(this);
         if(this._timer)
         {
            this._timer.stop();
            this._timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this._timer = null;
         }
         this._animal = null;
      }
   }
}

