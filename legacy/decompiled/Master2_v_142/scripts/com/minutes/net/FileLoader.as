package com.minutes.net
{
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.HTTPStatusEvent;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.TimerEvent;
   import flash.net.URLRequest;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   
   public class FileLoader extends EventDispatcher
   {
      
      private var timer:Timer;
      
      private var _contents:Object;
      
      private var _urlArray:Array;
      
      private var preTime:Number = 0;
      
      private var _loader:Loader;
      
      private var _index:int = 0;
      
      public function FileLoader()
      {
         super();
      }
      
      public function get contents() : Object
      {
         return this._contents;
      }
      
      public function get urlArray() : Array
      {
         return this._urlArray;
      }
      
      private function onIOError(param1:IOErrorEvent) : void
      {
         if(this.contents == null)
         {
            this._contents = new Object();
         }
         this.contents[this.urlArray[this._index]] = "error";
         if(this._index + 1 >= this.urlArray.length)
         {
            this.comp();
         }
         else
         {
            this._index += 1;
            this.load();
         }
      }
      
      private function onProgress(param1:ProgressEvent) : void
      {
      }
      
      public function load(param1:Array = null) : void
      {
         var _loc2_:String = null;
         if(param1 != null)
         {
            this.urlArray = param1;
         }
         if(this.urlArray == null)
         {
            throw new Error("需要设置urlArray或urls参数");
         }
         if(this._loader == null)
         {
            this._loader = new Loader();
            this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onComp);
            this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onIOError);
            this._loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS,this.onHttpStatus);
            this._loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,this.onProgress);
            this.timer = new Timer(1000);
            this.timer.addEventListener(TimerEvent.TIMER,this.timerEventHandler);
            this.timer.start();
         }
         if(this.urlArray.length == 0 || this.urlArray[this._index] == "")
         {
            if(this.contents == null)
            {
               this._contents = new Object();
            }
            this.contents[this.urlArray[this._index]] = "";
            if(this._index + 1 >= this.urlArray.length)
            {
               this.comp();
            }
            else
            {
               this._index += 1;
               this.load();
            }
         }
         else
         {
            _loc2_ = this.urlArray[this._index];
            if(_loc2_)
            {
               this._loader.load(new URLRequest(_loc2_));
               this.preTime = getTimer();
            }
         }
      }
      
      private function onComp(param1:Event) : void
      {
         if(this.contents == null)
         {
            this._contents = new Object();
         }
         this.contents[this.urlArray[this._index]] = this._loader.contentLoaderInfo.content;
         if(this._index + 1 >= this.urlArray.length)
         {
            this.comp();
         }
         else
         {
            this._index += 1;
            this.load();
         }
      }
      
      private function comp() : void
      {
         dispatchEvent(new Event(Event.COMPLETE));
         this.timer.stop();
         this.timer = null;
         this._loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onComp);
         this._loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.onIOError);
         this._loader.contentLoaderInfo.removeEventListener(HTTPStatusEvent.HTTP_STATUS,this.onHttpStatus);
         this._loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,this.onProgress);
         this._index = 0;
         try
         {
            this._loader.close();
         }
         catch(e:Error)
         {
         }
         this._loader = null;
      }
      
      private function onHttpStatus(param1:HTTPStatusEvent) : void
      {
      }
      
      private function timerEventHandler(param1:TimerEvent) : void
      {
         var e:TimerEvent = param1;
         if(getTimer() - this.preTime > 1000 * 10)
         {
            if(this.contents == null)
            {
               this._contents = new Object();
            }
            this.contents[this.urlArray[this._index]] = "error";
            if(this._index + 1 >= this.urlArray.length)
            {
               this.comp();
            }
            else
            {
               this._index += 1;
               try
               {
                  this._loader.close();
               }
               catch(e:Error)
               {
               }
               this.load();
            }
         }
      }
      
      public function set urlArray(param1:Array) : void
      {
         this._urlArray = param1;
      }
   }
}

