package com.minutes.ui.collections
{
   import com.minutes.ui.core.LipiContainer;
   import com.minutes.ui.core.Reservoir;
   import flash.display.DisplayObject;
   
   public class LipiTile2 extends LipiContainer
   {
      
      public static var CHILD_CLICK:String = "childClick";
      
      public static var CHILD_OVER:String = "childOver";
      
      public static var CHILD_OUT:String = "childOut";
      
      private var _dataList:Array;
      
      private var _itemHeight:Number = 0;
      
      protected var aReservoir:Reservoir;
      
      private var _leftSpace:Number = 0;
      
      private var _topSpace:Number = 0;
      
      private var _itemWidth:Number = 0;
      
      private var _colAmount:int = 0;
      
      private var _childItem:Class;
      
      public function LipiTile2(param1:Class, param2:int, param3:Number, param4:Number, param5:Number = 0, param6:Number = 0)
      {
         super();
         this.childItem = param1;
         this.colAmount = param2;
         this.leftSpace = param5;
         this.topSpace = param6;
         this.itemWidth = param3;
         this.itemHeight = param4;
         this.aReservoir = new Reservoir(param1);
      }
      
      public function set dataList(param1:Array) : void
      {
         this._dataList = param1;
         if(this._dataList != null)
         {
            this.setChild();
         }
      }
      
      public function get childItem() : Class
      {
         return this._childItem;
      }
      
      public function get itemHeight() : Number
      {
         return this._itemHeight;
      }
      
      public function set childItem(param1:Class) : void
      {
         this._childItem = param1;
      }
      
      public function getPosition(param1:int) : Array
      {
         var _loc2_:Number = Math.floor(param1 / this.colAmount);
         var _loc3_:Number = param1 % this.colAmount;
         var _loc4_:Number = this.leftSpace + _loc3_ * this.itemWidth;
         var _loc5_:Number = this.topSpace + _loc2_ * this.itemHeight;
         return new Array(_loc4_,_loc5_);
      }
      
      private function setChild() : void
      {
         var _loc3_:LipiListChild = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.dataList.length)
         {
            if(numChildren > _loc1_)
            {
               _loc3_ = getChildAt(_loc1_) as LipiListChild;
               _loc3_.data = this.dataList[_loc1_];
            }
            else
            {
               _loc3_ = this.aReservoir.getInstance() as LipiListChild;
               _loc3_.data = this.dataList[_loc1_];
               addChild(_loc3_);
            }
            _loc1_++;
         }
         var _loc2_:* = int(numChildren - 1);
         while(_loc2_ >= this.dataList.length)
         {
            this.aReservoir.delInstance(getChildAt(_loc2_));
            removeChildAt(_loc2_);
            _loc2_--;
         }
         this.setChildPosition();
         vScrollPosition = 0;
      }
      
      public function set topSpace(param1:Number) : void
      {
         this._topSpace = param1;
      }
      
      protected function setChildPosition() : void
      {
         var _loc2_:DisplayObject = null;
         var _loc1_:Array = null;
         _loc2_ = null;
         var _loc3_:int = 0;
         while(_loc3_ < numChildren)
         {
            _loc1_ = this.getPosition(_loc3_);
            _loc2_ = getChildAt(_loc3_);
            _loc2_.x = _loc1_[0];
            _loc2_.y = _loc1_[1];
            _loc3_++;
         }
      }
      
      public function set itemWidth(param1:Number) : void
      {
         this._itemWidth = param1;
      }
      
      public function get dataList() : Array
      {
         return this._dataList;
      }
      
      public function set colAmount(param1:int) : void
      {
         this._colAmount = param1;
      }
      
      public function get topSpace() : Number
      {
         return this._topSpace;
      }
      
      public function get itemWidth() : Number
      {
         return this._itemWidth;
      }
      
      public function get colAmount() : int
      {
         return this._colAmount;
      }
      
      public function set itemHeight(param1:Number) : void
      {
         this._itemHeight = param1;
      }
      
      public function set leftSpace(param1:Number) : void
      {
         this._leftSpace = param1;
      }
      
      public function get leftSpace() : Number
      {
         return this._leftSpace;
      }
   }
}

