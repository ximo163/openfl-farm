package com.qzone.allianceActivity.collectingActivity.view
{
   import com.qzone.allianceActivity.collectingActivity.model.CollectingConsts;
   import com.qzone.allianceActivity.framewrok.MVCFacade;
   import com.qzone.allianceActivity.framewrok.utils.StylesManager;
   import com.qzone.allianceActivity.interfaces.IAllianceAppHelper;
   import flash.display.DisplayObject;
   import flash.display.InteractiveObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.utils.Dictionary;
   
   public class ScorePage extends Sprite
   {
      
      private var _items:Array;
      
      private var _pager:Sprite;
      
      private var _data:Array;
      
      private var _friendsCollection:Dictionary;
      
      private var _api:IAllianceAppHelper;
      
      private var _tip:ItemTip;
      
      private var _myProfile:MovieClip;
      
      private const MAX_ITEMS:uint = 24;
      
      private var _photo:Loader;
      
      private var _hilight:Dictionary;
      
      private var _currentIndex:int;
      
      public function ScorePage(param1:IAllianceAppHelper)
      {
         super();
         this._currentIndex = 0;
         this._items = null;
         this._api = param1;
      }
      
      private function showTip(param1:SerialItemRender) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         if(param1 == null)
         {
            return;
         }
         var _loc2_:Object = param1.data;
         if(_loc2_ != null)
         {
            _loc3_ = param1.serial;
            _loc4_ = 0;
            _loc5_ = 0;
            _loc4_ = _loc2_["collected"] as int;
            _loc6_ = this.x + param1.x + param1.width * 0.5;
            _loc7_ = this.y + param1.y;
            this._tip.showSerialTip(param1.serial,_loc4_,_loc6_,_loc7_);
         }
      }
      
      public function set headerInfo(param1:*) : void
      {
         var p:int;
         var reload:Boolean;
         var errorHandler:Function = null;
         var url:String = null;
         var info:* = param1;
         errorHandler = function(param1:IOErrorEvent):void
         {
         };
         if(info["name"] != undefined && info["name"].length > 8)
         {
            info["name"] = (info["name"] as String).substr(0,8) + "..";
         }
         this._myProfile["tfName"].text = info["name"];
         this._myProfile["p0"].text = info["serials"] + "/" + info["serialSum"];
         this._myProfile["p1"].text = info["stars"] + "/" + info["cropSum"] * 3;
         this._myProfile["p2"].text = info["crops"] + "/" + info["cropSum"];
         p = Math.max(1,Math.floor(info["serials"] * 100 / info["serialSum"]));
         this._myProfile["pb0"].gotoAndStop(p);
         p = Math.max(1,Math.floor(info["stars"] * 100 / (3 * info["cropSum"])));
         this._myProfile["pb1"].gotoAndStop(p);
         p = Math.max(1,Math.floor(info["crops"] * 100 / info["cropSum"]));
         this._myProfile["pb2"].gotoAndStop(p);
         reload = true;
         if(info["photo"] != undefined && info["photo"] != "")
         {
            url = info["photo"];
            if(this._photo == null)
            {
               this._photo = new Loader();
               this._photo.x = 10;
               this._photo.y = 0;
               this._myProfile.addChild(this._photo);
               this._photo.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,errorHandler);
               this._photo.contentLoaderInfo.addEventListener(IOErrorEvent.NETWORK_ERROR,errorHandler);
            }
            else if(this._photo.contentLoaderInfo.url == url)
            {
               reload = false;
            }
            else
            {
               this._photo.unload();
            }
            if(reload == true)
            {
               this._photo.load(new URLRequest(url));
            }
         }
      }
      
      public function set basedata(param1:Dictionary) : void
      {
         var _loc2_:String = null;
         this.reset();
         if(param1 != null)
         {
            this._data = new Array();
            for(_loc2_ in param1)
            {
               if(param1[_loc2_]["visible"] != false)
               {
                  this._data.push(param1[_loc2_]);
               }
            }
            this._data.sortOn("id",Array.DESCENDING | Array.NUMERIC);
         }
         if(this._items == null)
         {
            this._items = new Array();
         }
         this.handlePage(this._data);
         LayoutManager.sortByGrid(this._items,6,2,0,18,3);
      }
      
      private function reset() : void
      {
         var _loc1_:SerialItemRender = null;
         for each(_loc1_ in this._items)
         {
            if(_loc1_ != null)
            {
               _loc1_.data = null;
            }
         }
         this._currentIndex = 0;
         if(this._pager != null)
         {
            this._pager["tfNum"].text = "0/0";
         }
      }
      
      private function updateFooter(param1:Array) : void
      {
         if(this._pager == null)
         {
            return;
         }
         var _loc2_:int = Math.floor(this._currentIndex / this.MAX_ITEMS) + 1;
         var _loc3_:int = param1 == null ? 0 : int(Math.ceil(param1.length / this.MAX_ITEMS));
         this._pager["tfNum"].text = _loc2_ + "/" + _loc3_;
         if(this._currentIndex > 0)
         {
            StylesManager.enableMc(this._pager["left"] as InteractiveObject,true);
         }
         else
         {
            StylesManager.enableMc(this._pager["left"] as InteractiveObject,false);
         }
         if(_loc2_ < _loc3_)
         {
            StylesManager.enableMc(this._pager["right"] as InteractiveObject,true);
         }
         else
         {
            StylesManager.enableMc(this._pager["right"] as InteractiveObject,false);
         }
      }
      
      public function refreshFriendCollection(param1:Dictionary) : void
      {
         var _loc3_:SerialItemRender = null;
         this._friendsCollection = param1;
         if(this._friendsCollection == null)
         {
            return;
         }
         var _loc2_:int = 0;
         for each(_loc3_ in this._items)
         {
            _loc2_ = _loc3_.serial;
            if(_loc2_ > 0)
            {
               _loc3_.friends = param1[_loc2_];
            }
         }
      }
      
      public function set hilight(param1:Dictionary) : void
      {
         var _loc2_:int = 0;
         var _loc3_:SerialItemRender = null;
         this._hilight = param1;
         if(param1 != null)
         {
            _loc2_ = 0;
            for each(_loc3_ in this._items)
            {
               _loc2_ = _loc3_.serial;
               if(_loc2_ > 0)
               {
                  _loc3_.collected = param1[_loc2_];
                  if(this._friendsCollection != null)
                  {
                     _loc3_.friends = this._friendsCollection[_loc2_];
                  }
               }
            }
         }
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
      
      public function unBindPager() : void
      {
         if(this._pager != null)
         {
            this._pager["left"].removeEventListener(MouseEvent.CLICK,this.onMouseEvent);
            this._pager["right"].removeEventListener(MouseEvent.CLICK,this.onMouseEvent);
         }
      }
      
      private function handlePage(param1:Array) : void
      {
         var _loc5_:* = undefined;
         if(param1 == null)
         {
            return;
         }
         var _loc2_:Array = param1.slice(this._currentIndex,this._currentIndex + this.MAX_ITEMS);
         if(_loc2_ == null || _loc2_.length == 0)
         {
            return;
         }
         var _loc3_:int = 0;
         var _loc4_:SerialItemRender = null;
         for each(_loc5_ in _loc2_)
         {
            if(_loc3_ < this._items.length)
            {
               _loc4_ = this._items[_loc3_] as SerialItemRender;
            }
            else
            {
               _loc4_ = new SerialItemRender();
               addChild(_loc4_);
               this._items.push(_loc4_);
               _loc4_.addEventListener(MouseEvent.CLICK,this.onMouseEvent,false,0,true);
               _loc4_.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseEvent,false,0,true);
               _loc4_.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseEvent,false,0,true);
            }
            if(this._hilight != null)
            {
               _loc5_["collected"] = this._hilight[_loc5_["id"]];
            }
            _loc4_.data = _loc5_;
            if(this._friendsCollection != null)
            {
               _loc4_.friends = this._friendsCollection[_loc5_["id"]];
            }
            _loc3_++;
         }
         while(_loc3_ < this._items.length)
         {
            _loc4_ = this._items[_loc3_] as SerialItemRender;
            _loc4_.data = null;
            _loc3_++;
         }
         this.updateFooter(param1);
      }
      
      private function onMouseEvent(param1:MouseEvent) : void
      {
         var _loc4_:Mediator = null;
         var _loc2_:DisplayObject = param1.target as DisplayObject;
         var _loc3_:SerialItemRender = null;
         if(param1.type == MouseEvent.CLICK)
         {
            if(this._data != null && this._data.length > 0 && this._pager != null)
            {
               if(_loc2_ == this._pager["left"])
               {
                  this._currentIndex -= this.MAX_ITEMS;
                  if(this._currentIndex < 0)
                  {
                     this._currentIndex += this.MAX_ITEMS;
                  }
                  else
                  {
                     this.handlePage(this._data);
                  }
                  return;
               }
               if(_loc2_ == this._pager["right"])
               {
                  this._currentIndex += this.MAX_ITEMS;
                  if(this._currentIndex >= this._data.length)
                  {
                     this._currentIndex -= this.MAX_ITEMS;
                  }
                  else
                  {
                     this.handlePage(this._data);
                  }
                  return;
               }
               _loc3_ = _loc2_ as SerialItemRender;
               if(_loc3_ != null)
               {
                  _loc4_ = MVCFacade.getInstance().getObj(CollectingConsts.MEDIATOR) as Mediator;
                  _loc4_.showSerialPage(_loc3_.serial);
               }
            }
         }
         else if(param1.type == MouseEvent.MOUSE_OVER)
         {
            _loc3_ = _loc2_ as SerialItemRender;
            if(_loc3_ != null)
            {
               _loc3_.hilightBorder(true);
               this.showTip(_loc3_);
            }
            param1.stopImmediatePropagation();
         }
         else if(param1.type == MouseEvent.MOUSE_OUT)
         {
            _loc3_ = _loc2_ as SerialItemRender;
            if(_loc3_ != null)
            {
               _loc3_.hilightBorder(false);
               this._tip.hide(true);
            }
            param1.stopImmediatePropagation();
         }
      }
      
      public function get hilight() : Dictionary
      {
         return this._hilight;
      }
      
      public function rebind(param1:MovieClip, param2:Sprite, param3:ItemTip) : void
      {
         if(this._photo != null)
         {
            this._photo.unload();
            if(this._photo.parent != null)
            {
               this._photo.parent.removeChild(this._photo);
            }
            this._photo = null;
         }
         this._myProfile = param1;
         this._myProfile["p0"].text = "";
         this._myProfile["pb0"].gotoAndStop(1);
         this._myProfile["p1"].text = "";
         this._myProfile["pb1"].gotoAndStop(1);
         this._myProfile["p2"].text = "";
         this._myProfile["pb2"].gotoAndStop(1);
         if(param2 != null)
         {
            this._pager = param2;
            this._pager["left"].addEventListener(MouseEvent.CLICK,this.onMouseEvent,false,0,true);
            this._pager["right"].addEventListener(MouseEvent.CLICK,this.onMouseEvent,false,0,true);
            this.updateFooter(this._data);
         }
         this._tip = param3;
      }
      
      public function destroy() : void
      {
         var _loc1_:SerialItemRender = null;
         if(this._photo != null)
         {
            this._photo.unload();
            if(this._photo.parent != null)
            {
               this._photo.parent.removeChild(this._photo);
            }
            this._photo = null;
         }
         for each(_loc1_ in this._items)
         {
            if(_loc1_ != null)
            {
               _loc1_.destroy();
               if(_loc1_.parent != null)
               {
                  _loc1_.parent.removeChild(_loc1_);
               }
            }
         }
         this._items = null;
         this._hilight = null;
         this._data = null;
         this._myProfile = null;
         this._pager = null;
         this._tip = null;
      }
   }
}

