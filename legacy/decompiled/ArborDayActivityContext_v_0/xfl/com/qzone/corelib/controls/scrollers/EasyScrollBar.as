package com.qzone.corelib.controls.scrollers
{
   import com.qzone.corelib.controls.events.ScrollEvent;
   import com.qzone.corelib.controls.interfaces.IScroller;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   
   public class EasyScrollBar extends EventDispatcher implements IScroller
   {
      
      private static const DEFAULT_MAX_LINE_COUNT:int = 100;
      
      private var _max:Number = 0;
      
      private var _min:Number = 0;
      
      private var _maxLineCount:int = 100;
      
      private var _pageCount:int = 10;
      
      private var _scrollView:MovieClip = null;
      
      private var _dragBar:DragBar = null;
      
      private var _upScrollBtn:SimpleButton = null;
      
      private var _downScrollBtn:SimpleButton = null;
      
      private var _scrollTrack:MovieClip = null;
      
      private var _enabled:Boolean = false;
      
      private var _scrollArea:DisplayObjectContainer = null;
      
      private var _scrollSpeed:Number = 3;
      
      private var _wheelSpeed:Number = 3;
      
      private var _direction:int = 1;
      
      private var _isOnTrack:Boolean = false;
      
      private var _stage:Stage = null;
      
      private var _hideButtonMode:Boolean = false;
      
      private var _lineCount:int = 0;
      
      public function EasyScrollBar(param1:MovieClip, param2:int, param3:Boolean = false)
      {
         super();
         this._scrollView = param1;
         this._pageCount = param2;
         if(this._scrollView == null)
         {
            throw new ArgumentError("构造" + this + "的时候必须传入一个有效的素材！");
         }
         this._scrollView.mouseEnabled = false;
         this._dragBar = new DragBar(this._scrollView["dragBar"],param3);
         this._dragBar.visible = false;
         this._downScrollBtn = this._scrollView["downScrollBtn"];
         this._upScrollBtn = this._scrollView["upScrollBtn"];
         this._scrollTrack = this._scrollView["track"];
         this.height = this._scrollView.height;
         this._dragBar.y = this._min;
      }
      
      public function moveTo(param1:Number, param2:Number) : void
      {
         this._scrollView.x = param1;
         this._scrollView.y = param2;
      }
      
      private function addListener() : void
      {
         this._upScrollBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.downHandler);
         this._downScrollBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.downHandler);
         this._dragBar.addEventListener(MouseEvent.MOUSE_DOWN,this.barDownHandler);
         this._dragBar.addEventListener(MouseEvent.MOUSE_UP,this.barUpHandler);
         this._scrollTrack.addEventListener(MouseEvent.MOUSE_DOWN,this.trackDownHandler);
         if(this._scrollView.stage)
         {
            this.addToStageHandler(null);
            return;
         }
         this._scrollView.addEventListener(Event.ADDED_TO_STAGE,this.addToStageHandler);
      }
      
      private function addToStageHandler(param1:Event) : void
      {
         if(param1)
         {
            param1.currentTarget.removeEventListener(param1.type,arguments.callee);
         }
         this._stage = this._scrollView.stage;
         this._stage.addEventListener(MouseEvent.MOUSE_WHEEL,this.wheelHandler);
      }
      
      private function removeListener() : void
      {
         this._upScrollBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.downHandler);
         this._downScrollBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.downHandler);
         this._dragBar.removeEventListener(MouseEvent.MOUSE_DOWN,this.barDownHandler);
         this._dragBar.removeEventListener(MouseEvent.MOUSE_UP,this.barUpHandler);
         this._scrollTrack.removeEventListener(MouseEvent.MOUSE_DOWN,this.trackDownHandler);
         if(this._stage)
         {
            this._stage.removeEventListener(MouseEvent.MOUSE_WHEEL,this.wheelHandler);
         }
      }
      
      private function wheelHandler(param1:MouseEvent) : void
      {
         var _loc2_:DisplayObject = param1.target as DisplayObject;
         if(this._scrollView.contains(_loc2_) || Boolean(this._scrollArea) && Boolean(this._scrollArea.contains(_loc2_)))
         {
            this._direction = -param1.delta / Math.abs(param1.delta);
            this.renderHandler(null,this._wheelSpeed);
         }
      }
      
      private function trackDownHandler(param1:MouseEvent) : void
      {
         var _loc3_:Number = NaN;
         var _loc2_:DisplayObject = param1.target as DisplayObject;
         if(this._scrollTrack.contains(_loc2_))
         {
            this._isOnTrack = true;
            _loc3_ = this._scrollView.mouseY;
            if(_loc3_ > this._dragBar.y)
            {
               this._direction = 1;
            }
            else
            {
               this._direction = -1;
            }
            this.startRender();
            dispatchEvent(new ScrollEvent(ScrollEvent.START_SCROLLING));
         }
      }
      
      private function startRender() : void
      {
         this._stage.addEventListener(MouseEvent.MOUSE_UP,this.upHandler);
         this._scrollView.addEventListener(Event.ENTER_FRAME,this.renderHandler);
      }
      
      private function barUpHandler(param1:MouseEvent) : void
      {
         this._dragBar.stopDrag();
         this._scrollView.removeEventListener(Event.ENTER_FRAME,this.dragHandler);
         dispatchEvent(new ScrollEvent(ScrollEvent.STOP_SCROLLING));
      }
      
      private function barDownHandler(param1:MouseEvent) : void
      {
         var _loc2_:Rectangle = new Rectangle(this._dragBar.x,this._min,0,this._max - this._min);
         this._dragBar.startDrag(_loc2_);
         this._scrollView.addEventListener(Event.ENTER_FRAME,this.dragHandler);
         dispatchEvent(new ScrollEvent(ScrollEvent.START_SCROLLING));
      }
      
      private function dragHandler(param1:Event) : void
      {
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      private function downHandler(param1:MouseEvent) : void
      {
         var _loc2_:SimpleButton = param1.currentTarget as SimpleButton;
         if(_loc2_.name.indexOf("up") != -1)
         {
            this._direction = -1;
         }
         else
         {
            this._direction = 1;
         }
         this.startRender();
         dispatchEvent(new ScrollEvent(ScrollEvent.START_SCROLLING));
      }
      
      private function renderHandler(param1:Event, param2:Number = 0) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Number = NaN;
         if(param2 == 0)
         {
            param2 = this._scrollSpeed;
         }
         var _loc3_:Number = this._dragBar.y;
         _loc3_ += param2 * this._direction;
         if(this._isOnTrack)
         {
            if(this._direction == -1)
            {
               _loc4_ = Math.max(this._scrollView.mouseY,this._min);
               if(_loc3_ < _loc4_)
               {
                  _loc3_ = _loc4_;
               }
            }
            else if(this._direction == 1)
            {
               _loc5_ = Math.min(this._scrollView.mouseY,this._max);
               if(_loc3_ > _loc5_)
               {
                  _loc3_ = _loc5_;
               }
            }
         }
         if(_loc3_ < this._min)
         {
            _loc3_ = this._min;
         }
         else if(_loc3_ > this._max)
         {
            _loc3_ = this._max;
         }
         this._dragBar.y = _loc3_;
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      private function upHandler(param1:MouseEvent) : void
      {
         param1.currentTarget.removeEventListener(param1.type,arguments.callee);
         this._scrollView.removeEventListener(Event.ENTER_FRAME,this.renderHandler);
         this._isOnTrack = false;
         dispatchEvent(new ScrollEvent(ScrollEvent.STOP_SCROLLING));
      }
      
      private function initData() : void
      {
         this._min = this._upScrollBtn.y + this._upScrollBtn.height / 2;
         this._max = this._downScrollBtn.y - this._downScrollBtn.height / 2 - this._dragBar.height;
         this._max = Math.round(this._max);
         this._min = Math.round(this._min);
      }
      
      public function get x() : Number
      {
         return this._scrollView.x;
      }
      
      public function set x(param1:Number) : void
      {
         this._scrollView.x = param1;
      }
      
      public function get y() : Number
      {
         return this._scrollView.y;
      }
      
      public function set y(param1:Number) : void
      {
         this._scrollView.y = param1;
      }
      
      public function get height() : Number
      {
         return this._scrollView.height;
      }
      
      public function set height(param1:Number) : void
      {
         this._scrollTrack.height = param1;
         this._upScrollBtn.y = this._scrollTrack.y + this._upScrollBtn.height / 2;
         this._downScrollBtn.y = this._scrollTrack.y + this._scrollTrack.height - this._downScrollBtn.height / 2;
         this.initData();
      }
      
      public function get width() : Number
      {
         return this._scrollView.width;
      }
      
      public function get maxLineCount() : int
      {
         return this._maxLineCount;
      }
      
      public function set maxLineCount(param1:int) : void
      {
         this._maxLineCount = param1;
      }
      
      public function get pageCount() : int
      {
         return this._pageCount;
      }
      
      public function set pageCount(param1:int) : void
      {
         this._pageCount = param1;
      }
      
      public function setCurrentLineCount(param1:int) : void
      {
         this._lineCount = param1;
         if(this._lineCount <= this._pageCount)
         {
            this.enabled = false;
            this._dragBar.visible = false;
            if(this._hideButtonMode)
            {
               this._upScrollBtn.visible = this._downScrollBtn.visible = false;
            }
            return;
         }
         this.enabled = true;
         this._dragBar.visible = true;
         this._upScrollBtn.visible = this._downScrollBtn.visible = true;
         this._dragBar.y = this._scrollTrack.y + this._upScrollBtn.height;
         var _loc2_:Number = this._dragBar.minHeight;
         var _loc3_:Number = this._scrollTrack.height - this._upScrollBtn.height - this._downScrollBtn.height - _loc2_;
         var _loc4_:Number = Math.pow(this._dragBar.minHeight / (_loc3_ - _loc2_),1 / (this._maxLineCount - this._pageCount));
         var _loc5_:Number = (_loc3_ - _loc2_) * Math.pow(_loc4_,this._lineCount - this._pageCount);
         this._dragBar.height = _loc5_;
         this.initData();
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         this._enabled = param1;
         this._dragBar.mouseEnabled = this._enabled;
         if(this._enabled)
         {
            this.addListener();
            this._scrollView.mouseChildren = this._scrollView.mouseEnabled = true;
         }
         else
         {
            this.removeListener();
            this._scrollView.mouseChildren = this._scrollView.mouseEnabled = false;
         }
      }
      
      public function get scrollSpeed() : Number
      {
         return this._scrollSpeed;
      }
      
      public function set scrollSpeed(param1:Number) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         if(param1 > 100)
         {
            param1 = 100;
         }
         this._scrollSpeed = param1;
      }
      
      public function get scrollArea() : DisplayObjectContainer
      {
         return this._scrollArea;
      }
      
      public function set scrollArea(param1:DisplayObjectContainer) : void
      {
         this._scrollArea = param1;
      }
      
      public function get wheelSpeed() : Number
      {
         return this._wheelSpeed;
      }
      
      public function set wheelSpeed(param1:Number) : void
      {
         this._wheelSpeed = param1;
      }
      
      public function get value() : Number
      {
         return 100 * (this._dragBar.y - this._min) / (this._max - this._min);
      }
      
      public function set value(param1:Number) : void
      {
         if(param1 >= 100)
         {
            param1 = 99.9;
         }
         if(param1 < 0 || !param1)
         {
            param1 = 0;
         }
         this._dragBar.y = param1 * (this._max - this._min) / 100 + this._min;
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function get minBarHeight() : Number
      {
         return this._dragBar.minBarHeight;
      }
      
      public function set minBarHeight(param1:Number) : void
      {
         this._dragBar.minBarHeight = param1;
      }
      
      public function get hideButtonMode() : Boolean
      {
         return this._hideButtonMode;
      }
      
      public function set hideButtonMode(param1:Boolean) : void
      {
         this._upScrollBtn.visible = this._downScrollBtn.visible = this._lineCount > this._pageCount;
         this._hideButtonMode = param1;
      }
   }
}

