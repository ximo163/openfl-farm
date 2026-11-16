package com.qzone.corelib.controls
{
   import com.qzone.utils.ImageSizeUtil;
   import flash.display.Bitmap;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.system.SecurityDomain;
   import flash.utils.ByteArray;
   
   public class ExtLoader extends Sprite
   {
      
      public static const ONLOAD_INIT:String = "onLoadInit";
      
      protected var _autoRetry:int;
      
      public var defaultWidth:Number;
      
      public var defaultHeight:Number;
      
      protected var _border:Sprite;
      
      protected var _lc:LoaderContext;
      
      protected var _retryNum:int = 0;
      
      protected var _req:URLRequest;
      
      protected var _cachePrevImage:Boolean;
      
      protected var _prevImage:Bitmap;
      
      protected var _h:Number;
      
      protected var _style:int;
      
      protected var _smoothing:Boolean;
      
      public var contentUrl:String;
      
      protected var _w:Number;
      
      protected var _loader:Loader;
      
      public function ExtLoader(param1:Number = 150, param2:Number = 80, param3:int = -1, param4:Boolean = false, param5:int = 0, param6:Boolean = false, param7:int = 1)
      {
         super();
         this._w = param1;
         this._h = param2;
         this._style = param3;
         this._autoRetry = param7;
         this._smoothing = param4;
         this._cachePrevImage = param6;
         this._lc = new LoaderContext(true,ApplicationDomain.currentDomain,SecurityDomain.currentDomain);
         this._loader = new Loader();
         addChild(this._loader);
         this._border = new Sprite();
         this._border.graphics.lineStyle(0,0,param5 >= 1 ? 1 : 0);
         this._border.graphics.drawRect(0,0,this._w,this._h);
         this._border.graphics.endFill();
         addChild(this._border);
      }
      
      public function get contentHeight() : Number
      {
         return this._loader.height || 0;
      }
      
      protected function __onLoaderCompleteHandler(param1:Event) : void
      {
         this._retryNum = 0;
         if(this._cachePrevImage)
         {
            this._loader.alpha = 0;
            setChildIndex(this._loader,numChildren - 1);
         }
         this.defaultWidth = this._loader.content.width || 0;
         this.defaultHeight = this._loader.content.height || 0;
         ImageSizeUtil.setSize2(this._loader,0,0,this._w,this._h,this._style);
         if(this._loader.content is Bitmap && this._smoothing)
         {
            Bitmap(this._loader.content).smoothing = true;
         }
         this._loader.content.cacheAsBitmap = true;
         this._loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.__onLoaderCompleteHandler);
         dispatchEvent(new Event(ONLOAD_INIT));
      }
      
      public function get contentWidth() : Number
      {
         return this._loader.width || 0;
      }
      
      public function get loader() : Loader
      {
         return this._loader;
      }
      
      override public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         if(param1 == Event.COMPLETE || param1 == ProgressEvent.PROGRESS || param1 == IOErrorEvent.DISK_ERROR || param1 == IOErrorEvent.NETWORK_ERROR || param1 == IOErrorEvent.VERIFY_ERROR)
         {
            this._loader.contentLoaderInfo.addEventListener(param1,param2,param3,param4,param5);
         }
         else
         {
            super.addEventListener(param1,param2,param3,param4,param5);
         }
      }
      
      protected function __onLoaderIOErrorHandler(param1:IOErrorEvent) : void
      {
         if(this._retryNum < this._autoRetry && Boolean(this._autoRetry))
         {
            this._loader.load(this._req,this._lc);
            ++this._retryNum;
            return;
         }
         this._retryNum = 0;
         dispatchEvent(param1);
      }
      
      public function unloadPrevImage() : void
      {
         if(this._prevImage != null)
         {
            removeChild(this._prevImage);
            this._prevImage.bitmapData.dispose();
            this._prevImage = null;
         }
      }
      
      public function load(param1:String) : void
      {
         if(this._cachePrevImage)
         {
            if(this._loader.content is Bitmap)
            {
               this.unloadPrevImage();
               this._prevImage = new Bitmap(Bitmap(this._loader.content).bitmapData.clone(),"auto",true);
               this._prevImage.x = this._loader.x;
               this._prevImage.y = this._loader.y;
               this._prevImage.width = this._loader.width;
               this._prevImage.height = this._loader.height;
               addChild(this._prevImage);
            }
         }
         this.unload();
         this._req = new URLRequest(param1);
         this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.__onLoaderCompleteHandler);
         if(this._autoRetry > 0)
         {
            this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.__onLoaderIOErrorHandler);
         }
         this.contentUrl = param1;
         this._loader.load(this._req,this._lc);
      }
      
      public function set style(param1:int) : void
      {
         if(this._loader != null)
         {
            this._style = param1;
            ImageSizeUtil.setSize2(this._loader,0,0,this._w,this._h,this._style);
         }
      }
      
      public function loadBytes(param1:ByteArray, param2:LoaderContext = null) : void
      {
         this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.__onLoaderCompleteHandler);
         this._loader.loadBytes(param1,param2);
      }
      
      public function unload() : void
      {
         try
         {
            Bitmap(this._loader.content).bitmapData.dispose();
            this._loader.unload();
         }
         catch(err:Error)
         {
         }
      }
   }
}

