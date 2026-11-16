package mc.view.farm
{
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import mc.control.Command;
   import mc.model.FarmData;
   import mc.model.MData;
   import mc.view.farm.land.FarmOperateFloating;
   import mc.view.main.cursor.Cursor;
   import mc.view.main.floating.Float;
   
   public class RollCollection extends Sprite
   {
      
      private var farmData:FarmData;
      
      private var downLeft:Number = 0;
      
      private var _height:Number = 100;
      
      private var downTop:Number = 0;
      
      private var _top:Number = 0;
      
      private var _maxWidth:Number = 10000;
      
      private var _width:Number = 100;
      
      private var _maxHeight:Number = 10000;
      
      private var _left:Number = 0;
      
      private var downX:Number = 0;
      
      private var downY:Number = 0;
      
      public function RollCollection()
      {
         super();
         this.reRoll();
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         addEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         addEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
      }
      
      private function onMouseUp(param1:MouseEvent) : void
      {
         removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         stage.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
      }
      
      public function set maxWidth(param1:Number) : void
      {
         this._maxWidth = param1;
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         var _loc4_:Object = null;
         var _loc5_:Object = null;
         var _loc6_:Number = NaN;
         addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         stage.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp,false,0,true);
         this.downX = param1.stageX;
         this.downY = param1.stageY;
         this.downLeft = this.left;
         this.downTop = this.top;
         if(Cursor.name == "CursorTool" && Cursor.cursorArgument["type"] == 9)
         {
            _loc2_ = Cursor.cursorArgument;
            _loc4_ = MData.getInstance().mainData;
            _loc5_ = _loc4_.host;
            if(GetCropID.getHouse(_loc2_["tId"]) == "窝")
            {
               _loc6_ = Number(_loc4_.getAnimalNum(_loc5_["house1"],"窝"));
               if(_loc5_["animal1"] + 1 > _loc6_)
               {
                  _loc3_ = "您的窝已经住满哦！";
               }
            }
            else
            {
               _loc6_ = Number(_loc4_.getAnimalNum(_loc5_["house2"],"棚"));
               if(_loc5_["animal2"] + 1 > _loc6_)
               {
                  _loc3_ = "您的棚已经住满哦！”";
               }
               if(_loc5_["house2"] == 0)
               {
                  _loc3_ = "对不起，您需要先盖棚。";
               }
            }
            if(_loc3_)
            {
               this.farmOperate(_loc3_);
               return;
            }
            Command.getInstance().mainCommand.addPackAnimal(Cursor.cursorArgument["tId"],1);
         }
      }
      
      public function reRoll() : void
      {
         this.scrollRect = new Rectangle(this.left,this.top,this.width,this.height);
      }
      
      public function get maxWidth() : Number
      {
         return this._maxWidth;
      }
      
      public function set left(param1:Number) : void
      {
         this._left = param1;
      }
      
      public function get top() : Number
      {
         return this._top;
      }
      
      public function set maxHeight(param1:Number) : void
      {
         this._maxHeight = param1;
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = param1;
      }
      
      public function get left() : Number
      {
         return this._left;
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      public function set top(param1:Number) : void
      {
         this._top = param1;
      }
      
      public function get maxHeight() : Number
      {
         return this._maxHeight;
      }
      
      private function onRollOver(param1:MouseEvent) : void
      {
         Cursor.useSystem(false);
      }
      
      override public function set height(param1:Number) : void
      {
         this._height = param1;
      }
      
      private function onRollOut(param1:MouseEvent) : void
      {
         Cursor.useSystem(true);
      }
      
      private function farmOperate(param1:String) : void
      {
         var _loc2_:FarmOperateFloating = null;
         _loc2_ = new FarmOperateFloating(2000);
         _loc2_.text = param1;
         var _loc3_:Number = this.mouseX - scrollRect.x;
         var _loc4_:Number = this.mouseY - scrollRect.y;
         _loc2_.x = _loc3_;
         _loc2_.y = _loc4_;
         Float.open(_loc2_);
      }
      
      private function getRealitySize() : Array
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc1_:Number = 0;
         var _loc2_:Number = 0;
         var _loc3_:int = 0;
         while(_loc3_ < numChildren)
         {
            _loc4_ = getChildAt(_loc3_).width + getChildAt(_loc3_).x;
            if(_loc4_ > _loc1_)
            {
               _loc1_ = _loc4_;
            }
            _loc5_ = getChildAt(_loc3_).height + getChildAt(_loc3_).y;
            if(_loc5_ > _loc2_)
            {
               _loc2_ = _loc5_;
            }
            _loc3_++;
         }
         return [_loc1_,_loc2_];
      }
      
      private function onMouseMove(param1:MouseEvent) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Array = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         if(param1.buttonDown == true && !Cursor.useDrag)
         {
            _loc2_ = param1.stageX - this.downX;
            _loc3_ = param1.stageY - this.downY;
            _loc4_ = this.getRealitySize();
            _loc5_ = _loc4_[0] > this._maxWidth ? this._maxWidth : Number(_loc4_[0]);
            _loc6_ = _loc4_[1] > this._maxHeight ? this._maxHeight : Number(_loc4_[1]);
            if(this.downLeft - _loc2_ >= 0 && this.downLeft - _loc2_ + this.width <= _loc5_)
            {
               this.left = this.downLeft - _loc2_;
            }
            if(this.downTop - _loc3_ >= 0 && this.downTop - _loc3_ + this.height <= _loc6_)
            {
               this.top = this.downTop - _loc3_;
            }
            this.reRoll();
         }
         else
         {
            removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
            stage.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         }
      }
   }
}

