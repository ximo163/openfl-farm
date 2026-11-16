package com.minutes.ui.core
{
   import com.minutes.ui.constant.ScrollBarDirection;
   import com.minutes.ui.constant.ScrollPolicy;
   import com.minutes.ui.control.LipiScrollBar;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   
   public class LipiContainer extends LipiUIComponent
   {
      
      private var _vBarWidth:int = 17;
      
      private var _sSkin:ScrollBarSkin;
      
      private var _horizontalScrollPolicyChange:Boolean = false;
      
      private var _clipContentChange:Boolean = false;
      
      private var _verticalScrollPolicyChange:Boolean = false;
      
      private var _sizeChange:Boolean = false;
      
      public var verticalScrollBar:LipiScrollBar;
      
      private var _contentPane:Sprite = null;
      
      public var horizontalScrollBar:LipiScrollBar;
      
      private var _clipContent:Boolean = true;
      
      private var _mask:Sprite = new Sprite();
      
      private var _hBarWidthChange:Boolean = false;
      
      private var _horizontalScrollPolicy:int = 2;
      
      private var _verticalScrollPolicy:int = 2;
      
      private var _vBarWidthChange:Boolean = false;
      
      private var childChange:Boolean = false;
      
      private var _contentPaneSizeChange:Boolean = false;
      
      private var _hBarWidth:int = 17;
      
      public function LipiContainer()
      {
         super();
         this.init();
      }
      
      public function get contentPane() : Sprite
      {
         return this._contentPane;
      }
      
      override public function getChildByName(param1:String) : DisplayObject
      {
         if(this._contentPane == null)
         {
            return null;
         }
         return this._contentPane.getChildByName(param1);
      }
      
      public function get vBarWidth() : int
      {
         return this._vBarWidth;
      }
      
      override public function getChildIndex(param1:DisplayObject) : int
      {
         if(this._contentPane == null)
         {
            return -1;
         }
         return this._contentPane.getChildIndex(param1);
      }
      
      private function _setBarSkin() : void
      {
         if(this._sSkin == null)
         {
            return;
         }
         if(this.verticalScrollBar != null)
         {
            if(this._sSkin.trackSkin != null)
            {
               this.verticalScrollBar.trackSkin = this._sSkin.trackSkin;
            }
            if(this._sSkin.upSkin != null)
            {
               this.verticalScrollBar.upSkin = this._sSkin.upSkin;
            }
            if(this._sSkin.downSkin != null)
            {
               this.verticalScrollBar.downSkin = this._sSkin.downSkin;
            }
            if(this._sSkin.barSkin != null)
            {
               this.verticalScrollBar.barSkin = this._sSkin.barSkin;
            }
            if(this._sSkin.barIcon != null)
            {
               this.verticalScrollBar.barIcon = this._sSkin.barIcon;
            }
            this.verticalScrollBar.updateSkin();
         }
         if(this.horizontalScrollBar != null)
         {
            if(this._sSkin.barIcon != null)
            {
               this.horizontalScrollBar.trackSkin = this._sSkin.trackSkin;
            }
            if(this._sSkin.upSkin != null)
            {
               this.horizontalScrollBar.upSkin = this._sSkin.upSkin;
            }
            if(this._sSkin.downSkin != null)
            {
               this.horizontalScrollBar.downSkin = this._sSkin.downSkin;
            }
            if(this._sSkin.barSkin != null)
            {
               this.horizontalScrollBar.barSkin = this._sSkin.barSkin;
            }
            if(this._sSkin.barIcon != null)
            {
               this.horizontalScrollBar.barIcon = this._sSkin.barIcon;
            }
            this.horizontalScrollBar.updateSkin();
         }
      }
      
      override public function addChildAt(param1:DisplayObject, param2:int) : DisplayObject
      {
         if(this._contentPane == null)
         {
            return null;
         }
         this._contentPane.addChildAt(param1,param2);
         this._contentPaneSizeChange = true;
         invalidateDisplayList();
         return param1;
      }
      
      private function addVerticalScrollBar() : void
      {
         this.verticalScrollBar = new LipiScrollBar();
         this.verticalScrollBar.addEventListener(LipiScrollBar.SCROLL,this.verticalScroll);
         this.verticalScrollBar.visible = false;
         this.verticalScrollBar.container = this;
         this.verticalScrollBar.updateSkin();
         super.addChild(this.verticalScrollBar);
         this._setBarSkin();
      }
      
      private function init() : void
      {
         this._contentPane = new Sprite();
         this._contentPane.x = 0;
         this._contentPane.y = 0;
         super.addChild(this._contentPane);
         this._mask = new Sprite();
         this._mask.x = 0;
         this._mask.y = 0;
         super.addChild(this._mask);
         this._contentPane.mask = this._mask;
         this._clipContentChange = true;
         this._verticalScrollPolicyChange = true;
         this._horizontalScrollPolicyChange = true;
         this._contentPaneSizeChange = true;
         this._sizeChange = true;
         invalidateDisplayList();
         addEventListener(UIEvent.RESIZE,this.onResize);
         addEventListener(MouseEvent.MOUSE_WHEEL,this.mouseWheelHandler);
         this.graphics.beginFill(0,0.5);
         this.graphics.drawRect(0,0,this.width,this.height);
         addEventListener(MouseEvent.MOUSE_OVER,this.scrollOver);
         addEventListener(MouseEvent.MOUSE_OUT,this.scrollOut);
      }
      
      public function set vBarWidth(param1:int) : void
      {
         this._vBarWidth = param1;
         this._vBarWidthChange = true;
         invalidateDisplayList();
      }
      
      public function get verticalScrollVisible() : Boolean
      {
         if(this.verticalScrollBar == null)
         {
            return false;
         }
         return this.verticalScrollBar.visible;
      }
      
      private function horizontalScroll(param1:UIEvent) : void
      {
         this._contentPane.x = Number(param1.data) * this._contentPane.width * -1;
      }
      
      public function get horizontalScrollVisible() : Boolean
      {
         if(this.horizontalScrollBar == null)
         {
            return false;
         }
         return this.horizontalScrollBar.visible;
      }
      
      public function get horizontalScrollPolicy() : int
      {
         return this._horizontalScrollPolicy;
      }
      
      override public function get numChildren() : int
      {
         return this._contentPane.numChildren;
      }
      
      public function set clipContent(param1:Boolean) : void
      {
         this._clipContent = param1;
         this._clipContentChange = true;
         invalidateDisplayList();
      }
      
      public function get vScrollPosition() : Number
      {
         if(this.verticalScrollBar != null)
         {
            return this.verticalScrollBar.scrollPosition;
         }
         return 0;
      }
      
      private function resizeScrollBar() : void
      {
         if(this.verticalScrollPolicy == ScrollPolicy.OFF || this._clipContent == false)
         {
            if(this.verticalScrollBar != null)
            {
               this.verticalScrollBar.visible = false;
            }
         }
         else if(this.verticalScrollPolicy == ScrollPolicy.AUTO && this.height >= this._contentPane.height)
         {
            if(this.verticalScrollBar != null)
            {
               this.verticalScrollBar.visible = false;
            }
         }
         else
         {
            if(this.verticalScrollBar == null)
            {
               this.addVerticalScrollBar();
            }
            this.verticalScrollBar.visible = true;
            this.verticalScrollBar.width = this._vBarWidth;
            this.verticalScrollBar.x = this.width - this.verticalScrollBar.width;
            this.verticalScrollBar.y = 0;
            this.verticalScrollBar.visibleHeight = this.height;
            this.verticalScrollBar.pageHeight = this._contentPane.height;
         }
         if(this.horizontalScrollPolicy == ScrollPolicy.OFF || this._clipContent == false)
         {
            if(this.horizontalScrollBar != null)
            {
               this.horizontalScrollBar.visible = false;
            }
         }
         else if(this.horizontalScrollPolicy == ScrollPolicy.AUTO && this.width >= this._contentPane.width)
         {
            if(this.horizontalScrollBar != null)
            {
               this.horizontalScrollBar.visible = false;
            }
         }
         else
         {
            if(this.horizontalScrollBar == null)
            {
               this.addHorizontalScrollBar();
            }
            this.horizontalScrollBar.visible = true;
            this.horizontalScrollBar.width = this._hBarWidth;
            this.horizontalScrollBar.x = 0;
            this.horizontalScrollBar.y = this.height;
            this.horizontalScrollBar.visibleHeight = this.width;
            this.horizontalScrollBar.pageHeight = this._contentPane.width;
         }
         if(this.horizontalScrollBar != null && this.horizontalScrollBar.visible == true)
         {
            if(this.verticalScrollBar != null)
            {
               this.verticalScrollBar.height = this.height - this.verticalScrollBar.width;
            }
         }
         else if(this.verticalScrollBar != null)
         {
            this.verticalScrollBar.height = this.height;
         }
         if(this.verticalScrollBar != null && this.verticalScrollBar.visible == true)
         {
            if(this.horizontalScrollBar != null)
            {
               this.horizontalScrollBar.height = this.width - this.horizontalScrollBar.width;
            }
         }
         else if(this.horizontalScrollBar != null)
         {
            this.horizontalScrollBar.height = this.width;
         }
      }
      
      public function get clipContent() : Boolean
      {
         return this._clipContent;
      }
      
      public function setHBarWidth(param1:int) : void
      {
         this._hBarWidth = param1;
         this._vBarWidthChange = true;
         invalidateDisplayList();
      }
      
      private function mouseWheelHandler(param1:MouseEvent) : void
      {
         if(this.verticalScrollBar == null || this.verticalScrollBar.visible == false)
         {
            return;
         }
         if(param1.delta > 0)
         {
            this.verticalScrollBar.rollUp();
         }
         else
         {
            this.verticalScrollBar.rollDown();
         }
      }
      
      override public function getChildAt(param1:int) : DisplayObject
      {
         if(this._contentPane == null)
         {
            return null;
         }
         return this._contentPane.getChildAt(param1);
      }
      
      private function scrollOut(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         try
         {
            ExternalInterface.call("isRoll",true);
         }
         catch(e:Error)
         {
         }
      }
      
      public function set horizontalScrollPolicy(param1:int) : void
      {
         if(param1 > 3 || param1 < 0)
         {
            param1 = 3;
         }
         this._horizontalScrollPolicy = param1;
         this._horizontalScrollPolicyChange = true;
         invalidateDisplayList();
      }
      
      private function scrollOver(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         try
         {
            ExternalInterface.call("isRoll",false);
         }
         catch(e:Error)
         {
         }
      }
      
      override public function removeChildAt(param1:int) : DisplayObject
      {
         if(this._contentPane == null)
         {
            return null;
         }
         var _loc2_:DisplayObject = this._contentPane.removeChildAt(param1);
         this._contentPaneSizeChange = true;
         invalidateDisplayList();
         return _loc2_;
      }
      
      public function set vScrollPosition(param1:Number) : void
      {
         if(this.verticalScrollBar != null)
         {
            this.verticalScrollBar.scrollPosition = param1;
         }
      }
      
      private function addHorizontalScrollBar() : void
      {
         this.horizontalScrollBar = new LipiScrollBar();
         this.horizontalScrollBar.direction = ScrollBarDirection.HORIZONTAL;
         this.horizontalScrollBar.addEventListener(LipiScrollBar.SCROLL,this.horizontalScroll);
         this.horizontalScrollBar.visible = false;
         this.horizontalScrollBar.container = this;
         super.addChild(this.horizontalScrollBar);
         this._setBarSkin();
      }
      
      private function verticalScroll(param1:UIEvent) : void
      {
         this._contentPane.y = Number(param1.data) * this._contentPane.height * -1;
      }
      
      public function set verticalScrollPolicy(param1:int) : void
      {
         if(param1 > 3 || param1 < 0)
         {
            param1 = 3;
         }
         this._verticalScrollPolicy = param1;
         this._verticalScrollPolicyChange = true;
         invalidateDisplayList();
      }
      
      public function setBarSkin(param1:Class, param2:Class, param3:Class, param4:Class, param5:Class = null) : void
      {
         if(this._sSkin == null)
         {
            this._sSkin = new ScrollBarSkin();
         }
         this._sSkin.trackSkin = param1;
         this._sSkin.upSkin = param2;
         this._sSkin.downSkin = param3;
         this._sSkin.barSkin = param4;
         this._sSkin.barIcon = param5;
         this._setBarSkin();
      }
      
      public function resetSize() : void
      {
         this._contentPaneSizeChange = true;
         invalidateDisplayList();
      }
      
      public function get verticalScrollPolicy() : int
      {
         return this._verticalScrollPolicy;
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         var _loc3_:Boolean = false;
         if(this._clipContentChange == true)
         {
            if(this._clipContent == true)
            {
               this._mask.visible = true;
               this._contentPane.mask = this._mask;
            }
            else
            {
               this._mask.visible = false;
               this._contentPane.mask = null;
            }
            _loc3_ = true;
         }
         if(this._verticalScrollPolicyChange == true)
         {
            _loc3_ = true;
         }
         else if(this._horizontalScrollPolicyChange == true)
         {
            _loc3_ = true;
         }
         else if(this._contentPaneSizeChange == true)
         {
            _loc3_ = true;
         }
         if(this._sizeChange == true)
         {
            this._mask.graphics.clear();
            this._mask.graphics.beginFill(0);
            this._mask.graphics.drawRect(0,0,width,height);
            _loc3_ = true;
         }
         if(this._vBarWidthChange || this._hBarWidthChange)
         {
            _loc3_ = true;
            this._vBarWidthChange = false;
            this._hBarWidthChange = false;
         }
         if(_loc3_ == true)
         {
            this.resizeScrollBar();
         }
         this._clipContentChange = false;
         this._verticalScrollPolicyChange = false;
         this._horizontalScrollPolicyChange = false;
         this._contentPaneSizeChange = false;
         this._sizeChange = false;
         super.updateDisplayList(param1,param2);
      }
      
      private function onResize(param1:UIEvent) : void
      {
         this._sizeChange = true;
         invalidateDisplayList();
      }
      
      override public function addChild(param1:DisplayObject) : DisplayObject
      {
         if(this._contentPane == null)
         {
            return null;
         }
         this._contentPane.addChild(param1);
         this._contentPaneSizeChange = true;
         invalidateDisplayList();
         return param1;
      }
      
      public function removeAll() : void
      {
         if(this._contentPane == null)
         {
            return;
         }
         while(this._contentPane.numChildren > 0)
         {
            this._contentPane.removeChildAt(0);
         }
         this._contentPaneSizeChange = true;
         invalidateDisplayList();
      }
      
      override public function removeChild(param1:DisplayObject) : DisplayObject
      {
         if(this._contentPane == null)
         {
            return null;
         }
         this._contentPane.removeChild(param1);
         this._contentPaneSizeChange = true;
         invalidateDisplayList();
         return param1;
      }
   }
}

class ScrollBarSkin
{
   
   public var barSkin:Class;
   
   public var downSkin:Class;
   
   public var trackSkin:Class;
   
   public var barIcon:Class;
   
   public var upSkin:Class;
   
   public function ScrollBarSkin()
   {
      super();
   }
}
