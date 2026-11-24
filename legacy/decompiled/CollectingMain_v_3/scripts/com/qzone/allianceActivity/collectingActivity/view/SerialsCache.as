package com.qzone.allianceActivity.collectingActivity.view
{
   import flash.display.BitmapData;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.geom.Matrix;
   import flash.net.URLRequest;
   import flash.net.registerClassAlias;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.system.SecurityDomain;
   import flash.utils.ByteArray;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public final class SerialsCache extends EventDispatcher
   {
      
      private static var _instance:SerialsCache;
      
      internal static const EVENT_SERIAL_DOWNLOADED:String = "SERIAL_RES_DOWNLOADED";
      
      private var _iconRes:MovieClip;
      
      private var _iconCache:Array;
      
      private var _loading:Boolean;
      
      public function SerialsCache()
      {
         super(null);
         this._loading = false;
      }
      
      public static function getInstance() : SerialsCache
      {
         if(_instance == null)
         {
            _instance = new SerialsCache();
         }
         return _instance;
      }
      
      private function errorHandler(param1:IOErrorEvent) : void
      {
         this._loading = false;
      }
      
      private function clone(param1:*) : *
      {
         registerClassAlias("mySprite",getDefinitionByName(getQualifiedClassName(param1)) as Class);
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeObject(param1);
         _loc2_.position = 0;
         return _loc2_.readObject();
      }
      
      private function createIconCache(param1:MovieClip) : void
      {
         if(param1 == null)
         {
            return;
         }
         this._iconRes = param1;
         this._iconCache = new Array();
         var _loc2_:BitmapData = null;
         var _loc3_:Matrix = new Matrix();
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Number = 0;
         var _loc7_:int = 1;
         while(_loc7_ <= this._iconRes.totalFrames)
         {
            this._iconRes.gotoAndStop(_loc7_);
            _loc4_ = this._iconRes.width;
            _loc5_ = this._iconRes.height;
            _loc6_ = Math.min(48 / _loc4_,48 / _loc5_);
            _loc3_.identity();
            _loc3_.scale(_loc6_,_loc6_);
            _loc3_.translate(48 - Math.floor(_loc6_ * _loc4_),48 - Math.floor(_loc6_ * _loc5_));
            _loc2_ = new BitmapData(48,48,true,0);
            _loc2_.draw(this._iconRes,_loc3_,null,null,null,true);
            this._iconCache.push(_loc2_);
            _loc7_++;
         }
      }
      
      public function getSerialIconFromCache(param1:int, param2:Number = 1) : BitmapData
      {
         var _loc3_:BitmapData = null;
         var _loc4_:Matrix = null;
         if(this._iconCache == null)
         {
            return null;
         }
         param1--;
         if(param1 < 0 || param1 >= this._iconCache.length)
         {
            return null;
         }
         if(param2 <= 1.00001)
         {
            return this._iconCache[param1];
         }
         if(this._iconRes != null)
         {
            this._iconRes.gotoAndStop(param1 + 1);
            _loc3_ = null;
            _loc4_ = new Matrix();
            _loc4_.identity();
            _loc4_.scale(param2,param2);
            _loc3_ = new BitmapData(this._iconRes.width * param2,this._iconRes.height * param2,true,0);
            _loc3_.draw(this._iconRes,_loc4_,null,null,null,true);
            return _loc3_;
         }
         return null;
      }
      
      public function loadRes(param1:String) : void
      {
         if(param1 == "" || param1 == null)
         {
            return;
         }
         if(this._loading == true)
         {
            return;
         }
         if(this._iconRes != null)
         {
            return;
         }
         var _loc2_:Loader = new Loader();
         _loc2_.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.errorHandler);
         _loc2_.contentLoaderInfo.addEventListener(IOErrorEvent.NETWORK_ERROR,this.errorHandler);
         _loc2_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.loadComplete);
         _loc2_.load(new URLRequest(param1),new LoaderContext(true,ApplicationDomain.currentDomain,SecurityDomain.currentDomain));
      }
      
      private function loadComplete(param1:Event) : void
      {
         this._loading = false;
         var _loc2_:LoaderInfo = param1.target as LoaderInfo;
         if(_loc2_ != null)
         {
            this.createIconCache(_loc2_.content as MovieClip);
         }
         dispatchEvent(new Event(EVENT_SERIAL_DOWNLOADED));
      }
   }
}

