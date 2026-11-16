package entities
{
   import common.CommonData;
   import common.Consts;
   import common.GetCropID;
   import common.Settings;
   import common.misc.Utils;
   
   public final class PoolFish
   {
      
      private var _st:Object;
      
      public var _thief:Array;
      
      public var _plantTime:int;
      
      public var _output:int;
      
      public var _left:int;
      
      public var _type:int;
      
      public var _nextStepTime:Number;
      
      private var _cycles:Array;
      
      public var _fertilize:Boolean;
      
      public var _id:int;
      
      public function PoolFish(param1:Object)
      {
         super();
         this._fertilize = true;
         this.importObject(param1);
         this._nextStepTime = 0;
         this._st = null;
         this._cycles = null;
      }
      
      public function calcNextStepTime() : void
      {
         var _loc1_:int = this.level;
         if(_loc1_ < 0)
         {
            return;
         }
         if(_loc1_ == 3)
         {
            this._nextStepTime = Number.POSITIVE_INFINITY;
            return;
         }
         var _loc2_:Array = this.cycles;
         if(_loc2_ == null || _loc2_.length == 0)
         {
            return;
         }
         this._nextStepTime = this._plantTime + _loc2_[_loc1_];
      }
      
      public function importObject(param1:Object) : void
      {
         var _loc3_:int = 0;
         if(param1 == null)
         {
            return;
         }
         this._id = Utils.getIntAttribute(param1,"i");
         this._type = Utils.getIntAttribute(param1,"fid");
         this._left = Utils.getIntAttribute(param1,"l");
         this._output = Utils.getIntAttribute(param1,"o");
         this._plantTime = Utils.getIntAttribute(param1,"p");
         this._thief = param1["s"] as Array;
         if(this._thief == null)
         {
            this._thief = new Array();
         }
         this.calcNextStepTime();
         var _loc2_:int = int(Utils.getIntAttribute(param1,"f"));
         if(_loc2_ == 1 || _loc2_ == 2 || _loc2_ == 3)
         {
            _loc3_ = this.level;
            this._fertilize = _loc2_ == _loc3_ + 1 ? true : false;
            if(_loc3_ == Consts.FISH_MAX_LEVEL)
            {
               this._fertilize = false;
            }
         }
         else
         {
            this._fertilize = false;
         }
      }
      
      public function get canHarvest() : Boolean
      {
         return this.level >= Consts.FISH_MAX_LEVEL;
      }
      
      public function get level() : int
      {
         if(this._st == null)
         {
            this._st = Settings.getInstance().getFishByID(this._type.toString());
         }
         if(this._st == null)
         {
            return -1;
         }
         var _loc1_:Array = this.cycles;
         if(_loc1_ == null || _loc1_.length == 0)
         {
            return -1;
         }
         var _loc2_:Number = Number(CommonData.serverTime);
         var _loc3_:Number = _loc2_ - this._plantTime;
         if(_loc3_ < 0)
         {
            return -1;
         }
         var _loc4_:int = 0;
         while(_loc4_ < _loc1_.length)
         {
            if(_loc3_ < _loc1_[_loc4_])
            {
               return _loc4_;
            }
            _loc4_++;
         }
         return _loc1_.length;
      }
      
      public function get cycles() : Array
      {
         if(this._cycles != null)
         {
            return this._cycles;
         }
         if(this._st == null)
         {
            this._st = Settings.getInstance().getFishByID(this._type.toString());
         }
         if(this._st == null || this._st["cycle"] == undefined)
         {
            return null;
         }
         var _loc1_:Array = this._st["cycle"].split(",") as Array;
         if(_loc1_ == null || _loc1_.length == 0)
         {
            return null;
         }
         this._cycles = new Array();
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_.length)
         {
            this._cycles.push(parseFloat(_loc1_[_loc2_]));
            _loc2_++;
         }
         return this._cycles;
      }
      
      public function get animationUrl() : String
      {
         return GetCropID.getFishUrl(this._type,false);
      }
      
      public function get name() : String
      {
         if(this._st == null)
         {
            this._st = Settings.getInstance().getFishByID(this._type.toString());
         }
         return this._st["crop_name"];
      }
      
      public function get min() : int
      {
         var _loc1_:Number = 0;
         if(this._output > 0)
         {
            _loc1_ = this._output;
         }
         else
         {
            if(this._st == null)
            {
               this._st = Settings.getInstance().getFishByID(this._type.toString());
            }
            _loc1_ = parseFloat(this._st["output"]);
         }
         _loc1_ *= 0.6;
         return Math.ceil(_loc1_) as int;
      }
      
      public function refreshStatus(param1:Object) : void
      {
         var _loc3_:int = 0;
         this._left = Utils.getIntAttribute(param1,"l");
         this._output = Utils.getIntAttribute(param1,"o");
         this._plantTime = Utils.getIntAttribute(param1,"p");
         this.calcNextStepTime();
         var _loc2_:int = int(Utils.getIntAttribute(param1,"f"));
         if(_loc2_ == 1 || _loc2_ == 2 || _loc2_ == 3)
         {
            _loc3_ = this.level;
            this._fertilize = _loc2_ == _loc3_ + 1 ? true : false;
            if(_loc3_ == Consts.FISH_MAX_LEVEL)
            {
               this._fertilize = false;
            }
         }
         else
         {
            this._fertilize = false;
         }
      }
      
      public function get leftTime() : Array
      {
         if(this._st == null)
         {
            this._st = Settings.getInstance().getFishByID(this._type.toString());
         }
         if(this._st == null)
         {
            return null;
         }
         var _loc1_:Array = this.cycles;
         if(_loc1_ == null || _loc1_.length == 0)
         {
            return null;
         }
         var _loc2_:Number = Number(CommonData.serverTime);
         var _loc3_:Number = _loc2_ - this._plantTime;
         if(_loc3_ <= 0)
         {
            return null;
         }
         var _loc4_:Number = 0;
         var _loc5_:int = 0;
         while(_loc5_ < _loc1_.length)
         {
            if(_loc3_ < _loc1_[_loc5_])
            {
               if(_loc5_ > 0)
               {
                  _loc4_ = _loc1_[_loc5_] - _loc1_[_loc5_ - 1];
               }
               else
               {
                  _loc4_ = Number(_loc1_[_loc5_]);
               }
               return [_loc1_[_loc5_] - _loc3_,_loc4_];
            }
            _loc5_++;
         }
         return [0,0];
      }
      
      public function get poolSize() : int
      {
         if(this._st == null)
         {
            this._st = Settings.getInstance().getFishByID(this._type.toString());
         }
         return this._st["pool_size"];
      }
   }
}

