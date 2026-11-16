package mc.view.main.tip
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import mc.control.ViewControl;
   import mc.events.TipEvent;
   
   public class TipLayer extends Sprite
   {
      
      private var tipInstance:Object;
      
      private var timer:Timer;
      
      private var tip:Tip;
      
      private var waitArg:Object;
      
      private var waitTime:int = 0;
      
      private var lastTip:String;
      
      private var waitTip:String = "";
      
      private var waitTX:int = 0;
      
      private var waitTY:int = 0;
      
      public function TipLayer()
      {
         super();
         this.tipInstance = new Object();
         addEventListener(Event.ADDED_TO_STAGE,this.addedToStage);
         mouseChildren = false;
         mouseEnabled = false;
      }
      
      private function timerHandler(param1:TimerEvent) : void
      {
         if(this.waitTip != "")
         {
            if(this.lastTip != this.waitTip)
            {
               this.tip = this.getTip(this.waitTip);
               this.lastTip = this.waitTip;
            }
            if(this.tip != null)
            {
               addChild(this.tip);
               this.tip.data = this.waitArg;
               this.tip.tX = this.waitTX;
               this.tip.tY = this.waitTY;
               this.tip.mX = mouseX;
               this.tip.mY = mouseY;
            }
         }
      }
      
      private function init() : void
      {
         ViewControl.getInstance().addEventListener(TipEvent.TIP_SHOW,this.tipShow,false,0,true);
         ViewControl.getInstance().addEventListener(TipEvent.TIP_HIDE,this.tipHide,false,0,true);
         stage.addEventListener(MouseEvent.MOUSE_MOVE,this.stageMove,false,0,true);
         this.timer = new Timer(300,1);
         this.timer.addEventListener(TimerEvent.TIMER,this.timerHandler);
      }
      
      private function addedToStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.addedToStage);
         this.init();
      }
      
      private function getTip(param1:String) : Tip
      {
         var _loc2_:Tip = null;
         if(param1 == "")
         {
            return null;
         }
         if(this.tipInstance == null || !this.tipInstance.hasOwnProperty(param1))
         {
            _loc2_ = new (TipClassLib.getClass(param1) as Class)() as Tip;
            this.tipInstance[param1] = _loc2_;
            addChild(_loc2_);
         }
         else
         {
            _loc2_ = this.tipInstance[param1];
         }
         return _loc2_;
      }
      
      private function stageMove(param1:MouseEvent) : void
      {
         if(this.tip != null)
         {
            this.tip.mX = param1.stageX;
            this.tip.mY = param1.stageY;
            param1.updateAfterEvent();
         }
      }
      
      private function tipShow(param1:TipEvent) : void
      {
         if(this.tip != null)
         {
         }
         this.waitTip = param1.tipType;
         this.waitArg = param1.tipArgument;
         this.waitTX = param1.tX;
         this.waitTY = param1.tY;
         this.waitTime = getTimer();
         this.timer.stop();
         this.timer.start();
      }
      
      private function tipHide(param1:TipEvent) : void
      {
         if(this.tip != null && contains(this.tip))
         {
            removeChild(this.tip);
         }
         this.timer.stop();
      }
   }
}

