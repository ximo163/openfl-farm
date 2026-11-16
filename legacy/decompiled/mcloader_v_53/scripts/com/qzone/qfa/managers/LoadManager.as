package com.qzone.qfa.managers
{
   import com.qzone.qfa.managers.events.LoaderEvent;
   import com.qzone.qfa.managers.resource.Resource;
   import com.qzone.qfa.managers.resource.ResourceType;
   import flash.display.*;
   import flash.events.*;
   import flash.media.Sound;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.system.SecurityDomain;
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
      
      private var _itemFailed:int;
      
      private var _eventList:Array = [LoaderEvent.COMPLETE,LoaderEvent.ERROR,LoaderEvent.ID3_COMPLETE,LoaderEvent.PROGRESS,LoaderEvent.QUEUE_CHANGED,LoaderEvent.QUEUE_COMPLETE,LoaderEvent.QUEUE_PROGRESS,LoaderEvent.QUEUE_START,LoaderEvent.START,LoaderEvent.STATUS_CHANGED];
      
      private var _loadingThreadCount:int;
      
      private var _context:LoaderContext;
      
      public function LoadManager()
      {
         super();
         this.reset();
         this._maxThreadCount = 1;
         this._context = new LoaderContext();
         this._context.applicationDomain = ApplicationDomain.currentDomain;
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
      
      private function processFile(param1:* = null) : void
      {
         var loadItem:LoadItem = null;
         var res:Resource = null;
         var file:Bitmap = null;
         var e:* = param1;
         if(e)
         {
            loadItem = this._map[e.target] as LoadItem;
            if(!loadItem)
            {
               return;
            }
            res = loadItem.resource;
            res.message = loadItem.info.toString();
            if(res.type == ResourceType.TYPE_BITMAP)
            {
               file = LoaderInfo(e.target).content is MovieClip ? MovieClip(LoaderInfo(e.target).content).getChildAt(0) as Bitmap : LoaderInfo(e.target).content as Bitmap;
               res.data = file;
            }
            else if(res.type == ResourceType.TYPE_SWF)
            {
               try
               {
                  res.applicationDomain = LoaderInfo(e.target).applicationDomain;
                  res.data = LoaderInfo(e.target).content;
               }
               catch(err:Error)
               {
                  trace(err.toString());
               }
            }
            else if(res.type == ResourceType.TYPE_MP3)
            {
               res.data = e.target;
            }
            else
            {
               res.data = URLLoader(e.target).data;
            }
         }
      }
      
      private function unknownErrorHandler(param1:LoaderEvent) : void
      {
         var _loc2_:LoadItem = param1.target as LoadItem;
         if(_loc2_.percent >= 100 || _loc2_.status == 200)
         {
            dispatchEvent(this.packageEvent(LoaderEvent.COMPATIBLE_COMPLETE,this,_loc2_.percent,this._percentQueue,_loc2_.resource,"[LoaderManager]compatible complete"));
            this.completeHandler({"target":_loc2_.loader});
            return;
         }
         dispatchEvent(this.packageEvent(LoaderEvent.ERROR,this,_loc2_.percent,this._percentQueue,_loc2_.resource,"[LoaderManager] unkown error"));
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
         var _loc4_:* = undefined;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:* = undefined;
         if(this._status == STATUS_LOADING && Boolean(this._queue.length))
         {
            _loc5_ = 0;
            _loc6_ = int(this._queue.length);
            while(_loc5_ < _loc6_ && this._loadingThreadCount < this._maxThreadCount)
            {
               _loc1_ = LoadItem(this._queue[this._loadingThreadCount]);
               if(!_loc1_)
               {
                  return;
               }
               _loc1_.info = new ProgressInfo();
               _loc1_.info.start = getTimer();
               for(_loc7_ in this._map)
               {
                  if(this._map[_loc7_] == _loc1_)
                  {
                     return;
                  }
               }
               _loc2_ = _loc1_.resource;
               _loc3_ = new URLRequest(_loc2_.url);
               if(_loc2_.type == ResourceType.TYPE_BITMAP || _loc2_.type == ResourceType.TYPE_SWF)
               {
                  if(_loc2_.type == ResourceType.TYPE_SWF && !_loc2_.url.indexOf("file://"))
                  {
                     this._context.securityDomain = SecurityDomain.currentDomain;
                  }
                  else
                  {
                     this._context.securityDomain = null;
                  }
                  _loc4_ = new Loader();
                  this.setListeners(Loader(_loc4_).contentLoaderInfo);
                  Loader(_loc4_).load(_loc3_,this._context);
                  _loc4_ = _loc4_.contentLoaderInfo;
                  _loc2_.loaderInfo = _loc4_ as LoaderInfo;
               }
               else if(_loc2_.type == ResourceType.TYPE_MP3)
               {
                  _loc4_ = new Sound();
                  this.setListeners(_loc4_);
                  Sound(_loc4_).load(_loc3_);
               }
               else
               {
                  _loc4_ = new URLLoader();
                  if(_loc2_.type == ResourceType.TYPE_BINARY)
                  {
                     URLLoader(_loc4_).dataFormat = "binary";
                  }
                  this.setListeners(_loc4_);
                  URLLoader(_loc4_).load(_loc3_);
               }
               _loc2_.loader = _loc4_;
               _loc1_.loader = _loc4_;
               this._map[_loc4_] = _loc1_;
               _loc5_++;
               ++this._loadingThreadCount;
            }
         }
      }
      
      private function initHandler(param1:Event) : void
      {
         (this._map[param1.target] as LoadItem).info.init_complete = getTimer();
         dispatchEvent(this.packageEvent(LoaderEvent.INIT,this,0,this._percentQueue,this._map[param1.target].resource));
      }
      
      private function removeListeners(param1:IEventDispatcher) : void
      {
         param1.removeEventListener(Event.OPEN,this.openHandler);
         param1.removeEventListener(Event.INIT,this.initHandler);
         param1.removeEventListener(ProgressEvent.PROGRESS,this.progressHandler);
         param1.removeEventListener(Event.COMPLETE,this.completeHandler);
         param1.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.errorHandler);
         param1.removeEventListener(HTTPStatusEvent.HTTP_STATUS,this.httpstatusHandler);
         param1.removeEventListener(IOErrorEvent.IO_ERROR,this.errorHandler);
         if(param1 is Sound)
         {
            param1.removeEventListener(Event.ID3,this.ID3Handler);
         }
      }
      
      private function clearCurrentItem(param1:* = null) : void
      {
         var _loc2_:* = undefined;
         if(param1)
         {
            this.removeListeners(IEventDispatcher(param1.target));
         }
         else
         {
            for(_loc2_ in this._map)
            {
               this.removeListeners(_loc2_);
            }
         }
      }
      
      private function openHandler(param1:Event) : void
      {
         (this._map[param1.target] as LoadItem).info.open = getTimer();
         dispatchEvent(this.packageEvent(LoaderEvent.START,this,0,this._percentQueue,this._map[param1.target].resource));
      }
      
      public function add(param1:String, param2:Object = null) : Resource
      {
         return this.addAt(param1,this._queue.length,param2);
      }
      
      private function errorHandler(param1:*) : void
      {
         var _loc2_:LoadItem = this._map[param1.target];
         dispatchEvent(this.packageEvent(LoaderEvent.ERROR,this,_loc2_.percent,this._percentQueue,_loc2_.resource,param1.text));
         ++this._itemFailed;
         this.clearCurrentItem(param1);
         this.afterComplete(_loc2_);
      }
      
      public function get maxThreadCount() : uint
      {
         return this._maxThreadCount;
      }
      
      public function addAt(param1:String, param2:int, param3:Object = null) : Resource
      {
         var _loc5_:LoadItem = null;
         var _loc6_:String = null;
         var _loc4_:Resource = this.findItem(param1);
         if(_loc4_ == null)
         {
            _loc4_ = new Resource();
            _loc4_.url = param1;
            _loc4_.type = ResourceType.getType(param1);
            _loc5_ = new LoadItem();
            _loc5_.percent = 0;
            _loc5_.resource = _loc4_;
            _loc5_.addEventListener(LoaderEvent.ERROR,this.unknownErrorHandler);
            if(param3 != null)
            {
               for(_loc6_ in param3)
               {
                  _loc4_[_loc6_] = param3[_loc6_];
               }
            }
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
            dispatchEvent(this.packageEvent(LoaderEvent.COMPLETE,this,100,this._percentQueue,param1.resource));
         }
         if(this._queue.length)
         {
            this.loadItem();
         }
         else
         {
            dispatchEvent(this.packageEvent(LoaderEvent.QUEUE_COMPLETE,this,100,100,param1.resource));
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
      
      private function ID3Handler(param1:Event) : void
      {
         var _loc2_:LoaderEvent = this.packageEvent(LoaderEvent.ID3_COMPLETE,this,this._map[param1.target].percent,this._percentQueue,this._map[param1.target].resource);
         _loc2_.id3Info = param1.target["id3"];
         dispatchEvent(_loc2_);
      }
      
      public function set maxThreadCount(param1:uint) : void
      {
         this._maxThreadCount = Math.max(param1,0);
      }
      
      public function addEventListeners(param1:Function) : void
      {
         var _loc2_:String = null;
         for each(_loc2_ in this._eventList)
         {
            addEventListener(_loc2_,param1,false,0,false);
         }
      }
      
      public function get loadingThreadCount() : uint
      {
         return this._loadingThreadCount;
      }
      
      private function clear(param1:Event = null) : void
      {
         this.clearCurrentItem(param1);
         if(!this._itemFailed)
         {
            this.reset();
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
      
      private function completeHandler(param1:* = null) : void
      {
         var _loc2_:LoadItem = this._map[param1.target];
         _loc2_.stopReportTimer();
         _loc2_.removeEventListener(LoaderEvent.ERROR,this.unknownErrorHandler);
         if(_loc2_.info)
         {
            _loc2_.info.dispatch_complete = getTimer();
         }
         this.processFile(param1);
         delete this._map[param1.target];
         _loc2_.percent = 100;
         ++this._itemLoaded;
         this.clearCurrentItem(param1);
         this.afterComplete(_loc2_);
      }
      
      public function removeAt(param1:int) : Boolean
      {
         return this.removeItem(null,param1);
      }
      
      public function start() : void
      {
         if(this._status == STATUS_STOPPED && this._queue.length > 0)
         {
            this.setStatus(STATUS_LOADING);
            dispatchEvent(new LoaderEvent(LoaderEvent.QUEUE_START));
            this.loadItem();
         }
      }
      
      private function progressHandler(param1:ProgressEvent) : void
      {
         var _loc4_:* = undefined;
         var _loc5_:Number = NaN;
         var _loc2_:int = int(this._queue.length);
         var _loc3_:LoadItem = this._map[param1.target];
         this._percentQueue = 0;
         if(param1.bytesTotal < 1000)
         {
            _loc3_.percent = 50;
         }
         else
         {
            _loc3_.percent = param1.bytesLoaded / param1.bytesTotal * 100;
         }
         for(_loc4_ in this._map)
         {
            if(this._map[_loc4_].percent)
            {
               this._percentQueue += this._map[_loc4_].percent;
            }
         }
         this._percentQueue = (100 * this._itemLoaded + this._percentQueue) / (this._itemLoaded + this._itemFailed + _loc2_);
         _loc5_ = _loc3_.percent;
         dispatchEvent(this.packageEvent(LoaderEvent.PROGRESS,this,_loc5_,this._percentQueue,_loc3_.resource));
         dispatchEvent(this.packageEvent(LoaderEvent.QUEUE_PROGRESS,this,_loc5_,this._percentQueue,_loc3_.resource));
         _loc3_.startReportTimer();
         if(_loc3_.percent >= 100 && Boolean(_loc3_.info))
         {
            if(!_loc3_.info.bytes_complete)
            {
               _loc3_.info.bytes_complete = getTimer();
            }
         }
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
      
      public function get status() : String
      {
         return this._status;
      }
      
      private function setStatus(param1:String) : void
      {
         this._status = param1;
      }
      
      private function httpstatusHandler(param1:HTTPStatusEvent) : void
      {
         var _loc2_:LoadItem = this._map[param1.target];
         _loc2_.status = param1.status;
         if(param1.status == 404)
         {
            _loc2_.stopReportTimer();
         }
      }
      
      private function packageEvent(param1:String, param2:*, param3:Number, param4:Number, param5:Resource, param6:String = "") : LoaderEvent
      {
         var _loc7_:LoaderEvent = new LoaderEvent(param1);
         _loc7_.loader = param2;
         _loc7_.percentItem = param3;
         _loc7_.percentQueue = param4;
         _loc7_.item = param5;
         _loc7_.queue_count = this._itemLoaded;
         _loc7_.fail_count = this._itemFailed;
         _loc7_.queue_length = this._queue.length;
         if(param6)
         {
            _loc7_.msg = param6;
         }
         return _loc7_;
      }
      
      private function setListeners(param1:IEventDispatcher) : void
      {
         param1.addEventListener(Event.OPEN,this.openHandler,false,0,false);
         param1.addEventListener(Event.INIT,this.initHandler,false,0,false);
         param1.addEventListener(ProgressEvent.PROGRESS,this.progressHandler,false,0,false);
         param1.addEventListener(Event.COMPLETE,this.completeHandler,false,0,false);
         param1.addEventListener(HTTPStatusEvent.HTTP_STATUS,this.httpstatusHandler,false,0,false);
         param1.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.errorHandler,false,0,false);
         param1.addEventListener(IOErrorEvent.IO_ERROR,this.errorHandler,false,0,false);
         if(param1 is Sound)
         {
            param1.addEventListener(Event.ID3,this.ID3Handler,false,0,false);
         }
      }
   }
}

import com.qzone.qfa.managers.events.LoaderEvent;
import com.qzone.qfa.managers.resource.Resource;
import flash.display.LoaderInfo;
import flash.events.EventDispatcher;
import flash.net.URLLoader;
import flash.utils.clearInterval;
import flash.utils.setInterval;

class LoadItem extends EventDispatcher
{
   
   public var percent:Number;
   
   public var info:ProgressInfo;
   
   private var tid:uint;
   
   public var status:int = -1;
   
   public var loader:EventDispatcher;
   
   public var resource:Resource;
   
   private var _loop:int = 0;
   
   public function LoadItem()
   {
      super();
   }
   
   public function stopReportTimer() : void
   {
      if(this.tid)
      {
         clearInterval(this.tid);
         this.tid = 0;
      }
   }
   
   public function startReportTimer() : void
   {
      this.stopReportTimer();
      var _loc1_:int = this.percent >= 100 ? 1000 : 5000;
      this.tid = setInterval(this.handleTimeComplete,_loc1_);
   }
   
   private function handleTimeComplete() : void
   {
      var _loc1_:Boolean = false;
      if(this.resource.loader is URLLoader)
      {
         _loc1_ ||= (this.resource.loader as URLLoader).data == null;
      }
      else if(this.resource.loader is LoaderInfo)
      {
         _loc1_ ||= this.resource.loaderInfo.content == null;
      }
      if(this.percent >= 100 && _loc1_ && ++this._loop <= 30)
      {
         this.startReportTimer();
         return;
      }
      this.stopReportTimer();
      var _loc2_:LoaderEvent = new LoaderEvent(LoaderEvent.ERROR);
      _loc2_.item = this.resource;
      dispatchEvent(_loc2_);
   }
}

class ProgressInfo
{
   
   public var start:int;
   
   public var init_complete:int;
   
   public var open:int;
   
   public var bytes_complete:int;
   
   public var dispatch_complete:int;
   
   public function ProgressInfo()
   {
      super();
   }
   
   public function toString() : String
   {
      var _loc3_:String = null;
      var _loc1_:String = "";
      var _loc2_:Array = ["start","open","bytes_complete","init_complete","dispatch_complete"];
      for each(_loc3_ in _loc2_)
      {
         if(this[_loc3_])
         {
            _loc1_ += _loc3_ + ":" + this[_loc3_] + ", ";
         }
      }
      return _loc1_.replace(/,\s+$/,"").toUpperCase();
   }
}
