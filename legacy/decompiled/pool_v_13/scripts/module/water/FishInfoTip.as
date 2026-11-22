package module.water
{
   import common.Consts;
   import common.Session;
   import common.misc.Utils;
   import entities.PoolFish;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class FishInfoTip extends Sprite
   {
      
      private var _container:DisplayObjectContainer;
      
      private var _timer:Timer;
      
      private var _leftTime:int;
      
      private var _mc:MovieClip;
      
      private var _fish:PoolFish;
      
      private var _tip:MovieClip;
      
      public function FishInfoTip(param1:DisplayObjectContainer)
      {
         super();
         this._tip = Utils.getMaterial("MCFishTip") as MovieClip;
         if(this._tip != null)
         {
            addChild(this._tip);
         }
         this._container = param1;
         this._mc = null;
         this._fish = null;
         this._leftTime = 0;
      }
      
      private function calcLeftTime() : String
      {
         if(this._fish == null)
         {
            return "";
         }
         var _loc1_:int = int(this._fish.level);
         var _loc2_:String = "";
         if(_loc1_ == 0)
         {
            _loc2_ = "鱼苗期(";
         }
         else if(_loc1_ == 1)
         {
            _loc2_ = "幼鱼期(";
         }
         else if(_loc1_ == 2)
         {
            _loc2_ = "成熟期(";
         }
         var _loc3_:Array = this._fish.leftTime;
         if(_loc3_ == null || _loc3_.length == 0)
         {
            return _loc2_ + ")";
         }
         var _loc4_:int = _loc3_[0] / 3600;
         var _loc5_:int = (_loc3_[0] - _loc4_ * 3600) / 60;
         var _loc6_:int = _loc3_[0] % 60;
         if(_loc4_ > 0)
         {
            _loc2_ += _loc4_ + "小时";
         }
         if(_loc5_ > 0)
         {
            _loc2_ += _loc5_ + "分钟";
         }
         if(_loc4_ == 0 && _loc6_ >= 0)
         {
            _loc2_ += _loc6_ + "秒";
         }
         if(_loc1_ == 0)
         {
            _loc2_ += "至幼鱼期)";
         }
         else if(_loc1_ == 1)
         {
            _loc2_ += "至成熟期)";
         }
         else if(_loc1_ == 2)
         {
            _loc2_ += "至收获期)";
         }
         var _loc7_:Number = 120 * (1 - _loc3_[0] / _loc3_[1]);
         if(_loc7_ > 120)
         {
            _loc7_ = 120;
         }
         if(_loc7_ < 0)
         {
            _loc7_ = 0;
         }
         this._tip["growBar"].width = _loc7_;
         return _loc2_;
      }
      
      private function removeFish() : void
      {
         if(this._mc != null)
         {
            if(this._tip != null && this._tip.contains(this._mc))
            {
               this._tip.removeChild(this._mc);
            }
            FishAnimationMgr.getInstance().destroyMC(this._mc);
            this._mc = null;
         }
      }
      
      public function hide() : void
      {
         if(this._timer != null)
         {
            this._timer.stop();
         }
         this.removeFish();
         this._fish = null;
         if(parent != null)
         {
            parent.removeChild(this);
         }
      }
      
      public function update() : void
      {
         if(this._fish == null)
         {
            return;
         }
         this.calcOutput();
      }
      
      private function formatFishName(param1:String, param2:int, param3:int, param4:int) : String
      {
         var _loc5_:String = "S";
         if(param1 == "IDLE" || param1 == "SWIM" || param1 == "ADJUST")
         {
            _loc5_ = "S";
         }
         if(param1 == "JUMP")
         {
            _loc5_ = "J";
         }
         if(param3 >= Consts.FISH_MAX_LEVEL)
         {
            param3 = Consts.FISH_MAX_LEVEL - 1;
         }
         return "F" + _loc5_ + "_" + Utils.formatNumber(param2,2) + "_" + param3 + "_" + param4;
      }
      
      private function calcOutput() : String
      {
         if(this._fish == null)
         {
            return "";
         }
         if(this._fish._output == 0)
         {
            return "收获期(...)";
         }
         var _loc1_:String = "收获期(产";
         return _loc1_ + (this._fish._output + " 剩" + this._fish._left + ")");
      }
      
      public function show(param1:PoolFish) : void
      {
         if(this._fish != null && this._fish._id == param1._id)
         {
            return;
         }
         this._fish = param1;
         if(param1 == null)
         {
            this.hide();
            return;
         }
         var _loc2_:String = param1.name;
         var _loc3_:int = int(param1.level);
         var _loc4_:String = this.formatFishName("SWIM",param1._type,_loc3_,2);
         var _loc5_:MovieClip = FishAnimationMgr.getInstance().createFishMC(_loc4_);
         if(_loc5_ == null)
         {
            return;
         }
         this.removeFish();
         _loc5_.gotoAndStop(1);
         _loc5_.scaleX = _loc5_.scaleY = 32 / _loc5_.width;
         _loc5_.x = 0;
         _loc5_.y = (12 - _loc5_.height) * 0.5;
         this._tip.addChild(_loc5_);
         this._mc = _loc5_;
         this._tip["stepText"].text = _loc2_;
         var _loc6_:Array = param1._thief;
         var _loc7_:uint = parseFloat(Session.getInstance().hostId) as uint;
         if(_loc6_ != null && _loc6_.indexOf(_loc7_) != -1)
         {
            this._tip["stepText"].text += "(已捞取)";
         }
         if(_loc3_ == Consts.FISH_MAX_LEVEL)
         {
            this._tip["growText"].text = this.calcOutput();
            this._tip["growBar"].width = 120;
         }
         else
         {
            this._tip["growText"].text = this.calcLeftTime();
            if(this._timer == null)
            {
               this._timer = new Timer(1000);
               this._timer.addEventListener(TimerEvent.TIMER,this.onTimer,false,0,true);
            }
            this._timer.start();
         }
         if(this._container != null)
         {
            this._container.addChild(this);
         }
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         if(this._fish == null || this._tip == null)
         {
            return;
         }
         var _loc2_:int = int(this._fish.level);
         if(_loc2_ == Consts.FISH_MAX_LEVEL)
         {
            this._tip["growText"].text = this.calcOutput();
            this._tip["growBar"].width = 120;
            if(this._timer != null)
            {
               this._timer.stop();
            }
         }
         else
         {
            this._tip["growText"].text = this.calcLeftTime();
         }
      }
   }
}

