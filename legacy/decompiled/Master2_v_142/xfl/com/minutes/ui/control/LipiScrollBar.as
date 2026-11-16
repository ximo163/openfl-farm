package com.minutes.ui.control
{
   import com.minutes.ui.constant.ScrollBarDirection;
   import com.minutes.ui.core.LipiContainer;
   import com.minutes.ui.core.LipiSkin;
   import com.minutes.ui.core.LipiUIComponent;
   import com.minutes.ui.core.UIEvent;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Rectangle;
   import flash.utils.Timer;
   
   public class LipiScrollBar extends LipiUIComponent
   {
      
      public static const SCROLL:String = "scrollEvent";
      
      private var _container:LipiContainer;
      
      private var _upButton:LipiUIComponent;
      
      private var _direction:String = ScrollBarDirection.VERTICAL;
      
      private var _downButton:LipiUIComponent;
      
      private var _trackBarTimer2:Timer;
      
      private var _heightChange:Boolean = false;
      
      private var _downSkin:Class;
      
      private var _trackBarTimer1:Timer;
      
      private var _trackBar:LipiUIComponent;
      
      private var _buttonHeightChange:Boolean = false;
      
      private var _thumbBar:ThumbBar;
      
      private var _visibleHeight:Number = 0;
      
      private var _pageHeight:Number = 0;
      
      private var timer:Timer = new Timer(250);
      
      private var oldHeight:Number;
      
      private var _pageHeightChange:Boolean = false;
      
      private var _widthChange:Boolean = false;
      
      private var _upSkin:Class;
      
      private var oldWidth:Number;
      
      private var _trackSkin:Class;
      
      private var _barIcon:Class;
      
      private var _barSkin:Class;
      
      private var _thumbIcon:Sprite;
      
      private var _buttonHeight:Number = 12;
      
      private var _visibleHeightChange:Boolean = false;
      
      public function LipiScrollBar()
      {
         super();
         this.init();
      }
      
      public function get buttonHeight() : Number
      {
         return this._buttonHeight;
      }
      
      public function set visibleHeight(param1:Number) : void
      {
         this._visibleHeight = param1;
         this._visibleHeightChange = true;
         invalidateDisplayList();
      }
      
      private function thumbBarMouseUp(param1:MouseEvent) : void
      {
         this._thumbBar.stopDrag();
         stage.removeEventListener(MouseEvent.MOUSE_UP,this.thumbBarMouseUp);
         removeEventListener(Event.ENTER_FRAME,this.thumbBarEnterFrame);
      }
      
      public function set direction(param1:String) : void
      {
         this._direction = param1;
         if(param1 == ScrollBarDirection.VERTICAL)
         {
            rotation = 0;
         }
         else
         {
            rotation = 270;
         }
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         super.updateDisplayList(param1,param2);
         if(this._widthChange)
         {
            this._downButton.width = this.width;
            this._upButton.width = this.width;
            this._trackBar.width = this.width;
            this._thumbBar.width = this.width;
         }
         if(this._heightChange)
         {
            this._downButton.y = this.height - this._downButton.height;
            this._trackBar.height = this.height;
         }
         if(this._buttonHeightChange)
         {
            this._upButton.height = this._buttonHeight;
            this._downButton.height = this._buttonHeight;
         }
         if(this._pageHeightChange || this._visibleHeightChange)
         {
            if(this.pageHeight != 0)
            {
               if(this.pageHeight < this.visibleHeight)
               {
                  this.pageHeight = this.visibleHeight;
               }
               this._thumbBar.height = this.visibleHeight / this.pageHeight * (this.height - this._upButton.height - this._downButton.height);
            }
         }
         this._pageHeightChange = true;
         this._visibleHeightChange = true;
         this._buttonHeightChange = true;
         this._widthChange = true;
         this._heightChange = true;
      }
      
      public function rollUp() : void
      {
         this.upButtonClick();
      }
      
      public function get container() : LipiContainer
      {
         return this._container;
      }
      
      public function set container(param1:LipiContainer) : void
      {
         this._container = param1;
         this.height = param1.height;
      }
      
      private function trackBarClickHandler(param1:MouseEvent) : void
      {
         this.trackBarMouseHandler();
      }
      
      public function get direction() : String
      {
         return this._direction;
      }
      
      private function init() : void
      {
         this.timer.start();
         this.oldWidth = this.width;
         this.oldHeight = this.height;
         this.bgAlpha = 0;
         this.width = 17;
         addEventListener(UIEvent.RESIZE,this.resizeHandler);
         this._barSkin = LipiScrollBarSkin.BarSkin;
         this._barIcon = LipiScrollBarSkin.BarIcon;
         this._upSkin = LipiScrollBarSkin.UpSkin;
         this._downSkin = LipiScrollBarSkin.DownSkin;
         this._trackSkin = LipiScrollBarSkin.TrackSkin;
         this.createTrackBar();
         this.createUpButton();
         this.createDownButton();
         this.createThumbBar();
         this.updateSkin();
      }
      
      private function thumbBarMouseDown(param1:MouseEvent) : void
      {
         var _loc2_:Number = Math.ceil(this.height - this._thumbBar.height - this._downButton.height - this._upButton.height);
         this._thumbBar.startDrag(false,new Rectangle(0,this._upButton.height,0,_loc2_));
         stage.addEventListener(MouseEvent.MOUSE_UP,this.thumbBarMouseUp);
         addEventListener(Event.ENTER_FRAME,this.thumbBarEnterFrame);
      }
      
      private function createDownButton() : void
      {
         this._downButton = new LipiUIComponent();
         this._downButton.addEventListener(MouseEvent.CLICK,this.downButtonClick);
         this._downButton.addEventListener(MouseEvent.MOUSE_DOWN,this.downButtonMouseDown);
         this._downButton.width = this.width;
         this._downButton.height = this.buttonHeight;
         this._downButton.x = 0;
         this._downButton.y = this.height - this._downButton.height;
         addChild(this._downButton);
      }
      
      public function get maxScrollPosition() : int
      {
         return this.height - this._downButton.height - this._thumbBar.height - this._upButton.height;
      }
      
      private function downButtonMouseUp(param1:Event) : void
      {
         this.timer.removeEventListener(TimerEvent.TIMER,this.downButtonTimer);
      }
      
      public function get scrollPosition() : Number
      {
         return this._thumbBar.y - this._upButton.height;
      }
      
      private function upButtonTimer(param1:TimerEvent) : void
      {
         this.upButtonClick();
      }
      
      public function get pageHeight() : Number
      {
         return this._pageHeight;
      }
      
      public function set buttonHeight(param1:Number) : void
      {
         this._buttonHeight = param1;
         this._buttonHeightChange = true;
         invalidateDisplayList();
      }
      
      public function enforceScrollPosition(param1:Number) : void
      {
         var _loc2_:Number = param1 * (this.height - this._upButton.height - this._downButton.height);
         this._thumbBar.y = _loc2_ + this._upButton.height;
      }
      
      private function downButtonTimer(param1:TimerEvent) : void
      {
         this.downButtonClick();
      }
      
      private function thumbBarEnterFrame(param1:Event) : void
      {
         this.scrollPosition = this.scrollPosition;
      }
      
      public function get visibleHeight() : Number
      {
         return this._visibleHeight;
      }
      
      private function upButtonMouseDown(param1:MouseEvent) : void
      {
         stage.addEventListener(MouseEvent.MOUSE_UP,this.upButtonMouseUp);
         this.timer.addEventListener(TimerEvent.TIMER,this.upButtonTimer);
      }
      
      public function set scrollPosition(param1:Number) : void
      {
         this._thumbBar.y = param1 + this._upButton.height;
         var _loc2_:UIEvent = new UIEvent(LipiScrollBar.SCROLL);
         _loc2_.data = param1 / (this.height - this._upButton.height - this._downButton.height);
         dispatchEvent(_loc2_);
      }
      
      private function trackBarMouse(param1:Event = null) : void
      {
         this._trackBarTimer2 = new Timer(150);
         this._trackBarTimer2.addEventListener(TimerEvent.TIMER,this.trackBarMouseHandler);
         this._trackBarTimer2.start();
      }
      
      public function rollDown() : void
      {
         this.downButtonClick();
      }
      
      private function upButtonMouseUp(param1:Event) : void
      {
         this.timer.removeEventListener(TimerEvent.TIMER,this.upButtonTimer);
      }
      
      private function createUpButton() : void
      {
         this._upButton = new LipiUIComponent();
         this._upButton.addEventListener(MouseEvent.CLICK,this.upButtonClick);
         this._upButton.addEventListener(MouseEvent.MOUSE_DOWN,this.upButtonMouseDown);
         this._upButton.width = this.width;
         this._upButton.height = this.buttonHeight;
         this._upButton.x = 0;
         this._upButton.y = 0;
         addChild(this._upButton);
      }
      
      private function trackBarMouseHandler(param1:Event = null) : void
      {
         var _loc2_:Number = mouseY;
         if(_loc2_ > this._thumbBar.y && _loc2_ < this._thumbBar.y + this._thumbBar.height)
         {
            return;
         }
         if(_loc2_ < this._thumbBar.y)
         {
            if(this.scrollPosition - this._thumbBar.height > 0)
            {
               this.scrollPosition -= this._thumbBar.height;
            }
            else
            {
               this.scrollPosition = 0;
            }
         }
         else if(this.scrollPosition + this._thumbBar.height > this.height - this._downButton.height - this._thumbBar.height - this._upButton.height)
         {
            this.scrollPosition = this.height - this._downButton.height - this._thumbBar.height - this._upButton.height;
         }
         else
         {
            this.scrollPosition += this._thumbBar.height;
         }
      }
      
      public function set trackSkin(param1:Class) : void
      {
         this._trackSkin = param1;
      }
      
      private function downButtonMouseDown(param1:MouseEvent) : void
      {
         stage.addEventListener(MouseEvent.MOUSE_UP,this.downButtonMouseUp);
         this.timer.addEventListener(TimerEvent.TIMER,this.downButtonTimer);
      }
      
      public function set barIcon(param1:Class) : void
      {
         this._barIcon = param1;
      }
      
      public function set pageHeight(param1:Number) : void
      {
         this._pageHeight = param1;
         this._pageHeightChange = true;
         invalidateDisplayList();
      }
      
      private function upButtonClick(param1:MouseEvent = null) : void
      {
         if(this._thumbBar.y - this._upButton.height - this._thumbBar.height / 10 > 0)
         {
            this.scrollPosition -= this._thumbBar.height / 10;
         }
         else
         {
            this.scrollPosition = 0;
         }
      }
      
      private function createTrackBar() : void
      {
         this._trackBar = new LipiUIComponent();
         this._trackBar.addEventListener(MouseEvent.CLICK,this.trackBarClickHandler);
         this._trackBar.addEventListener(MouseEvent.MOUSE_DOWN,this.trackBarMouseDown);
         this._trackBar.width = this.width;
         this._trackBar.height = this.height;
         this._trackBar.x = 0;
         this._trackBar.y = 0;
         addChild(this._trackBar);
      }
      
      public function updateSkin() : void
      {
         if(this._trackSkin == null)
         {
            this._trackBar.bgColor = 15658734;
            this._trackBar.bgAlpha = 0.5;
         }
         else
         {
            this._trackBar.bgAlpha = 0;
            this._trackBar.bgSkin = new LipiSkin(this._trackSkin);
         }
         if(this._upSkin == null)
         {
            this._upButton.bgColor = 10027008;
         }
         else
         {
            this._upButton.bgAlpha = 0;
            this._upButton.bgSkin = new LipiSkin(this._upSkin);
         }
         if(this._downSkin == null)
         {
            this._downButton.bgColor = 10027008;
         }
         else
         {
            this._downButton.bgAlpha = 0;
            this._downButton.bgSkin = new LipiSkin(this._downSkin);
         }
         if(this._barSkin == null)
         {
            this._thumbBar.bgColor = 16711680;
         }
         else
         {
            this._thumbBar.bgAlpha = 0;
            this._thumbBar.bgSkin = new LipiSkin(this._barSkin);
         }
         if(this._barIcon != null)
         {
            this._thumbBar.iconSkin = this._barIcon;
         }
      }
      
      public function set barSkin(param1:Class) : void
      {
         this._barSkin = param1;
      }
      
      public function set upSkin(param1:Class) : void
      {
         this._upSkin = param1;
      }
      
      private function trackBarMouseUpHandler(param1:MouseEvent) : void
      {
         stage.removeEventListener(MouseEvent.MOUSE_UP,this.trackBarMouseUpHandler);
         if(this._trackBarTimer1 != null)
         {
            this._trackBarTimer1.removeEventListener(TimerEvent.TIMER,this.trackBarMouse);
            this._trackBarTimer1.stop();
            this._trackBarTimer1 = null;
         }
         if(this._trackBarTimer2 != null)
         {
            this._trackBarTimer2.removeEventListener(TimerEvent.TIMER,this.trackBarMouseHandler);
            this._trackBarTimer2.stop();
            this._trackBarTimer2 = null;
         }
      }
      
      private function downButtonClick(param1:MouseEvent = null) : void
      {
         if(this._thumbBar.y + this._thumbBar.height / 10 < this.height - this._downButton.height - this._thumbBar.height)
         {
            this.scrollPosition += this._thumbBar.height / 10;
         }
         else
         {
            this.scrollPosition = this.height - this._downButton.height - this._thumbBar.height - this._upButton.height;
         }
      }
      
      private function resizeHandler(param1:UIEvent) : void
      {
         if(this.height != this.oldHeight)
         {
            this._heightChange = true;
            this.oldHeight = this.height;
            invalidateDisplayList();
         }
         if(this.width != this.oldWidth)
         {
            this._widthChange = true;
            this.oldWidth = this.width;
            invalidateDisplayList();
         }
      }
      
      private function createThumbBar() : void
      {
         this._thumbBar = new ThumbBar();
         this._thumbBar.addEventListener(MouseEvent.MOUSE_DOWN,this.thumbBarMouseDown);
         this._thumbBar.width = this.width;
         this._thumbBar.height = this.height - this._upButton.height - this._downButton.height;
         this._thumbBar.x = 0;
         this._thumbBar.y = this._upButton.height;
         addChild(this._thumbBar);
      }
      
      public function set downSkin(param1:Class) : void
      {
         this._downSkin = param1;
      }
      
      private function trackBarMouseDown(param1:MouseEvent) : void
      {
         this._trackBarTimer1 = new Timer(300,1);
         this._trackBarTimer1.addEventListener(TimerEvent.TIMER,this.trackBarMouse);
         this._trackBarTimer1.start();
         stage.addEventListener(MouseEvent.MOUSE_UP,this.trackBarMouseUpHandler);
      }
   }
}

import com.minutes.ui.core.LipiUIComponent;
import com.minutes.ui.core.UIEvent;
import flash.display.Sprite;

class ThumbBar extends LipiUIComponent
{
   
   private var iconButton:Sprite;
   
   public function ThumbBar()
   {
      super();
      addEventListener(UIEvent.RESIZE,this.thumbBarResize);
   }
   
   private function thumbBarResize(param1:UIEvent) : void
   {
      if(this.iconButton != null)
      {
         this.iconButton.width = this.width;
         this.iconButton.height = this.width;
         this.iconButton.x = 0;
         this.iconButton.y = (this.height - this.iconButton.height) / 2;
         if(this.height < this.width)
         {
            this.iconButton.visible = false;
         }
      }
   }
   
   public function set iconSkin(param1:Class) : void
   {
      if(param1 == null && this.iconButton != null)
      {
         removeChild(this.iconButton);
         this.iconButton = null;
      }
      else
      {
         if(this.iconButton == null)
         {
            this.iconButton = new param1();
         }
         this.iconButton.width = this.width;
         this.iconButton.height = this.width;
         this.iconButton.x = 0;
         this.iconButton.y = (this.height - this.iconButton.height) / 2;
         trace(this.iconButton.x,this.iconButton.y);
         addChild(this.iconButton);
      }
   }
}
