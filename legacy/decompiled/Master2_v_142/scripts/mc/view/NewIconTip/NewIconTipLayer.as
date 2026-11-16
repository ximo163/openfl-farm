package mc.view.NewIconTip
{
   import common.MaterialLib;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import mc.view.ViewEvent;
   
   public class NewIconTipLayer extends Sprite
   {
      
      public static const NewActivityTip:Class = NewIconTipLayer_NewActivityTip;
      
      public static const OLD_ACTIVITY_TIP:String = "oldActivityTip";
      
      public static const NEW_ACTIVITY_TIP:String = "newActivityTip";
      
      private var tipDic:Dictionary;
      
      public function NewIconTipLayer()
      {
         super();
         NewIconTipModel.gi().addEventListener("NewIconTip",this.newIconTip);
      }
      
      public function newIconTip(param1:ViewEvent) : void
      {
         var _loc3_:MovieClip = null;
         var _loc2_:Object = param1.data;
         if(_loc2_["tipType"] == NEW_ACTIVITY_TIP)
         {
            _loc3_ = new NewActivityTip() as MovieClip;
         }
         else
         {
            _loc3_ = MaterialLib.getInstance().getMaterial("newIconTip") as MovieClip;
         }
         _loc3_.tipMc.tip.text = _loc2_["tipTxt"];
         if(_loc2_["newPoint"])
         {
            _loc3_.x = _loc2_["newPoint"].x;
            _loc3_.y = _loc2_["newPoint"].y;
            addChild(_loc3_);
         }
         this.registTip(_loc3_,_loc2_["tartget"]);
      }
      
      private function updatePosion(param1:MovieClip, param2:DisplayObject) : void
      {
         var _loc3_:Point = param2.localToGlobal(new Point(param2.width / 2,param2.height));
         param1.x = _loc3_.x;
         param1.y = _loc3_.y;
      }
      
      private function registTip(param1:MovieClip, param2:DisplayObject) : void
      {
         var _loc3_:Timer = null;
         if(!this.tipDic)
         {
            this.tipDic = new Dictionary();
         }
         if(param2)
         {
            _loc3_ = new Timer(1000,6);
            _loc3_.addEventListener(TimerEvent.TIMER,this.__tick);
         }
         else
         {
            _loc3_ = new Timer(5000,1);
         }
         _loc3_.addEventListener(TimerEvent.TIMER_COMPLETE,this.__removeTip);
         this.tipDic[_loc3_] = {
            "tip":param1,
            "target":param2
         };
         _loc3_.start();
      }
      
      private function __removeTip(param1:TimerEvent) : void
      {
         var _loc2_:Timer = param1.target as Timer;
         var _loc3_:MovieClip = this.tipDic[_loc2_].tip as MovieClip;
         _loc3_.gotoAndStop(1);
         removeChild(_loc3_);
         _loc2_.stop();
         _loc2_.removeEventListener(TimerEvent.TIMER,this.__tick);
         _loc2_.removeEventListener(TimerEvent.TIMER_COMPLETE,this.__removeTip);
         this.tipDic[_loc2_] = null;
         delete this.tipDic[_loc2_];
      }
      
      private function __tick(param1:TimerEvent) : void
      {
         var _loc2_:Timer = param1.target as Timer;
         if(this.tipDic[_loc2_].target)
         {
            this.updatePosion(this.tipDic[_loc2_].tip as MovieClip,this.tipDic[_loc2_].target as DisplayObject);
         }
         if(!(this.tipDic[_loc2_].tip as MovieClip).parent)
         {
            addChild(this.tipDic[_loc2_].tip);
         }
      }
   }
}

