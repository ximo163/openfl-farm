package common.view.floating
{
   import com.qzone.qui.controls.Text;
   import com.qzone.qui.effects.Move;
   import com.qzone.qui.managers.EffectManager;
   import com.qzone.utils.AlignUtil;
   import common.Consts;
   import common.misc.Utils;
   import flash.display.DisplayObjectContainer;
   import flash.display.GradientType;
   import flash.display.Graphics;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.TimerEvent;
   import flash.filters.DropShadowFilter;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.utils.Timer;
   import interfaces.IMsgCenter;
   
   public class TextTipFloating extends FloatingBase
   {
      
      private var _text:Text;
      
      private var _timer:Timer;
      
      public var effect:*;
      
      private var _icon:Sprite;
      
      public function TextTipFloating(param1:IMsgCenter)
      {
         super(param1);
         mouseChildren = false;
         mouseEnabled = false;
         super.floatName = Consts.FLOAT_TYPE_TEXTTIP;
         this._icon = Utils.getMaterial("SuccessIcon") as Sprite;
         if(this._icon != null)
         {
            this._icon.scaleX = this._icon.scaleY = 0.33;
            this._icon.x = this._icon.y = 20;
            addChild(this._icon);
         }
         this._text = new Text(240);
         this._text.textDefaultFormat.color = 3355443;
         this._text.textDefaultFormat.size = 14;
         this._text.textDefaultFormat.leading = 5;
         if(this._icon != null)
         {
            this._text.x = this._icon.width + this._icon.x + 5;
            this._text.y = this._icon.y;
         }
         addChild(this._text);
         this._timer = null;
      }
      
      private function onAddedEffectEnd() : void
      {
         var _loc1_:DisplayObjectContainer = null;
         var _loc2_:Point = null;
         var _loc3_:Point = null;
         if(super._data != null)
         {
            _loc1_ = super._data["parent"] as DisplayObjectContainer;
            if(_loc1_ != null)
            {
               _loc2_ = new Point(AlignUtil.middle(_loc1_ as Stage == null ? _loc1_.width : (_loc1_ as Stage).stageWidth,this.width),AlignUtil.middle(_loc1_ as Stage == null ? _loc1_.height : (_loc1_ as Stage).stageHeight,this.height));
               _loc3_ = _loc1_.localToGlobal(_loc2_);
               this.x = _loc3_.x;
               this.y = _loc3_.y;
            }
         }
      }
      
      private function stopTimer() : void
      {
         if(this._timer != null)
         {
            this._timer.removeEventListener(TimerEvent.TIMER,this.onTimeout);
            this._timer.stop();
            this._timer = null;
         }
      }
      
      override public function start(param1:Object) : void
      {
         var _loc3_:String = null;
         super.start(param1);
         if(param1["icon"] != undefined && param1["icon"] != "")
         {
            if(this._icon != null)
            {
               removeChild(this._icon);
            }
            _loc3_ = param1["icon"];
            if(_loc3_ == "success")
            {
               this._icon = Utils.getMaterial("SuccessIcon") as Sprite;
            }
            else if(_loc3_ == "error")
            {
               this._icon = Utils.getMaterial("ErrorIcon") as Sprite;
            }
            else if(_loc3_ == "tip")
            {
               this._icon = Utils.getMaterial("TipIcon") as Sprite;
            }
            if(this._icon != null)
            {
               this._icon.scaleX = this._icon.scaleY = 0.33;
               this._icon.x = this._icon.y = 20;
               addChild(this._icon);
            }
         }
         if(param1["text"] != undefined && param1["text"] != "")
         {
            this._text.text = param1["text"];
            if(this._icon != null)
            {
               this._text.x = this._icon.width + this._icon.x + 5;
               this._text.y = this._icon.y;
            }
         }
         if(param1["effect"] != undefined)
         {
            this.effect = param1["effect"];
         }
         else
         {
            this.effect = Move;
         }
         this.drawBackground();
         var _loc2_:DisplayObjectContainer = param1["parent"] as DisplayObjectContainer;
         if(_loc2_ != null)
         {
            this.x = AlignUtil.middle(_loc2_ as Stage == null ? _loc2_.width : (_loc2_ as Stage).stageWidth,this.width);
            this.y = AlignUtil.middle(_loc2_ as Stage == null ? _loc2_.height : (_loc2_ as Stage).stageHeight,this.height);
            EffectManager.In(_loc2_,this,this.onAddedEffectEnd);
         }
         if(this._timer == null)
         {
            if(param1.hasOwnProperty("stoptime"))
            {
               this._timer = new Timer(param1["stoptime"],1);
            }
            else
            {
               this._timer = new Timer(2000,1);
            }
            this._timer.addEventListener(TimerEvent.TIMER,this.onTimeout);
            this._timer.start();
         }
      }
      
      private function drawBackground() : void
      {
         var _loc1_:Matrix = new Matrix();
         _loc1_.rotate(90);
         _loc1_.createGradientBox(200,200,Math.PI / 2,50,50);
         var _loc2_:Graphics = this.graphics;
         _loc2_.clear();
         _loc2_.beginGradientFill(GradientType.LINEAR,[16777215,0],[0.8,0.7],[0,255],_loc1_);
         _loc2_.lineStyle(1,13421772);
         _loc2_.drawRoundRect(0,0,width + 20 * 2,height + 20 * 2,20,20);
         _loc2_.endFill();
         this.filters = [new DropShadowFilter(5,45,0,0.6,5,5)];
      }
      
      private function onTimeout(param1:TimerEvent) : void
      {
         super.close();
      }
      
      override public function end() : void
      {
         super.end();
         this.stopTimer();
         this._icon = null;
         this._text = null;
      }
   }
}

