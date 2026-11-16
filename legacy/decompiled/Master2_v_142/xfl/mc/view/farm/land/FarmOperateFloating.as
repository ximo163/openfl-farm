package mc.view.farm.land
{
   import common.MaterialLib;
   import flash.display.Sprite;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import mc.view.main.floating.Float;
   import mc.view.main.floating.FloatingBase;
   
   public class FarmOperateFloating extends FloatingBase
   {
      
      private var _sTime:int;
      
      private var _timer:Timer;
      
      private var textField:TextField;
      
      private var _t:Number = 1000;
      
      public function FarmOperateFloating(param1:Number = 0)
      {
         var _loc2_:Sprite = null;
         super();
         _loc2_ = MaterialLib.getInstance().getMaterial("TalkBoxMy1") as Sprite;
         addChild(_loc2_);
         x = 100;
         y = 100;
         this.textField = new TextField();
         this.textField.wordWrap = true;
         this.textField.defaultTextFormat = new TextFormat("Verdana",12,8999699);
         this.textField.width = 94;
         this.textField.height = 50;
         this.textField.x = -64;
         this.textField.y = -58;
         addChild(this.textField);
         if(param1)
         {
            this._t = param1;
         }
      }
      
      public function get text() : String
      {
         return this.textField.text;
      }
      
      override public function start() : void
      {
         if(this._timer == null)
         {
            this._timer = new Timer(100);
            this._timer.addEventListener(TimerEvent.TIMER,this.onTimer);
            this._timer.start();
            this._sTime = getTimer();
         }
      }
      
      public function set text(param1:String) : void
      {
         this.textField.htmlText = param1;
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         if(getTimer() - this._sTime > this._t)
         {
            this._timer.stop();
            this._timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this._timer = null;
            Float.close(this);
         }
      }
   }
}

