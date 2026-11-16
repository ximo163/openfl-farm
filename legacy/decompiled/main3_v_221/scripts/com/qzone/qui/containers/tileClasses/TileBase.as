package com.qzone.qui.containers.tileClasses
{
   import com.qzone.qui.containers.Canvas;
   import com.qzone.qui.core.Direction;
   import com.qzone.qui.events.ScrollEvent;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class TileBase extends Canvas
   {
      
      protected var _contentHeight:Number;
      
      protected var _childrenWidth:int;
      
      protected var _data:Array;
      
      public var itemRollOverFn:Function;
      
      protected var _childrenHeight:int;
      
      protected var _contentWidth:Number;
      
      public var gapH:int = 10;
      
      public var tileWidth:Number;
      
      protected var _childArray:Array = [];
      
      public var gapV:int = 10;
      
      public var itemClickFn:Function;
      
      public var itemRollOutFn:Function;
      
      public var labelField:String = "label";
      
      public var dataField:String = "data";
      
      public var tileHeight:Number;
      
      public var itemRenderer:Class;
      
      public var direction:String = "horizontal";
      
      public function TileBase()
      {
         super();
         paddingH = 10;
         paddingV = 10;
      }
      
      public function removeAll() : void
      {
         var _loc1_:* = int(this._childArray.length - 1);
         while(_loc1_ >= 0)
         {
            this.removeElementAt(_loc1_);
            _loc1_--;
         }
      }
      
      override protected function get contentHeight() : Number
      {
         this._contentHeight = this._childrenHeight + paddingV;
         return this._contentHeight || _content.height;
      }
      
      protected function onRebuildComplete() : void
      {
         this.dispatchEvent(new Event(Event.COMPLETE));
      }
      
      public function getElementAt(param1:uint) : Object
      {
         return content.getChildAt(param1);
      }
      
      protected function rebuild() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:DisplayObject = null;
         this.removeAll();
         if(Boolean(this._data) && Boolean(content))
         {
            _loc1_ = int(this._data.length);
            while(_loc2_ < _loc1_)
            {
               _loc3_ = new this.itemRenderer() as DisplayObject;
               this._childArray[_loc2_] = _loc3_;
               _loc3_[this.dataField] = this._data[_loc2_];
               this.eventHandle(_loc3_);
               _loc2_++;
            }
         }
         this.layout();
         this.onRebuildComplete();
      }
      
      public function addElement(param1:DisplayObject) : void
      {
         this.addElementAt(param1,this._childArray.length);
      }
      
      protected function layout() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:DisplayObject = null;
         var _loc1_:int = int(this._childArray.length);
         while(_loc8_ < _loc1_)
         {
            _loc9_ = this._childArray[_loc8_] as DisplayObject;
            _loc9_[this.dataField] = this._data[_loc8_];
            _loc2_ = int(int(this.tileWidth) || int(_loc9_.width));
            _loc3_ = int(int(this.tileHeight) || int(_loc9_.height));
            if(this.direction == Direction.HORIZONTAL)
            {
               _loc5_ = Math.floor((_width - paddingH) / (_loc2_ + this.gapH));
               _loc4_ = Math.ceil(_loc1_ / _loc5_);
               _loc6_ = _loc8_ % _loc5_;
               _loc7_ = Math.floor(_loc8_ / _loc5_);
            }
            else if(this.direction == Direction.VERTICAL)
            {
               _loc4_ = Math.floor((_height - paddingV) / (_loc3_ + this.gapV));
               _loc5_ = Math.ceil(_loc1_ / _loc4_);
               _loc6_ = _loc8_ / _loc4_;
               _loc7_ = Math.floor(_loc8_ % _loc4_);
            }
            _loc9_.x = paddingH + _loc2_ * _loc6_ + this.gapH * _loc6_;
            _loc9_.y = paddingV + _loc3_ * _loc7_ + this.gapV * _loc7_;
            content.addChild(_loc9_ as DisplayObject);
            _loc8_++;
         }
         this._childrenWidth = paddingH + _loc5_ * (_loc2_ + this.gapH) - this.gapH;
         this._childrenHeight = paddingV + _loc4_ * (_loc3_ + this.gapV) - this.gapV;
         validateNow();
      }
      
      public function removeElementAt(param1:int) : DisplayObject
      {
         var _loc2_:DisplayObject = null;
         if(param1 < this._childArray.length && param1 > -1)
         {
            _loc2_ = this._childArray.splice(param1,1)[0] as DisplayObject;
            if(_loc2_)
            {
               this.eventHandle(_loc2_,"removeEventListener");
               if(_loc2_.parent)
               {
                  _loc2_.parent.removeChild(_loc2_);
               }
               delayCall(this.layout);
            }
         }
         return _loc2_;
      }
      
      public function addElementAt(param1:DisplayObject, param2:int) : void
      {
         if(param2 <= this._childArray.length && param2 > -1)
         {
            this._childArray.splice(param2,0,param1);
            this.eventHandle(param1);
            delayCall(this.layout);
         }
      }
      
      public function get dataProvider() : Array
      {
         return this._data;
      }
      
      public function scrollVerticalReset() : void
      {
         _scrollRect.y = 0;
         this.rebuild();
      }
      
      public function get items() : Array
      {
         return this._childArray;
      }
      
      override protected function get contentWidth() : Number
      {
         this._contentWidth = this._childrenWidth + paddingH;
         return this._contentWidth || _content.width;
      }
      
      override protected function onScrollChange(param1:ScrollEvent) : void
      {
      }
      
      public function removeElement(param1:DisplayObject) : int
      {
         var _loc2_:int = -1;
         if(content == param1.parent)
         {
            _loc2_ = content.getChildIndex(param1);
            this.removeElementAt(_loc2_);
         }
         return _loc2_;
      }
      
      protected function eventHandle(param1:DisplayObject, param2:String = "addEventListener") : void
      {
         this.itemClickFn && param1[param2](MouseEvent.CLICK,this.itemClickFn);
         this.itemRollOverFn && param1[param2](MouseEvent.ROLL_OVER,this.itemRollOverFn);
         this.itemRollOutFn && param1[param2](MouseEvent.ROLL_OUT,this.itemRollOutFn);
      }
      
      public function set dataProvider(param1:Array) : void
      {
         this._data = param1;
         if(_inited)
         {
            _scrollRect.y = 0;
            _scrollRect.x = 0;
         }
         this.rebuild();
         _inited = false;
      }
      
      override protected function updateBackGround() : void
      {
         var _loc1_:int = Math.max(this._childrenWidth + paddingH,_width - _scrollW);
         var _loc2_:int = Math.max(this._childrenHeight + paddingV,_height - _scrollH);
         drawBackGround(_loc1_,_loc2_);
      }
   }
}

