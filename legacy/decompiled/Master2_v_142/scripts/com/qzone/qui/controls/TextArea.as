package com.qzone.qui.controls
{
   import com.qzone.qui.core.Direction;
   import com.qzone.qui.events.ScrollEvent;
   import com.qzone.qui.utils.EventUtil;
   import com.qzone.utils.AlignUtil;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class TextArea extends TextInput
   {
      
      private var vScroll:VScrollBar;
      
      private var _scrollW:int;
      
      public var wordWrap:Boolean = true;
      
      private var hScroll:HScrollBar;
      
      private var _scrollH:int;
      
      public function TextArea()
      {
         super();
         _height = 100;
         _width = 100;
         _textField.multiline = true;
      }
      
      private function textFieldScrollHandle(param1:Event) : void
      {
         this.updateScrollBar();
      }
      
      protected function scrollHandle(param1:ScrollEvent) : void
      {
         if(param1.direction == Direction.VERTICAL)
         {
            _textField.scrollV = param1.position + 1;
         }
         else if(param1.direction == Direction.HORIZONTAL)
         {
            _textField.scrollH = param1.position;
         }
      }
      
      protected function textChanged() : void
      {
         this.updateScrollBar();
         _textField.removeEventListener(Event.SCROLL,this.textFieldScrollHandle);
      }
      
      private function updateScrollBar() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(_textField.maxScrollV > 1)
         {
            if(this.vScroll == null)
            {
               this.vScroll = new VScrollBar();
               this.vScroll.addEventListener(ScrollEvent.SCROLL,this.scrollHandle);
               this.vScroll.addEventListener(MouseEvent.CLICK,EventUtil.stopImmediatePropagation);
               this.addChild(this.vScroll);
            }
            _loc1_ = _textField.numLines - (_textField.maxScrollV - 1);
            _loc2_ = _textField.numLines;
            _loc3_ = _textField.scrollV - 1;
            this.vScroll.setScrollProperties(_loc1_,_loc3_,_loc2_);
            this.vScroll.visible = true;
            this._scrollW = this.vScroll.width;
         }
         else
         {
            if(this.vScroll)
            {
               this.vScroll.visible = false;
            }
            this._scrollW = 0;
         }
         if(_textField.maxScrollH > 1)
         {
            if(this.hScroll == null)
            {
               this.hScroll = new HScrollBar();
               this.hScroll.addEventListener(ScrollEvent.SCROLL,this.scrollHandle);
               this.hScroll.addEventListener(MouseEvent.CLICK,EventUtil.stopImmediatePropagation);
               this.addChild(this.hScroll);
            }
            _loc1_ = _textField.width;
            _loc2_ = _textField.width + _textField.maxScrollH;
            _loc3_ = _textField.scrollH;
            this.hScroll.setScrollProperties(_loc1_,_loc3_,_loc2_);
            this.hScroll.visible = true;
            this._scrollH = this.hScroll.height;
         }
         else
         {
            if(this.hScroll)
            {
               this.hScroll.visible = false;
            }
            this._scrollH = 0;
         }
         this.setSize();
      }
      
      override protected function _FOCUS_OUT(param1:Event) : void
      {
         _textField.removeEventListener(Event.SCROLL,this.textFieldScrollHandle);
         _textField.mouseWheelEnabled = false;
         super._FOCUS_OUT(param1);
      }
      
      override protected function init() : void
      {
         _textField.wordWrap = this.wordWrap;
         _textField.addEventListener(Event.SCROLL,this.textFieldScrollHandle);
         super.init();
      }
      
      override protected function _FOCUS_IN(param1:Event) : void
      {
         _textField.addEventListener(Event.SCROLL,this.textFieldScrollHandle);
         _textField.mouseWheelEnabled = true;
         super._FOCUS_IN(param1);
      }
      
      override public function set htmlText(param1:String) : void
      {
         _text = param1 || "";
         if(_added)
         {
            _textField.htmlText = _text;
            this.resetScrollPos();
            this.textChanged();
         }
      }
      
      override public function set text(param1:String) : void
      {
         _text = param1 || "";
         if(_added)
         {
            _textField.text = _text;
            this.resetScrollPos();
            this.textChanged();
         }
      }
      
      override protected function setSize() : void
      {
         if(this.vScroll)
         {
            this.vScroll.x = AlignUtil.right(_width,this.vScroll.width);
         }
         if(this.hScroll)
         {
            this.hScroll.y = AlignUtil.right(_height,this.hScroll.height);
         }
         if(_skin)
         {
            _skin.width = this._scrollW > 0 ? _width - this._scrollW + 1 : _width - this._scrollW;
            _skin.height = this._scrollH > 0 ? _height - this._scrollH + 1 : _height - this._scrollH;
         }
         _textField.x = paddingH;
         _textField.y = paddingV;
         _textField.width = _width - paddingH * 2 - this._scrollW;
         _textField.height = _height - paddingV * 2 - this._scrollH;
         this.scrollBarChange();
      }
      
      private function scrollBarChange() : void
      {
         if(Boolean(this.hScroll && this.hScroll.visible) && Boolean(this.vScroll) && this.vScroll.visible)
         {
            this.hScroll.width = _width - this.vScroll.width;
            this.vScroll.height = _height - this.hScroll.height;
         }
         else if(Boolean(this.vScroll) && Boolean(this.hScroll) && this.hScroll.visible)
         {
            this.hScroll.width = _width;
            this.vScroll.height = _height - this.hScroll.height;
         }
         else if(Boolean(this.hScroll) && Boolean(this.vScroll) && this.vScroll.visible)
         {
            this.hScroll.width = _width - this.vScroll.width;
            this.vScroll.height = _height;
         }
         else
         {
            if(this.hScroll)
            {
               this.hScroll.width = _width;
            }
            if(this.vScroll)
            {
               this.vScroll.height = _height;
            }
         }
      }
      
      private function resetScrollPos() : void
      {
         _textField.scrollV = 0;
         _textField.scrollH = 0;
      }
   }
}

