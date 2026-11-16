package com.qzone.corelib.net
{
   import common.misc.QzoneJSAPI;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.events.Event;
   import flash.events.HTTPStatusEvent;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.utils.Dictionary;
   
   public class RSLManager
   {
      
      public static var applicationDomain:ApplicationDomain;
      
      private static var instance:RSLManager;
      
      private var _cache:Dictionary;
      
      public var rslLoader:RSLLoader;
      
      public function RSLManager()
      {
         super();
         if(instance != null)
         {
            throw new Error("实例化单例类出错");
         }
      }
      
      public static function getClass(param1:String) : Class
      {
         if(applicationDomain.hasDefinition(param1))
         {
            return applicationDomain.getDefinition(param1) as Class;
         }
         return null;
      }
      
      public static function getInstance() : RSLManager
      {
         if(instance == null)
         {
            instance = new RSLManager();
         }
         return instance;
      }
      
      public static function getMaterial(param1:String) : Object
      {
         var _loc2_:Class = getClass(param1) as Class;
         if(_loc2_)
         {
            return new _loc2_();
         }
         return null;
      }
      
      private function handleError(param1:Event) : void
      {
         var _loc9_:HTTPStatusEvent = null;
         var _loc2_:LoaderInfo = param1.target as LoaderInfo;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:String = param1.type;
         var _loc4_:String = _loc2_.url;
         var _loc5_:Object = this._cache[_loc4_];
         if(_loc5_ == null)
         {
            return;
         }
         var _loc6_:Array = _loc5_["fail"] as Array;
         var _loc7_:Function = null;
         var _loc8_:Boolean = true;
         if(_loc3_ == HTTPStatusEvent.HTTP_STATUS)
         {
            _loc9_ = param1 as HTTPStatusEvent;
            if(_loc9_.status == 404 && _loc4_.indexOf("appimg1.") != -1)
            {
               for each(_loc7_ in _loc6_)
               {
                  _loc7_({"404":true});
               }
            }
            if(_loc9_.status < 300)
            {
               _loc8_ = false;
            }
            else
            {
               QzoneJSAPI.reportError("Download file[ " + _loc4_ + "] status " + _loc9_.status,1);
            }
         }
         if(_loc8_ == true)
         {
            _loc2_.removeEventListener(Event.COMPLETE,this.onRequestFileSuccess);
            _loc2_.removeEventListener(_loc3_,this.handleError);
            for each(_loc7_ in _loc6_)
            {
               QzoneJSAPI.reportError("Notify download file error " + _loc3_,1);
               _loc7_(null);
            }
            delete this._cache[_loc4_];
         }
      }
      
      private function onRequestFileSuccess(param1:Event) : void
      {
         var _loc5_:Function = null;
         var _loc2_:LoaderInfo = param1.target as LoaderInfo;
         if(_loc2_ == null || _loc2_.content == null)
         {
            throw new Error("System loader error.");
         }
         _loc2_.removeEventListener(Event.COMPLETE,this.onRequestFileSuccess);
         _loc2_.removeEventListener(IOErrorEvent.IO_ERROR,this.handleError);
         _loc2_.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.handleError);
         _loc2_.removeEventListener(HTTPStatusEvent.HTTP_STATUS,this.handleError);
         var _loc3_:String = _loc2_.url;
         var _loc4_:Object = this._cache[_loc3_];
         if(_loc4_ != null)
         {
            for each(_loc5_ in _loc4_["success"])
            {
               _loc5_(_loc2_.content);
            }
            delete this._cache[_loc3_];
         }
      }
      
      public function requestClass(param1:String, param2:Function, param3:String = null, param4:Object = null) : void
      {
         var name:String = param1;
         var callback:Function = param2;
         var url:String = param3;
         var data:Object = param4;
         if(getClass(name))
         {
            if(data != null)
            {
               callback && callback(data);
            }
            else
            {
               callback && callback();
            }
         }
         else
         {
            if(url == null || url == "")
            {
               return;
            }
            this.rslLoader.loader.contentLoaderInfo.addEventListener(Event.COMPLETE,function(param1:Event):void
            {
               param1.currentTarget.removeEventListener(Event.COMPLETE,arguments.callee);
               requestClass(name,callback,url,data);
            });
            if(url.indexOf("appimg1.") != -1 && callback != null)
            {
               this.rslLoader.loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS,function(param1:HTTPStatusEvent):void
               {
                  if(param1.status == 404 && data != null)
                  {
                     data["404"] = true;
                     callback(data);
                  }
               });
            }
            this.rslLoader.load([{"url":url}]);
         }
      }
      
      public function requestFile(param1:String, param2:Function, param3:Function = null) : void
      {
         var _loc8_:Object = null;
         var _loc9_:Array = null;
         if(param1 == null || param1 == "")
         {
            return;
         }
         if(this._cache == null)
         {
            this._cache = new Dictionary();
         }
         var _loc4_:Loader = null;
         if(this._cache != null && this._cache[param1] != undefined)
         {
            _loc8_ = this._cache[param1];
            if(_loc8_ != null)
            {
               _loc9_ = _loc8_["success"] as Array;
               if(param2 != null)
               {
                  if(_loc9_ == null)
                  {
                     _loc8_["success"] = [param2];
                  }
                  else if(_loc9_.indexOf(param2) == -1)
                  {
                     _loc9_.push(param2);
                  }
               }
               _loc9_ = _loc8_["fail"] as Array;
               if(param3 != null)
               {
                  if(_loc9_ == null)
                  {
                     _loc8_["fail"] = [param3];
                  }
                  else if(_loc9_.indexOf(param3) == -1)
                  {
                     _loc9_.push(param3);
                  }
               }
               return;
            }
         }
         else
         {
            _loc4_ = new Loader();
            this._cache[param1] = {"loader":_loc4_};
            if(param2 != null)
            {
               this._cache[param1]["success"] = [param2];
            }
            if(param3 != null)
            {
               this._cache[param1]["fail"] = [param3];
            }
         }
         var _loc5_:LoaderInfo = _loc4_.contentLoaderInfo;
         _loc5_.addEventListener(Event.COMPLETE,this.onRequestFileSuccess,false,0,true);
         _loc5_.addEventListener(IOErrorEvent.IO_ERROR,this.handleError,false,0,true);
         _loc5_.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.handleError,false,0,true);
         _loc5_.addEventListener(HTTPStatusEvent.HTTP_STATUS,this.handleError,false,0,true);
         var _loc6_:URLRequest = new URLRequest(param1);
         var _loc7_:LoaderContext = new LoaderContext(false,applicationDomain);
         _loc4_.load(_loc6_,_loc7_);
      }
   }
}

