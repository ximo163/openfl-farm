package framework.layers
{
   import common.Consts;
   import common.view.tip.TipControl;
   import events.TipEvent;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import framework.base.BaseLayer;
   import interfaces.ITip;
   
   public class TipLayer extends BaseLayer
   {
      
      private var m_libs:Object;
      
      private var m_tip:ITip;
      
      private var m_waitTX:int;
      
      private var m_waitTY:int;
      
      private var m_waitArg:Object;
      
      private var m_timer:Timer;
      
      private var m_waitTip:String;
      
      private var m_ctrl:TipControl;
      
      public function TipLayer(param1:TipControl)
      {
         if(param1 != null)
         {
            super(param1.getMsgCenter());
            this.m_ctrl = param1;
            this.m_libs = new Object();
            this.m_waitArg = null;
            this.m_waitTX = this.m_waitTY = 0;
            this.m_waitTip = "";
            this.m_timer = null;
            this.m_tip = null;
            mouseEnabled = false;
            mouseChildren = false;
            name = Consts.LAYER_TIP;
            return;
         }
         throw new ArgumentError("Null parameter");
      }
      
      private function remove() : void
      {
         if(this.m_tip != null && this.contains(this.m_tip.displayObject) == true)
         {
            removeChild(this.m_tip.displayObject);
            this.m_tip = null;
         }
      }
      
      private function getTip(param1:String) : ITip
      {
         var _loc3_:Class = null;
         if(param1 == "")
         {
            return null;
         }
         if(this.m_ctrl == null)
         {
            return null;
         }
         var _loc2_:ITip = null;
         if(this.m_libs == null || this.m_libs.hasOwnProperty(param1) == false)
         {
            _loc3_ = this.m_ctrl.getClass(param1) as Class;
            if(_loc3_ == null)
            {
               return null;
            }
            _loc2_ = new _loc3_() as ITip;
            if(_loc2_.displayObject != null)
            {
               this.m_libs[param1] = _loc2_;
               addChild(_loc2_.displayObject);
            }
            else
            {
               _loc2_ = null;
            }
         }
         else
         {
            _loc2_ = this.m_libs[param1];
         }
         return _loc2_;
      }
      
      private function onTipHide(param1:TipEvent) : void
      {
         this.remove();
         if(this.m_timer != null)
         {
            this.m_timer.stop();
         }
      }
      
      override protected function init() : void
      {
         super.init();
         m_msgCenter.addEventListener(TipEvent.TIP_SHOW,this.onTipShow,false,0,true);
         m_msgCenter.addEventListener(TipEvent.TIP_HIDE,this.onTipHide,false,0,true);
         m_msgCenter.addEventListener(TipEvent.TIP_UPDATE,this.onTipUpdate,false,0,true);
         stage.addEventListener(MouseEvent.MOUSE_MOVE,this.stageMove,false,0,true);
         this.m_timer = new Timer(300,1);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer,false,0,true);
      }
      
      private function stageMove(param1:MouseEvent) : void
      {
         if(this.m_tip != null)
         {
            this.m_tip.mX = param1.stageX;
            this.m_tip.mY = param1.stageY;
         }
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         if(this.m_waitTip == "")
         {
            return;
         }
         if(this.m_tip == null || this.m_tip.tipName != this.m_waitTip)
         {
            this.m_tip = this.getTip(this.m_waitTip);
            this.m_waitTip = "";
            if(this.m_tip != null)
            {
               this.addChild(this.m_tip.displayObject);
               this.m_tip.data = this.m_waitArg;
               this.m_tip.tX = this.m_waitTX;
               this.m_tip.tY = this.m_waitTY;
               this.m_tip.mX = mouseX;
               this.m_tip.mY = mouseY;
            }
         }
      }
      
      private function onTipShow(param1:TipEvent) : void
      {
         this.remove();
         this.m_waitTip = param1.tipType;
         this.m_waitArg = param1.tipArgument;
         this.m_waitTX = param1.tX;
         this.m_waitTY = param1.tY;
         if(this.m_timer != null)
         {
            this.m_timer.reset();
            this.m_timer.start();
         }
      }
      
      private function onTipUpdate(param1:TipEvent) : void
      {
         if(this.m_tip == null)
         {
            return;
         }
         if(this.m_tip.tipName != param1.tipType)
         {
            return;
         }
         this.m_tip.data = param1.tipArgument;
      }
   }
}

