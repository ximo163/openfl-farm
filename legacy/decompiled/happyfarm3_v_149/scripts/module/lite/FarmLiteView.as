package module.lite
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.DataEvent;
   import flash.events.Event;
   import flash.events.HTTPStatusEvent;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.net.URLRequest;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.ui.Mouse;
   import flash.utils.Dictionary;
   
   public class FarmLiteView extends Sprite
   {
      
      public static var SCALE:Number = 0.75;
      
      public static var LAND_SUM:int = 24;
      
      public static const ITEM_WIDTH:Number = 204 * SCALE;
      
      public static const ITEM_HEIGHT:Number = 102 * SCALE;
      
      private var _arrowCursor:CursorArrow_Lite;
      
      private var _items:Array;
      
      private const ITEM_TIP_OFFSET:Number = 20 * SCALE;
      
      private var _overFilters:Array;
      
      private var _bgLoader:Loader;
      
      private var _poolLoading:FarmLoading_Lite;
      
      private var _harvestAnimationStep:Dictionary;
      
      private var _pickIcon:canPickIcon_Lite;
      
      private var _model:FarmLiteModel;
      
      private var _currentItem:int;
      
      private var _currentCursor:DisplayObject;
      
      private var _pickIndex:int;
      
      private var _pickCursor:CursorHand_Lite;
      
      public function FarmLiteView(param1:FarmLiteModel)
      {
         super();
         this._model = param1;
         this._currentItem = -1;
         this._overFilters = [new ColorMatrixFilter([1.6,0,0,0,-21.59,0,1.6,0,0,-21.59,0,0,1.6,0,-21.59,0,0,0,1,0])];
         this._items = null;
         this._pickIcon = new canPickIcon_Lite();
         this._pickIcon.scaleX = this._pickIcon.scaleY = 1 / SCALE;
         this._pickIcon.mouseChildren = false;
         this._pickIcon.mouseEnabled = false;
         this._pickIndex = -1;
         addEventListener(Event.ADDED_TO_STAGE,this.onInit,false,0,true);
         addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove,false,0,true);
         addEventListener(MouseEvent.ROLL_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.ROLL_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp,false,0,true);
         addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
         this._model.addEventListener(FarmLiteModel.EVENT_HARVEST,this.onHarvest,false,0,true);
      }
      
      private function onHarvest(param1:DataEvent) : void
      {
         var _loc5_:DisplayObjectContainer = null;
         var _loc6_:Number = NaN;
         var _loc7_:DisplayObject = null;
         var _loc8_:TextField = null;
         var _loc2_:String = param1.data;
         var _loc3_:Array = _loc2_.split(",");
         if(_loc3_ == null || _loc3_.length == 0)
         {
            return;
         }
         var _loc4_:Number = parseFloat(_loc3_[0]);
         if(isNaN(_loc4_) == true)
         {
            return;
         }
         if(_loc4_ >= 0 && _loc4_ < this._items.length)
         {
            _loc5_ = this._items[_loc4_] as DisplayObjectContainer;
            if(_loc5_ != null)
            {
               _loc7_ = _loc5_.getChildByName("_seed_");
               if(_loc7_ != null)
               {
                  _loc5_.removeChild(_loc7_);
               }
               _loc7_ = null;
            }
            _loc6_ = parseFloat(_loc3_[1]);
            if(isNaN(_loc6_) == false)
            {
               _loc8_ = new TextField();
               _loc8_.defaultTextFormat = new TextFormat("Verdana",18,16737792,true);
               _loc8_.filters = [new GlowFilter(16777215,1,3,3,7)];
               _loc8_.autoSize = TextFieldAutoSize.LEFT;
               _loc8_.text = "+" + _loc6_.toString();
               _loc8_.addEventListener(Event.ENTER_FRAME,this.onHarvestAnimation,false,0,true);
               _loc5_.addChild(_loc8_);
               _loc8_.x = (_loc5_.width - _loc8_.textWidth) / 2;
               _loc8_.y = -_loc8_.textHeight;
               if(this._harvestAnimationStep == null)
               {
                  this._harvestAnimationStep = new Dictionary();
               }
               this._harvestAnimationStep[_loc8_] = 0;
            }
         }
         if(this._pickIndex == _loc4_)
         {
            this._pickIndex = -1;
            if(this._pickIcon.parent != null)
            {
               this._pickIcon.parent.removeChild(this._pickIcon);
            }
            this.showPickIcon();
         }
      }
      
      private function pick(param1:int) : void
      {
         var _loc2_:Object = this._model.getLandByIndex(param1);
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:int = 0;
         if(_loc2_["a"] != 0)
         {
            _loc3_ = this._model.idState(parseInt(_loc2_["a"]),parseFloat(_loc2_["q"]),parseInt(_loc2_["b"]),parseInt(_loc2_["bitmap"]),parseInt(_loc2_["a"]));
            if(_loc3_ != 5)
            {
               return;
            }
            this._model.harvest(param1);
         }
      }
      
      private function onInit(param1:Event) : void
      {
         this._bgLoader = new Loader();
         this._bgLoader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS,this.onLoadError,false,0,true);
         this._bgLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onLoadError,false,0,true);
         this._bgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoadComplete,false,0,true);
         this._bgLoader.load(new URLRequest(this._model.background));
         this._bgLoader.mouseChildren = false;
         this._bgLoader.mouseEnabled = false;
         addChildAt(this._bgLoader,0);
         this._bgLoader.x = (1024 - stage.stageWidth) / 2;
         this._bgLoader.y = (768 - stage.stageWidth) / 2;
         this._items = new Array();
         var _loc2_:Object = null;
         var _loc3_:Sprite = null;
         var _loc4_:Point = null;
         var _loc5_:FarmLoading_Lite = null;
         var _loc6_:int = 0;
         while(_loc6_ < LAND_SUM)
         {
            _loc2_ = this._model.getLandByIndex(_loc6_);
            if(_loc2_ == null)
            {
               _loc3_ = new Wasteland_Lite();
               _loc4_ = this.calcXY(_loc6_);
               _loc3_.x = _loc4_.x;
               _loc3_.y = _loc4_.y;
               _loc3_.scaleX = _loc3_.scaleY = SCALE;
               _loc3_.mouseEnabled = false;
               this._items.push(_loc3_);
               addChild(_loc3_);
            }
            else
            {
               if(_loc2_["bitmap"] > 2)
               {
                  _loc2_["bitmap"] = 2;
               }
               if(_loc2_["bitmap"] == 0)
               {
                  _loc3_ = new Farmland_Lite();
               }
               else if(_loc2_["bitmap"] == 1)
               {
                  _loc3_ = new FarmlandRed_Lite();
               }
               else if(_loc2_["bitmap"] == 2)
               {
                  _loc3_ = new FarmlandBlack_Lite();
               }
               _loc4_ = this.calcXY(_loc6_);
               _loc3_.x = _loc4_.x;
               _loc3_.y = _loc4_.y;
               _loc3_.scaleX = _loc3_.scaleY = SCALE;
               _loc3_.mouseChildren = false;
               _loc3_.name = "_land_" + _loc6_;
               this._items.push(_loc3_);
               addChild(_loc3_);
               if(_loc2_["a"] != 0)
               {
                  _loc5_ = new FarmLoading_Lite();
                  _loc5_.mouseChildren = false;
                  _loc5_.mouseEnabled = false;
                  _loc5_.x = _loc3_.width * 0.5 + 20;
                  _loc5_.y = (_loc3_.height - _loc5_.height) * 0.5;
                  _loc5_.name = "_seed_";
                  _loc3_.addChild(_loc5_);
               }
            }
            _loc6_++;
         }
         this.showPickIcon();
         this._poolLoading = new FarmLoading_Lite();
         _loc4_ = this.calcXY(16);
         this._poolLoading.x = _loc4_.x + 150;
         this._poolLoading.y = _loc4_.y + 125;
         this._poolLoading.mouseEnabled = false;
         addChild(this._poolLoading);
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(this._currentCursor == null)
         {
            Mouse.hide();
            if(this._pickIndex == -1)
            {
               if(this._arrowCursor == null)
               {
                  this._arrowCursor = new CursorArrow_Lite();
                  this._arrowCursor.mouseEnabled = false;
                  this._arrowCursor.mouseChildren = false;
               }
               this._currentCursor = this._arrowCursor;
            }
            else
            {
               if(this._pickCursor == null)
               {
                  this._pickCursor = new CursorHand_Lite();
                  this._pickCursor.mouseEnabled = false;
                  this._pickCursor.mouseChildren = false;
               }
               this._currentCursor = this._pickCursor;
            }
            this._currentCursor.x = mouseX;
            this._currentCursor.y = mouseY;
            addChild(this._currentCursor);
         }
         var _loc2_:DisplayObject = param1.target as DisplayObject;
         if(_loc2_.name.indexOf("_land_") != -1)
         {
            _loc2_.filters = this._overFilters;
         }
      }
      
      private function onMouseUp(param1:MouseEvent) : void
      {
         if(this._currentCursor != null)
         {
            this._currentCursor["gotoAndStop"](1);
         }
      }
      
      private function calcXY(param1:int) : Point
      {
         var _loc2_:Number = 225;
         var _loc3_:Number = 92;
         var _loc4_:Point = new Point();
         var _loc5_:int = param1 / 3;
         var _loc6_:int = param1 % 3;
         if(param1 < 18)
         {
            _loc4_.x = _loc2_ + _loc5_ * ITEM_WIDTH / 2 - _loc6_ * ITEM_WIDTH / 2;
            _loc4_.y = _loc3_ + _loc5_ * ITEM_HEIGHT / 2 + _loc6_ * ITEM_HEIGHT / 2;
         }
         else
         {
            _loc2_ = -3;
            _loc3_ += ITEM_HEIGHT * 1.5;
            _loc5_ = param1 - 18;
            _loc4_.x = _loc2_ + _loc5_ * ITEM_WIDTH / 2;
            _loc4_.y = _loc3_ + _loc5_ * ITEM_HEIGHT / 2;
         }
         return _loc4_;
      }
      
      private function showPickIcon() : void
      {
         if(this._pickIndex != -1)
         {
            return;
         }
         var _loc1_:Object = null;
         var _loc2_:Sprite = null;
         var _loc3_:int = 0;
         var _loc4_:Array = [0,3,6,9,12,15,1,4,7,10,13,16,2,5,8,11,14,17,18,19,20,21,22,23];
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_.length)
         {
            _loc1_ = this._model.getLandByIndex(_loc4_[_loc5_]);
            if(_loc1_ != null)
            {
               _loc2_ = getChildByName("_land_" + _loc4_[_loc5_]) as Sprite;
               if(_loc2_ != null)
               {
                  if(_loc1_["a"] != 0 && _loc1_["k"] > 0 && _loc1_["m"] > 0)
                  {
                     _loc3_ = this._model.idState(parseInt(_loc1_["a"]),parseFloat(_loc1_["q"]),parseInt(_loc1_["b"]),parseInt(_loc1_["bitmap"]),parseInt(_loc1_["a"]));
                     if(_loc3_ >= 5)
                     {
                        this._pickIcon.x = _loc2_.width * 0.5;
                        this._pickIcon.y = -40;
                        _loc2_.addChild(this._pickIcon);
                        this._pickIndex = _loc4_[_loc5_];
                        break;
                     }
                  }
               }
            }
            _loc5_++;
         }
      }
      
      private function onHarvestAnimation(param1:Event) : void
      {
         var _loc2_:DisplayObject = param1.target as DisplayObject;
         if(_loc2_ == null)
         {
            return;
         }
         if(this._harvestAnimationStep == null || this._harvestAnimationStep[_loc2_] == undefined)
         {
            return;
         }
         var _loc3_:int = this._harvestAnimationStep[_loc2_] as int;
         _loc2_.y -= Math.abs(Math.cos(_loc3_ * 5) * 20);
         if(++_loc3_ > 10)
         {
            _loc2_.removeEventListener(Event.ENTER_FRAME,this.onHarvestAnimation);
            _loc2_.parent.removeChild(_loc2_);
            delete this._harvestAnimationStep[_loc2_];
            _loc2_ = null;
            return;
         }
         this._harvestAnimationStep[_loc2_] += 1;
      }
      
      private function onLoadError(param1:Event) : void
      {
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         var _loc2_:DisplayObject = param1.target as DisplayObject;
         if(_loc2_ == null || _loc2_.name.indexOf("_land_") == -1)
         {
            return;
         }
         var _loc3_:int = parseInt(_loc2_.name.substring(6));
         this.pick(_loc3_);
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         Mouse.show();
         if(this._currentCursor != null && this._currentCursor.parent != null)
         {
            removeChild(this._currentCursor);
            this._currentCursor = null;
         }
         var _loc2_:DisplayObject = param1.target as DisplayObject;
         if(_loc2_.name.indexOf("_land_") != -1)
         {
            _loc2_.filters = null;
         }
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         if(this._currentCursor != null)
         {
            if(this._currentCursor["totalFrames"] > 1)
            {
               this._currentCursor["gotoAndStop"](2);
            }
         }
      }
      
      private function onMouseMove(param1:MouseEvent) : void
      {
         if(this._currentCursor != null)
         {
            this._currentCursor.x = mouseX;
            this._currentCursor.y = mouseY;
         }
      }
      
      public function destroy() : void
      {
         var _loc2_:DisplayObjectContainer = null;
         var _loc1_:MovieClip = null;
         for each(_loc2_ in this._items)
         {
            if(_loc2_ is MovieClip)
            {
               _loc2_["stop"]();
            }
            _loc1_ = _loc2_.getChildByName("_seed_") as MovieClip;
            if(_loc1_ != null)
            {
               _loc1_.stop();
            }
            removeChild(_loc2_);
         }
         if(this._pickIcon != null)
         {
            this._pickIcon.stop();
            if(this._pickIcon.parent != null)
            {
               this._pickIcon.parent.removeChild(this._pickIcon);
            }
            this._pickIcon = null;
         }
         if(this._currentCursor != null && this._currentCursor.parent != null)
         {
            this._currentCursor.parent.removeChild(this._currentCursor);
         }
         if(this._poolLoading != null && this._poolLoading.parent != null)
         {
            this._poolLoading.parent.removeChild(this._poolLoading);
         }
         this._poolLoading = null;
         this._currentCursor = null;
         this._items = null;
      }
      
      private function onLoadComplete(param1:Event) : void
      {
         this._bgLoader.x = -50;
         this._bgLoader.y = -190;
      }
   }
}

