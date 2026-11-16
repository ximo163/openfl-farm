package com.qzone.allianceActivity
{
   import com.qzone.allianceActivity.interfaces.IAllianceActivityContext;
   import com.qzone.allianceActivity.interfaces.IAllianceAppHelper;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.external.ExternalInterface;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.system.SecurityDomain;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   public class AllianceActivityManager
   {
      
      private static var _instance:AllianceActivityManager;
      
      private var _loaders:Dictionary = new Dictionary();
      
      private var _initializeServerTime:Number = -1;
      
      private var _moduleMap:Dictionary;
      
      private var _initialized:Boolean = false;
      
      private var _appHelpersMap:Dictionary = new Dictionary();
      
      private var _initializeTime:Number = -1;
      
      private var _config:AllianceActivityConfig;
      
      public function AllianceActivityManager()
      {
         var _loc1_:AbstractAllianceActivityContext = null;
         var _loc2_:IAllianceAppHelper = null;
         var _loc3_:IAllianceActivityContext = null;
         super();
      }
      
      public static function getInstance() : AllianceActivityManager
      {
         if(_instance == null)
         {
            _instance = new AllianceActivityManager();
         }
         return _instance;
      }
      
      public function destoryActivityContext(param1:String) : void
      {
         var _loc2_:IAllianceActivityContext = null;
         if(this._moduleMap[param1])
         {
            _loc2_ = this.getActivityContext(param1);
            if(_loc2_)
            {
               _loc2_.destory();
            }
            this._moduleMap[param1] = null;
            delete this._moduleMap[param1];
         }
      }
      
      public function registerAppHelper(param1:String, param2:IAllianceAppHelper) : void
      {
         this._appHelpersMap[param1] = param2;
      }
      
      private function cacheModule(param1:String, param2:IAllianceActivityContext) : void
      {
         this._moduleMap[param1] = param2;
      }
      
      public function reset() : void
      {
         this._initialized = false;
      }
      
      public function initialize(param1:XML, param2:Number, param3:String) : void
      {
         if(!this._initialized)
         {
            this._initializeServerTime = param2;
            this._initializeTime = getTimer();
            this._moduleMap = new Dictionary();
            this._config = new AllianceActivityConfig(param3);
            this._config.readXML(param1);
            this._initialized = true;
         }
      }
      
      public function get initialized() : Boolean
      {
         return this._initialized;
      }
      
      public function get config() : AllianceActivityConfig
      {
         return this._config;
      }
      
      private function loadModuleResultHandler(param1:Event) : void
      {
         var loader:Loader = null;
         var content:DisplayObject = null;
         var moduleUrl:String = null;
         var activityId:String = null;
         var key:* = undefined;
         var activityContext:IAllianceActivityContext = null;
         var activityConfig:AllianceActivityInfo = null;
         var event:Event = param1;
         var loaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
         try
         {
            loader = loaderInfo.loader;
            content = loaderInfo.loader.content;
         }
         catch(e:Error)
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.call("Clinic.log.report","加载联合活动素材文件失败",3);
            }
         }
         if(Boolean(event.type == Event.COMPLETE) && Boolean(content) && content is IAllianceActivityContext)
         {
            moduleUrl = loaderInfo.url;
            activityId = this.getActivityIdByModuleUrl(moduleUrl);
            for(key in this._loaders)
            {
               if(this._loaders[key] == loader)
               {
                  activityId = key;
                  delete this._loaders[key];
                  break;
               }
            }
            activityContext = content as IAllianceActivityContext;
            activityConfig = this._config.getActivityConfig(activityId);
            activityContext.activityId = activityId;
            activityContext.appId = this._config.getAppId();
            activityContext.currentTime = this.getSevTime();
            activityContext.initialize(activityConfig);
            this.cacheModule(activityId,activityContext);
            loader.dispatchEvent(new Event(Event.COMPLETE));
         }
         else
         {
            loader.dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
         }
      }
      
      public function loadActivityModule(param1:String) : EventDispatcher
      {
         var _loc2_:Loader = new Loader();
         var _loc3_:LoaderContext = new LoaderContext(false,ApplicationDomain.currentDomain);
         var _loc4_:String = this.getModuelUrl(param1);
         var _loc5_:URLRequest = new URLRequest(_loc4_);
         _loc2_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.loadModuleResultHandler);
         _loc2_.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.loadModuleResultHandler);
         if(_loc4_.indexOf("file://") >= 0 || _loc4_.indexOf("://") < 0)
         {
            _loc3_.securityDomain = null;
         }
         else
         {
            _loc3_.securityDomain = SecurityDomain.currentDomain;
         }
         _loc2_.load(_loc5_,_loc3_);
         this._loaders[param1] = _loc2_;
         return _loc2_;
      }
      
      private function getActivityIdByModuleUrl(param1:String) : String
      {
         var _loc2_:AllianceActivityInfo = this._config.getActivityConfigByModuleUrl(param1);
         if(_loc2_)
         {
            return _loc2_.id;
         }
         return null;
      }
      
      public function retriveAppHelper(param1:String) : IAllianceAppHelper
      {
         return this._appHelpersMap[param1];
      }
      
      public function getActivityContext(param1:String) : IAllianceActivityContext
      {
         if(this._moduleMap != null && this._moduleMap.hasOwnProperty(param1))
         {
            return this._moduleMap[param1];
         }
         return null;
      }
      
      public function invoke(param1:String, param2:String, param3:Array) : *
      {
         var _loc5_:Function = null;
         var _loc4_:* = this.getActivityContext(param1);
         if(_loc4_)
         {
            _loc5_ = _loc4_[param2];
            return _loc5_.apply(_loc4_,param3);
         }
         return null;
      }
      
      public function setActivityStartAndExpireTime(param1:String, param2:Number, param3:Number) : void
      {
         var _loc4_:AllianceActivityInfo = this._config.getActivityConfig(param1);
         if(_loc4_)
         {
            _loc4_.startTime = param2;
            _loc4_.expireTime = param3;
         }
      }
      
      public function checkActivityAvaliable(param1:String) : Boolean
      {
         var _loc2_:AllianceActivityInfo = this._config.getActivityConfig(param1);
         var _loc3_:Number = this.getSevTime();
         if(_loc2_)
         {
            if(_loc2_.startTime < _loc3_ && _loc2_.expireTime > _loc3_)
            {
               return true;
            }
         }
         return false;
      }
      
      public function getSevTime() : Number
      {
         return this._initializeServerTime + getTimer() - this._initializeTime;
      }
      
      public function isActivityModuleReady(param1:String) : Boolean
      {
         if(this._moduleMap.hasOwnProperty(param1))
         {
            return this._moduleMap[param1] is IAllianceActivityContext;
         }
         return false;
      }
      
      private function getModuelUrl(param1:String) : String
      {
         var _loc2_:AllianceActivityInfo = this._config.getActivityConfig(param1);
         if(_loc2_)
         {
            return _loc2_.src;
         }
         return null;
      }
   }
}

