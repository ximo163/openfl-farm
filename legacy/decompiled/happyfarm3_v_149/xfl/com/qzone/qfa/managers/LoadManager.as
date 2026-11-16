package com.qzone.qfa.managers
{
   import com.qzone.qfa.data.Resource;
   import com.qzone.qfa.data.ResourceType;
   import com.qzone.qfa.events.LoaderEvent;
   import flash.display.*;
   import flash.events.*;
   import flash.net.*;
   import flash.system.*;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   public class LoadManager extends EventDispatcher
   {
      
      public static const STATUS_LOADING:String = "loading";
      
      public static const STATUS_STOPPED:String = "stopped";
      
      private var _status:String;
      
      private var _queue:Array;
      
      private var _itemLoaded:int;
      
      private var _map:Dictionary;
      
      private var _percentQueue:Number;
      
      private var _maxThreadCount:uint;
      
      private var _startTime:int;
      
      private var _itemFailed:int;
      
      private var _eventList:Array = [LoaderEvent.COMPLETE,LoaderEvent.ERROR,LoaderEvent.PROGRESS,LoaderEvent.QUEUE_CHANGED,LoaderEvent.QUEUE_COMPLETE,LoaderEvent.QUEUE_PROGRESS,LoaderEvent.QUEUE_START,LoaderEvent.START,LoaderEvent.STATUS_CHANGED];
      
      private var _defaultAppDomain:ApplicationDomain;
      
      private var _loadingThreadCount:int;
      
      public function LoadManager(param1:ApplicationDomain = null)
      {
         super();
         this.reset();
         this._maxThreadCount = 1;
         if(param1)
         {
            this._defaultAppDomain = param1;
         }
      }
      
      public function stop() : void
      {
         if(this._status == STATUS_LOADING)
         {
            this.clear();
            dispatchEvent(new LoaderEvent(LoaderEvent.QUEUE_CHANGED));
         }
      }
      
      public function remove(param1:String) : Boolean
      {
         return this.removeItem(param1);
      }
      
      private function processFile(param1:Event = null) : void
      {
         var _loc2_:LoadItem = null;
         var _loc3_:Resource = null;
         var _loc4_:Bitmap = null;
         if(param1)
         {
            _loc2_ = this._map[param1.target] as LoadItem;
            if(!_loc2_)
            {
               return;
            }
            _loc3_ = _loc2_.resource;
            _loc3_.loaded = true;
            if(_loc3_.type == ResourceType.TYPE_BITMAP)
            {
               _loc4_ = LoaderInfo(param1.target).content is MovieClip ? MovieClip(LoaderInfo(param1.target).content).getChildAt(0) as Bitmap : LoaderInfo(param1.target).content as Bitmap;
               _loc3_.data = _loc4_;
            }
            else if(_loc3_.type == ResourceType.TYPE_SWF)
            {
               _loc3_.applicationDomain = _loc2_.appDomain ? _loc2_.appDomain : (this._defaultAppDomain ? this._defaultAppDomain : LoaderInfo(param1.target).applicationDomain);
               _loc3_.data = LoaderInfo(param1.target).content;
            }
            else
            {
               _loc3_.data = URLLoader(param1.target).data;
            }
         }
      }
      
      private function unknownErrorHandler(param1:LoaderEvent) : void
      {
         var _loc2_:LoadItem = param1.target as LoadItem;
         dispatchEvent(this.packageEvent(LoaderEvent.ERROR,this,_loc2_.percent,getTimer() - _loc2_.loadTime,this._percentQueue,_loc2_.resource,"[LoaderManager] unkown error"));
         ++this._itemFailed;
         this.clearCurrentItem(param1);
         this.afterComplete(_loc2_);
      }
      
      public function get count() : int
      {
         return this._queue.length;
      }
      
      public function removeAll() : void
      {
         this.clear();
         this.reset();
         dispatchEvent(new LoaderEvent(LoaderEvent.QUEUE_CHANGED));
      }
      
      private function loadItem() : void
      {
         var _loc1_:LoadItem = null;
         var _loc2_:Resource = null;
         var _loc3_:URLRequest = null;
         var _loc4_:LoaderContext = null;
         var _loc5_:* = undefined;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:* = undefined;
         if(this._status == STATUS_LOADING && Boolean(this._queue.length))
         {
            _loc6_ = 0;
            _loc7_ = int(this._queue.length);
            while(_loc6_ < _loc7_ && this._loadingThreadCount < this._maxThreadCount)
            {
               _loc1_ = LoadItem(this._queue[this._loadingThreadCount]);
               if(!_loc1_)
               {
                  return;
               }
               for(_loc8_ in this._map)
               {
                  if(this._map[_loc8_] == _loc1_)
                  {
                     return;
                  }
               }
               _loc2_ = _loc1_.resource;
               _loc3_ = new URLRequest(_loc2_.url);
               _loc1_.loadTime = getTimer();
               if(_loc2_.type == ResourceType.TYPE_BITMAP || _loc2_.type == ResourceType.TYPE_SWF)
               {
                  if(_loc1_.appDomain)
                  {
                     _loc4_ = new LoaderContext(_loc2_.type == ResourceType.TYPE_SWF,_loc1_.appDomain);
                  }
                  else if(this._defaultAppDomain)
                  {
                     _loc4_ = new LoaderContext(_loc2_.type == ResourceType.TYPE_SWF,this._defaultAppDomain);
                  }
                  else
                  {
                     _loc4_ = new LoaderContext(_loc2_.type == ResourceType.TYPE_SWF,new ApplicationDomain());
                  }
                  if(Boolean(_loc4_) && Boolean(_loc2_.type == ResourceType.TYPE_SWF) && !_loc2_.url.indexOf("file://"))
                  {
                     _loc4_.securityDomain = SecurityDomain.currentDomain;
                  }
                  _loc5_ = new Loader();
                  _loc2_.loaderInfo = Loader(_loc5_).contentLoaderInfo;
                  this.setListeners(Loader(_loc5_).contentLoaderInfo);
                  Loader(_loc5_).load(_loc3_,_loc4_);
                  _loc5_ = _loc5_.contentLoaderInfo;
               }
               else
               {
                  _loc5_ = new URLLoader();
                  if(_loc2_.type == ResourceType.TYPE_BINARY)
                  {
                     _loc5_.dataFormat = URLLoaderDataFormat.BINARY;
                  }
                  else
                  {
                     _loc5_.dataFormat = URLLoaderDataFormat.TEXT;
                  }
                  this.setListeners(_loc5_);
                  URLLoader(_loc5_).load(_loc3_);
               }
               this._map[_loc5_] = _loc1_;
               _loc6_++;
               ++this._loadingThreadCount;
            }
         }
      }
      
      private function removeListeners(param1:IEventDispatcher) : void
      {
         param1.removeEventListener(Event.OPEN,this.openHandler);
         param1.removeEventListener(ProgressEvent.PROGRESS,this.progressHandler);
         param1.removeEventListener(Event.COMPLETE,this.completeHandler);
         param1.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.errorHandler);
         param1.removeEventListener(HTTPStatusEvent.HTTP_STATUS,this.httpstatusHandler);
         param1.removeEventListener(IOErrorEvent.IO_ERROR,this.errorHandler);
      }
      
      private function clearCurrentItem(param1:Event = null) : void
      {
         var target:* = undefined;
         var e:Event = param1;
         if(e)
         {
            this.removeListeners(IEventDispatcher(e.target));
         }
         else
         {
            for(target in this._map)
            {
               try
               {
                  if("close" in target)
                  {
                     target["close"]();
                  }
                  if("unloadAndStop" in target)
                  {
                     target["unloadAndStop"]();
                  }
               }
               catch(e:Error)
               {
               }
               this.removeListeners(target);
            }
         }
      }
      
      public function add(param1:String, param2:ApplicationDomain = null) : Resource
      {
         return this.addAt(param1,this._queue.length,param2);
      }
      
      private function errorHandler(param1:*) : void
      {
         var _loc2_:LoadItem = this._map[param1.target];
         dispatchEvent(this.packageEvent(LoaderEvent.ERROR,this,_loc2_.percent,getTimer() - _loc2_.loadTime,this._percentQueue,_loc2_.resource,param1.text));
         ++this._itemFailed;
         this.clearCurrentItem(param1);
         this.afterComplete(_loc2_);
      }
      
      private function openHandler(param1:Event = null) : void
      {
         dispatchEvent(this.packageEvent(LoaderEvent.START,this,0,0,this._percentQueue,this._map[param1.target].resource));
      }
      
      public function get maxThreadCount() : uint
      {
         return this._maxThreadCount;
      }
      
      public function addAt(param1:String, param2:int, param3:ApplicationDomain = null) : Resource
      {
         var _loc5_:LoadItem = null;
         var _loc4_:Resource = this.findItem(param1);
         if(_loc4_ == null)
         {
            _loc4_ = new Resource();
            _loc4_.url = param1;
            _loc4_.type = ResourceType.getType(param1);
            _loc5_ = new LoadItem();
            _loc5_.percent = 0;
            _loc5_.resource = _loc4_;
            _loc5_.appDomain = param3;
            if(param2 < 0 || param2 > this._queue.length)
            {
               return null;
            }
            if(this._status == STATUS_LOADING && param2 == 0)
            {
               return null;
            }
            this._queue.splice(param2,0,_loc5_);
            return _loc4_;
         }
         return null;
      }
      
      private function afterComplete(param1:LoadItem) : void
      {
         var _loc2_:uint = 0;
         var _loc3_:uint = this._queue.length;
         while(_loc2_ < _loc3_)
         {
            if(this._queue[_loc2_] == param1)
            {
               this._queue.splice(_loc2_,1);
            }
            _loc2_++;
         }
         if(this._queue.length == 0)
         {
            this.setStatus(STATUS_STOPPED);
         }
         if(this._loadingThreadCount > 0)
         {
            --this._loadingThreadCount;
         }
         if(param1.percent == 100)
         {
            dispatchEvent(this.packageEvent(LoaderEvent.COMPLETE,this,param1.loadTime,100,this._percentQueue,param1.resource));
         }
         if(this._queue.length)
         {
            this.loadItem();
         }
         else
         {
            dispatchEvent(this.packageEvent(LoaderEvent.QUEUE_COMPLETE,this,getTimer() - this._startTime,100,100,param1.resource));
            this.clear();
         }
      }
      
      private function removeItem(param1:String, param2:int = -1) : Boolean
      {
         var _loc3_:* = undefined;
         var _loc4_:int = 0;
         var _loc5_:Resource = null;
         var _loc6_:int = 0;
         for(_loc3_ in this._map)
         {
            if(this._status == STATUS_LOADING && this._map[_loc3_].url == param1)
            {
               return false;
            }
         }
         if(param1 != null && param1.length > 4)
         {
            _loc4_ = int(this._queue.length);
            _loc6_ = 0;
            while(_loc6_ < _loc4_)
            {
               _loc5_ = LoadItem(this._queue[_loc6_]).resource;
               if(_loc5_.url == param1)
               {
                  this._queue.splice(_loc6_,1);
                  return true;
               }
               _loc6_++;
            }
         }
         if(param2 > -1)
         {
            this._queue.splice(param2,1);
            return true;
         }
         return false;
      }
      
      public function set maxThreadCount(param1:uint) : void
      {
         this._maxThreadCount = Math.max(param1,0);
      }
      
      public function get loadingThreadCount() : uint
      {
         return this._loadingThreadCount;
      }
      
      public function addEventListeners(param1:Function) : void
      {
         var _loc2_:String = null;
         for each(_loc2_ in this._eventList)
         {
            addEventListener(_loc2_,param1,false,0,false);
         }
      }
      
      private function reset() : void
      {
         this._itemLoaded = 0;
         this._itemFailed = 0;
         this._loadingThreadCount = 0;
         this._percentQueue = 0;
         this._map = new Dictionary();
         this._queue = [];
         this._loadingThreadCount = 0;
         if(this._status != STATUS_STOPPED)
         {
            this.setStatus(STATUS_STOPPED);
         }
      }
      
      private function completeHandler(param1:Event = null) : void
      {
         var _loc2_:LoadItem = this._map[param1.target];
         _loc2_.loadTime = getTimer() - _loc2_.loadTime;
         this.processFile(param1);
         delete this._map[param1.target];
         _loc2_.percent = 100;
         ++this._itemLoaded;
         this.clearCurrentItem(param1);
         this.afterComplete(_loc2_);
      }
      
      private function clear(param1:Event = null) : void
      {
         this.clearCurrentItem(param1);
         if(!this._itemFailed)
         {
            this.reset();
         }
      }
      
      public function removeAt(param1:int) : Boolean
      {
         return this.removeItem(null,param1);
      }
      
      public function start() : void
      {
         if(this._status == STATUS_STOPPED && this._queue.length > 0)
         {
            this._startTime = getTimer();
            this.setStatus(STATUS_LOADING);
            dispatchEvent(new LoaderEvent(LoaderEvent.QUEUE_START));
            this.loadItem();
         }
      }
      
      private function progressHandler(param1:ProgressEvent) : void
      {
         var _loc4_:* = undefined;
         var _loc5_:Number = NaN;
         var _loc6_:int = 0;
         var _loc2_:int = int(this._queue.length);
         var _loc3_:LoadItem = this._map[param1.target];
         this._percentQueue = 0;
         if(param1.bytesTotal == 0)
         {
            _loc3_.percent = 80;
         }
         else
         {
            _loc3_.percent = param1.bytesLoaded / param1.bytesTotal * 100;
         }
         for(_loc4_ in this._map)
         {
            if(LoadItem(this._map[_loc4_]).percent)
            {
               this._percentQueue += LoadItem(this._map[_loc4_]).percent;
            }
         }
         this._percentQueue = (100 * this._itemLoaded + this._percentQueue) / (this._itemLoaded + this._itemFailed + _loc2_);
         _loc5_ = _loc3_.percent;
         _loc6_ = getTimer() - _loc3_.loadTime;
         dispatchEvent(this.packageEvent(LoaderEvent.PROGRESS,this,_loc6_,_loc5_,this._percentQueue,_loc3_.resource));
         dispatchEvent(this.packageEvent(LoaderEvent.QUEUE_PROGRESS,this,getTimer() - this._startTime,_loc5_,this._percentQueue,_loc3_.resource));
      }
      
      public function removeEventListeners(param1:Function) : void
      {
         var _loc2_:String = null;
         for each(_loc2_ in this._eventList)
         {
            removeEventListener(_loc2_,param1);
         }
      }
      
      private function findItem(param1:String) : Resource
      {
         var _loc3_:Resource = null;
         var _loc2_:int = int(this._queue.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_)
         {
            _loc3_ = LoadItem(this._queue[_loc4_]).resource;
            if(_loc3_.url == param1)
            {
               return _loc3_;
            }
            _loc4_++;
         }
         return null;
      }
      
      private function httpstatusHandler(param1:HTTPStatusEvent) : void
      {
      }
      
      public function get status() : String
      {
         return this._status;
      }
      
      private function setStatus(param1:String) : void
      {
         this._status = param1;
      }
      
      private function packageEvent(param1:String, param2:*, param3:int, param4:Number, param5:Number, param6:Resource, param7:String = "") : LoaderEvent
      {
         var _loc8_:LoaderEvent = new LoaderEvent(param1);
         _loc8_.loader = param2;
         _loc8_.percentItem = param4;
         _loc8_.percentQueue = param5;
         _loc8_.loadTime = param3;
         _loc8_.item = param6;
         _loc8_.queueCount = this._itemLoaded;
         _loc8_.failCount = this._itemFailed;
         _loc8_.queueLength = this._queue.length;
         if(!param7)
         {
            _loc8_.msg = param7;
         }
         return _loc8_;
      }
      
      private function setListeners(param1:IEventDispatcher) : void
      {
         param1.addEventListener(Event.OPEN,this.openHandler,false,0,false);
         param1.addEventListener(ProgressEvent.PROGRESS,this.progressHandler,false,0,false);
         param1.addEventListener(Event.COMPLETE,this.completeHandler,false,0,false);
         param1.addEventListener(HTTPStatusEvent.HTTP_STATUS,this.httpstatusHandler,false,0,false);
         param1.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.errorHandler,false,0,false);
         param1.addEventListener(IOErrorEvent.IO_ERROR,this.errorHandler,false,0,false);
      }
   }
}

import com.qzone.qfa.data.Resource;
import flash.system.ApplicationDomain;

class LoadItem
{
   
   public var loadTime:int;
   
   public var appDomain:ApplicationDomain;
   
   public var percent:Number;
   
   public var resource:Resource;
   
   public function LoadItem()
   {
      super();
   }
}
