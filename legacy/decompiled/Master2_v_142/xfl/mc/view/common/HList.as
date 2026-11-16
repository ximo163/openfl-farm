package mc.view.common
{
   import com.minutes.ui.collections.LipiListChild;
   import com.minutes.ui.collections.SimpleCollection;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.geom.Rectangle;
   
   public class HList extends SimpleCollection
   {
      
      private var _childSprite:Sprite;
      
      private var _align:String = "left";
      
      private var _width:Number = 100;
      
      private var _dataList:Array = [];
      
      private var _gap:int;
      
      private var itemPosition:int = 0;
      
      private var _height:Number = 100;
      
      private var offsetX:Number = 0;
      
      private var _itemClass:Class;
      
      private var offsetY:Number = 0;
      
      public function HList(param1:Class, param2:int = 0)
      {
         super();
         this._itemClass = param1;
         this._gap = param2;
         this._childSprite = new Sprite();
         addChild(this._childSprite);
      }
      
      public function leftMove2(param1:int = 1) : void
      {
         var _loc3_:Number = NaN;
         var _loc2_:Number = this._childSprite.getChildAt(this.itemPosition).x;
         if(this.itemPosition - param1 >= 0)
         {
            this.itemPosition -= param1;
            _loc3_ = this._childSprite.getChildAt(this.itemPosition).x;
            this.offsetX += _loc3_ - _loc2_;
            scrollRect = new Rectangle(_loc3_,0,this.width,this.height);
         }
      }
      
      public function get align() : String
      {
         return this._align;
      }
      
      public function set align(param1:String) : void
      {
         this._align = param1;
         this.setChildPosition();
      }
      
      public function rightMove(param1:int) : Boolean
      {
         if(this._childSprite.width < this.width)
         {
            return false;
         }
         var _loc2_:Boolean = true;
         if(this.offsetX + this.width + param1 > this._childSprite.width)
         {
            this.offsetX = this._childSprite.width - this.width;
            _loc2_ = false;
         }
         else
         {
            this.offsetX += param1;
         }
         scrollRect = new Rectangle(this.offsetX,this.offsetY,this.width,this.height);
         return _loc2_;
      }
      
      public function set dataList(param1:Array) : void
      {
         this._dataList = param1;
         this.setChild();
      }
      
      public function get rightEnabled() : Boolean
      {
         if(this.offsetX >= this._childSprite.width - this.width - 5)
         {
            return false;
         }
         return true;
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      private function setChild() : void
      {
         var _loc2_:DisplayObject = null;
         var _loc1_:int = 0;
         while(_loc1_ < this._dataList.length)
         {
            if(_loc1_ >= this._childSprite.numChildren)
            {
               _loc2_ = new this._itemClass();
               this._childSprite.addChild(_loc2_);
            }
            (this._childSprite.getChildAt(_loc1_) as LipiListChild).data = this._dataList[_loc1_];
            _loc1_++;
         }
         while(this._childSprite.numChildren > this._dataList.length)
         {
            this._childSprite.removeChildAt(this._childSprite.numChildren - 1);
         }
         this.setChildPosition();
         scrollRect = new Rectangle(0,0,this.width,this.height);
         this.offsetX = 0;
         this.itemPosition = 0;
      }
      
      public function rightMove2(param1:int = 1) : void
      {
         var _loc3_:Number = NaN;
         var _loc2_:Number = this._childSprite.getChildAt(this.itemPosition).x;
         if(this.itemPosition + param1 < this._childSprite.numChildren - 4)
         {
            this.itemPosition += param1;
            _loc3_ = this._childSprite.getChildAt(this.itemPosition).x;
            this.offsetX += _loc3_ - _loc2_;
            scrollRect = new Rectangle(_loc3_,0,this.width,this.height);
         }
      }
      
      private function setChildPosition() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(this.align == "left")
         {
            _loc1_ = 0;
         }
         else if(this.align == "center")
         {
            if(this._childSprite.numChildren == 0)
            {
               _loc1_ = 0;
            }
            else
            {
               _loc1_ = (this.width - (this._childSprite.numChildren * (this._childSprite.getChildAt(_loc2_).width + this._gap) - 1)) / 2;
            }
         }
         else
         {
            _loc1_ = this.width - (this._childSprite.numChildren * (this._childSprite.getChildAt(_loc2_).width + this._gap) - 1);
         }
         _loc2_ = 0;
         while(_loc2_ < this._childSprite.numChildren)
         {
            this._childSprite.getChildAt(_loc2_).x = _loc1_;
            _loc1_ = _loc1_ + this._childSprite.getChildAt(_loc2_).width + this._gap;
            _loc2_++;
         }
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = param1;
         this.offsetX = 0;
         this.offsetY = 0;
         scrollRect = new Rectangle(this.offsetX,this.offsetY,this.width,this.height);
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      public function get dataList() : Array
      {
         return this._dataList;
      }
      
      override public function set height(param1:Number) : void
      {
         this._height = param1;
         this.offsetX = 0;
         this.offsetY = 0;
         scrollRect = new Rectangle(this.offsetX,this.offsetY,this.width,this.height);
      }
      
      public function get leftEnabled() : Boolean
      {
         if(this.offsetX <= 0)
         {
            return false;
         }
         return true;
      }
      
      public function leftMove(param1:int) : Boolean
      {
         var _loc2_:Boolean = true;
         if(this.offsetX - param1 < 0)
         {
            this.offsetX = 0;
            _loc2_ = false;
         }
         else
         {
            this.offsetX -= param1;
         }
         scrollRect = new Rectangle(this.offsetX,this.offsetY,this.width,this.height);
         return _loc2_;
      }
   }
}

