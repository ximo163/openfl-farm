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
   import flash.utils.Dictionary;
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
      
      public var applicationDomain:ApplicationDomain;
      
      public var contentCheckDelay:int = 3000;
      
      private var _checkTimer:Timer;
      
      private var _urls:Object = {};
      
      private var _index:int;
      
      public var ignoreError:Boolean;
      
      private var _req:URLRequest;
      
      public var faultList:Array = [];
      
      public var completeFn:Function;
      
      private var _rslDict:Dictionary;
      
      public var errorFn:Function;
      
      private var _loading:Boolean;
      
      public var retryTimes:uint = 1;
      
      public function RSLLoader()
      {
         super();
         this.applicationDomain = ApplicationDomain.currentDomain;
         this._lc = new LoaderContext();
         this._req = new URLRequest();
         this._loader = new Loader();
         this._rslDict = new Dictionary();
         this._checkTimer = new Timer(this.contentCheckDelay,1);
         this._checkTimer.addEventListener(TimerEvent.TIMER,this.contentCheck);
         this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.loadComplete);
         this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.loadError);
         this._loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.loadError);
         this._loader.contentLoaderInfo.addEventListener(Event.OPEN,this.loadOpen);
         this._loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,this.loadOpen);
      }
      
      private function loadRSL() : void
      {
         this._url = this.rsls[this._index].url;
         this._req.url = this._url;
         this._loading = true;
         ++this._index;
         if(this._urls[this._url])
         {
            this.loadComplete(null);
         }
         else
         {
            this._loader.load(this._req,this._lc);
         }
      }
      
      private function contentCheck(param1:Event) : void
      {
         this._checkTimer.stop();
         this.loadRetry();
      }
      
      public function get loader() : Loader
      {
         return this._loader;
      }
      
      private function loadComplete(param1:Event) : void
      {
         this._checkTimer.stop();
         this._urls[this._url] = true;
         this.completeFn && this.completeFn(param1);
         this.loadNext(param1);
      }
      
      private function loadError(param1:Event) : void
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
      
      public function get loading() : Boolean
      {
         return this._loading;
      }
      
      private function loadAllComplete(param1:Event) : void
      {
         this._loading = false;
         this.listCompleteFn && this.listCompleteFn(param1);
      }
      
      private function loadOpen(param1:Event) : void
      {
         this._checkTimer.stop();
         this._checkTimer.start();
      }
      
      public function load(param1:Array) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         for each(_loc2_ in param1)
         {
            _loc3_ = _loc2_.url;
            if(this._urls[_loc3_] === undefined)
            {
               this.rsls.push(_loc2_);
               this._urls[_loc3_] = false;
            }
         }
         if(this._loading == false)
         {
            if(this._index < this.rsls.length)
            {
               this._lc.applicationDomain = this.applicationDomain;
               this.loadRSL();
            }
         }
      }
      
      private function loadRetry() : void
      {
         var _loc1_:String = this._req.url;
         if(this.retryTimes == 0 || this._retryUrls[_loc1_] >= this.retryTimes)
         {
            trace("RSLLoader Load Next Force!");
            this.faultList.push(_loc1_);
            this.loadNext(null);
         }
         else
         {
            trace("RSLLoader Retry Load Again!");
            this._loader.load(this._req,this._lc);
            if(this._retryUrls[_loc1_] > 0)
            {
               this._retryUrls[_loc1_] = 1;
            }
            else
            {
               ++this._retryUrls[_loc1_];
            }
         }
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

