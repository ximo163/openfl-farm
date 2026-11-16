package common.view.floating
{
   import common.Consts;
   import common.misc.Utils;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.utils.getTimer;
   import interfaces.IMsgCenter;
   
   public class AddHealthAnimation extends FloatingBase
   {
      
      private var _preTime:int;
      
      private var _addHealth:MovieClip;
      
      public function AddHealthAnimation(param1:IMsgCenter)
      {
         super(param1);
         super.floatName = Consts.FLOAT_TYPE_HEALTH;
         this._addHealth = Utils.getMaterial("AddHealth") as MovieClip;
         if(this._addHealth != null)
         {
            addChild(this._addHealth);
         }
         this._preTime = 0;
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemoved,false,0,true);
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         if(getTimer() - this._preTime > 3000)
         {
            removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
            this._preTime = 0;
            super.close();
         }
      }
      
      private function onRemoved(param1:Event) : void
      {
         removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         this._preTime = 0;
      }
      
      override public function start(param1:Object) : void
      {
         super.start(param1);
         if(this._addHealth != null)
         {
            this._addHealth.gotoAndPlay(2);
         }
         if(this._preTime == 0)
         {
            this._preTime = getTimer();
            addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         }
      }
   }
}

