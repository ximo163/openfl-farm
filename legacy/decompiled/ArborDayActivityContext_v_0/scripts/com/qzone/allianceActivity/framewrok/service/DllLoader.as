package com.qzone.allianceActivity.framewrok.service
{
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   import flash.utils.ByteArray;
   
   public class DllLoader extends EventDispatcher
   {
      
      protected var _dllFileLoader:URLLoader;
      
      protected var _contentLoader:Loader;
      
      protected var _url:String;
      
      protected var _context:LoaderContext;
      
      protected var _compress:Boolean = false;
      
      public function DllLoader(param1:LoaderContext)
      {
         super();
         this._context = param1;
      }
      
      public function load(param1:String = null) : void
      {
         if(param1 != null)
         {
            this._url = param1;
         }
         this._dllFileLoader = new URLLoader();
         this._dllFileLoader.dataFormat = URLLoaderDataFormat.BINARY;
         this._dllFileLoader.addEventListener(ProgressEvent.PROGRESS,this.progressHandler);
         this._dllFileLoader.addEventListener(IOErrorEvent.IO_ERROR,this.errorHandler);
         this._dllFileLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.errorHandler);
         this._dllFileLoader.addEventListener(Event.COMPLETE,this.loadFileCompleteHandler);
         this._dllFileLoader.load(new URLRequest(this._url));
      }
      
      protected function loadFileCompleteHandler(param1:Event) : void
      {
         this._dllFileLoader.removeEventListener(ProgressEvent.PROGRESS,this.progressHandler);
         this._dllFileLoader.removeEventListener(IOErrorEvent.IO_ERROR,this.errorHandler);
         this._dllFileLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.errorHandler);
         this._dllFileLoader.removeEventListener(Event.COMPLETE,this.loadFileCompleteHandler);
         var _loc2_:ByteArray = this._dllFileLoader.data;
         if(this._compress)
         {
            _loc2_.uncompress();
         }
         this._contentLoader = new Loader();
         this._contentLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.errorHandler);
         this._contentLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.loadContentCompleteHandler);
         this._contentLoader.loadBytes(_loc2_,this._context);
      }
      
      protected function loadContentCompleteHandler(param1:Event) : void
      {
         this._contentLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.errorHandler);
         this._contentLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.loadContentCompleteHandler);
         this._contentLoader.unload();
         this._dllFileLoader = null;
         this._contentLoader = null;
         dispatchEvent(param1);
      }
      
      protected function progressHandler(param1:ProgressEvent) : void
      {
         dispatchEvent(param1);
      }
      
      protected function errorHandler(param1:Event) : void
      {
         dispatchEvent(param1);
      }
      
      public function get compress() : Boolean
      {
         return this._compress;
      }
      
      public function set compress(param1:Boolean) : void
      {
         this._compress = param1;
      }
      
      public function get url() : String
      {
         return this._url;
      }
      
      public function set url(param1:String) : void
      {
         this._url = param1;
      }
   }
}

