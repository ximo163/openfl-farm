package com.qzone.qui.controls.listClasses
{
   import com.qzone.qui.controls.scrollClasses.ScrollBarMode;
   import com.qzone.qui.controls.scrollClasses.ScrollBase;
   import com.qzone.qui.core.Direction;
   import com.qzone.qui.events.ScrollEvent;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class ListBase extends ScrollBase
   {
      
      private var _data:Array;
      
      public var allowMultipleSelection:Boolean;
      
      private var _selectedItemRenderer:Array;
      
      private var _dataMap:Array;
      
      public var rowHeight:int;
      
      private var changed:Boolean;
      
      private var _selectedItem:Object;
      
      private var _selectedIndices:Array;
      
      public var rowCount:int;
      
      private var _selectedItems:Array;
      
      public var labelField:String = "label";
      
      public var dataField:String = "data";
      
      private var _selectedIndex:int = -1;
      
      public var itemRenderer:Class;
      
      protected var direction:String = "vertical";
      
      public function ListBase()
      {
         super();
         this.rowHeight = 18;
         vScrollMode = ScrollBarMode.LINE;
         hScrollMode = ScrollBarMode.LINE;
         this._dataMap = [];
         this._selectedIndices = [];
         this._selectedItems = [];
         this._selectedItemRenderer = [];
         _content = new Sprite();
      }
      
      private function deSelectAll() : void
      {
         var _loc1_:String = null;
         for(_loc1_ in this._dataMap)
         {
            this._dataMap[_loc1_] = false;
         }
      }
      
      private function updateItemRenderAt(param1:int) : void
      {
         var _loc2_:Object = _content.getChildAt(param1);
         if(_loc2_)
         {
            if(this.direction == Direction.HORIZONTAL)
            {
               _loc2_.selected = this._dataMap[param1 + _scrollPositionH];
            }
            else
            {
               _loc2_.selected = this._dataMap[param1 + _scrollPositionV];
            }
         }
      }
      
      public function scrollToIndex(param1:int) : void
      {
         if(this.direction == Direction.HORIZONTAL)
         {
            if(param1 >= _scrollPositionH + _pageSizeH - 1)
            {
               _scrollPositionH = param1 + 2 - _pageSizeH;
               if(hScrollBar)
               {
                  hScrollBar.setScrollProperties(_pageSizeH,_scrollPositionH,_maxScrollPositionH);
               }
               delayCall(this.rebuild);
            }
         }
         else if(param1 >= _scrollPositionV + _pageSizeV - 1)
         {
            _scrollPositionV = param1 + 2 - _pageSizeV;
            if(vScrollBar)
            {
               vScrollBar.setScrollProperties(_pageSizeV,_scrollPositionV,_maxScrollPositionV);
            }
            delayCall(this.rebuild);
         }
      }
      
      public function get selectedIndices() : Array
      {
         return this.getSelectedIndices();
      }
      
      override protected function init() : void
      {
         super.init();
         this.addChild(_content);
      }
      
      protected function onRebuildComplete() : void
      {
         this.dispatchEvent(new Event(Event.COMPLETE));
      }
      
      public function set selectedIndices(param1:Array) : void
      {
         this._selectedIndices = param1;
         this.setSelectedIndices();
      }
      
      private function rebuild() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:DisplayObject = null;
         this.removeAll();
         if(Boolean(this._data) && Boolean(_content))
         {
            if(this.direction == Direction.HORIZONTAL)
            {
               _loc1_ = _pageSizeH;
               if(_scrollPositionH + _pageSizeH > this._data.length)
               {
                  _loc1_ = this._data.length - _scrollPositionH;
               }
               _loc2_ = 0;
               while(_loc2_ < _loc1_)
               {
                  _loc3_ = _loc2_ + _scrollPositionH;
                  _loc4_ = new this.itemRenderer(_loc3_);
                  _loc4_.x = this.rowHeight * _loc2_ + borderSizeH + paddingH;
                  _loc4_.y = borderSizeV + paddingV;
                  _loc4_.width = this.rowHeight;
                  _loc4_.height = _height - borderSizeV * 2 - paddingV * 2;
                  _loc4_[this.dataField] = this._data[_loc3_];
                  _loc4_["selected"] = this._dataMap[_loc3_];
                  this.addItemEvent(_loc4_);
                  _content.addChild(_loc4_);
                  _loc2_++;
               }
            }
            else
            {
               _loc1_ = _pageSizeV;
               if(_scrollPositionV + _pageSizeV > this._data.length)
               {
                  _loc1_ = this._data.length - _scrollPositionV;
               }
               _loc2_ = 0;
               while(_loc2_ < _loc1_)
               {
                  _loc3_ = _loc2_ + _scrollPositionV;
                  _loc4_ = new this.itemRenderer(_loc3_);
                  _loc4_.y = this.rowHeight * _loc2_ + borderSizeV + paddingV;
                  _loc4_.x = borderSizeH + paddingH;
                  _loc4_.width = _width - borderSizeH * 2 - paddingH * 2;
                  _loc4_.height = this.rowHeight;
                  _loc4_["labelField"] = this.labelField;
                  _loc4_[this.dataField] = this._data[_loc3_];
                  _loc4_["selected"] = this._dataMap[_loc3_];
                  this.addItemEvent(_loc4_);
                  _content.addChild(_loc4_);
                  _loc2_++;
               }
            }
         }
         this.onRebuildComplete();
      }
      
      public function set selectedItem(param1:Object) : void
      {
         this._selectedItem = param1;
         this.setSelectedItem();
      }
      
      public function removeAll() : void
      {
         var _loc1_:* = int(_content.numChildren - 1);
         while(_loc1_ >= 0)
         {
            _content.removeChildAt(_loc1_);
            _loc1_--;
         }
      }
      
      private function removeItemEvent(param1:DisplayObject) : void
      {
         param1.removeEventListener(MouseEvent.CLICK,this.onItemSelect);
      }
      
      private function addItemEvent(param1:DisplayObject) : void
      {
         param1.addEventListener(MouseEvent.CLICK,this.onItemSelect);
      }
      
      public function addItemAt(param1:int, ... rest) : void
      {
         var _loc3_:* = 0;
         if(param1 < this._data.length && param1 > -1)
         {
            _loc3_ = int(rest.length - 1);
            while(_loc3_ >= 0)
            {
               this._data.splice(param1,0,rest[_loc3_]);
               this._dataMap.splice(param1,0,false);
               _loc3_--;
            }
            this.updateScrollProperties();
            delayCall(this.rebuild);
         }
      }
      
      public function getItemAt(param1:uint) : Object
      {
         var _loc2_:Object = null;
         if(param1 < this._data.length && param1 > -1)
         {
            _loc2_ = this._data[param1];
         }
         return _loc2_;
      }
      
      private function onItemSelect(param1:Event) : void
      {
         var _loc2_:DisplayObject = param1.currentTarget as DisplayObject;
         this.setItemRenderSelected(_loc2_);
         this.dispatchEvent(new Event(Event.CHANGE));
      }
      
      private function getSelectedItems() : Array
      {
         var _loc1_:String = null;
         this._selectedItems = [];
         for(_loc1_ in this._dataMap)
         {
            if(this._dataMap[_loc1_])
            {
               this._selectedItems.push(this._data[_loc1_]);
            }
         }
         return this._selectedItems;
      }
      
      private function updateItemRender() : void
      {
         var _loc1_:* = int(_content.numChildren - 1);
         while(_loc1_ >= 0)
         {
            this.updateItemRenderAt(_loc1_);
            _loc1_--;
         }
      }
      
      public function removeItem(param1:Object) : Object
      {
         var _loc2_:String = null;
         for(_loc2_ in this._data)
         {
            if(this._data[_loc2_] == param1)
            {
               param1 = this.removeItemAt(int(_loc2_));
               break;
            }
         }
         return param1;
      }
      
      public function get dataProvider() : Array
      {
         return this._data;
      }
      
      private function setSelectedIndex() : void
      {
         if(!this.allowMultipleSelection)
         {
            this.deSelectAll();
         }
         this._dataMap[this._selectedIndex] = true;
         this.updateItemRender();
      }
      
      private function setSelectedItems() : void
      {
         var _loc1_:Array = null;
         var _loc2_:String = null;
         var _loc3_:String = null;
         if(this.allowMultipleSelection)
         {
            _loc1_ = [];
            for(_loc2_ in this._selectedItems)
            {
               for(_loc3_ in this._data)
               {
                  if(this._data[_loc3_] == this._selectedItems[_loc2_])
                  {
                     _loc1_.push(_loc3_);
                     break;
                  }
               }
            }
            this.selectedIndices = _loc1_;
         }
      }
      
      private function setItemRenderSelected(param1:Object) : void
      {
         var _loc2_:int = int(param1.index);
         var _loc3_:Object = param1.data;
         this._selectedIndex = _loc2_;
         this._selectedItem = _loc3_;
         this._selectedItemRenderer.push(param1);
         if(this.allowMultipleSelection)
         {
            this._dataMap[this._selectedIndex] = !this._dataMap[this._selectedIndex];
         }
         else
         {
            this.deSelectAll();
            this._dataMap[this._selectedIndex] = true;
         }
         this.updateItemRender();
      }
      
      private function updateScrollProperties() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(this.direction == Direction.HORIZONTAL)
         {
            _loc1_ = this._data ? int(this._data.length) : 0;
            _loc2_ = _loc1_;
            if(this.rowCount > 0)
            {
               _width = this.rowHeight * this.rowCount + borderSizeH * 2;
               _loc2_ = _loc1_;
               _pageSizeH = this.rowCount;
            }
            else
            {
               _loc2_ = _loc1_ - this.rowCount + 1;
               _pageSizeH = Math.ceil(_width / this.rowHeight);
            }
            if(_loc2_ > 1)
            {
               _maxScrollPositionH = _loc2_;
            }
            else
            {
               _maxScrollPositionH = 1;
            }
         }
         else
         {
            if(this.rowCount > 0)
            {
               _height = this.rowHeight * this.rowCount + borderSizeV * 2;
            }
            _pageSizeV = Math.ceil(_height / this.rowHeight);
            _loc1_ = this._data ? int(this._data.length) : 0;
            _loc3_ = _loc1_ - this.rowCount + 1;
            if(_loc3_ > 1)
            {
               _maxScrollPositionV = _loc3_;
            }
            else
            {
               _maxScrollPositionV = 1;
            }
         }
         updateScrollBar();
         setSize();
      }
      
      public function set selectedItems(param1:Array) : void
      {
         this._selectedItems = param1;
         this.setSelectedItems();
      }
      
      public function get selectedItem() : Object
      {
         return this._selectedItem;
      }
      
      private function setSelectedItem() : void
      {
         var _loc1_:String = null;
         for(_loc1_ in this._data)
         {
            if(this._selectedItem == this._data[_loc1_])
            {
               this.selectedIndex = int(_loc1_);
               break;
            }
         }
      }
      
      public function removeItemAt(param1:int) : Object
      {
         var _loc2_:Object = null;
         if(param1 < this._data.length && param1 > -1)
         {
            _loc2_ = this._data.splice(param1,1);
            this._dataMap.splice(param1,1);
            this.updateScrollProperties();
            delayCall(this.rebuild);
         }
         return _loc2_;
      }
      
      public function addItem(... rest) : void
      {
         var _loc2_:String = null;
         for(_loc2_ in rest)
         {
            this._data.push(rest[_loc2_]);
            this._dataMap.push(false);
         }
         this.updateScrollProperties();
         delayCall(this.rebuild);
      }
      
      private function getSelectedIndices() : Array
      {
         var _loc1_:String = null;
         this._selectedIndices = [];
         for(_loc1_ in this._dataMap)
         {
            if(this._dataMap[_loc1_])
            {
               this._selectedIndices.push(_loc1_);
            }
         }
         return this._selectedIndices;
      }
      
      private function setSelectedIndices() : void
      {
         var _loc1_:String = null;
         if(this.allowMultipleSelection)
         {
            this.deSelectAll();
            for each(_loc1_ in this._selectedIndices)
            {
               this._dataMap[_loc1_] = true;
            }
         }
         this.updateItemRender();
      }
      
      override protected function onScrollChange(param1:ScrollEvent) : void
      {
         this.rebuild();
      }
      
      public function scrollToSelected() : void
      {
         var _loc1_:int = int(this.selectedIndices[0]);
         this.scrollToIndex(_loc1_);
      }
      
      public function get selectedItems() : Array
      {
         return this.getSelectedItems();
      }
      
      public function set selectedIndex(param1:int) : void
      {
         this._selectedIndex = param1;
         this.setSelectedIndex();
      }
      
      public function set dataProvider(param1:Array) : void
      {
         this._data = param1;
         this.deSelectAll();
         _scrollPositionV = 0;
         _scrollPositionH = 0;
         this.updateScrollProperties();
         this.rebuild();
      }
      
      public function get selectedIndex() : int
      {
         var _loc1_:Array = this.getSelectedIndices();
         if(_loc1_.length > 0)
         {
            return _loc1_[0];
         }
         return -1;
      }
      
      public function replaceItemAt(param1:Object, param2:uint) : Object
      {
         var _loc3_:Object = null;
         if(param2 < this._data.length && param2 > -1)
         {
            _loc3_ = this._data.splice(param2,1,param1);
            delayCall(this.rebuild);
         }
         return _loc3_;
      }
   }
}

