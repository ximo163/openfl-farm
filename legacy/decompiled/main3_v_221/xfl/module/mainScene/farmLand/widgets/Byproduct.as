package module.mainScene.farmLand.widgets
{
   import common.misc.Utils;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   
   public class Byproduct
   {
      
      private var _insect:int;
      
      private var _parent:DisplayObjectContainer;
      
      private var _insectSprite:Sprite;
      
      private var _insectPosition:Array;
      
      private var _weedSprite:Sprite;
      
      private var _weed:int;
      
      private var _weedPosition:Array;
      
      public function Byproduct(param1:DisplayObjectContainer)
      {
         super();
         this._insectPosition = [[0,10],[45,20],[120,10]];
         this._weedPosition = [[0,10],[45,20],[120,10]];
         this._weed = 0;
         this._insect = 0;
         this._parent = param1;
      }
      
      public function updateInsectPosition() : void
      {
         var _loc1_:int = 0;
         if(this._insectPosition == null)
         {
            return;
         }
         if(this._insectSprite != null)
         {
            _loc1_ = 0;
            while(_loc1_ < this._insectSprite.numChildren)
            {
               this._insectSprite.getChildAt(_loc1_).x = this._insectPosition[_loc1_][0];
               this._insectSprite.getChildAt(_loc1_).y = this._insectPosition[_loc1_][1];
               _loc1_++;
            }
         }
      }
      
      public function set insectPosition(param1:Array) : void
      {
         this._insectPosition = param1;
      }
      
      public function clear() : void
      {
         if(this._parent != null)
         {
            if(this._insectSprite != null && this._parent.contains(this._insectSprite) == true)
            {
               this._parent.removeChild(this._insectSprite);
               this._insectSprite = null;
            }
            if(this._weedSprite != null && this._parent.contains(this._weedSprite) == true)
            {
               this._parent.removeChild(this._weedSprite);
               this._weedSprite = null;
            }
         }
         this._weed = 0;
         this._insect = 0;
      }
      
      public function updateWeed() : void
      {
         var _loc1_:Sprite = null;
         if(this._weedSprite == null && this._weed != 0)
         {
            this._weedSprite = new Sprite();
            this._weedSprite.name = "__weeds__";
            this._parent.addChild(this._weedSprite);
         }
         if(this._weedSprite == null)
         {
            return;
         }
         this._weed = Math.min(3,this._weed);
         if(this._weedSprite.numChildren > this._weed)
         {
            while(this._weedSprite.numChildren > this._weed)
            {
               this._weedSprite.removeChildAt(this._weedSprite.numChildren - 1);
            }
         }
         else
         {
            while(this._weedSprite.numChildren < this._weed)
            {
               _loc1_ = Utils.getMaterial("Weed") as Sprite;
               if(_loc1_ != null)
               {
                  _loc1_.cacheAsBitmap = true;
                  _loc1_.x = this._weedPosition[this._weedSprite.numChildren][0];
                  _loc1_.y = this._weedPosition[this._weedSprite.numChildren][1];
                  this._weedSprite.addChild(_loc1_);
               }
            }
         }
      }
      
      public function set insect(param1:int) : void
      {
         this._insect = param1;
      }
      
      public function set weed(param1:int) : void
      {
         this._weed = param1;
      }
      
      public function updateInsect() : void
      {
         var _loc1_:Sprite = null;
         if(this._insectSprite == null && this._insect != 0)
         {
            this._insectSprite = new Sprite();
            this._insectSprite.name = "__insects__";
            this._parent.addChild(this._insectSprite);
         }
         if(this._insectSprite == null)
         {
            return;
         }
         this._insect = Math.min(3,this._insect);
         if(this._insectSprite.numChildren > this._insect)
         {
            while(this._insectSprite.numChildren > this._insect)
            {
               this._insectSprite.removeChildAt(this._insectSprite.numChildren - 1);
            }
         }
         else
         {
            while(this._insectSprite.numChildren < this._insect)
            {
               _loc1_ = Utils.getMaterial("Insect") as Sprite;
               this._insectSprite.addChild(_loc1_);
            }
         }
      }
   }
}

