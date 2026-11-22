package module.water
{
   import common.Consts;
   import common.misc.Utils;
   import entities.PoolFish;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import flash.system.ApplicationDomain;
   
   public class FishMover
   {
      
      private var _cdt:int;
      
      private const FAST_SPEED:Number = 1.2;
      
      private var _nextThinkingTime:int;
      
      private var _status:int;
      
      private var _state:String;
      
      private const FAST_DURATION:uint = 2;
      
      private const IDLE_DURATION:uint = 8;
      
      private var _frameDuration:int;
      
      private var _step:int;
      
      private const BRAKE_ACC:Number = 0.03;
      
      private var _mc:MovieClip;
      
      private var _fish:PoolFish;
      
      private var _spawnPos:Point;
      
      private var _velocity:Point;
      
      private var _acc:Point;
      
      private const NORMAL_SPEED:Number = 0.75;
      
      private var _waterPool:WaterPool;
      
      private const JUMP_SPEED:Number = 0;
      
      private const FAST:uint = 1;
      
      private var _dir:int;
      
      private const NORMAL:uint = 2;
      
      private const NORMAL_DURATION:uint = 4;
      
      private const MAX_SPEED:Number = 1.4;
      
      private var _corner:int;
      
      private const ADJUST_SPEED:Number = 0.4;
      
      private var _checkLoading:Boolean;
      
      private var _wps:Array;
      
      private const MAX_STEP:uint = 110;
      
      public function FishMover(param1:WaterPool, param2:PoolFish)
      {
         super();
         this._waterPool = param1;
         this._fish = param2;
         this._state = "SWIM";
         this._dir = -1;
         this._status = this.NORMAL;
         this._frameDuration = this.NORMAL_DURATION;
         this._step = 0;
         this._nextThinkingTime = 0;
         this._cdt = 0;
         this._corner = 0;
         this._mc = null;
         this._wps = null;
         this._spawnPos = null;
         this._checkLoading = true;
         this._velocity = new Point();
         this._acc = new Point();
      }
      
      public function stop() : void
      {
         this._state = "IDLE";
         this._velocity.x = this._velocity.y = 0;
         this._acc.x = this._acc.y = 0;
         this._frameDuration = this.IDLE_DURATION;
         this._status = this.NORMAL;
         this._step = 0;
         this._nextThinkingTime = 99999999;
         if(this._mc != null)
         {
            Utils.stroke(this._mc);
         }
      }
      
      private function adjustPosition() : void
      {
         if(this._mc == null)
         {
            return;
         }
         var _loc1_:Point = this._waterPool.calcCenterVector(this._mc);
         var _loc2_:int = 3 * _loc1_.x;
         var _loc3_:int = 3 * _loc1_.y;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Point = new Point(this._mc.width * 0.5,this._mc.height * 0.5);
         _loc6_ = this._mc.localToGlobal(_loc6_);
         var _loc7_:* = 20;
         while(_loc7_ > 0)
         {
            _loc6_.x += _loc2_;
            _loc6_.y += _loc3_;
            _loc4_ += _loc2_;
            _loc5_ += _loc3_;
            if(this._waterPool.cdWithPoolLimit(_loc6_) == true)
            {
               this._mc.x += _loc4_;
               this._mc.y += _loc5_;
               break;
            }
            _loc7_--;
         }
      }
      
      public function get x() : Number
      {
         if(this._mc == null)
         {
            return 0;
         }
         return this._mc.x;
      }
      
      public function localToGlobal(param1:Point) : Point
      {
         if(this._mc == null || param1 == null)
         {
            return param1;
         }
         return this._mc.localToGlobal(param1);
      }
      
      private function spawn(param1:Boolean) : MovieClip
      {
         var _loc5_:DisplayObject = null;
         var _loc6_:uint = 0;
         var _loc7_:Number = NaN;
         var _loc2_:Boolean = false;
         if(this._dir == 1 || this._dir == 3)
         {
            _loc2_ = true;
            this._dir = (this._dir + 1) % 4;
         }
         var _loc3_:String = this.formatFishName(this._state,this._fish._type,this._fish.level,this._dir);
         var _loc4_:MovieClip = FishAnimationMgr.getInstance().createFishMC(_loc3_);
         if(_loc4_ == null)
         {
            return null;
         }
         if(_loc2_ == true)
         {
            _loc4_.scaleX = -1;
         }
         if(param1 == true)
         {
            if(this._spawnPos != null)
            {
               _loc4_.x = this._spawnPos.x;
               _loc4_.y = this._spawnPos.y;
               this._spawnPos = null;
            }
            else
            {
               _loc5_ = this._waterPool.randSpawnCircle();
               if(_loc5_ != null)
               {
                  _loc6_ = _loc5_.width * 0.5;
                  _loc7_ = Math.random() * 360 * Math.PI / 180;
                  _loc4_.x = _loc5_.x + _loc6_ + Math.sin(_loc7_) * _loc6_ - _loc4_.scaleX * _loc4_.width * 0.5;
                  _loc4_.y = _loc5_.y + _loc6_ + Math.cos(_loc7_) * _loc6_ - _loc4_.height * 0.5;
               }
            }
         }
         _loc4_.gotoAndStop(1);
         _loc4_.cacheAsBitmap = true;
         return _loc4_;
      }
      
      public function get loaded() : Boolean
      {
         return this._mc != null;
      }
      
      public function get hFlip() : Boolean
      {
         if(this._mc == null)
         {
            return false;
         }
         return this._mc.scaleX < 0 ? true : false;
      }
      
      private function get fishContainer() : DisplayObjectContainer
      {
         return this._waterPool.fishContainer;
      }
      
      public function grow() : void
      {
         this.changeFish();
         this.playFeedEffect();
      }
      
      private function next() : void
      {
         ++this._step;
         if(this._step >= this._nextThinkingTime)
         {
            this.think();
         }
      }
      
      public function continueMove() : void
      {
         if(this._mc != null)
         {
            Utils.unStroke(this._mc);
         }
         this.think();
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
         if(param3 > 2)
         {
            param3 = 2;
         }
         return "F" + _loc5_ + "_" + Utils.formatNumber(param2,2) + "_" + param3 + "_" + param4;
      }
      
      public function moveFrame() : void
      {
         if(this._mc == null && this._checkLoading == true)
         {
            this.next();
            return;
         }
         --this._frameDuration;
         if(this._frameDuration < 0)
         {
            this._frameDuration = this._status == this.FAST ? int(this.FAST_DURATION) : int(this.NORMAL_DURATION);
            if(this._state == "IDLE" || this._state == "ADJUST")
            {
               this.playFishAnimation(false,true);
               this._frameDuration = this.IDLE_DURATION;
            }
            else if(this._state == "SWIM" || this._state == "CENTER")
            {
               this.checkCD();
               this.playFishAnimation(this._status == this.FAST,true);
            }
            else if(this._state == "JUMP")
            {
               this.playFishAnimation(true,false);
            }
         }
         if(this._state == "SWIM")
         {
            this.move(this._velocity,null);
         }
         else if(this._state == "ADJUST")
         {
            this.move(this._velocity,null);
         }
         else if(this._state == "CENTER")
         {
            this.move(this._velocity,null);
         }
         else if(this._state == "IDLE")
         {
            this.move(this._velocity,this._acc,true);
         }
         else if(this._state == "JUMP")
         {
         }
         this.next();
      }
      
      private function slowdown() : void
      {
         var _loc1_:Point = this._waterPool.calcNormalizedVelocity((this._dir + 2) % 4);
         this._acc.x = _loc1_.x * this.BRAKE_ACC;
         this._acc.y = _loc1_.y * this.BRAKE_ACC;
         trace("Slow down at acc : " + this._acc.toString());
      }
      
      private function changeFish() : void
      {
         var _loc1_:MovieClip = this.spawn(this._mc == null);
         if(_loc1_ != null)
         {
            if(this._mc != null)
            {
               _loc1_.x = this._mc.x;
               _loc1_.y = this._mc.y;
               _loc1_.x -= (_loc1_.scaleX * _loc1_.width - this._mc.scaleX * this._mc.width) * 0.5;
               _loc1_.y -= (_loc1_.scaleY * _loc1_.height - this._mc.scaleY * this._mc.height) * 0.5;
               this.removeFish();
            }
            else
            {
               this._mc = _loc1_;
               this.playWaterEffect(-1);
            }
            this._mc = _loc1_;
            this.fishContainer.addChild(this._mc);
         }
      }
      
      public function set fish(param1:PoolFish) : void
      {
         var _loc2_:DisplayObject = null;
         if(this._mc != null)
         {
            _loc2_ = this._mc.getChildByName("__MATURE__");
            if(_loc2_ != null)
            {
               this._mc.removeChild(_loc2_);
            }
         }
         this.removeFish();
         this._fish = param1;
      }
      
      private function playFeedEffect() : void
      {
         if(this._mc == null || this._mc.parent == null)
         {
            return;
         }
         var _loc1_:MovieClip = Utils.getMaterial("FishFoodEffect") as MovieClip;
         if(_loc1_ == null)
         {
            return;
         }
         var _loc2_:Point = new Point(this._mc.x,this._mc.y);
         _loc2_.x += this._mc.width * 0.5 * this._mc.scaleX;
         _loc2_.y += this._mc.height * 0.5 * this._mc.scaleY;
         _loc1_.x = _loc2_.x;
         _loc1_.y = _loc2_.y;
         _loc1_.scaleX = _loc1_.scaleY = 0.5;
         this._mc.parent.addChild(_loc1_);
         _loc1_.gotoAndPlay(1);
      }
      
      private function playWaterEffect(param1:int) : void
      {
         var _loc2_:Point = null;
         if(this._mc == null)
         {
            return;
         }
         if(this._state == "SWIM" && param1 == this.NORMAL && this._status == this.FAST)
         {
            _loc2_ = new Point(this._mc.x,this._mc.y);
            _loc2_.x += this._mc.width * 0.5 * this._mc.scaleX;
            _loc2_.y += this._mc.height * 0.5 * this._mc.scaleY;
            this._waterPool.showWaterFlower(_loc2_,this._dir);
         }
      }
      
      private function checkResource() : Boolean
      {
         if(this._mc != null)
         {
            return true;
         }
         if(this._fish == null)
         {
            return false;
         }
         var _loc1_:String = this.formatFishName("SWIM",this._fish._type,this._fish.level,0);
         return ApplicationDomain.currentDomain.hasDefinition(_loc1_);
      }
      
      public function set spawnPos(param1:Point) : void
      {
         this._spawnPos = param1;
      }
      
      private function equalZeroSpeed(param1:Point) : Boolean
      {
         if(param1 == null)
         {
            return true;
         }
         if(param1.x * param1.x + param1.y * param1.y <= 0.05)
         {
            return true;
         }
         return false;
      }
      
      private function towardCenter() : Boolean
      {
         if(this._mc == null)
         {
            return false;
         }
         var _loc1_:int = this._waterPool.atCorner(this._mc.x,this._mc.y);
         if(_loc1_ != -1)
         {
            ++this._corner;
            if(this._corner >= 3)
            {
               this._corner = 0;
               this._state = "CENTER";
               this._frameDuration = this.IDLE_DURATION;
               this._wps = new Array(1);
               if(_loc1_ == 0 || _loc1_ == 3)
               {
                  this._dir = 1;
                  this._wps[0] = _loc1_ == 0 ? 2 : 0;
               }
               else
               {
                  this._dir = 3;
                  this._wps[0] = _loc1_ == 1 ? 2 : 0;
               }
               this.updateVelocity();
               this.changeFish();
               trace("towards center at dir : " + this._dir);
               return true;
            }
         }
         else
         {
            this._corner = 0;
            this._wps = null;
         }
         return false;
      }
      
      private function changeDir(param1:int) : void
      {
         if(this._dir == -1)
         {
            this._dir = this.randomDir();
         }
         else
         {
            if(param1 == -1)
            {
               param1 = this.randomDir();
            }
            this._dir += param1;
            this._dir %= 4;
         }
         this.updateVelocity();
      }
      
      private function canJump(param1:int) : Boolean
      {
         if(this._mc == null || this._fish.level < Consts.FISH_MAX_LEVEL - 1)
         {
            return false;
         }
         return true;
      }
      
      public function hitTest(param1:Number, param2:Number) : Boolean
      {
         if(this._mc != null)
         {
            if(this._mc.hitTestPoint(param1,param2,false) == true)
            {
               return true;
            }
         }
         return false;
      }
      
      private function updateVelocity() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:int = 0;
         var _loc3_:Point = null;
         if(this._state != "IDLE")
         {
            if(this._dir == 1 || this._dir == 3)
            {
               this._status = this.NORMAL;
               this._frameDuration = this.NORMAL_DURATION;
            }
            _loc1_ = this._status == this.FAST ? this.FAST_SPEED : this.NORMAL_SPEED;
            if(this._state == "JUMP")
            {
               _loc1_ = this.JUMP_SPEED;
            }
            _loc2_ = int(this._fish.poolSize);
            if(this._fish.poolSize == 2)
            {
               _loc1_ *= 0.95;
            }
            else if(this._fish.poolSize == 3)
            {
               _loc1_ *= 0.9;
            }
            else if(this._fish.poolSize > 3)
            {
               _loc1_ *= 0.85;
            }
            _loc3_ = this._waterPool.calcNormalizedVelocity(this._dir);
            this._velocity.x = _loc3_.x * _loc1_;
            this._velocity.y = _loc3_.y * _loc1_;
         }
      }
      
      private function playFishAnimation(param1:Boolean, param2:Boolean) : void
      {
         if(this._mc == null)
         {
            return;
         }
         var _loc3_:int = this._mc.currentFrame;
         if(param1 == false)
         {
            if(_loc3_ == 1)
            {
               this._mc.gotoAndStop(2);
            }
            else if(_loc3_ == 2)
            {
               this._mc.gotoAndStop(5);
            }
            else if(_loc3_ == 5)
            {
               this._mc.gotoAndStop(6);
            }
            else
            {
               this._mc.gotoAndStop(1);
            }
         }
         else if(_loc3_ + 1 <= this._mc.totalFrames)
         {
            this._mc.gotoAndStop(_loc3_ + 1);
         }
         else if(param2)
         {
            this._mc.gotoAndStop(1);
         }
         else
         {
            this._mc.stop();
         }
      }
      
      private function adjustState() : void
      {
         if(this._mc == null)
         {
            return;
         }
         this._cdt = 0;
         this._state = "ADJUST";
         this._status = this.NORMAL;
         this._frameDuration = this.IDLE_DURATION;
         this._step = 0;
         this._nextThinkingTime = (Math.random() + 0.5) * this.MAX_STEP * 0.5;
         var _loc1_:Point = this._waterPool.calcCenterVector(this._mc);
         if(_loc1_.x < 0 && _loc1_.y > 0)
         {
            this._dir = 2;
         }
         else if(_loc1_.x <= 0 && _loc1_.y <= 0)
         {
            this._dir = 3;
         }
         else if(_loc1_.x >= 0 && _loc1_.y <= 0)
         {
            this._dir = 0;
         }
         else if(_loc1_.x >= 0 && _loc1_.y >= 0)
         {
            this._dir = 1;
         }
         this._velocity.x = _loc1_.x * this.ADJUST_SPEED;
         this._velocity.y = _loc1_.y * this.ADJUST_SPEED;
         this.changeFish();
      }
      
      private function randomDir() : int
      {
         if(Math.random() < 0.6)
         {
            return Math.random() < 0.5 ? 0 : 2;
         }
         return Math.random() < 0.5 ? 1 : 3;
      }
      
      public function get fish() : PoolFish
      {
         return this._fish;
      }
      
      private function move(param1:Point, param2:Point = null, param3:Boolean = true) : void
      {
         if(this._mc == null || param1 == null)
         {
            return;
         }
         if(param2 != null && param3 == false)
         {
            throw new ArgumentError("Can NOT support speed up!");
         }
         if(param2 == null)
         {
            this._mc.x += param1.x;
            this._mc.y += param1.y;
         }
         else if(param2.x != 0 && param2.y != 0)
         {
            param1.x += param2.x;
            param1.y += param2.y;
            trace("Accellerated velocity : " + param1.x + " , " + param1.y);
            if(Math.sqrt(param1.x * param1.x + param1.x * param1.x) >= this.MAX_SPEED)
            {
               param1.x -= param2.x;
               param1.y -= param2.y;
               param2.x = 0;
               param2.y = 0;
            }
            else if(this.equalZeroSpeed(param1) == false)
            {
               this._mc.x += param1.x;
               this._mc.y += param1.y;
            }
            else
            {
               param2.x = 0;
               param2.y = 0;
            }
         }
      }
      
      private function checkCD() : void
      {
         if(this._mc == null)
         {
            return;
         }
         var _loc1_:Point = new Point(this._mc.width * 0.5,this._mc.height * 0.5);
         _loc1_ = this._mc.localToGlobal(_loc1_);
         _loc1_.x += this._velocity.x;
         _loc1_.y += this._velocity.y;
         if(this._waterPool.cdWithPoolLimit(_loc1_) == false)
         {
            ++this._cdt;
            if(this._cdt >= 3)
            {
               this.adjustState();
            }
            else
            {
               if(Math.random() < 0.5)
               {
                  this.changeDir(2);
               }
               else
               {
                  this.changeDir(-1);
               }
               this.changeFish();
               this.adjustPosition();
            }
         }
         else if(this._cdt > 0)
         {
            --this._cdt;
         }
      }
      
      public function think() : void
      {
         if(this._fish == null)
         {
            return;
         }
         if(this.checkResource() == false)
         {
            this._step = 0;
            this._nextThinkingTime = 4;
            this._checkLoading = true;
            return;
         }
         this._checkLoading = false;
         var _loc1_:String = this._state;
         var _loc2_:int = this._status;
         if(_loc1_ == "CENTER")
         {
            if(this._wps != null && this._wps.length > 0)
            {
               this._dir = this._wps.pop();
               this._frameDuration = this.IDLE_DURATION;
               this._status = this.NORMAL;
               this._nextThinkingTime = (Math.random() + 3) * this.MAX_STEP;
               this.updateVelocity();
               this.changeFish();
               return;
            }
            this._corner = 0;
            this._wps = null;
         }
         var _loc3_:Number = Math.random();
         if(_loc3_ < 0.7)
         {
            this._state = "SWIM";
         }
         else if(_loc3_ < 0.85)
         {
            this._state = "IDLE";
         }
         else
         {
            this._state = "JUMP";
         }
         if(this._state == "JUMP" && this._fish.level < Consts.FISH_MAX_LEVEL - 1)
         {
            this._state = "SWIM";
         }
         this._cdt = 0;
         this._dir = 2;
         _loc3_ = Math.random();
         this._status = _loc3_ < 0.5 ? int(this.FAST) : int(this.NORMAL);
         this._velocity.x = this._velocity.y = 0;
         this._acc.x = this._acc.y = 0;
         this._frameDuration = this._status == this.FAST ? int(this.FAST_DURATION) : int(this.NORMAL_DURATION);
         this._step = 0;
         this._nextThinkingTime = (Math.random() + 0.5) * this.MAX_STEP;
         if(this._state == "IDLE")
         {
            this._frameDuration = this.IDLE_DURATION;
            this._status = this.NORMAL;
            _loc3_ = Math.random();
            if(_loc3_ < 0.5)
            {
               this._dir = this.randomDir();
            }
            this.changeFish();
            if(_loc1_ == "SWIM")
            {
               this.slowdown();
            }
         }
         else
         {
            if(this.towardCenter() == true)
            {
               return;
            }
            if(this._state == "JUMP")
            {
               this._dir = 2;
            }
            else
            {
               _loc3_ = Math.random();
               if(_loc3_ < 0.5)
               {
                  this.changeDir(-1);
               }
            }
            this.changeFish();
            if(this._mc != null && this.canJump(this._dir) == false)
            {
               this._state = "SWIM";
            }
            if(this._state == "JUMP")
            {
               this._status = this.NORMAL;
               this._frameDuration = this.NORMAL_DURATION;
               this._nextThinkingTime = this._frameDuration * this._mc.totalFrames + 1;
            }
            this.playWaterEffect(_loc2_);
         }
      }
      
      public function get y() : Number
      {
         if(this._mc == null)
         {
            return 0;
         }
         return this._mc.y;
      }
      
      private function removeFish() : void
      {
         if(this._mc == null)
         {
            return;
         }
         if(this.fishContainer.contains(this._mc) == true)
         {
            Utils.unStroke(this._mc);
            FishAnimationMgr.getInstance().destroyMC(this._mc);
         }
         this._mc = null;
      }
   }
}

