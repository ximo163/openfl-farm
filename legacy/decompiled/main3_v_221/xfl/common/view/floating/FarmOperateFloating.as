package common.view.floating
{
   import common.Consts;
   import common.misc.Utils;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.Timer;
   import interfaces.IMsgCenter;
   
   public class FarmOperateFloating extends FloatingBase
   {
      
      private var _timer:Timer;
      
      private var _textField:TextField;
      
      public function FarmOperateFloating(param1:IMsgCenter)
      {
         super(param1);
         super.floatName = Consts.FLOAT_TYPE_OPERATE;
         this._textField = null;
         this._timer = null;
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemoved,false,0,true);
      }
      
      private function initialize(param1:Boolean) : void
      {
         if(this.numChildren == 2)
         {
            return;
         }
         var _loc2_:Sprite = null;
         if(param1 == true)
         {
            _loc2_ = Utils.getMaterial("TalkBoxMy1") as Sprite;
         }
         else
         {
            _loc2_ = Utils.getMaterial("TalkBoxHe1") as Sprite;
         }
         addChild(_loc2_);
         this._textField = new TextField();
         this._textField.wordWrap = true;
         if(param1 == true)
         {
            this._textField.defaultTextFormat = new TextFormat("Verdana",12,3355443);
         }
         else
         {
            this._textField.defaultTextFormat = new TextFormat("Verdana",12,16777215);
         }
         this._textField.width = 90;
         this._textField.height = 46;
         this._textField.x = -58;
         this._textField.y = -58;
         addChild(this._textField);
      }
      
      public function set text(param1:String) : void
      {
         if(this._textField != null)
         {
            if(param1.length < 16)
            {
               this._textField.defaultTextFormat = new TextFormat("Verdana",12,3355443);
            }
            else
            {
               this._textField.defaultTextFormat = new TextFormat("Verdana",10,3355443);
            }
            this._textField.text = param1;
         }
      }
      
      override public function start(param1:Object) : void
      {
         super.start(param1);
         if(param1 == null)
         {
            return;
         }
         this.initialize(param1["me"]);
         this.text = param1["text"];
         this._textField.y = -56 + parseInt(param1["yAdjust"]);
         if(this._timer == null)
         {
            this._timer = new Timer(2500,1);
            this._timer.addEventListener(TimerEvent.TIMER,this.onTimer);
            this._timer.start();
         }
         else
         {
            this._timer.reset();
            this._timer.start();
         }
      }
      
      private function onRemoved(param1:Event) : void
      {
         if(this._timer != null)
         {
            this._timer.stop();
            this._timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this._timer = null;
         }
      }
      
      override public function end() : void
      {
         super.end();
         if(this._timer != null && this._timer.running == true)
         {
            this._timer.stop();
            this._timer.addEventListener(TimerEvent.TIMER,this.onTimer);
            this._timer = null;
         }
         this._textField = null;
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         if(this._timer != null)
         {
            this._timer.stop();
            this._timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this._timer = null;
         }
         super.close();
      }
   }
}

