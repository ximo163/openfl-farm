package com.qzone.corelib.controls.scrollviews
{
   import com.qzone.corelib.controls.events.ScrollEvent;
   import com.qzone.corelib.controls.interfaces.IScroller;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class BasicScrollView extends EventDispatcher
   {
      
      private var _listContainer:DisplayObjectContainer = null;
      
      protected var _container:DisplayObjectContainer = null;
      
      protected var _scroller:IScroller = null;
      
      protected var _rowCount:int = 5;
      
      protected var _columnCount:int = 1;
      
      protected var _enabled:Boolean = false;
      
      protected var _dataProvider:Array = null;
      
      protected var _itemRenderClass:Class = null;
      
      protected var _itemList:Array = null;
      
      protected var _currentLineIndex:int = 0;
      
      protected var _lineCount:int = 0;
      
      protected var _horizontalGap:Number = 0;
      
      protected var _verticalGap:Number = 1;
      
      protected var _itemHeight:Number = 0;
      
      protected var _itemWidth:Number = 0;
      
      private var _lastValue:Number = 0;
      
      protected var _itemCount:int = 0;
      
      protected var _offsetX:Number = 0;
      
      protected var _offsetY:Number = 0;
      
      protected var _dataIndex:int = 0;
      
      protected var _forceUpdate:Boolean = false;
      
      public function BasicScrollView(param1:DisplayObjectContainer, param2:int, param3:int = 1, param4:Number = 5, param5:Number = 5)
      {
         super();
         this._rowCount = param2;
         this._columnCount = param3;
         this._horizontalGap = param4;
         this._verticalGap = param5;
         this._listContainer = param1;
         this._container = new ViewContainer();
         this._container.name = "item_renderer_container";
         this._listContainer.addChild(this._container);
      }
      
      protected function initView() : void
      {
         this._itemList = [];
         var _loc1_:RendererWrapper = null;
         var _loc2_:int = 0;
         while(_loc2_ < this._itemCount)
         {
            _loc1_ = new RendererWrapper(this._itemRenderClass);
            _loc1_.index = _loc2_;
            this._itemList.push(_loc1_);
            _loc2_++;
         }
         this._itemHeight = _loc1_.height;
         this._itemWidth = _loc1_.width;
         var _loc3_:Number = this._columnCount * (this._itemWidth + this._horizontalGap) - this._horizontalGap;
         var _loc4_:Number = this._rowCount * (this._itemHeight + this._verticalGap) - this._verticalGap;
         var _loc5_:Shape = new Shape();
         var _loc6_:Graphics = _loc5_.graphics;
         _loc6_.beginFill(0,0);
         _loc6_.drawRect(0,0,_loc3_,_loc4_);
         _loc6_.endFill();
         _loc5_.name = "scroll_view_mask";
         this._container.width = _loc3_;
         this._container.height = _loc4_;
         _loc5_.x = this._offsetX;
         _loc5_.y = this._offsetY;
         if(this._container.parent)
         {
            this._container.parent.addChild(_loc5_);
         }
         this._container.mask = _loc5_;
      }
      
      protected function addListener() : void
      {
         if(this._scroller == null)
         {
            return;
         }
         this._scroller.addEventListener(Event.CHANGE,this.scrollHandler);
         this._scroller.addEventListener(ScrollEvent.START_SCROLLING,this.scrollingHandler);
         this._scroller.addEventListener(ScrollEvent.STOP_SCROLLING,this.scrollingHandler);
      }
      
      protected function removeListener() : void
      {
         if(this._scroller == null)
         {
            return;
         }
         this._scroller.removeEventListener(Event.CHANGE,this.scrollHandler);
         this._scroller.removeEventListener(ScrollEvent.START_SCROLLING,this.scrollingHandler);
         this._scroller.removeEventListener(ScrollEvent.STOP_SCROLLING,this.scrollingHandler);
      }
      
      protected function scrollingHandler(param1:Event) : void
      {
         switch(param1.type)
         {
            case ScrollEvent.START_SCROLLING:
               RendererWrapper.scrolling = true;
               break;
            case ScrollEvent.STOP_SCROLLING:
               RendererWrapper.scrolling = false;
         }
         if(param1 is ScrollEvent)
         {
            this._container.dispatchEvent(param1 as ScrollEvent);
         }
      }
      
      private function scrollHandler(param1:Event) : void
      {
         if(this._scroller == null)
         {
            return;
         }
         this._lastValue = this._scroller.value;
         this.startScrollRenderer();
      }
      
      protected function startScrollRenderer() : void
      {
      }
      
      protected function refreshDisplay() : void
      {
      }
      
      protected function adjustItemViewOrder(param1:Boolean) : void
      {
      }
      
      public function scrollTo(param1:int) : void
      {
         this._forceUpdate = true;
      }
      
      protected function caculateLineCount() : void
      {
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         this._enabled = param1;
         if(this._scroller)
         {
            this._scroller.enabled = this._enabled;
         }
         if(this._enabled)
         {
            this.addListener();
         }
         else
         {
            this.removeListener();
         }
      }
      
      public function get scroller() : IScroller
      {
         return this._scroller;
      }
      
      public function set scroller(param1:IScroller) : void
      {
         this._scroller = param1;
      }
      
      public function get dataProvider() : Array
      {
         return this._dataProvider;
      }
      
      public function set dataProvider(param1:Array) : void
      {
         this._forceUpdate = true;
         this._dataProvider = param1;
         if(this._dataProvider == null)
         {
            this._dataProvider = [];
         }
         this._currentLineIndex = 0;
         this.caculateLineCount();
         if(this._itemList == null)
         {
            this.initView();
         }
         if(this._scroller)
         {
            this._scroller.setCurrentLineCount(this._lineCount);
            this._scroller.value = 0;
         }
         this.refreshDisplay();
      }
      
      public function get itemRenderClass() : Class
      {
         return this._itemRenderClass;
      }
      
      public function set itemRenderClass(param1:Class) : void
      {
         this._itemRenderClass = param1;
         this.dataProvider = null;
      }
      
      public function get width() : Number
      {
         return (this._itemWidth + this._horizontalGap) * this._columnCount - this._horizontalGap;
      }
      
      public function get height() : Number
      {
         return (this._itemHeight + this._verticalGap) * this._rowCount - this._verticalGap;
      }
      
      public function get x() : Number
      {
         return this._offsetX;
      }
      
      public function set x(param1:Number) : void
      {
         this._offsetX = param1;
         if(this._container.x == 0)
         {
            this._container.x = param1;
         }
         var _loc2_:DisplayObject = this._container.mask;
         if(_loc2_)
         {
            _loc2_.x = this._offsetX - (_loc2_.scaleX - 1) / _loc2_.scaleX * _loc2_.width / 2;
         }
      }
      
      public function get y() : Number
      {
         return this._offsetY;
      }
      
      public function set y(param1:Number) : void
      {
         this._offsetY = param1;
         if(this._container.y == 0)
         {
            this._container.y = param1;
         }
         var _loc2_:DisplayObject = this._container.mask;
         if(_loc2_)
         {
            _loc2_.y = this._offsetY - (_loc2_.scaleY - 1) / _loc2_.scaleY * _loc2_.height / 2;
         }
      }
      
      public function get visible() : Boolean
      {
         return this._container.visible;
      }
      
      public function set visible(param1:Boolean) : void
      {
         this._container.visible = param1;
      }
      
      public function get mask() : DisplayObject
      {
         return this._container.mask;
      }
   }
}

