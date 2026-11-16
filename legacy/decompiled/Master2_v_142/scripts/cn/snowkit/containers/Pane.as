package cn.snowkit.containers
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   
   public class Pane extends Sprite
   {
      
      public static const ALIGN_LEFT:int = 0;
      
      public static const ALIGN_CNETER:int = 1;
      
      public static const ALIGN_RIGHT:int = 2;
      
      public static const VALIGN_TOP:int = 0;
      
      public static const VALIGN_MIDDLE:int = 1;
      
      public static const VALIGN_BUTTOM:int = 2;
      
      public static const MODE_H:int = 0;
      
      public static const MODE_V:int = 1;
      
      protected var _totalWidth:Number;
      
      protected var _mode:int;
      
      protected var _align:int;
      
      protected var _container:Sprite;
      
      protected var _fillColor:uint;
      
      protected var _fillAlpha:Number;
      
      public var topSpace:int = -1;
      
      public var leftSpace:int = -1;
      
      protected var _border:Sprite;
      
      protected var _totalHeight:Number;
      
      protected var _vAlign:int;
      
      protected var _borderAlpha:Number;
      
      protected var _blank:int;
      
      protected var _paneWidth:Number;
      
      protected var _paneHeight:Number;
      
      public function Pane(param1:Number = 100, param2:Number = 100, param3:Boolean = false, param4:uint = 0, param5:Number = 0)
      {
         super();
         this._paneWidth = param1;
         this._paneHeight = param2;
         this._fillColor = param4;
         this._fillAlpha = param5;
         this._borderAlpha = param3 ? 1 : 0;
         this._mode = 0;
         this._align = 0;
         this._blank = 2;
         this._border = new Sprite();
         this._drawBorder();
         this._border.mouseChildren = this._border.mouseEnabled = false;
         addChild(this._border);
         this._container = new Sprite();
         addChild(this._container);
      }
      
      public function set align(param1:int) : void
      {
         this._align = param1;
      }
      
      protected function _orderChilds() : void
      {
         var _loc3_:DisplayObject = null;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc1_:int = this._container.numChildren;
         this._totalWidth = 0;
         this._totalHeight = 0;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            _loc3_ = this._container.getChildAt(_loc2_) as DisplayObject;
            if(_loc3_ != null)
            {
               if(this._mode == MODE_H)
               {
                  _loc3_.x = int(this._totalWidth + this._blank);
                  this._totalWidth += (_loc3_.hasOwnProperty("visibleWidth") ? _loc3_["visibleWidth"] : _loc3_.width) + this._blank;
                  _loc4_ = _loc3_.hasOwnProperty("visibleHeight") ? Number(_loc3_["visibleHeight"]) : _loc3_.height;
                  this._totalHeight = _loc4_ > this._totalHeight ? _loc4_ : this._totalHeight;
               }
               else
               {
                  _loc3_.y = int(this._totalHeight + this._blank);
                  this._totalHeight += (_loc3_.hasOwnProperty("visibleHeight") ? _loc3_["visibleHeight"] : _loc3_.height) + this._blank;
                  _loc5_ = _loc3_.hasOwnProperty("visibleWidth") ? Number(_loc3_["visibleWidth"]) : _loc3_.width;
                  this._totalWidth = _loc5_ > this._totalWidth ? _loc5_ : this._totalWidth;
               }
            }
            _loc2_++;
         }
      }
      
      public function setSizeWH(param1:Number, param2:Number) : void
      {
         this._paneWidth = param1;
         this._paneHeight = param2;
         this._drawBorder();
         this._setChildsXY();
      }
      
      public function get fillAlpha() : Number
      {
         return this._fillAlpha;
      }
      
      override public function contains(param1:DisplayObject) : Boolean
      {
         if(this._container.contains(param1))
         {
            return true;
         }
         return false;
      }
      
      public function get fillColor() : uint
      {
         return this._fillColor;
      }
      
      public function appendChild(param1:DisplayObject) : DisplayObject
      {
         var _loc2_:DisplayObject = this._container.addChild(param1);
         this._setChildsXY();
         return _loc2_;
      }
      
      override public function get numChildren() : int
      {
         return this._container.numChildren;
      }
      
      public function set blank(param1:int) : void
      {
         this._blank = param1;
      }
      
      public function get paneHeight() : Number
      {
         return this._paneHeight;
      }
      
      protected function _drawBorder() : void
      {
         this._border.graphics.clear();
         this._border.graphics.lineStyle(0,0,this._borderAlpha);
         this._border.graphics.beginFill(this._fillColor,this._fillAlpha);
         this._border.graphics.drawRect(0,0,this._paneWidth,this._paneHeight);
         this._border.graphics.endFill();
      }
      
      public function set fillAlpha(param1:Number) : void
      {
         this._fillAlpha = param1;
         this._drawBorder();
      }
      
      public function get paneWidth() : Number
      {
         return this._paneWidth;
      }
      
      public function set fillColor(param1:uint) : void
      {
         this._fillColor = param1;
         this._drawBorder();
      }
      
      public function set mode(param1:int) : void
      {
         this._mode = param1;
      }
      
      public function revalidate() : void
      {
         this._drawBorder();
         this._setChildsXY();
      }
      
      override public function removeChildAt(param1:int) : DisplayObject
      {
         var _loc2_:DisplayObject = this._container.removeChildAt(param1);
         this.revalidate();
         return _loc2_;
      }
      
      public function get blank() : int
      {
         return this._blank;
      }
      
      protected function _setChildsXY() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:DisplayObject = null;
         this._orderChilds();
         switch(this._align)
         {
            case ALIGN_LEFT:
               this._container.x = this.leftSpace == -1 ? this._blank : this.leftSpace;
               break;
            case ALIGN_CNETER:
               this._container.x = int((this._paneWidth - this._totalWidth) / 2);
               break;
            case ALIGN_RIGHT:
               this._container.x = int(this._paneWidth - this._totalWidth - this._blank * 2);
         }
         switch(this._vAlign)
         {
            case VALIGN_TOP:
               this._container.y = this.topSpace == -1 ? this._blank : this.topSpace;
               break;
            case VALIGN_MIDDLE:
               _loc1_ = this._container.numChildren;
               _loc2_ = 0;
               while(_loc2_ < _loc1_)
               {
                  _loc3_ = this._container.getChildAt(_loc2_) as DisplayObject;
                  _loc3_.y = int((this._totalHeight - (_loc3_.hasOwnProperty("visibleHeight") ? _loc3_["visibleHeight"] : _loc3_.height)) / 2);
                  _loc2_++;
               }
               this._container.y = int((this._paneHeight - this._totalHeight) / 2);
               break;
            case VALIGN_BUTTOM:
               _loc1_ = this._container.numChildren;
               _loc2_ = 0;
               while(_loc2_ < _loc1_)
               {
                  _loc3_ = this._container.getChildAt(_loc2_) as DisplayObject;
                  _loc3_.y = int(this._totalHeight - (_loc3_.hasOwnProperty("visibleHeight") ? _loc3_["visibleHeight"] : _loc3_.height));
                  _loc2_++;
               }
               this._container.y = int(this._paneHeight - this._totalHeight);
         }
      }
      
      public function set paneHeight(param1:Number) : void
      {
         this._paneHeight = param1;
      }
      
      public function set vAlign(param1:int) : void
      {
         this._vAlign = param1;
      }
      
      override public function removeChild(param1:DisplayObject) : DisplayObject
      {
         if(this._container.contains(param1))
         {
            this._container.removeChild(param1);
            this.revalidate();
         }
         return param1;
      }
      
      public function set paneWidth(param1:Number) : void
      {
         this._paneWidth = param1;
      }
   }
}

