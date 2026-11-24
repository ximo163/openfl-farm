package com.qzone.allianceActivity.collectingActivity.view
{
   import com.qzone.allianceActivity.collectingActivity.model.CollectingConsts;
   import com.qzone.allianceActivity.framewrok.MVCFacade;
   import com.qzone.allianceActivity.framewrok.utils.StylesManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   
   public class CropListPage extends Sprite
   {
      
      private var _items:Array;
      
      private var _mode:int;
      
      private var _pager:MovieClip;
      
      private var _tip:ItemTip;
      
      private var _allCrops:Array;
      
      public var MAX_ITEMS:uint = 14;
      
      private const MAX_MAX_ITEMS:uint = 21;
      
      private var _hilight:Array;
      
      private var _currentIndex:int;
      
      public function CropListPage()
      {
         super();
      }
      
      private function showTip(param1:CropItemRender) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc2_:Object = param1.data;
         var _loc3_:int = this.x + param1.x + param1.width * 0.5 - 5;
         var _loc4_:int = this.y + param1.y + 5;
         if(_loc2_ != null)
         {
            this._tip.showCropTip(param1.id,_loc2_["cName"],_loc2_["star"],_loc2_["harvestNumber"],_loc3_,_loc4_);
         }
         else
         {
            this._tip.showCropTip(param1.id,"",0,0,_loc3_,_loc4_);
         }
      }
      
      public function reset() : void
      {
         var _loc1_:CropItemRender = null;
         this._pager["tfNum"].text = "1/1";
         this.stopScrollPage(true,true);
         this.stopScrollPage(false,true);
         this._currentIndex = 0;
         for each(_loc1_ in this._items)
         {
            _loc1_.hide();
         }
      }
      
      private function updateFooter() : void
      {
         var _loc1_:int = Math.floor(this._currentIndex / this.MAX_ITEMS) + 1;
         var _loc2_:int = 0;
         if(this._allCrops != null)
         {
            _loc2_ = int(this._allCrops.length);
         }
         var _loc3_:int = Math.ceil(_loc2_ / this.MAX_ITEMS) as int;
         this._pager["tfNum"].text = _loc1_ + "/" + _loc3_;
         if(this._currentIndex > 0)
         {
            this.stopScrollPage(true,false);
         }
         else
         {
            this.stopScrollPage(true,true);
         }
         if(this._currentIndex + this.MAX_ITEMS < _loc2_)
         {
            this.stopScrollPage(false,false);
         }
         else
         {
            this.stopScrollPage(false,true);
         }
      }
      
      private function handlePage() : void
      {
         if(this._allCrops == null)
         {
            return;
         }
         var _loc1_:Array = this._allCrops.slice(this._currentIndex,this._currentIndex + this.MAX_ITEMS);
         if(_loc1_ == null || _loc1_.length == 0)
         {
            return;
         }
         var _loc2_:int = 0;
         while(_loc2_ < this.MAX_ITEMS)
         {
            if(_loc2_ < _loc1_.length)
            {
               (this._items[_loc2_] as CropItemRender).id = _loc1_[_loc2_];
            }
            else
            {
               (this._items[_loc2_] as CropItemRender).hide();
            }
            _loc2_++;
         }
         this.hilightPage();
         this.updateFooter();
      }
      
      public function get baseData() : Array
      {
         return this._allCrops;
      }
      
      private function stopScrollPage(param1:Boolean, param2:Boolean) : void
      {
         if(param2 == true)
         {
            if(param1 == true)
            {
               this._pager["left"]["mouseEnabled"] = false;
               this._pager["left"].filters = StylesManager.getGrayFilter();
            }
            else
            {
               this._pager["right"]["mouseEnabled"] = false;
               this._pager["right"].filters = StylesManager.getGrayFilter();
            }
         }
         else if(param1 == true)
         {
            this._pager["left"]["mouseEnabled"] = true;
            this._pager["left"].filters = null;
         }
         else
         {
            this._pager["right"]["mouseEnabled"] = true;
            this._pager["right"].filters = null;
         }
      }
      
      private function hilightPage() : void
      {
         var _loc2_:* = undefined;
         var _loc1_:int = 0;
         while(_loc1_ < this._items.length)
         {
            for each(_loc2_ in this._hilight)
            {
               if((this._items[_loc1_] as CropItemRender).id == _loc2_["cId"])
               {
                  (this._items[_loc1_] as CropItemRender).hilight(_loc2_);
                  break;
               }
            }
            _loc1_++;
         }
      }
      
      public function unBindPager() : void
      {
         if(this._pager != null)
         {
            this._pager["left"].removeEventListener(MouseEvent.CLICK,this.onMouseEvent);
            this._pager["right"].removeEventListener(MouseEvent.CLICK,this.onMouseEvent);
         }
      }
      
      public function set hilight(param1:Array) : void
      {
         this._hilight = param1;
         if(param1 != null && param1.length > 0)
         {
            this.hilightPage();
         }
      }
      
      private function onMouseEvent(param1:MouseEvent) : void
      {
         var _loc3_:Mediator = null;
         var _loc2_:CropItemRender = null;
         if(param1.type == MouseEvent.CLICK)
         {
            if(this._allCrops != null && this._allCrops.length > 0)
            {
               if(param1.target.name == "left")
               {
                  this._currentIndex -= this.MAX_ITEMS;
                  if(this._currentIndex < 0)
                  {
                     this._currentIndex += this.MAX_ITEMS;
                  }
                  else
                  {
                     this.handlePage();
                  }
               }
               else if(param1.target.name == "right")
               {
                  this._currentIndex += this.MAX_ITEMS;
                  if(this._currentIndex >= this._allCrops.length)
                  {
                     this._currentIndex -= this.MAX_ITEMS;
                  }
                  else
                  {
                     this.handlePage();
                  }
               }
            }
            _loc2_ = param1.target as CropItemRender;
            if(_loc2_ != null && _loc2_.canBuy == true)
            {
               _loc3_ = MVCFacade.getInstance().getObj(CollectingConsts.MEDIATOR) as Mediator;
               _loc3_.openBuyWindow(_loc2_.id);
            }
         }
         else if(param1.type == MouseEvent.MOUSE_OVER)
         {
            _loc2_ = param1.target as CropItemRender;
            if(_loc2_ != null)
            {
               _loc2_.filters = CollectingConsts.textGlowFilter;
               this.showTip(_loc2_);
            }
         }
         else if(param1.type == MouseEvent.MOUSE_OUT)
         {
            _loc2_ = param1.target as CropItemRender;
            if(_loc2_ != null)
            {
               _loc2_.filters = null;
               if(this._tip != null)
               {
                  this._tip.hide(true);
               }
            }
         }
      }
      
      public function rebind(param1:int, param2:MovieClip, param3:ItemTip) : void
      {
         this._mode = param1;
         this._pager = param2;
         this._tip = param3;
         this._pager["left"].addEventListener(MouseEvent.CLICK,this.onMouseEvent,false,0,true);
         this._pager["right"].addEventListener(MouseEvent.CLICK,this.onMouseEvent,false,0,true);
      }
      
      public function destroy() : void
      {
         var _loc1_:CropItemRender = null;
         for each(_loc1_ in this._items)
         {
            _loc1_.destroy();
         }
         this._items = null;
         this._allCrops = null;
         this._hilight = null;
         this._tip = null;
      }
      
      public function set baseData(param1:Array) : void
      {
         var _loc2_:CropItemRender = null;
         var _loc3_:int = 0;
         this.reset();
         if(this._items == null)
         {
            this._items = new Array();
            _loc2_ = null;
            _loc3_ = 0;
            while(_loc3_ < this.MAX_MAX_ITEMS)
            {
               _loc2_ = new CropItemRender();
               _loc2_.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseEvent,false,0,true);
               _loc2_.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseEvent,false,0,true);
               _loc2_.addEventListener(MouseEvent.CLICK,this.onMouseEvent,false,0,true);
               this._items.push(_loc2_);
               addChild(_loc2_);
               _loc3_++;
            }
         }
         this._allCrops = param1;
         this.handlePage();
         LayoutManager.sortByGrid(this._items,7,0,0,11,8);
      }
   }
}

import com.qzone.allianceActivity.collectingActivity.model.CollectingConsts;
import com.qzone.allianceActivity.collectingActivity.model.CollectingModel;
import com.qzone.allianceActivity.framewrok.MVCFacade;
import com.qzone.allianceActivity.interfaces.IAllianceAppHelper;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.system.SecurityDomain;

class CropItemRender extends Sprite
{
   
   private var _class:Class = CropItemRender__class;
   
   private var _id:int;
   
   private var _data:Object;
   
   private var _api:IAllianceAppHelper;
   
   private var _lv:int;
   
   private var _render:Sprite;
   
   private var _model:CollectingModel;
   
   private var _ldr:Loader;
   
   public function CropItemRender()
   {
      super();
      mouseChildren = false;
      buttonMode = true;
      this._api = MVCFacade.getInstance().getObj(CollectingConsts.APPHELPER) as IAllianceAppHelper;
      this._model = MVCFacade.getInstance().getObj(CollectingConsts.MODEL) as CollectingModel;
   }
   
   public function hide() : void
   {
      var _loc1_:DisplayObjectContainer = null;
      if(this._render != null)
      {
         this._render.visible = false;
         this._render["star1"].visible = false;
         this._render["star2"].visible = false;
         this._render["star3"].visible = false;
         this._render["tfLvl"].text = "";
         _loc1_ = this._render["holder"] as DisplayObjectContainer;
         while(_loc1_.numChildren > 0)
         {
            _loc1_.removeChildAt(0);
         }
      }
   }
   
   public function get data() : Object
   {
      return this._data;
   }
   
   private function render() : void
   {
      var _loc2_:DisplayObjectContainer = null;
      if(this._render == null)
      {
         this._render = new this._class() as Sprite;
         addChild(this._render);
      }
      else
      {
         this._render.visible = true;
         this._render["gray"].visible = true;
      }
      var _loc1_:String = this._api.execute("10006",this._id) as String;
      if(_loc1_ != null && _loc1_ != "")
      {
         if(this._ldr == null)
         {
            this._ldr = new Loader();
            this._ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.errorHandler);
            this._ldr.contentLoaderInfo.addEventListener(IOErrorEvent.NETWORK_ERROR,this.errorHandler);
            this._ldr.contentLoaderInfo.addEventListener(Event.COMPLETE,this.loadComplete);
         }
         else
         {
            this._ldr.unload();
         }
         _loc2_ = this._render["holder"] as DisplayObjectContainer;
         while(_loc2_.numChildren > 0)
         {
            _loc2_.removeChildAt(0);
         }
         this._ldr.load(new URLRequest(_loc1_),new LoaderContext(true,ApplicationDomain.currentDomain,SecurityDomain.currentDomain));
      }
      this._render["star1"].visible = false;
      this._render["star2"].visible = false;
      this._render["star3"].visible = false;
      this._render["tfLvl"].text = this._lv + "级";
      if(this.canBuy == false)
      {
         this._render["gray"].gotoAndStop(2);
      }
      else
      {
         this._render["gray"].gotoAndStop(1);
      }
   }
   
   public function get canBuy() : Boolean
   {
      var _loc1_:Object = this._model.getCropConfig(this._id);
      if(_loc1_ != null && _loc1_["qd"] != undefined && _loc1_["qd"] > 0 && _loc1_["sr"] == 0)
      {
         return false;
      }
      return true;
   }
   
   public function get id() : int
   {
      return this._id;
   }
   
   private function errorHandler(param1:IOErrorEvent) : void
   {
   }
   
   public function set id(param1:int) : void
   {
      this._id = param1;
      if(this._data != null)
      {
         this._data["star"] = 0;
         this._data["harvestNumber"] = 0;
      }
      var _loc2_:Object = this._model.getCropConfig(this.id);
      if(_loc2_ != null)
      {
         if(_loc2_["lv"] != undefined)
         {
            this._lv = _loc2_["lv"];
         }
         if(this._data != null)
         {
            this._data["cName"] = _loc2_["name"];
         }
      }
      this.render();
   }
   
   public function destroy() : void
   {
      if(this._ldr != null)
      {
         this._ldr.unload();
         this._ldr = null;
      }
      if(this._render != null)
      {
         removeChild(this._render);
         this._render = null;
      }
   }
   
   public function hilight(param1:Object) : void
   {
      if(param1 == null || param1["cId"] == undefined || param1["cId"] != this._id)
      {
         return;
      }
      this._data = {
         "cId":param1["cId"],
         "cName":param1["cName"],
         "harvestNumber":param1["harvestNumber"],
         "star":param1["star"]
      };
      this._render["star1"].visible = false;
      this._render["star2"].visible = false;
      this._render["star3"].visible = false;
      var _loc2_:int = int(param1["star"]);
      if(_loc2_ == 1)
      {
         this._render["star1"].visible = true;
         this._render["star2"].visible = false;
         this._render["star3"].visible = false;
      }
      else if(_loc2_ == 2)
      {
         this._render["star1"].visible = true;
         this._render["star2"].visible = true;
         this._render["star3"].visible = false;
      }
      else if(_loc2_ == 3)
      {
         this._render["star1"].visible = true;
         this._render["star2"].visible = true;
         this._render["star3"].visible = true;
      }
      if(param1["harvestNumber"] > 0)
      {
         this._render["gray"].visible = false;
      }
   }
   
   private function loadComplete(param1:Event) : void
   {
      var _loc3_:Class = null;
      var _loc4_:DisplayObject = null;
      var _loc5_:DisplayObjectContainer = null;
      var _loc2_:String = "Crop_" + this._id + "_Seed";
      if(ApplicationDomain.currentDomain.hasDefinition(_loc2_) == true)
      {
         _loc3_ = ApplicationDomain.currentDomain.getDefinition(_loc2_) as Class;
         if(_loc3_ != null)
         {
            _loc4_ = new _loc3_() as DisplayObject;
            _loc4_.width = 60;
            _loc4_.height = 60;
            _loc4_.x = 5;
            _loc4_.y = 2;
            _loc5_ = this._render["holder"] as DisplayObjectContainer;
            _loc5_.addChild(_loc4_);
         }
      }
   }
}
