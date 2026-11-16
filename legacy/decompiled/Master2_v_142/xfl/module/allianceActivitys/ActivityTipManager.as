package module.allianceActivitys
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import mc.view.NewIconTip.NewIconTipLayer;
   import mc.view.WindowsManager;
   import mc.view.main.tip.TipControl;
   
   public class ActivityTipManager
   {
      
      private static var _mouseTip:Dictionary = new Dictionary();
      
      public function ActivityTipManager()
      {
         super();
      }
      
      public static function removeMouseTip(param1:DisplayObject) : void
      {
         param1.removeEventListener(MouseEvent.ROLL_OVER,mouseTipHandler);
         param1.removeEventListener(MouseEvent.ROLL_OUT,mouseTipHandler);
      }
      
      public static function showMouseTip(param1:DisplayObject, param2:String) : void
      {
         param1.addEventListener(MouseEvent.ROLL_OVER,mouseTipHandler);
         param1.addEventListener(MouseEvent.ROLL_OUT,mouseTipHandler);
         _mouseTip[param1] = param2;
      }
      
      private static function mouseTipHandler(param1:MouseEvent) : void
      {
         if(param1.type == MouseEvent.ROLL_OVER)
         {
            TipControl.show("MouseTip",_mouseTip[param1.currentTarget]);
         }
         else
         {
            TipControl.hide();
         }
      }
      
      public static function showBubble(param1:DisplayObject, param2:String, param3:int = 6, param4:Number = 0, param5:Number = 0) : void
      {
         var timer:Timer;
         var iconTip:MovieClip = null;
         var __tick:Function = null;
         var __dispose:Function = null;
         var target:DisplayObject = param1;
         var msn:String = param2;
         var showTime:int = param3;
         var offsetX:Number = param4;
         var offsetY:Number = param5;
         __tick = function(param1:TimerEvent):void
         {
            var _loc2_:Point = null;
            _loc2_ = WindowsManager.gi().leftPane.localToGlobal(new Point(target.x + offsetX,target.y + offsetY));
            iconTip.x = _loc2_.x;
            iconTip.y = _loc2_.y;
            iconTip.visible = true;
         };
         __dispose = function(param1:TimerEvent):void
         {
            var _loc2_:Timer = param1.target as Timer;
            _loc2_.removeEventListener(TimerEvent.TIMER,__tick);
            _loc2_.removeEventListener(TimerEvent.TIMER_COMPLETE,__dispose);
            _loc2_.stop();
            if(Boolean(iconTip) && Boolean(iconTip.parent))
            {
               iconTip.gotoAndStop(1);
               iconTip.parent.removeChild(iconTip);
               iconTip = null;
            }
         };
         iconTip = new NewIconTipLayer.NewActivityTip() as MovieClip;
         iconTip.gotoAndPlay(1);
         iconTip.tipMc.tip.text = msn;
         iconTip.visible = false;
         WindowsManager.gi().leftPane.stage.addChild(iconTip);
         timer = new Timer(1000,showTime);
         timer.addEventListener(TimerEvent.TIMER,__tick);
         timer.addEventListener(TimerEvent.TIMER_COMPLETE,__dispose);
         timer.start();
      }
   }
}

