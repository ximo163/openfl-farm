package wild.com.comm
{
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.HTTPStatusEvent;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   import flash.utils.setTimeout;
   
   public class CropLoader extends EventDispatcher
   {
      
      public static const ITEM_COMPLETE:String = "item_complete";
      
      private var _contents:Object;
      
      private var _loader:Loader;
      
      private var _material:Boolean;
      
      private var _urlArray:Array;
      
      public var lc:LoaderContext;
      
      public function CropLoader()
      {
         super();
      }
      
      private function onIOError(param1:IOErrorEvent) : void
      {
         this._contents[this._loader.contentLoaderInfo.url] = "error";
         this.loadNext();
      }
      
      private function onHttpStatus(param1:HTTPStatusEvent) : void
      {
      }
      
      public function load(param1:Array = null, param2:Boolean = false) : void
      {
         if(param1 == null)
         {
            throw new Error("需要设置urlArray或urls参数");
         }
         this._contents = new Object();
         this._urlArray = param1;
         this._material = param2;
         if(this._loader == null)
         {
            this._loader = new Loader();
            this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onComp);
            this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onIOError);
            this._loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS,this.onHttpStatus);
            this._loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,this.onProgress);
         }
         setTimeout(this.loadNext,50);
      }
      
      private function comp() : void
      {
         dispatchEvent(new Event(Event.COMPLETE));
         this._loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onComp);
         this._loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.onIOError);
         this._loader.contentLoaderInfo.removeEventListener(HTTPStatusEvent.HTTP_STATUS,this.onHttpStatus);
         this._loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,this.onProgress);
         try
         {
            this._loader.close();
         }
         catch(e:Error)
         {
         }
         this._loader = null;
      }
      
      public function get urlArray() : Array
      {
         return this._urlArray;
      }
      
      public function set urlArray(param1:Array) : void
      {
         this._urlArray = param1;
      }
      
      private function onComp(param1:Event) : void
      {
         if(this._material)
         {
            this._contents[this._loader.contentLoaderInfo.url] = param1.currentTarget.applicationDomain;
         }
         else
         {
            this._contents[this._loader.contentLoaderInfo] = this._loader.contentLoaderInfo.content;
         }
         dispatchEvent(new Event(CropLoader.ITEM_COMPLETE));
         this.loadNext();
      }
      
      private function loadNext() : void
      {
         var _loc1_:String = null;
         if(this._urlArray.length > 0)
         {
            _loc1_ = this._urlArray.shift();
            if(_loc1_)
            {
               this._loader.load(new URLRequest(_loc1_),this.lc);
            }
         }
         else
         {
            this.comp();
         }
      }
      
      public function get contents() : Object
      {
         return this._contents;
      }
      
      private function onProgress(param1:ProgressEvent) : void
      {
      }
   }
}

