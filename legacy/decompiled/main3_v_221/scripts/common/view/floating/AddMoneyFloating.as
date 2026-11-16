package common.view.floating
{
   import common.Consts;
   import common.misc.Utils;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.utils.getTimer;
   import interfaces.IMsgCenter;
   
   public class AddMoneyFloating extends FloatingBase
   {
      
      private var _preTime:int = 0;
      
      protected var _addAddAnimation:MovieClip;
      
      public function AddMoneyFloating(param1:IMsgCenter)
      {
         super(param1);
         super.floatName = Consts.FLOAT_TYPE_MONEY;
         this._addAddAnimation = Utils.getMaterial("AddAnimationEx") as MovieClip;
         if(this._addAddAnimation != null)
         {
            this._addAddAnimation.addValueBox.addValue.width = 100;
            addChild(this._addAddAnimation);
         }
         this._preTime = 0;
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemoved,false,0,true);
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         if(getTimer() - this._preTime > 5000)
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
         var _loc2_:int = super._data["value"] as Number;
         if(_loc2_ >= 0)
         {
            this._addAddAnimation.addValueBox.addValue.text = "+" + _loc2_;
         }
         else
         {
            this._addAddAnimation.addValueBox.addValue.text = _loc2_;
         }
         if(this._preTime == 0)
         {
            this._preTime = getTimer();
            addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
         }
         this._addAddAnimation.gotoAndPlay(2);
      }
   }
}

