package com.qzone.qui.containers.boxClasses
{
   import com.qzone.qui.containers.Canvas;
   import com.qzone.qui.core.Align;
   import com.qzone.qui.core.Direction;
   import com.qzone.qui.styles.Style;
   import com.qzone.utils.AlignUtil;
   import flash.display.DisplayObject;
   
   public class Box extends Canvas
   {
      
      public var gapV:int = Style.boxGapV;
      
      protected var _contentHeight:Number;
      
      private var nextX:int;
      
      private var _childrenWidth:int;
      
      public var specialGapH:int = 0;
      
      private var nextY:int;
      
      public var specialGapHIndex:int = 0;
      
      public var alignH:String = "center";
      
      private var _childrenHeight:int;
      
      private var addSpecialGapH:Boolean = true;
      
      protected var _contentWidth:Number;
      
      public var alignV:String = "middle";
      
      public var gapH:int = Style.boxGapH;
      
      protected var direction:String = "horizontal";
      
      public function Box(param1:Number = 200, param2:Number = 200)
      {
         super(param1,param2);
         paddingH = Style.boxPaddingH;
         paddingV = Style.boxPaddingV;
         backgroundColor = Style.boxBackgroundColor;
         backgroundAlpha = Style.boxBackgroundAlpha;
      }
      
      private function BL(param1:DisplayObject) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         this.nextX = paddingH;
         if(Direction.HORIZONTAL == this.direction)
         {
            this._childrenWidth += param1.width + this.gapH;
            this._childrenHeight += param1.height + this.gapV;
            _loc3_ = _height - paddingV - _scrollH;
            if(this.nextX < paddingH)
            {
               this.nextX = paddingH;
            }
            if(_loc3_ < paddingV)
            {
               _loc3_ = paddingV;
            }
            while(_loc2_ < content.numChildren)
            {
               param1 = _content.getChildAt(_loc2_) as DisplayObject;
               param1.x = this.nextX;
               param1.y = _loc3_ - param1.height;
               this.nextX += param1.width + this.gapH;
               _loc2_++;
            }
         }
         else
         {
            this._childrenWidth = Math.max(param1.width + this.gapH,this._childrenWidth);
            this._childrenHeight += param1.height + this.gapV;
            _loc3_ = _height - paddingV - (this._childrenHeight - this.gapV);
            if(this.nextX < paddingH)
            {
               this.nextX = paddingH;
            }
            if(_loc3_ < paddingV)
            {
               _loc3_ = paddingV;
            }
            while(_loc2_ < content.numChildren)
            {
               param1 = _content.getChildAt(_loc2_) as DisplayObject;
               param1.y = _loc3_;
               param1.x = this.nextX;
               _loc3_ += param1.height + this.gapV;
               _loc2_++;
            }
         }
      }
      
      override protected function get contentHeight() : Number
      {
         this._contentHeight = this._childrenHeight - this.gapV + paddingV * 2;
         return this._contentHeight || _content.height;
      }
      
      public function removeAllElements() : void
      {
         if(content == null)
         {
            return;
         }
         while(content.numChildren > 0)
         {
            content.removeChildAt(0);
         }
         this.nextX = this.nextY = 0;
         this._childrenWidth = this._childrenHeight = 0;
      }
      
      private function BR(param1:DisplayObject) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(Direction.HORIZONTAL == this.direction)
         {
            this._childrenWidth += param1.width + this.gapH;
            this._childrenHeight += param1.height + this.gapV;
            _loc4_ = _width - paddingH - (this._childrenWidth - this.gapH);
            _loc3_ = _height - paddingV - _scrollH;
            if(_loc4_ < paddingH)
            {
               _loc4_ = paddingH;
            }
            if(_loc3_ < paddingV)
            {
               _loc3_ = paddingV;
            }
            while(_loc2_ < content.numChildren)
            {
               param1 = _content.getChildAt(_loc2_) as DisplayObject;
               param1.x = _loc4_;
               param1.y = _loc3_ - param1.height;
               _loc4_ += param1.width + this.gapH;
               _loc2_++;
            }
         }
         else
         {
            this._childrenWidth = Math.max(param1.width + this.gapH,this._childrenWidth);
            this._childrenHeight += param1.height + this.gapV;
            _loc4_ = _width - paddingH - _scrollW;
            _loc3_ = _height - paddingV - (this._childrenHeight - this.gapV);
            if(this._childrenWidth > _width)
            {
               _loc4_ = this._childrenWidth;
            }
            if(_loc4_ < paddingH)
            {
               _loc4_ = paddingH;
            }
            if(_loc3_ < paddingV)
            {
               _loc3_ = paddingV;
            }
            while(_loc2_ < content.numChildren)
            {
               param1 = _content.getChildAt(_loc2_) as DisplayObject;
               param1.y = _loc3_;
               param1.x = _loc4_ - param1.width;
               _loc3_ += param1.height + this.gapV;
               _loc2_++;
            }
         }
      }
      
      private function BC(param1:DisplayObject) : void
      {
         var _loc2_:int = 0;
         this.nextY = _height - paddingV - _scrollH;
         if(Direction.HORIZONTAL == this.direction)
         {
            this._childrenWidth += param1.width + this.gapH;
            this._childrenHeight = Math.max(param1.height + this.gapV,this._childrenHeight);
            this.nextX = AlignUtil.middle(_width,this._childrenWidth - this.gapH);
            if(this.nextX < paddingH)
            {
               this.nextX = paddingH;
            }
            if(this.nextY < paddingV)
            {
               this.nextY = paddingV;
            }
            while(_loc2_ < content.numChildren)
            {
               param1 = _content.getChildAt(_loc2_) as DisplayObject;
               param1.x = this.nextX;
               param1.y = this.nextY - param1.height;
               this.nextX += param1.width + this.gapH;
               _loc2_++;
            }
         }
         else
         {
            this._childrenWidth = Math.max(param1.width + this.gapH,this._childrenWidth);
            this._childrenHeight += param1.height + this.gapV;
            this.nextX = Math.floor((_width - _scrollW) / 2);
            this.nextY = _height - paddingV - (this._childrenHeight - this.gapV);
            if(this.nextX < paddingH)
            {
               this.nextX = paddingH;
            }
            if(this.nextY < paddingV)
            {
               this.nextY = paddingV;
            }
            while(_loc2_ < content.numChildren)
            {
               param1 = _content.getChildAt(_loc2_) as DisplayObject;
               param1.y = this.nextY;
               param1.x = Math.max(paddingV,Math.floor(this.nextX - param1.width / 2));
               this.nextY += param1.height + this.gapV;
               _loc2_++;
            }
         }
      }
      
      public function addElement(param1:DisplayObject) : DisplayObject
      {
         content.addChild(param1);
         if(Align.MIDDLE == this.alignV)
         {
            if(Align.CENTER == this.alignH)
            {
               this.MC(param1);
            }
            else if(Align.LEFT == this.alignH)
            {
               this.ML(param1);
            }
            else if(Align.RIGHT == this.alignH)
            {
               this.MR(param1);
            }
         }
         else if(Align.TOP == this.alignV)
         {
            if(Align.CENTER == this.alignH)
            {
               this.TC(param1);
            }
            else if(Align.LEFT == this.alignH)
            {
               this.TL(param1);
            }
            else if(Align.RIGHT == this.alignH)
            {
               this.TR(param1);
            }
         }
         else if(Align.BOTTOM == this.alignV)
         {
            if(Align.CENTER == this.alignH)
            {
               this.BC(param1);
            }
            else if(Align.LEFT == this.alignH)
            {
               this.BL(param1);
            }
            else if(Align.RIGHT == this.alignH)
            {
               this.BR(param1);
            }
         }
         validateNow();
         return param1;
      }
      
      override protected function get contentWidth() : Number
      {
         this._contentWidth = this._childrenWidth - this.gapH + paddingH * 2;
         return this._contentWidth || _content.width;
      }
      
      private function MC(param1:DisplayObject) : void
      {
         var _loc2_:int = 0;
         if(Direction.HORIZONTAL == this.direction)
         {
            this._childrenWidth += param1.width + this.gapH;
            this._childrenHeight = Math.max(param1.height + this.gapV,this._childrenHeight);
            this.nextX = AlignUtil.middle(_width,this._childrenWidth - this.gapH);
            this.nextY = Math.floor((_height - _scrollH) / 2);
            if(this.nextX < paddingH)
            {
               this.nextX = paddingH;
            }
            if(this.nextY < paddingV)
            {
               this.nextY = paddingV;
            }
            while(_loc2_ < content.numChildren)
            {
               param1 = _content.getChildAt(_loc2_) as DisplayObject;
               param1.x = this.nextX;
               param1.y = Math.floor(this.nextY - param1.height / 2);
               this.nextX += param1.width + this.gapH;
               _loc2_++;
            }
         }
         else
         {
            this._childrenWidth = Math.max(param1.width + this.gapH,this._childrenWidth);
            this._childrenHeight += param1.height + this.gapV;
            this.nextY = AlignUtil.middle(_height,this._childrenHeight - this.gapV);
            this.nextX = Math.floor((_width - _scrollW) / 2);
            if(this.nextX < paddingH)
            {
               this.nextX = paddingH;
            }
            if(this.nextY < paddingV)
            {
               this.nextY = paddingV;
            }
            while(_loc2_ < content.numChildren)
            {
               param1 = _content.getChildAt(_loc2_) as DisplayObject;
               param1.y = this.nextY;
               param1.x = Math.max(paddingV,Math.floor(this.nextX - param1.width / 2));
               this.nextY += param1.height + this.gapV;
               _loc2_++;
            }
         }
      }
      
      private function TR(param1:DisplayObject) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         this.nextY = paddingV;
         if(Direction.HORIZONTAL == this.direction)
         {
            this._childrenWidth += param1.width + this.gapH;
            this._childrenHeight += param1.height + this.gapV;
            _loc3_ = _width - paddingH - (this._childrenWidth - this.gapH);
            if(_loc3_ < paddingH)
            {
               _loc3_ = paddingH;
            }
            if(this.nextY < paddingV)
            {
               this.nextY = paddingV;
            }
            while(_loc2_ < content.numChildren)
            {
               param1 = _content.getChildAt(_loc2_) as DisplayObject;
               param1.x = _loc3_;
               param1.y = this.nextY;
               _loc3_ += param1.width + this.gapH;
               _loc2_++;
            }
         }
         else
         {
            this._childrenWidth = Math.max(param1.width + this.gapH,this._childrenWidth);
            this._childrenHeight += param1.height + this.gapV;
            _loc3_ = _width - paddingH - _scrollW;
            if(this._childrenWidth > _width)
            {
               _loc3_ = this._childrenWidth;
            }
            if(_loc3_ < paddingH)
            {
               _loc3_ = paddingH;
            }
            if(this.nextY < paddingV)
            {
               this.nextY = paddingV;
            }
            while(_loc2_ < content.numChildren)
            {
               param1 = _content.getChildAt(_loc2_) as DisplayObject;
               param1.y = this.nextY;
               param1.x = _loc3_ - param1.width;
               this.nextY += param1.height + this.gapV;
               _loc2_++;
            }
         }
      }
      
      private function ML(param1:DisplayObject) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         this.nextX = paddingH;
         if(Direction.HORIZONTAL == this.direction)
         {
            this._childrenWidth += param1.width + this.gapH;
            this._childrenHeight = Math.max(param1.height + this.gapV,this._childrenHeight);
            _loc3_ = Math.floor((_height - _scrollH) / 2);
            if(this.nextX < paddingH)
            {
               this.nextX = paddingH;
            }
            if(_loc3_ < paddingV)
            {
               _loc3_ = paddingV;
            }
            while(_loc2_ < content.numChildren)
            {
               param1 = _content.getChildAt(_loc2_) as DisplayObject;
               param1.x = this.nextX;
               param1.y = Math.floor(_loc3_ - param1.height / 2);
               this.nextX += param1.width + this.gapH;
               _loc2_++;
            }
         }
         else
         {
            this._childrenHeight += param1.height + this.gapV;
            _loc3_ = AlignUtil.middle(_height,this._childrenHeight - this.gapV);
            if(this.nextX < paddingH)
            {
               this.nextX = paddingH;
            }
            if(_loc3_ < paddingV)
            {
               _loc3_ = paddingV;
            }
            while(_loc2_ < content.numChildren)
            {
               param1 = _content.getChildAt(_loc2_) as DisplayObject;
               param1.y = _loc3_;
               param1.x = this.nextX;
               _loc3_ += param1.height + this.gapV;
               _loc2_++;
            }
         }
      }
      
      public function removeElement(param1:DisplayObject) : DisplayObject
      {
         this._childrenWidth -= param1.width;
         content.removeChild(param1);
         validateNow();
         return param1;
      }
      
      private function TC(param1:DisplayObject) : void
      {
         var _loc2_:int = 0;
         this.nextY = paddingV;
         if(Direction.HORIZONTAL == this.direction)
         {
            this._childrenWidth += param1.width + this.gapH;
            this._childrenHeight = Math.max(param1.height + this.gapV,this._childrenHeight);
            this.nextX = AlignUtil.middle(_width,this._childrenWidth - this.gapH);
            if(this.nextX < paddingH)
            {
               this.nextX = paddingH;
            }
            if(this.nextY < paddingV)
            {
               this.nextY = paddingV;
            }
            while(_loc2_ < content.numChildren)
            {
               param1 = _content.getChildAt(_loc2_) as DisplayObject;
               param1.x = this.nextX;
               param1.y = this.nextY;
               this.nextX += param1.width + this.gapH;
               _loc2_++;
            }
         }
         else
         {
            this._childrenHeight += param1.height + this.gapV;
            this._childrenWidth = Math.max(param1.width + this.gapH,this._childrenWidth);
            this.nextX = Math.floor((_width - _scrollW) / 2);
            if(this.nextX < paddingH)
            {
               this.nextX = paddingH;
            }
            if(this.nextY < paddingV)
            {
               this.nextY = paddingV;
            }
            while(_loc2_ < content.numChildren)
            {
               param1 = _content.getChildAt(_loc2_) as DisplayObject;
               param1.y = this.nextY;
               param1.x = Math.max(paddingV,Math.floor(this.nextX - param1.width / 2));
               this.nextY += param1.height + this.gapV;
               _loc2_++;
            }
         }
      }
      
      private function MR(param1:DisplayObject) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(Direction.HORIZONTAL == this.direction)
         {
            this._childrenWidth += param1.width + this.gapH;
            this._childrenHeight += param1.height + this.gapV;
            _loc4_ = _width - paddingH - (this._childrenWidth - this.gapH);
            _loc3_ = Math.floor((_height - _scrollH) / 2);
            if(_loc4_ < paddingH)
            {
               _loc4_ = paddingH;
            }
            if(_loc3_ < paddingV)
            {
               _loc3_ = paddingV;
            }
            _loc5_ = 0;
            while(_loc2_ < content.numChildren)
            {
               if(_loc2_ == this.specialGapHIndex)
               {
                  _loc5_ = this.specialGapH;
               }
               else
               {
                  _loc5_ = 0;
               }
               this._childrenWidth += _loc5_;
               param1 = _content.getChildAt(_loc2_) as DisplayObject;
               param1.x = _loc4_;
               param1.y = Math.floor(_loc3_ - param1.height / 2);
               _loc4_ += param1.width + this.gapH + _loc5_;
               _loc2_++;
            }
         }
         else
         {
            this._childrenWidth = Math.max(param1.width + this.gapH,this._childrenWidth);
            this._childrenHeight += param1.height + this.gapV;
            _loc4_ = _width - paddingH - _scrollW;
            _loc3_ = AlignUtil.middle(_height,this._childrenHeight - this.gapV);
            if(this._childrenWidth > _width)
            {
               _loc4_ = this._childrenWidth;
            }
            if(_loc4_ < paddingH)
            {
               _loc4_ = paddingH;
            }
            if(_loc3_ < paddingV)
            {
               _loc3_ = paddingV;
            }
            while(_loc2_ < content.numChildren)
            {
               param1 = _content.getChildAt(_loc2_) as DisplayObject;
               param1.y = _loc3_;
               param1.x = _loc4_ - param1.width;
               _loc3_ += param1.height + this.gapV;
               _loc2_++;
            }
         }
      }
      
      override protected function updateBackGround() : void
      {
         var _loc1_:int = Math.max(this._childrenWidth + paddingH * 2 - this.gapV,_width - _scrollW);
         var _loc2_:int = Math.max(this._childrenHeight + paddingV * 2 - this.gapH,_height - _scrollH);
         drawBackGround(_loc1_,_loc2_);
      }
      
      private function TL(param1:DisplayObject) : void
      {
         var _loc2_:int = 0;
         this.nextY = paddingV;
         this.nextX = paddingH;
         if(Direction.HORIZONTAL == this.direction)
         {
            this._childrenWidth += param1.width + this.gapH;
            this._childrenHeight += param1.height + this.gapV;
            if(this.nextX < paddingH)
            {
               this.nextX = paddingH;
            }
            if(this.nextY < paddingV)
            {
               this.nextY = paddingV;
            }
            while(_loc2_ < content.numChildren)
            {
               param1 = _content.getChildAt(_loc2_) as DisplayObject;
               param1.x = this.nextX;
               param1.y = this.nextY;
               this.nextX += param1.width + this.gapH;
               _loc2_++;
            }
         }
         else
         {
            this._childrenHeight += param1.height + this.gapV;
            if(this.nextX < paddingH)
            {
               this.nextX = paddingH;
            }
            if(this.nextY < paddingV)
            {
               this.nextY = paddingV;
            }
            while(_loc2_ < content.numChildren)
            {
               param1 = _content.getChildAt(_loc2_) as DisplayObject;
               param1.y = this.nextY;
               param1.x = this.nextX;
               this.nextY += param1.height + this.gapV;
               _loc2_++;
            }
         }
      }
   }
}

