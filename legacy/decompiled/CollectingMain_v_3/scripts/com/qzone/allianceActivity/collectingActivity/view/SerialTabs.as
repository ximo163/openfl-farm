package com.qzone.allianceActivity.collectingActivity.view
{
   import com.qzone.allianceActivity.collectingActivity.model.CollectingConsts;
   import com.qzone.allianceActivity.collectingActivity.model.CollectingModel;
   import com.qzone.allianceActivity.framewrok.MVCFacade;
   import com.qzone.allianceActivity.framewrok.utils.StylesManager;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   
   public class SerialTabs extends EventDispatcher
   {
      
      private var _btnLeft:SimpleButton;
      
      private var _parent:DisplayObjectContainer;
      
      private var _items:Array;
      
      private var _mode:int;
      
      private var _arrow:MovieClip;
      
      private var _container:DisplayObjectContainer;
      
      private var _selected:int;
      
      private const inset:int = 12;
      
      private var _config:XML;
      
      private const MAX_ITEMS:uint = 6;
      
      private var _model:CollectingModel;
      
      private var _currentIndex:int;
      
      private var _baseData:Array;
      
      private var _btnRight:SimpleButton;
      
      public function SerialTabs(param1:XML, param2:DisplayObjectContainer)
      {
         super(null);
         this._config = param1;
         this._parent = param2;
         this._container = new Sprite();
         if(param2 != null)
         {
            this._container.x = 130;
            this._container.y = 118;
            param2.addChild(this._container);
         }
         this._selected = 0;
         this._currentIndex = 0;
         this._model = MVCFacade.getInstance().getObj(CollectingConsts.MODEL) as CollectingModel;
         this._container.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseEvent,false,0,true);
         this._container.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseEvent,false,0,true);
         this._container.addEventListener(MouseEvent.CLICK,this.onMouseEvent,false,0,true);
      }
      
      private function updateArrow() : void
      {
         var _loc2_:SerialItemRender = null;
         if(this._arrow == null)
         {
            return;
         }
         var _loc1_:SerialItemRender = null;
         for each(_loc2_ in this._items)
         {
            if(_loc2_.serial == this._selected)
            {
               _loc2_.hilightBorder(true);
               _loc2_.scaleX = _loc2_.scaleY = 1.08;
               _loc1_ = _loc2_;
            }
            else
            {
               _loc2_.hilightBorder(false);
               _loc2_.scaleX = _loc2_.scaleY = 1;
            }
         }
         if(_loc1_ == null)
         {
            this._arrow.visible = false;
         }
         else
         {
            this._arrow.x = this._container.x + _loc1_.x + _loc1_.width * 0.5;
            this._arrow.visible = true;
         }
      }
      
      private function scrollLeft() : void
      {
         this._currentIndex -= this.MAX_ITEMS;
         if(this._currentIndex < 0)
         {
            this._currentIndex += this.MAX_ITEMS;
            return;
         }
         this.handlePage();
         this.updateScroller();
         this.updateArrow();
      }
      
      private function onMouseEvent(param1:MouseEvent) : void
      {
         var _loc2_:DisplayObject = param1.target as DisplayObject;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:String = _loc2_.name;
         if(param1.type == MouseEvent.CLICK)
         {
            if(_loc3_ == "btnLeft")
            {
               this.scrollLeft();
            }
            else if(_loc3_ == "btnRight")
            {
               this.scrollRight();
            }
            else if(_loc2_ is SerialItemRender)
            {
               if((_loc2_ as SerialItemRender).serial != this._selected)
               {
                  this.switch2Serial((_loc2_ as SerialItemRender).serial);
                  dispatchEvent(new Event(Event.CHANGE));
               }
            }
         }
         else if(param1.type != MouseEvent.MOUSE_OVER)
         {
            if(param1.type == MouseEvent.MOUSE_OUT)
            {
            }
         }
      }
      
      private function scrollRight() : void
      {
         this._currentIndex += this.MAX_ITEMS;
         if(this._currentIndex >= this._baseData.length)
         {
            this._currentIndex -= this.MAX_ITEMS;
            return;
         }
         this.handlePage();
         this.updateScroller();
         this.updateArrow();
      }
      
      private function handlePage() : void
      {
         var _loc4_:* = undefined;
         if(this._container == null)
         {
            return;
         }
         if(this._baseData == null || this._baseData.length == 0)
         {
            return;
         }
         var _loc1_:Array = this._baseData.slice(this._currentIndex,this._currentIndex + this.MAX_ITEMS);
         if(_loc1_ == null || _loc1_.length == 0)
         {
            return;
         }
         if(this._items == null)
         {
            this._items = new Array();
         }
         var _loc2_:int = 0;
         var _loc3_:SerialItemRender = null;
         for each(_loc4_ in _loc1_)
         {
            if(_loc2_ < this._items.length)
            {
               _loc3_ = this._items[_loc2_] as SerialItemRender;
            }
            else
            {
               _loc3_ = new SerialItemRender();
               _loc3_.buttonMode = true;
               this._container.addChild(_loc3_);
               this._items.push(_loc3_);
            }
            _loc3_.data = _loc4_;
            _loc3_.collected = _loc3_.sum;
            _loc2_++;
         }
         while(_loc2_ < this._items.length)
         {
            _loc3_ = this._items[_loc2_] as SerialItemRender;
            _loc3_.data = null;
            _loc2_++;
         }
         LayoutManager.sortByRow(this._items,0,0,this.inset);
      }
      
      public function switch2Serial(param1:int) : Boolean
      {
         var _loc3_:* = undefined;
         var _loc4_:int = 0;
         var _loc2_:int = 0;
         for each(_loc3_ in this._baseData)
         {
            if(_loc3_["id"] == param1)
            {
               break;
            }
            _loc2_++;
         }
         _loc4_ = Math.floor(_loc2_ / this.MAX_ITEMS) * this.MAX_ITEMS;
         if(this._currentIndex != _loc4_)
         {
            this._currentIndex = _loc4_;
            this.handlePage();
            this.updateScroller();
         }
         this._selected = param1;
         this.updateArrow();
         return true;
      }
      
      public function get selected() : int
      {
         return this._selected;
      }
      
      private function updateScroller() : void
      {
         if(this._currentIndex == 0 || this._baseData == null || this._baseData.length == 0)
         {
            this._btnLeft.enabled = false;
            this._btnLeft.filters = StylesManager.getGrayFilter();
         }
         else
         {
            this._btnLeft.enabled = true;
            this._btnLeft.filters = null;
         }
         if(this._baseData == null || this._baseData.length == 0 || this._currentIndex + this.MAX_ITEMS >= this._baseData.length)
         {
            this._btnRight.enabled = false;
            this._btnRight.filters = StylesManager.getGrayFilter();
         }
         else
         {
            this._btnRight.enabled = true;
            this._btnRight.filters = null;
         }
      }
      
      public function destroy() : void
      {
         var _loc1_:SerialItemRender = null;
         if(this._baseData != null)
         {
            this._baseData.splice(0,-1);
         }
         for each(_loc1_ in this._items)
         {
            _loc1_.destroy();
         }
         this._items = null;
         this._baseData = null;
         this._selected = 0;
      }
      
      public function buildSerialsTab(param1:int) : void
      {
         if(this._config == null || this._container == null)
         {
            return;
         }
         var _loc2_:Dictionary = this._model.serialsData;
         var _loc3_:String = null;
         this._baseData = new Array();
         if(this._mode == 0)
         {
            for(_loc3_ in _loc2_)
            {
               if(_loc2_[_loc3_]["type"] == param1 && _loc2_[_loc3_]["id"] >= CollectingConsts.NORMAL_SERIAL_START)
               {
                  this._baseData.push(_loc2_[_loc3_]);
               }
            }
         }
         else
         {
            for(_loc3_ in _loc2_)
            {
               if(_loc2_[_loc3_]["id"] < CollectingConsts.NORMAL_SERIAL_START && _loc2_[_loc3_]["visible"] == true)
               {
                  if(_loc2_[_loc3_]["type"] == param1)
                  {
                     this._baseData.push(_loc2_[_loc3_]);
                  }
               }
            }
         }
         this._currentIndex = -1;
         this._selected = 0;
         if(this._baseData.length > 0)
         {
            this.switch2Serial(this._baseData[0]["id"]);
         }
         else
         {
            this.handlePage();
            this.updateScroller();
            this.updateArrow();
         }
      }
      
      public function updateTabs() : void
      {
      }
      
      public function refreshSerialIcons() : void
      {
         var _loc2_:SerialItemRender = null;
         var _loc1_:SerialsCache = SerialsCache.getInstance();
         for each(_loc2_ in this._items)
         {
            _loc2_.icon = _loc1_.getSerialIconFromCache(_loc2_.serial);
         }
      }
      
      public function rebind(param1:int, param2:SimpleButton, param3:SimpleButton, param4:MovieClip) : void
      {
         this.destroy();
         this._mode = param1;
         this._btnLeft = param2;
         this._btnRight = param3;
         this._arrow = param4;
         this._btnLeft.addEventListener(MouseEvent.CLICK,this.onMouseEvent,false,0,true);
         this._btnRight.addEventListener(MouseEvent.CLICK,this.onMouseEvent,false,0,true);
      }
   }
}

