package com.qzone.qui.controls.scrollClasses
{
   import com.qzone.qui.controls.UIComponent;
   import com.qzone.qui.core.Direction;
   import com.qzone.qui.events.ScrollEvent;
   import com.qzone.qui.makers.ButtonMaker;
   import com.qzone.qui.styles.Style;
   import com.qzone.qui.utils.FrameTimer;
   import flash.display.InteractiveObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class ScrollBar extends UIComponent
   {
      
      public static var updateAfterEvent:Boolean;
      
      public var lineScrollSize:int = 1;
      
      private var downArrow:Sprite;
      
      private var _position:Number = 1;
      
      public var thumbIconSkin:Class;
      
      public var repeatInterval:int = 40;
      
      public var scrollMode:String = "pixel";
      
      private var _maxScrollPosition:Number = 1;
      
      private var stepArrow:InteractiveObject;
      
      private var _pageSize:Number = 1;
      
      private var lenProp:String;
      
      protected var _direction:String;
      
      public var downArrowSkin:Class;
      
      public var repeatDelay:int = 500;
      
      private var scrolled:Boolean;
      
      private var upArrow:Sprite;
      
      private var changed:Boolean;
      
      private var _scrollPercent:Number;
      
      private var _scrollPosition:Number = 0;
      
      private var selfLenProp:String;
      
      private var track:Sprite;
      
      public var upArrowSkin:Class;
      
      private var _bounds:Rectangle = new Rectangle();
      
      private var thumb:ScrollThumb;
      
      private var stepTimer:FrameTimer;
      
      public var pageScrollSize:Number = 5;
      
      private var posProp:String;
      
      public var trackSkin:Class;
      
      private var _force:Boolean;
      
      public var thumbSkin:Class;
      
      private var stagePosProp:String;
      
      public function ScrollBar()
      {
         super();
      }
      
      override protected function setSize() : void
      {
         if(this.thumb[this.posProp] == 0)
         {
            this._bounds[this.posProp] = this.upArrow[this.lenProp] - 1;
            this.thumb[this.posProp] = this._bounds[this.posProp];
         }
         if(_added)
         {
            this.track[this.lenProp] = this[this.selfLenProp];
            this.downArrow[this.posProp] = this[this.selfLenProp] - this.downArrow[this.lenProp];
         }
         this.contentChange();
      }
      
      override protected function setSkin() : void
      {
         this.track = new this.trackSkin();
         this.addChild(this.track);
         this.upArrow = new this.upArrowSkin();
         ButtonMaker.addTarget(this.upArrow);
         this.upArrow.useHandCursor = false;
         this.addChild(this.upArrow);
         this.downArrow = new this.downArrowSkin();
         ButtonMaker.addTarget(this.downArrow);
         this.downArrow.useHandCursor = false;
         this.addChild(this.downArrow);
         this.thumb = new ScrollThumb(this,this.thumbSkin,this.thumbIconSkin,this._direction);
         this.addChild(this.thumb);
      }
      
      private function contentChange() : void
      {
         this.setThumbSize();
         if(this._maxScrollPosition <= this._pageSize)
         {
            enabled = false;
         }
         else
         {
            enabled = true;
         }
      }
      
      private function addEvent() : void
      {
         this.track.addEventListener(MouseEvent.CLICK,this.thumbClick);
         this.thumb.addEventListener(MouseEvent.MOUSE_DOWN,this.thumbMouseDown);
         this.upArrow.addEventListener(MouseEvent.MOUSE_DOWN,this.arrowMouseDown);
         this.upArrow.addEventListener(MouseEvent.CLICK,this.arrowClick);
         this.downArrow.addEventListener(MouseEvent.MOUSE_DOWN,this.arrowMouseDown);
         this.downArrow.addEventListener(MouseEvent.CLICK,this.arrowClick);
      }
      
      private function changeNumber(param1:InteractiveObject) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(this.scrollMode == ScrollBarMode.LINE)
         {
            _loc3_ = Math.ceil(this._bounds[this.lenProp] / (this.maxScrollPosition - this.pageSize));
            _loc2_ = this.lineScrollSize * _loc3_;
         }
         else
         {
            _loc2_ = this.pageScrollSize;
         }
         if(param1 == this.upArrow)
         {
            this.thumbPosition -= _loc2_;
         }
         else if(param1 == this.downArrow)
         {
            this.thumbPosition += _loc2_;
         }
      }
      
      public function get maxScrollPosition() : Number
      {
         return this._maxScrollPosition;
      }
      
      override protected function setEnabled() : void
      {
         if(false == _enabled)
         {
            this.removeEvent();
            this.mouseEnabled = false;
            this.mouseChildren = false;
            this.filters = Style.getDisableFilter();
         }
         else
         {
            this.addEvent();
            this.mouseEnabled = true;
            this.mouseChildren = true;
            this.filters = Style.getRollOutFilter();
         }
      }
      
      public function get thumbPosition() : int
      {
         return this.thumb[this.posProp];
      }
      
      private function arrowMouseUp(param1:Event) : void
      {
         var _loc2_:InteractiveObject = param1.target as InteractiveObject;
         _loc2_.removeEventListener(MouseEvent.MOUSE_UP,this.arrowMouseUp);
         _loc2_.removeEventListener(MouseEvent.ROLL_OUT,this.arrowMouseUp);
         if(this.stepTimer)
         {
            this.stepTimer.stop();
            this.stepTimer.removeEventListener(TimerEvent.TIMER,this.arrowOnTimer);
            this.stepTimer = null;
            this.stepArrow = null;
         }
      }
      
      private function thumbMouseDown(param1:Event) : void
      {
         if(this.stage)
         {
            this.stage.addEventListener(MouseEvent.MOUSE_UP,this.thumbMouseUp);
            this.stage.addEventListener(MouseEvent.MOUSE_MOVE,this.thumbMouseMove);
            this.thumb.startDrag(false,this._bounds);
         }
      }
      
      public function get pageSize() : Number
      {
         return this._pageSize;
      }
      
      private function arrowClick(param1:Event) : void
      {
         var _loc2_:InteractiveObject = param1.target as InteractiveObject;
         this.changeNumber(_loc2_);
      }
      
      override protected function init() : void
      {
         if(this.direction == Direction.VERTICAL)
         {
            this.lenProp = "height";
            this.posProp = "y";
            this.stagePosProp = "stageY";
            this.selfLenProp = "_height";
         }
         else if(this.direction == Direction.HORIZONTAL)
         {
            this.lenProp = "width";
            this.posProp = "x";
            this.selfLenProp = "_width";
            this.stagePosProp = "stageX";
         }
         super.init();
      }
      
      public function set thumbPosition(param1:int) : void
      {
         if(param1 > this._bounds[this.lenProp] + this._bounds[this.posProp])
         {
            this.thumb[this.posProp] = this._bounds[this.lenProp] + this._bounds[this.posProp];
         }
         else if(param1 < this._bounds[this.posProp])
         {
            this.thumb[this.posProp] = this._bounds[this.posProp];
         }
         else
         {
            this.thumb[this.posProp] = param1;
         }
         delayCall(this.scrollChange);
      }
      
      public function set maxScrollPosition(param1:Number) : void
      {
         this._maxScrollPosition = param1;
         delayCall(this.contentChange);
      }
      
      private function setThumbSize() : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc1_:Number = this._pageSize / this._maxScrollPosition;
         if(_loc1_ >= 1 || isNaN(_loc1_))
         {
            if(this.thumb)
            {
               this.thumb.visible = false;
            }
         }
         else
         {
            _loc3_ = this[this.selfLenProp] - this.upArrow[this.lenProp] - this.downArrow[this.lenProp];
            _loc4_ = Math.max(Math.floor(_loc3_ * _loc1_),Style.ScrollBarMinSize);
            this._bounds[this.lenProp] = _loc3_ - _loc4_ + 2;
            if(this.thumb)
            {
               this.thumb.visible = true;
            }
         }
         var _loc2_:Number = Math.ceil(this._scrollPosition / (this._maxScrollPosition - this._pageSize) * this._bounds[this.lenProp]) + this._bounds[this.posProp];
         if(_loc2_ > this._bounds[this.lenProp] + this._bounds[this.posProp])
         {
            _loc2_ = this._bounds[this.lenProp] + this._bounds[this.posProp];
         }
         if(this.thumb)
         {
            this.thumb[this.posProp] = _loc2_;
         }
         this.thumb.setThumbSize(_loc4_);
      }
      
      public function set scrollPosition(param1:int) : void
      {
         this._scrollPosition = param1;
         this._force = true;
         this.contentChange();
         this.scrollChange();
      }
      
      public function get scrollPosition() : int
      {
         return this._scrollPosition;
      }
      
      public function set pageSize(param1:Number) : void
      {
         this._pageSize = param1;
         delayCall(this.contentChange);
      }
      
      private function thumbClick(param1:MouseEvent) : void
      {
         var _loc2_:Point = this.localToGlobal(new Point(this.x,this.y));
         var _loc3_:int = param1[this.stagePosProp] - _loc2_[this.posProp] - this.thumb[this.lenProp] / 2;
         if(_loc3_ < this.thumbPosition)
         {
            this.thumbPosition = _loc3_;
         }
         else
         {
            this.thumbPosition = _loc3_;
         }
      }
      
      public function setScrollProperties(param1:Number, param2:Number, param3:Number) : void
      {
         this._maxScrollPosition = param3;
         this._pageSize = param1;
         this._scrollPosition = param2;
         this._force = true;
         this.contentChange();
      }
      
      private function scrollChange() : void
      {
         var _loc2_:Number = NaN;
         var _loc1_:Number = (this.thumb[this.posProp] - this._bounds[this.posProp]) / this._bounds[this.lenProp];
         if(isNaN(_loc1_) == false && (this._force || _loc1_ != this._scrollPercent))
         {
            this._scrollPercent = _loc1_;
            _loc2_ = Math.floor(this._scrollPercent * (this._maxScrollPosition - this._pageSize));
            if(this._force || this._position != _loc2_)
            {
               if(_loc2_ < 0)
               {
                  _loc2_ = 0;
               }
               this._position = _loc2_;
               this.dispatchEvent(new ScrollEvent(ScrollEvent.SCROLL,null,_loc2_,this._direction));
               this._scrollPosition = this._position;
            }
            this._force = false;
         }
      }
      
      private function arrowMouseDown(param1:Event) : void
      {
         var _loc2_:InteractiveObject = param1.target as InteractiveObject;
         _loc2_.addEventListener(MouseEvent.MOUSE_UP,this.arrowMouseUp);
         _loc2_.addEventListener(MouseEvent.ROLL_OUT,this.arrowMouseUp);
         if(this.stepTimer == null)
         {
            FrameTimer.init(this);
            this.stepTimer = new FrameTimer(this.repeatDelay);
            this.stepTimer.addEventListener(TimerEvent.TIMER,this.arrowOnTimer);
         }
         this.stepArrow = _loc2_;
         this.stepTimer.stop();
         this.stepTimer.start();
      }
      
      private function thumbMouseMove(param1:MouseEvent) : void
      {
         delayCall(this.scrollChange);
         if(updateAfterEvent)
         {
            param1.updateAfterEvent();
         }
      }
      
      private function thumbMouseUp(param1:Event) : void
      {
         if(this.stage)
         {
            this.stage.removeEventListener(MouseEvent.MOUSE_UP,this.thumbMouseUp);
            this.stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.thumbMouseMove);
            this.thumb.stopDrag();
         }
      }
      
      private function arrowOnTimer(param1:Event) : void
      {
         this.changeNumber(this.stepArrow);
         param1.target.delay = this.repeatInterval;
      }
      
      private function removeEvent() : void
      {
         this.track.removeEventListener(MouseEvent.CLICK,this.thumbClick);
         this.thumb.removeEventListener(MouseEvent.MOUSE_DOWN,this.thumbMouseDown);
         this.upArrow.removeEventListener(MouseEvent.MOUSE_DOWN,this.arrowMouseDown);
         this.upArrow.removeEventListener(MouseEvent.CLICK,this.arrowClick);
         this.downArrow.removeEventListener(MouseEvent.MOUSE_DOWN,this.arrowMouseDown);
         this.downArrow.removeEventListener(MouseEvent.CLICK,this.arrowClick);
      }
      
      public function get direction() : String
      {
         return this._direction;
      }
   }
}

