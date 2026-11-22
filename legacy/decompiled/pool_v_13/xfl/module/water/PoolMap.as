package module.water
{
   import common.misc.Utils;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.Point;
   
   public class PoolMap extends Sprite
   {
      
      internal static const SPAWN_CIRCLE_NUM:uint = 24;
      
      private var _dirsVector:Array;
      
      private var _centerAnchor:Point;
      
      protected var _fishContainer:DisplayObjectContainer;
      
      private var _anchors:Array;
      
      private var _cornerRadius:Number;
      
      protected var _pool:MovieClip;
      
      private var _limit:DisplayObject;
      
      public function PoolMap()
      {
         super();
         this.createPoolMap();
         this.hideCircles();
      }
      
      private function hideCircles() : void
      {
         if(this._pool == null)
         {
            return;
         }
         var _loc1_:uint = uint(this._pool.numChildren);
         var _loc2_:DisplayObject = null;
         var _loc3_:int = 0;
         while(_loc3_ < _loc1_)
         {
            _loc2_ = this._pool.getChildAt(_loc3_);
            if((_loc2_.name.length == 2 || _loc2_.name.length == 3) && _loc2_.name.charAt(0) == "c")
            {
               _loc2_.visible = false;
            }
            _loc3_++;
         }
      }
      
      private function createPoolMap() : void
      {
         this._pool = Utils.getMaterial("PoolMap") as MovieClip;
         if(this._pool != null)
         {
            this._pool.mouseChildren = false;
            this._pool.mouseEnabled = false;
            this._fishContainer = this._pool["holder"] as DisplayObjectContainer;
            this._limit = this._pool["limit"] as DisplayObject;
            if(this._limit != null)
            {
               this._limit.visible = false;
               this._anchors = [this._limit["a1"],this._limit["a2"],this._limit["a3"],this._limit["a4"]];
            }
            this.initializeCalculations();
         }
      }
      
      public function randSpawnCircle() : DisplayObject
      {
         var _loc1_:Array = ["c4","c7","c10","c13","c16","c19"];
         var _loc2_:int = Math.floor(Math.random() * _loc1_.length) as int;
         return this._pool[_loc1_[_loc2_]] as DisplayObject;
      }
      
      public function get fishContainer() : DisplayObjectContainer
      {
         return this._fishContainer;
      }
      
      public function cdWithCircles(param1:MovieClip, param2:Array) : Boolean
      {
         if(param1 == null || param2 == null || param2.length == 0)
         {
            return false;
         }
         var _loc3_:Point = new Point(param1.width * 0.5,param1.height * 0.5);
         _loc3_ = param1.localToGlobal(_loc3_);
         var _loc4_:int = int(param2.length);
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            if(this._pool.hasOwnProperty("c" + param2[_loc5_]) != false)
            {
               if(this._pool["c" + param2[_loc5_]].hitTestPoint(_loc3_.x,_loc3_.y,true) == true)
               {
                  return true;
               }
            }
            _loc5_++;
         }
         return false;
      }
      
      public function atCorner(param1:Number, param2:Number) : int
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = Number.POSITIVE_INFINITY;
         var _loc5_:int = -1;
         var _loc6_:int = int(this._anchors.length);
         var _loc7_:DisplayObject = null;
         var _loc8_:int = 0;
         while(_loc8_ < _loc6_)
         {
            _loc7_ = this._anchors[_loc8_] as DisplayObject;
            _loc3_ = (param1 - (_loc7_.x + this._limit.x)) * (param1 - (_loc7_.x + this._limit.x)) + (param2 - (_loc7_.y + this._limit.y)) * (param2 - (_loc7_.y + this._limit.y));
            if(_loc3_ <= this._cornerRadius)
            {
               if(_loc3_ < _loc4_)
               {
                  _loc4_ = _loc3_;
                  _loc5_ = _loc8_;
               }
            }
            _loc8_++;
         }
         return _loc5_;
      }
      
      public function calcNormalizedVelocity(param1:int) : Point
      {
         if(param1 < 0)
         {
            return null;
         }
         if(this._dirsVector != null && param1 < this._dirsVector.length)
         {
            return this._dirsVector[param1];
         }
         var _loc2_:Point = new Point();
         if(param1 == 0)
         {
            _loc2_.x = this._anchors[0].x - this._anchors[3].x;
            _loc2_.y = this._anchors[0].y - this._anchors[3].y;
         }
         else if(param1 == 1)
         {
            _loc2_.x = this._anchors[2].x - this._anchors[3].x;
            _loc2_.y = this._anchors[2].y - this._anchors[3].y;
         }
         else if(param1 == 2)
         {
            _loc2_.x = this._anchors[2].x - this._anchors[1].x;
            _loc2_.y = this._anchors[2].y - this._anchors[1].y;
         }
         else if(param1 == 3)
         {
            _loc2_.x = this._anchors[0].x - this._anchors[1].x;
            _loc2_.y = this._anchors[0].y - this._anchors[1].y;
         }
         var _loc3_:Number = Math.sqrt(_loc2_.x * _loc2_.x + _loc2_.y * _loc2_.y);
         if(_loc3_ > 0)
         {
            _loc2_.x /= _loc3_;
            _loc2_.y /= _loc3_;
         }
         return _loc2_;
      }
      
      public function calcCenterVector(param1:MovieClip) : Point
      {
         if(param1 == null)
         {
            return null;
         }
         var _loc2_:Point = new Point();
         _loc2_.x = param1.x + param1.width * 0.5 * param1.scaleX;
         _loc2_.y = param1.y + param1.height * 0.5 * param1.scaleY;
         var _loc3_:Point = new Point(this._centerAnchor.x - _loc2_.x,this._centerAnchor.y - _loc2_.y);
         var _loc4_:Number = Math.sqrt(_loc3_.x * _loc3_.x + _loc3_.y * _loc3_.y);
         _loc3_.x /= _loc4_;
         _loc3_.y /= _loc4_;
         return _loc3_;
      }
      
      public function cdWithPoolLimit(param1:Point) : Boolean
      {
         if(param1 == null || this._limit == null)
         {
            return false;
         }
         return this._limit.hitTestPoint(param1.x,param1.y,true);
      }
      
      private function initializeCalculations() : void
      {
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         if(this._dirsVector == null)
         {
            _loc1_ = new Array(4);
            _loc2_ = 0;
            while(_loc2_ < 4)
            {
               _loc1_[_loc2_] = this.calcNormalizedVelocity(_loc2_);
               _loc2_++;
            }
            this._dirsVector = _loc1_;
         }
         if(this._centerAnchor == null)
         {
            this._centerAnchor = new Point((this._anchors[3].x + this._anchors[1].x) * 0.5,(this._anchors[0].y + this._anchors[2].y) * 0.5);
            this._centerAnchor.x += this._limit.x;
            this._centerAnchor.y += this._limit.y;
            _loc3_ = (this._anchors[1].x - this._anchors[0].x) * (this._anchors[1].x - this._anchors[0].x) + (this._anchors[1].y - this._anchors[0].y) * (this._anchors[1].y - this._anchors[0].y);
            _loc3_ /= 4;
            _loc4_ = (this._anchors[3].x - this._anchors[2].x) * (this._anchors[3].x - this._anchors[2].x) + (this._anchors[3].y - this._anchors[2].y) * (this._anchors[3].y - this._anchors[2].y);
            _loc4_ = _loc4_ / 4;
            this._cornerRadius = (_loc3_ + _loc4_) / 2;
         }
      }
   }
}

