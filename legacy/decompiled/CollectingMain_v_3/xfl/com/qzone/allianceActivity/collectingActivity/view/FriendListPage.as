package com.qzone.allianceActivity.collectingActivity.view
{
   import com.qzone.allianceActivity.collectingActivity.model.FriendData;
   import com.qzone.allianceActivity.framewrok.events.MVCEvent;
   import com.qzone.allianceActivity.framewrok.utils.StylesManager;
   import com.qzone.allianceActivity.interfaces.IAllianceAppHelper;
   import flash.display.InteractiveObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class FriendListPage extends Sprite
   {
      
      public static const MSG_ITEM_CLICKED:String = "FriendListItemClicked";
      
      private var _items:Array;
      
      private var _pager:Sprite;
      
      private var _data:Array;
      
      private var _api:IAllianceAppHelper;
      
      private var _tabs:TabButtonGroup;
      
      private const MAX_ITEMS:uint = 12;
      
      private var _currentIndex:int;
      
      public function FriendListPage(param1:IAllianceAppHelper)
      {
         super();
         this._api = param1;
         this._currentIndex = 0;
         _sort = 0;
      }
      
      public function get sort() : int
      {
         return _sort;
      }
      
      private function updateFooter(param1:Array) : void
      {
         if(param1 == null)
         {
            this._pager["tfNum"].text = "0/0";
            StylesManager.enableMc(this._pager["left"] as InteractiveObject,false);
            StylesManager.enableMc(this._pager["right"] as InteractiveObject,false);
            return;
         }
         this._pager.visible = true;
         var _loc2_:int = Math.floor(this._currentIndex / this.MAX_ITEMS) + 1;
         var _loc3_:int = Math.ceil(param1.length / this.MAX_ITEMS);
         this._pager["tfNum"].text = _loc2_ + "/" + _loc3_;
         if(this._currentIndex > 0)
         {
            StylesManager.enableMc(this._pager["left"] as InteractiveObject,true);
         }
         else
         {
            StylesManager.enableMc(this._pager["left"] as InteractiveObject,false);
         }
         if(this._currentIndex + this.MAX_ITEMS < param1.length)
         {
            StylesManager.enableMc(this._pager["right"] as InteractiveObject,true);
         }
         else
         {
            StylesManager.enableMc(this._pager["right"] as InteractiveObject,false);
         }
      }
      
      private function reset() : void
      {
         var _loc1_:FriendItemRender = null;
         for each(_loc1_ in this._items)
         {
            if(_loc1_ != null)
            {
               _loc1_.data = null;
            }
         }
         this._currentIndex = 0;
         this._pager["tfNum"].text = "1/1";
      }
      
      public function set data(param1:Array) : void
      {
         this.reset();
         this._data = param1;
         if(this._items == null)
         {
            this._items = new Array();
         }
         _sort = -1;
         this.sort = 0;
      }
      
      private function handlePage(param1:Array) : void
      {
         var _loc5_:* = undefined;
         var _loc6_:FriendItemRender = null;
         var _loc7_:Array = null;
         var _loc8_:Array = null;
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
         var _loc4_:Boolean = false;
         for each(_loc5_ in _loc2_)
         {
            if(_loc3_ < this._items.length)
            {
               (this._items[_loc3_] as FriendItemRender).data = _loc5_;
            }
            else
            {
               _loc6_ = new FriendItemRender();
               _loc6_.data = _loc5_;
               this._items.push(_loc6_);
               addChild(_loc6_);
               _loc4_ = true;
               _loc6_.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseEvent,false,0,true);
               _loc6_.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseEvent,false,0,true);
               _loc6_.addEventListener(MouseEvent.CLICK,this.onMouseEvent,false,0,true);
            }
            _loc3_++;
         }
         while(_loc3_ < this.MAX_ITEMS)
         {
            if(_loc3_ < this._items.length)
            {
               (this._items[_loc3_] as FriendItemRender).data = null;
            }
            _loc3_++;
         }
         this.updateFooter(param1);
         this.loadHeadPics();
         if(_loc4_ == true)
         {
            _loc7_ = [];
            _loc8_ = [];
            _loc3_ = 0;
            while(_loc3_ < this._items.length)
            {
               if(_loc3_ < 6)
               {
                  _loc7_.push(this._items[_loc3_]);
               }
               else
               {
                  _loc8_.push(this._items[_loc3_]);
               }
               _loc3_++;
            }
            LayoutManager.sortByCol(_loc7_,0,0,17);
            LayoutManager.sortByCol(_loc8_,364,0,17);
         }
      }
      
      public function refreshSort() : void
      {
         var _loc2_:FriendData = null;
         if(this._data == null || this._data.length == 0)
         {
            return;
         }
         if(_sort == 0)
         {
            this._data.sortOn(["collectSerials","name"],[Array.DESCENDING | Array.NUMERIC,Array.DESCENDING | Array.CASEINSENSITIVE]);
         }
         else if(_sort == 1)
         {
            this._data.sortOn(["lightedCrops","name"],[Array.DESCENDING | Array.NUMERIC,Array.DESCENDING | Array.CASEINSENSITIVE]);
         }
         else
         {
            this._data.sortOn(["stars","name"],[Array.DESCENDING | Array.NUMERIC,Array.DESCENDING | Array.CASEINSENSITIVE]);
         }
         var _loc1_:* = 1;
         for each(_loc2_ in this._data)
         {
            _loc2_.index = _loc1_++;
         }
         this.handlePage(this._data);
      }
      
      public function destroy() : void
      {
         var _loc1_:FriendItemRender = null;
         this._data = null;
         this._currentIndex = 0;
         for each(_loc1_ in this._items)
         {
            _loc1_.destroy();
            if(_loc1_.parent != null)
            {
               _loc1_.parent.removeChild(_loc1_);
            }
         }
         this._items = null;
         this._pager = null;
         this._tabs = null;
      }
      
      private function onSortChanged(param1:Event) : void
      {
         this.sort = this._tabs.currentSelected;
      }
      
      private function setHeadList(param1:Object) : void
      {
         if(param1 == null)
         {
            return;
         }
         if(this._items == null)
         {
            return;
         }
         var _loc2_:int = 0;
         while(_loc2_ < this._items.length)
         {
            this._items[_loc2_].refreshHead(param1);
            _loc2_++;
         }
      }
      
      public function goto(param1:FriendData) : void
      {
         if(param1 == null)
         {
            return;
         }
         this._currentIndex = Math.floor((param1.index - 1) / this.MAX_ITEMS) as int;
         this._currentIndex *= this.MAX_ITEMS;
         this.handlePage(this._data);
      }
      
      public function get length() : int
      {
         if(this._data == null)
         {
            return 0;
         }
         return this._data.length;
      }
      
      public function refreshPager() : void
      {
         this.updateFooter(this._data);
      }
      
      public function unBindPager() : void
      {
         if(this._pager != null)
         {
            this._pager["left"].removeEventListener(MouseEvent.CLICK,this.onMouseEvent);
            this._pager["right"].removeEventListener(MouseEvent.CLICK,this.onMouseEvent);
         }
      }
      
      private function loadHeadPics() : void
      {
         var _loc2_:Array = null;
         var _loc3_:FriendData = null;
         var _loc4_:int = 0;
         var _loc1_:String = this._api.execute("10013") as String;
         if(_loc1_ == "qzone")
         {
            _loc2_ = [];
            _loc3_ = null;
            _loc4_ = 0;
            while(_loc4_ < this.MAX_ITEMS)
            {
               if(_loc4_ + this._currentIndex >= this._data.length)
               {
                  break;
               }
               _loc3_ = this._data[_loc4_ + this._currentIndex] as FriendData;
               if(_loc3_ != null)
               {
                  if(_loc3_.photo == "" || _loc3_.photo == null)
                  {
                     _loc2_.push(_loc3_.uin);
                  }
               }
               _loc4_++;
            }
            this._api.execute("10016",{
               "uins":_loc2_,
               "callback":this.setHeadList
            }) as String;
         }
      }
      
      private function findMe(param1:Array) : void
      {
         var _loc2_:* = undefined;
         this._currentIndex = 0;
         for each(_loc2_ in param1)
         {
            if(_loc2_["me"] == true)
            {
               this._currentIndex -= this._currentIndex % this.MAX_ITEMS;
               break;
            }
            ++this._currentIndex;
         }
      }
      
      private function onMouseEvent(param1:MouseEvent) : void
      {
         var _loc3_:MVCEvent = null;
         if(this._data != null && this._data.length > 0)
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
                  this.handlePage(this._data);
               }
               return;
            }
            if(param1.target.name == "right")
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
         }
         var _loc2_:FriendItemRender = param1.currentTarget as FriendItemRender;
         if(_loc2_ == null)
         {
            _loc2_ = param1.target.parent as FriendItemRender;
         }
         if(_loc2_ != null)
         {
            if(param1.type == MouseEvent.CLICK)
            {
               if(_loc2_.data.me == false)
               {
                  _loc3_ = new MVCEvent(MSG_ITEM_CLICKED);
                  _loc3_.put("friend",_loc2_.data);
                  dispatchEvent(_loc3_);
                  if(_loc2_.data != null && _loc2_.data.me == false)
                  {
                     _loc2_.hilight = false;
                  }
               }
            }
            else if(param1.type == MouseEvent.MOUSE_OVER)
            {
               _loc2_.hilight = true;
            }
            else if(param1.type == MouseEvent.MOUSE_OUT)
            {
               if(_loc2_.data != null && _loc2_.data.me == false)
               {
                  _loc2_.hilight = false;
               }
            }
         }
      }
      
      public function rebind(param1:Array, param2:Sprite) : void
      {
         this._pager = param2;
         this._pager["left"].addEventListener(MouseEvent.CLICK,this.onMouseEvent,false,0,true);
         this._pager["right"].addEventListener(MouseEvent.CLICK,this.onMouseEvent,false,0,true);
         if(param1 != null && param1.length > 1)
         {
            if(this._tabs == null)
            {
               this._tabs = new TabButtonGroup(param1,0,2);
            }
            else
            {
               this._tabs.rebind(param1,2);
            }
            this._tabs.addEventListener(Event.CHANGE,this.onSortChanged,false,0,true);
         }
      }
      
      public function set sort(param1:int) : void
      {
         var _loc3_:FriendData = null;
         if(this._data == null || this._data.length == 0)
         {
            return;
         }
         _sort = param1;
         if(param1 == 0)
         {
            this._data.sortOn(["collectSerials","name"],[Array.DESCENDING | Array.NUMERIC,Array.DESCENDING | Array.CASEINSENSITIVE]);
         }
         else if(param1 == 1)
         {
            this._data.sortOn(["lightedCrops","name"],[Array.DESCENDING | Array.NUMERIC,Array.DESCENDING | Array.CASEINSENSITIVE]);
         }
         else
         {
            this._data.sortOn(["stars","name"],[Array.DESCENDING | Array.NUMERIC,Array.DESCENDING | Array.CASEINSENSITIVE]);
         }
         var _loc2_:* = 1;
         for each(_loc3_ in this._data)
         {
            _loc3_.index = _loc2_++;
         }
         this.findMe(this._data);
         this.handlePage(this._data);
      }
   }
}

import com.qzone.allianceActivity.collectingActivity.model.FriendData;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;

class FriendItemRender extends Sprite
{
   
   private var _class:Class = FriendItemRender__class;
   
   private var _data:FriendData;
   
   private var _photo:Loader;
   
   private var _render:MovieClip;
   
   public function FriendItemRender()
   {
      super();
   }
   
   public function destroy() : void
   {
      if(this._photo != null)
      {
         this._photo.unload();
         this._photo = null;
      }
      if(this._render != null)
      {
         this._render.stop();
         this._render = null;
      }
      this._data = null;
   }
   
   private function errorHandler(param1:IOErrorEvent) : void
   {
   }
   
   public function set hilight(param1:Boolean) : void
   {
      if(this._render != null)
      {
         this._render.gotoAndStop(param1 ? 2 : 1);
      }
   }
   
   private function replace50(param1:String) : String
   {
      var _loc4_:int = 0;
      if(param1 == null || param1 == "")
      {
         return param1;
      }
      var _loc2_:String = param1;
      var _loc3_:int = _loc2_.lastIndexOf("/50/50");
      if(_loc3_ == -1)
      {
         _loc4_ = _loc2_.lastIndexOf("/50");
         if(_loc4_ != -1)
         {
            _loc2_ = _loc2_.substring(0,_loc4_) + "/30" + _loc2_.substring(_loc4_ + 3,_loc2_.length);
         }
      }
      else
      {
         _loc2_ = _loc2_.substring(0,_loc3_) + "/30/50" + _loc2_.substring(_loc3_ + 6,_loc2_.length);
      }
      return _loc2_;
   }
   
   public function get data() : FriendData
   {
      return this._data;
   }
   
   public function set data(param1:FriendData) : void
   {
      this._data = param1;
      this.render();
   }
   
   private function render() : void
   {
      if(this._data == null)
      {
         if(this._photo != null)
         {
            this._photo.unload();
         }
         if(this._render != null)
         {
            this._render.visible = false;
         }
         return;
      }
      if(this._render == null)
      {
         this._render = new this._class() as MovieClip;
         this._render.gotoAndStop(1);
         this._render["tfNo"]["mouseEnabled"] = false;
         this._render["tfName"]["mouseEnabled"] = false;
         this._render["tfNum"]["mouseEnabled"] = false;
         this._render["mcIcon"]["mouseEnabled"] = false;
         addChild(this._render);
      }
      else
      {
         this._render.visible = true;
      }
      if(this._photo == null)
      {
         this._photo = new Loader();
         this._photo.x = 47;
         this._photo.y = 4;
         this._photo.mouseEnabled = false;
         addChild(this._photo);
         this._photo.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.errorHandler);
         this._photo.contentLoaderInfo.addEventListener(IOErrorEvent.NETWORK_ERROR,this.errorHandler);
      }
      else
      {
         this._photo.unload();
      }
      var _loc1_:String = this._data.photo;
      if(_loc1_ != null && _loc1_ != "")
      {
         if(this._data.me == true)
         {
            _loc1_ = this.replace50(_loc1_);
         }
         this._photo.load(new URLRequest(_loc1_));
      }
      this._render["tfNo"].text = this._data.index;
      this._render["tfName"].text = this._data.name;
      if(this._data.index == 1)
      {
         this._render["mcIcon"].gotoAndStop(1);
      }
      else if(this._data.index == 2)
      {
         this._render["mcIcon"].gotoAndStop(2);
      }
      else if(this._data.index == 3)
      {
         this._render["mcIcon"].gotoAndStop(3);
      }
      else
      {
         this._render["mcIcon"].gotoAndStop(4);
      }
      if(_sort == 0)
      {
         this._render["tfNum"].text = this._data.collectSerials;
      }
      else if(_sort == 1)
      {
         this._render["tfNum"].text = this._data.lightedCrops;
      }
      else
      {
         this._render["tfNum"].text = this._data.stars;
      }
      if(this._data.me == true)
      {
         this._render.gotoAndStop(2);
         this._render["btnCompare"].visible = false;
      }
      else
      {
         this._render.gotoAndStop(1);
         this._render["btnCompare"].visible = true;
      }
   }
   
   public function refreshHead(param1:Object) : void
   {
      var _loc2_:String = null;
      if(this._data != null && param1 != null)
      {
         _loc2_ = this._data.uin.toString();
         if(param1[_loc2_] != undefined && param1[_loc2_] != null)
         {
            if(param1[_loc2_] is String)
            {
               this._data.photo = param1[_loc2_];
            }
            else
            {
               this._data.photo = param1[_loc2_][0];
            }
            if(this._photo != null && this._data.photo != null && this._data.photo != "")
            {
               this._photo.load(new URLRequest(this._data.photo));
            }
         }
      }
   }
   
   public function get hilight() : Boolean
   {
      if(this._render != null)
      {
         return this._render.currentFrame == 2;
      }
      return false;
   }
}

var _sort:int;
