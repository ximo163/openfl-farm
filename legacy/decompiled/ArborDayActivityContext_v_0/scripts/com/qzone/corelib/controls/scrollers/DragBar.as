package com.qzone.corelib.controls.scrollers
{
   import flash.display.DisplayObject;
   import flash.display.FrameLabel;
   import flash.display.MovieClip;
   import flash.display.Scene;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   
   public class DragBar extends EventDispatcher
   {
      
      private const ROLL_OVER:String = "over";
      
      private const ROLL_OUT:String = "out";
      
      private const MOUSE_DOWN:String = "down";
      
      private const DISABLED:String = "disabled";
      
      private var _barView:MovieClip = null;
      
      private var _top:MovieClip = null;
      
      private var _middle:MovieClip = null;
      
      private var _bottom:MovieClip = null;
      
      private var _line:MovieClip = null;
      
      private var _simpleMode:Boolean = false;
      
      private var _mouseEnabled:Boolean = false;
      
      private var _isMouseDown:Boolean = false;
      
      private var _minBarHeight:Number = 50;
      
      public function DragBar(param1:MovieClip, param2:Boolean = false)
      {
         super();
         this._barView = param1;
         this._barView.mouseChildren = false;
         this._simpleMode = param2;
         this.init();
      }
      
      private function init() : void
      {
         var _loc3_:String = null;
         if(this._simpleMode)
         {
            this.storeFrameList(this._barView);
            return;
         }
         var _loc1_:Array = ["top","middle","bottom","line"];
         var _loc2_:MovieClip = null;
         for each(_loc3_ in _loc1_)
         {
            _loc2_ = this._barView[_loc3_];
            if(_loc2_ != null)
            {
               _loc2_.stop();
               this.storeFrameList(_loc2_);
               this["_" + _loc3_] = _loc2_;
            }
         }
      }
      
      private function storeFrameList(param1:MovieClip) : void
      {
         var _loc4_:FrameLabel = null;
         var _loc2_:Array = [];
         var _loc3_:Scene = param1.scenes[0];
         for each(_loc4_ in _loc3_.labels)
         {
            _loc2_.push(_loc4_.name);
         }
         param1["list"] = _loc2_;
      }
      
      public function startDrag(param1:Rectangle = null) : void
      {
         this._barView.startDrag(false,param1);
      }
      
      public function stopDrag() : void
      {
         this._barView.stopDrag();
      }
      
      private function addListener() : void
      {
         this._barView.addEventListener(MouseEvent.ROLL_OVER,this.overHandler);
         this._barView.addEventListener(MouseEvent.ROLL_OUT,this.outHandler);
         this._barView.addEventListener(MouseEvent.MOUSE_DOWN,this.downHandler);
      }
      
      private function removeListener() : void
      {
         this._barView.removeEventListener(MouseEvent.ROLL_OVER,this.overHandler);
         this._barView.removeEventListener(MouseEvent.ROLL_OUT,this.outHandler);
         this._barView.removeEventListener(MouseEvent.MOUSE_DOWN,this.downHandler);
      }
      
      private function downHandler(param1:MouseEvent) : void
      {
         dispatchEvent(param1);
         this._isMouseDown = true;
         this.status = this.MOUSE_DOWN;
         this._barView.stage.addEventListener(MouseEvent.MOUSE_UP,this.upHandler);
      }
      
      private function upHandler(param1:MouseEvent) : void
      {
         param1.currentTarget.removeEventListener(param1.type,arguments.callee);
         dispatchEvent(param1);
         this._isMouseDown = false;
         var _loc3_:DisplayObject = param1.target as DisplayObject;
         if(this._barView.contains(_loc3_))
         {
            this.status = this.ROLL_OVER;
         }
         else
         {
            this.status = this.ROLL_OUT;
         }
      }
      
      private function outHandler(param1:MouseEvent) : void
      {
         this.status = this.ROLL_OUT;
      }
      
      private function overHandler(param1:MouseEvent) : void
      {
         if(this._isMouseDown)
         {
            this.status = this.MOUSE_DOWN;
            return;
         }
         this.status = this.ROLL_OVER;
      }
      
      private function set status(param1:String) : void
      {
         if(this._simpleMode)
         {
            this.setClipStopAt(this._barView,param1);
            return;
         }
         this.setClipStopAt(this._top,param1);
         this.setClipStopAt(this._middle,param1);
         this.setClipStopAt(this._bottom,param1);
      }
      
      private function setClipStopAt(param1:MovieClip, param2:String) : void
      {
         if(param1["list"].indexOf(param2) == -1)
         {
            return;
         }
         param1.gotoAndStop(param2);
      }
      
      public function get mouseEnabled() : Boolean
      {
         return this._mouseEnabled;
      }
      
      public function set mouseEnabled(param1:Boolean) : void
      {
         this._mouseEnabled = param1;
         if(!this._mouseEnabled)
         {
            this.status = this.DISABLED;
            this.removeListener();
         }
         else
         {
            this.status = this.ROLL_OUT;
            this.addListener();
         }
      }
      
      public function get height() : Number
      {
         return this._barView.height;
      }
      
      public function set height(param1:Number) : void
      {
         if(param1 < this._minBarHeight)
         {
            param1 = this._minBarHeight;
         }
         if(this._simpleMode)
         {
            this._barView.height = param1;
            return;
         }
         var _loc2_:Number = param1 - this._top.height - this._bottom.height;
         if(_loc2_ < 0)
         {
            _loc2_ = 0;
         }
         this._top.y = 0;
         this._middle.height = _loc2_;
         this._middle.y = this._top.y + this._top.height;
         this._bottom.y = this._middle.y + this._middle.height;
         if(this._line)
         {
            this._line.y = this._middle.y + (this._middle.height - this._line.height) / 2;
         }
      }
      
      public function get width() : Number
      {
         return this._barView.width;
      }
      
      public function get x() : Number
      {
         return this._barView.x;
      }
      
      public function set x(param1:Number) : void
      {
         this._barView.x = param1;
      }
      
      public function get y() : Number
      {
         return this._barView.y;
      }
      
      public function set y(param1:Number) : void
      {
         this._barView.y = param1;
      }
      
      public function get minHeight() : Number
      {
         if(this._simpleMode)
         {
            return this._minBarHeight;
         }
         var _loc1_:Number = this._top.height + this._bottom.height;
         if(this._minBarHeight < _loc1_)
         {
            return _loc1_;
         }
         return this._minBarHeight;
      }
      
      public function get visible() : Boolean
      {
         return this._barView.visible;
      }
      
      public function set visible(param1:Boolean) : void
      {
         this._barView.visible = param1;
      }
      
      public function get minBarHeight() : Number
      {
         return this._minBarHeight;
      }
      
      public function set minBarHeight(param1:Number) : void
      {
         this._minBarHeight = param1;
      }
   }
}

