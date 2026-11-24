package com.qzone.corelib.controls.scrollviews
{
   import flash.display.DisplayObjectContainer;
   
   public class VScrollView extends BasicScrollView
   {
      
      public function VScrollView(param1:DisplayObjectContainer, param2:int, param3:int = 1, param4:Number = 5, param5:Number = 5)
      {
         super(param1,param2,param3,param4,param5);
         _itemCount = (_rowCount + 1) * _columnCount;
      }
      
      override protected function startScrollRenderer() : void
      {
         var _loc1_:int = _offsetY - _scroller.value * (_lineCount - _rowCount) * (_itemHeight + _verticalGap) / 100;
         var _loc2_:Number = -((_loc1_ - _offsetY) / (_itemHeight + _verticalGap)) >> 0;
         var _loc3_:Boolean = _loc1_ > _container.y;
         _container.y = _loc1_;
         if(_currentLineIndex == _loc2_)
         {
            return;
         }
         if(Math.abs(_currentLineIndex - _loc2_) > 1)
         {
            _forceUpdate = true;
         }
         _currentLineIndex = _loc2_;
         this.adjustItemViewOrder(_loc3_);
         this.refreshDisplay();
      }
      
      override protected function refreshDisplay() : void
      {
         var _loc6_:int = 0;
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         var _loc4_:RendererWrapper = null;
         var _loc5_:int = _currentLineIndex;
         while(_loc5_ < _currentLineIndex + _rowCount + 1)
         {
            _loc6_ = 0;
            while(_loc6_ < _columnCount)
            {
               _loc4_ = _itemList[_loc1_];
               _loc2_ = _loc5_ * _columnCount + _loc6_;
               _loc4_.index = _loc1_;
               _loc3_ = _dataProvider[_loc2_];
               if(_forceUpdate)
               {
                  _loc4_.dataIndex = _loc2_;
                  _loc4_.data = _loc3_;
               }
               if(_loc3_)
               {
                  if(_loc4_.parent != _container)
                  {
                     _container.addChild(_loc4_);
                  }
               }
               else
               {
                  _loc4_.parent && _loc4_.parent.removeChild(_loc4_);
               }
               _loc4_.x = int(_loc6_ * _loc4_.width + _loc6_ * _horizontalGap);
               _loc4_.y = int(_loc5_ * _loc4_.height + _loc5_ * _verticalGap);
               _loc1_++;
               _loc6_++;
            }
            _loc5_++;
         }
         _forceUpdate = false;
      }
      
      override protected function adjustItemViewOrder(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         var _loc3_:RendererWrapper = null;
         var _loc4_:RendererWrapper = null;
         if(param1)
         {
            _loc2_ = 0;
            while(_loc2_ < _columnCount)
            {
               _loc3_ = _itemList[0];
               _loc4_ = _itemList.pop() as RendererWrapper;
               _loc4_.y = int(_loc3_.y - _itemHeight - _verticalGap);
               --_loc3_.dataIndex;
               _loc4_.data = _dataProvider[_loc4_.dataIndex];
               _itemList.unshift(_loc4_);
               _loc2_++;
            }
         }
         else
         {
            _loc2_ = 0;
            while(_loc2_ < _columnCount)
            {
               _loc3_ = _itemList.shift() as RendererWrapper;
               _loc4_ = _itemList[_itemList.length - 1];
               _loc3_.y = int(_loc4_.y + _itemHeight + _verticalGap);
               _loc3_.dataIndex = _loc4_.dataIndex + 1;
               _loc3_.data = _dataProvider[_loc3_.dataIndex];
               _itemList.push(_loc3_);
               _loc2_++;
            }
         }
      }
      
      override protected function caculateLineCount() : void
      {
         _lineCount = Math.ceil(_dataProvider.length / _columnCount);
      }
      
      override public function scrollTo(param1:int) : void
      {
         super.scrollTo(param1);
         if(param1 < 0)
         {
            param1 = 0;
         }
         var _loc2_:int = Math.floor(param1 / _columnCount);
         if(_loc2_ > _lineCount - _rowCount && _lineCount > _rowCount)
         {
            _loc2_ = _lineCount - _rowCount;
         }
         _scroller.value = 100 * _loc2_ / (_lineCount - _rowCount);
      }
   }
}

