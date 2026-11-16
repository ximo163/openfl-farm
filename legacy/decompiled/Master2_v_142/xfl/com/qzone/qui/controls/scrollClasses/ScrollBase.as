package com.qzone.qui.controls.scrollClasses
{
   import com.qzone.qui.controls.HScrollBar;
   import com.qzone.qui.controls.UIComponent;
   import com.qzone.qui.controls.VScrollBar;
   import com.qzone.qui.core.Direction;
   import com.qzone.qui.events.ScrollEvent;
   import com.qzone.qui.styles.Style;
   import com.qzone.qui.utils.EventUtil;
   import com.qzone.utils.AlignUtil;
   import flash.display.DisplayObjectContainer;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   
   public class ScrollBase extends UIComponent
   {
      
      protected var _maxScrollPositionH:Number = 0;
      
      protected var hScrollMode:String;
      
      protected var _pageSizeH:Number = 0;
      
      public var borderSizeH:int;
      
      protected var _maxScrollPositionV:Number = 0;
      
      protected var vScrollMode:String;
      
      protected var _pageSizeV:Number = 0;
      
      public var borderSizeV:int;
      
      protected var _scrollPositionH:Number = 0;
      
      public var vScrollBar:VScrollBar;
      
      protected var _scrollPositionV:Number = 0;
      
      protected var _content:DisplayObjectContainer;
      
      public var paddingH:int;
      
      protected var _scrollH:int;
      
      public var paddingV:int;
      
      protected var _hScrollPolicy:String = "auto";
      
      protected var _scrollW:int;
      
      protected var _scrollRect:Rectangle;
      
      protected var _vScrollPolicy:String = "auto";
      
      public var hScrollBar:HScrollBar;
      
      public function ScrollBase()
      {
         super();
         this._scrollRect = new Rectangle(0,0,_width - this._scrollW - this.borderSizeH * 2,_height - this._scrollH - this.borderSizeV * 2);
      }
      
      protected function get contentHeight() : Number
      {
         if(this._content.scrollRect)
         {
            return this._content.transform.pixelBounds.height;
         }
         return this._content.height;
      }
      
      override protected function setSize() : void
      {
         if(this.vScrollBar)
         {
            this.vScrollBar.height = _height;
            this.vScrollBar.x = AlignUtil.right(_width,this.vScrollBar.width);
            if(this.vScrollMode == ScrollBarMode.LINE)
            {
               this.vScrollBar.pageSize = this._pageSizeV;
            }
            else
            {
               this.vScrollBar.pageSize = _height - this._scrollH;
            }
         }
         if(this.hScrollBar)
         {
            this.hScrollBar.width = _width;
            this.hScrollBar.y = AlignUtil.right(_height,this.hScrollBar.height);
            if(this.hScrollMode == ScrollBarMode.LINE)
            {
               this.hScrollBar.pageSize = this._pageSizeH;
            }
            else
            {
               this.hScrollBar.pageSize = _width - this._scrollW;
            }
         }
         this.updateScrollRect();
         this.scrollBarChange();
      }
      
      override protected function init() : void
      {
         super.init();
      }
      
      private function showHScroll() : void
      {
         if(this.hScrollBar == null)
         {
            this.hScrollBar = new HScrollBar();
            this.hScrollBar.addEventListener(ScrollEvent.SCROLL,this._scroll);
            this.hScrollBar.scrollMode = this.hScrollMode;
            super.addChild(this.hScrollBar);
         }
         this.hScrollBar.visible = true;
      }
      
      public function get horizontalScrollPolicy() : String
      {
         return this._hScrollPolicy;
      }
      
      private function showVScroll() : void
      {
         if(this.vScrollBar == null)
         {
            this.vScrollBar = new VScrollBar();
            this.vScrollBar.addEventListener(ScrollEvent.SCROLL,this._scroll);
            this.vScrollBar.scrollMode = this.vScrollMode;
            super.addChild(this.vScrollBar);
         }
         this.vScrollBar.visible = true;
      }
      
      protected function updateScrollBar() : void
      {
         this.checkScrollBar();
         if(this._content)
         {
            if(this._scrollW)
            {
               this.showVScroll();
            }
            else if(this.vScrollBar)
            {
               this.vScrollBar.visible = false;
            }
            if(this._scrollH)
            {
               this.showHScroll();
            }
            else if(this.hScrollBar)
            {
               this.hScrollBar.visible = false;
            }
            if(Boolean(this.vScrollBar) && Boolean(this._scrollRect))
            {
               if(this.vScrollMode == ScrollBarMode.LINE)
               {
                  this.vScrollBar.setScrollProperties(this._pageSizeV,this._scrollPositionV,this._maxScrollPositionV);
               }
               else
               {
                  this.vScrollBar.setScrollProperties(_height - this._scrollH,this._scrollRect.y,this.contentHeight);
               }
            }
            if(this.hScrollBar)
            {
               if(this.hScrollMode == ScrollBarMode.LINE)
               {
                  this.hScrollBar.setScrollProperties(this._pageSizeH,this._scrollPositionH,this._maxScrollPositionH);
               }
               else
               {
                  this.hScrollBar.setScrollProperties(_width - this._scrollW,this._scrollRect.x,this.contentWidth);
               }
            }
            this.scrollBarChange();
            this.updateScrollRect();
         }
      }
      
      private function _MOUSE_WHEEL(param1:MouseEvent) : void
      {
         if(Boolean(this._scrollW) || Boolean(this._scrollH))
         {
            EventUtil.stopAll(param1);
         }
         if(Boolean(this.vScrollBar) && this.vScrollBar.visible)
         {
            this.vScrollBar.thumbPosition -= param1.delta * this.vScrollBar.pageScrollSize;
         }
         else if(Boolean(this.hScrollBar) && this.hScrollBar.visible)
         {
            this.hScrollBar.thumbPosition -= param1.delta * this.hScrollBar.pageScrollSize;
         }
      }
      
      public function set horizontalScrollPolicy(param1:String) : void
      {
         this._hScrollPolicy = param1;
      }
      
      protected function get contentWidth() : Number
      {
         if(this._content.scrollRect)
         {
            return this._content.transform.pixelBounds.width;
         }
         return this._content.width;
      }
      
      private function scrollBarChange() : void
      {
         if(Boolean(this.hScrollBar && this.hScrollBar.visible) && Boolean(this.vScrollBar) && this.vScrollBar.visible)
         {
            this.hScrollBar.width = _width - this.vScrollBar.width;
            this.vScrollBar.height = _height - this.hScrollBar.height;
         }
         else if(Boolean(this.vScrollBar) && Boolean(this.hScrollBar) && this.hScrollBar.visible)
         {
            this.hScrollBar.width = _width;
            this.vScrollBar.height = _height - this.hScrollBar.height;
         }
         else if(Boolean(this.hScrollBar) && Boolean(this.vScrollBar) && this.vScrollBar.visible)
         {
            this.hScrollBar.width = _width - this.vScrollBar.width;
            this.vScrollBar.height = _height;
         }
         else
         {
            if(this.hScrollBar)
            {
               this.hScrollBar.width = _width;
            }
            if(this.vScrollBar)
            {
               this.vScrollBar.height = _height;
            }
         }
      }
      
      protected function checkScrollBar() : void
      {
         if(this._content)
         {
            if(this._vScrollPolicy == ScrollPolicy.AUTO)
            {
               if(this.vScrollMode == ScrollBarMode.LINE)
               {
                  if(this._maxScrollPositionV > this._pageSizeV)
                  {
                     this._scrollW = Style.vScrollBarWidth;
                  }
                  else
                  {
                     this._scrollW = 0;
                  }
               }
               else if(this.contentHeight > _height - this._scrollH)
               {
                  this._scrollW = Style.vScrollBarWidth;
               }
               else
               {
                  this._scrollW = 0;
               }
            }
            else if(this._vScrollPolicy == ScrollPolicy.ON)
            {
               this._scrollW = Style.vScrollBarWidth;
            }
            if(this._hScrollPolicy == ScrollPolicy.AUTO)
            {
               if(this.hScrollMode == ScrollBarMode.LINE)
               {
                  if(this._maxScrollPositionH > this._pageSizeH)
                  {
                     this._scrollH = Style.hScrollBarHeight;
                  }
                  else
                  {
                     this._scrollH = 0;
                  }
               }
               else if(this.contentWidth > _width - this._scrollW)
               {
                  this._scrollH = Style.hScrollBarHeight;
               }
               else
               {
                  this._scrollH = 0;
               }
            }
            else if(this._hScrollPolicy == ScrollPolicy.ON)
            {
               this._scrollH = Style.hScrollBarHeight;
            }
            if(this._vScrollPolicy == ScrollPolicy.AUTO)
            {
               if(this.vScrollMode == ScrollBarMode.LINE)
               {
                  if(this._maxScrollPositionV > this._pageSizeV)
                  {
                     this._scrollW = Style.vScrollBarWidth;
                  }
                  else
                  {
                     this._scrollW = 0;
                  }
               }
               else if(this.contentHeight > _height - this._scrollH)
               {
                  this._scrollW = Style.vScrollBarWidth;
               }
               else
               {
                  this._scrollW = 0;
               }
            }
            else if(this._vScrollPolicy == ScrollPolicy.ON)
            {
               this._scrollW = Style.vScrollBarWidth;
            }
         }
      }
      
      protected function onScrollChange(param1:ScrollEvent) : void
      {
      }
      
      public function set verticalScrollPolicy(param1:String) : void
      {
         this._vScrollPolicy = param1;
      }
      
      private function _scroll(param1:ScrollEvent) : void
      {
         if(param1.direction == Direction.VERTICAL)
         {
            if(this.vScrollMode == ScrollBarMode.LINE)
            {
               this._scrollPositionV = param1.position;
            }
            else
            {
               this._scrollRect.y = param1.position;
            }
         }
         else if(param1.direction == Direction.HORIZONTAL)
         {
            if(this.hScrollMode == ScrollBarMode.LINE)
            {
               this._scrollPositionH = param1.position;
            }
            else
            {
               this._scrollRect.x = param1.position;
            }
         }
         this._content.scrollRect = this._scrollRect;
         this.onScrollChange(param1);
      }
      
      public function get verticalScrollPolicy() : String
      {
         return this._vScrollPolicy;
      }
      
      protected function removeEvent() : void
      {
         this.removeEventListener(MouseEvent.MOUSE_WHEEL,this._MOUSE_WHEEL);
      }
      
      protected function addEvent() : void
      {
         this.addEventListener(MouseEvent.MOUSE_WHEEL,this._MOUSE_WHEEL);
      }
      
      private function updateScrollRect() : void
      {
         if(this._scrollRect)
         {
            this._scrollRect = this._scrollRect.clone();
            if(this.vScrollMode == ScrollBarMode.LINE)
            {
               if(this._scrollW > 0)
               {
                  this._scrollRect.width = _width - this._scrollW;
               }
               else
               {
                  this._scrollRect.width = _width - this.borderSizeH;
               }
            }
            else
            {
               this._scrollRect.width = _width - this._scrollW - this.borderSizeH * 2;
            }
            if(this.hScrollMode == ScrollBarMode.LINE)
            {
               if(this._scrollH > 0)
               {
                  this._scrollRect.height = _height - this._scrollH;
               }
               else
               {
                  this._scrollRect.height = _height - this.borderSizeV;
               }
            }
            else
            {
               this._scrollRect.height = _height - this._scrollH - this.borderSizeV * 2;
            }
         }
         if(this._content)
         {
            this._content.scrollRect = this._scrollRect;
         }
      }
      
      override protected function setEnabled() : void
      {
         if(false == _enabled)
         {
            this.removeEvent();
            this.filters = Style.getDisableFilter();
            this.mouseChildren = false;
         }
         else
         {
            this.addEvent();
            this.filters = Style.getRollOutFilter();
            this.mouseChildren = true;
         }
      }
   }
}

