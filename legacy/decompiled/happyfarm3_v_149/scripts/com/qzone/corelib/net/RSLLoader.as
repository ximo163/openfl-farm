package com.qzone.corelib.net
{
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.events.TimerEvent;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.system.SecurityDomain;
   import flash.utils.Timer;
   
   public class RSLLoader
   {
      
      public var rsls:Array = [];
      
      private var _lc:LoaderContext;
      
      public var listCompleteFn:Function;
      
      public var securityDomain:SecurityDomain;
      
      private var _retryUrls:Object = {};
      
      private var _url:String;
      
      private var _loader:Loader;
      
      private var _urls:Object = {};
      
      private var _checkTimer:Timer;
      
      public var contentCheckDelay:int = 3000;
      
      private var _index:int;
      
      public var ignoreError:Boolean;
      
      private var _req:URLRequest;
      
      public var completeFn:Function;
      
      public var applicationDomain:ApplicationDomain;
      
      public var faultList:Array = [];
      
      public var errorFn:Function;
      
      private var _loading:Boolean;
      
      public var retryTimes:uint = 1;
      
      public function RSLLoader()
      {
         super();
         this.ignoreError = false;
         this.applicationDomain = ApplicationDomain.currentDomain;
         this._lc = new LoaderContext();
         this._req = new URLRequest();
         this._loader = new Loader();
         this._index = 0;
         this._loading = false;
         this._checkTimer = new Timer(this.contentCheckDelay,1);
         this._checkTimer.addEventListener(TimerEvent.TIMER,this.onTimeOut);
         this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoadComplete);
         this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onLoadError);
         this._loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onLoadError);
         this._loader.contentLoaderInfo.addEventListener(Event.OPEN,this.onLoadOpen);
         this._loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,this.onLoadProgress);
      }
      
      private function loadRSL() : void
      {
         this._url = this.rsls[this._index]["url"];
         if(this._url == "")
         {
            this._loading = false;
            ++this._index;
            this.onLoadComplete(null);
         }
         else
         {
            this._req.url = this._url;
            this._loading = true;
            ++this._index;
            if(this._urls[this._url] == true)
            {
               this.onLoadComplete(null);
            }
            else
            {
               this._loader.load(this._req,this._lc);
            }
         }
      }
      
      public function get loader() : Loader
      {
         return this._loader;
      }
      
      private function onLoadError(param1:Event) : void
      {
         this._checkTimer.stop();
         this.errorFn && this.errorFn(param1);
         var _loc2_:String = this._req.url;
         this.faultList.push(_loc2_);
         if(this.ignoreError)
         {
            this.loadNext(param1);
         }
      }
      
      private function onLoadProgress(param1:ProgressEvent) : void
      {
      }
      
      private function loadAllComplete(param1:Event) : void
      {
         this._loading = false;
         this.listCompleteFn && this.listCompleteFn(param1);
      }
      
      public function get loading() : Boolean
      {
         return this._loading;
      }
      
      private function onLoadComplete(param1:Event) : void
      {
         this._checkTimer.stop();
         this._urls[this._url] = true;
         this.completeFn && this.completeFn(param1);
         this.loadNext(param1);
      }
      
      public function reset() : void
      {
         this._urls = {};
         this.rsls = [];
         this.faultList = [];
         this._retryUrls = {};
         this._index = 0;
         this._loading = false;
      }
      
      private function onLoadOpen(param1:Event) : void
      {
         this._checkTimer.reset();
         this._checkTimer.start();
      }
      
      private function loadRetry() : void
      {
         var _loc1_:String = this._req.url;
         if(this.retryTimes == 0 || this._retryUrls[_loc1_] >= this.retryTimes)
         {
            trace("RSLLoader timeout, force to load next one!");
            this.faultList.push(_loc1_);
            this.loadNext(null);
         }
         else
         {
            trace("RSLLoader Retry Load Again!");
            this._loader.load(this._req,this._lc);
            if(this._retryUrls[_loc1_] == undefined)
            {
               this._retryUrls[_loc1_] = 1;
            }
            else
            {
               ++this._retryUrls[_loc1_];
            }
         }
      }
      
      public function load(param1:Array) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         for each(_loc2_ in param1)
         {
            if(!(_loc2_ == null || _loc2_["url"] == undefined))
            {
               _loc3_ = _loc2_["url"];
               if(!(_loc3_ == "" || _loc3_ == null))
               {
                  if(this._urls[_loc3_] === undefined)
                  {
                     this.rsls.push(_loc2_);
                     this._urls[_loc3_] = false;
                  }
               }
            }
         }
         if(this._loading == false)
         {
            if(this._index < this.rsls.length)
            {
               this._lc.applicationDomain = this.applicationDomain;
               this._lc.securityDomain = this.securityDomain;
               this.loadRSL();
            }
         }
      }
      
      private function onTimeOut(param1:Event) : void
      {
         this._checkTimer.stop();
         this.loadRetry();
      }
      
      private function loadNext(param1:Event) : void
      {
         if(this._index < this.rsls.length)
         {
            this.loadRSL();
         }
         else
         {
            this.loadAllComplete(param1);
         }
      }
   }
}

