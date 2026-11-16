package framework.layers
{
   import common.Consts;
   import common.view.cursor.CursorControl;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import framework.base.BaseLayer;
   import interfaces.IMsgCenter;
   import module.FarmApplication;
   
   public class FarmLayer extends BaseLayer
   {
      
      private var _height:Number;
      
      private var _width:Number;
      
      private var _downTop:Number;
      
      private var _top:Number;
      
      private var _maxWidth:Number;
      
      private var _left:Number;
      
      private var _downLeft:Number;
      
      private var _realitySize:Array;
      
      private var _maxHeight:Number;
      
      private var _downX:Number;
      
      private var _downY:Number;
      
      public function FarmLayer(param1:IMsgCenter)
      {
         super(param1);
         this.name = Consts.LAYER_SCENE_CONTENT;
         this._left = this._top = 0;
         this._width = this._height = 100;
         this._maxWidth = this._maxHeight = 10000;
         this._downLeft = this._downTop = 0;
         this._downX = this._downY = 0;
         this._realitySize = null;
      }
      
      private function onMouseUp(param1:MouseEvent) : void
      {
         removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         stage.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         this._realitySize = null;
      }
      
      public function set maxWidth(param1:Number) : void
      {
         this._maxWidth = param1;
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove,false,0,true);
         stage.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp,false,0,true);
         this._downX = param1.stageX;
         this._downY = param1.stageY;
         this._downLeft = this.left;
         this._downTop = this.top;
         this._realitySize = this.getRealitySize();
      }
      
      public function get maxWidth() : Number
      {
         return this._maxWidth;
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override protected function init() : void
      {
         this.reRoll();
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         addEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         addEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
      }
      
      public function get top() : Number
      {
         return this._top;
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = param1;
      }
      
      public function set left(param1:Number) : void
      {
         this._left = param1;
      }
      
      public function reRoll() : void
      {
         this.scrollRect = new Rectangle(this.left,this.top,this.width,this.height);
      }
      
      override public function set height(param1:Number) : void
      {
         this._height = param1;
      }
      
      public function set maxHeight(param1:Number) : void
      {
         this._maxHeight = param1;
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      public function get left() : Number
      {
         return this._left;
      }
      
      public function set top(param1:Number) : void
      {
         this._top = param1;
      }
      
      public function get maxHeight() : Number
      {
         return this._maxHeight;
      }
      
      private function onRollOut(param1:MouseEvent) : void
      {
         var _loc2_:FarmApplication = super.m_msgCenter as FarmApplication;
         if(_loc2_ != null)
         {
            _loc2_.useSystemCursor(true);
         }
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
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         if(param1.buttonDown == true)
         {
            _loc2_ = param1.stageX - this._downX;
            _loc3_ = param1.stageY - this._downY;
            if(this._realitySize == null)
            {
               this._realitySize = this.getRealitySize();
            }
            _loc4_ = this._realitySize[0] > this._maxWidth ? this._maxWidth : Number(this._realitySize[0]);
            _loc5_ = this._realitySize[1] > this._maxHeight ? this._maxHeight : Number(this._realitySize[1]);
            if(this._downLeft - _loc2_ >= 0 && this._downLeft - _loc2_ + this.width <= _loc4_)
            {
               this.left = this._downLeft - _loc2_;
            }
            if(this._downTop - _loc3_ >= 0 && this._downTop - _loc3_ + this.height <= _loc5_)
            {
               this.top = this._downTop - _loc3_;
            }
            this.reRoll();
         }
         else
         {
            removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
            stage.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
            this._realitySize = null;
         }
      }
      
      private function onRollOver(param1:MouseEvent) : void
      {
         var _loc2_:FarmApplication = super.m_msgCenter as FarmApplication;
         if(_loc2_ != null)
         {
            _loc2_.useSystemCursor(false);
         }
         var _loc3_:CursorControl = _loc2_.farmView.cursorCtrl;
         if(this.name == Consts.LAYER_SCENE_CONTENT)
         {
            if(_loc3_.name == Consts.CURSOR_WILD_HAND)
            {
               _loc3_.setCursor(Consts.CURSOR_STYLE_ARROW);
            }
            else if(_loc3_.name == null || _loc3_.name == "")
            {
               _loc2_.dispatchEvent(new Event(Consts.MSG_SET_LAND_CURSOR));
            }
         }
      }
   }
}

