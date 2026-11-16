package com.qzone.corelib.net
{
   import flash.events.Event;
   import flash.system.ApplicationDomain;
   
   public class RSLManager
   {
      
      public static var applicationDomain:ApplicationDomain;
      
      private static var instance:RSLManager;
      
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
      
      public function requestClass(param1:String, param2:Function, param3:String = null, param4:Object = null) : void
      {
         var name:String = param1;
         var callback:Function = param2;
         var url:String = param3;
         var data:Object = param4;
         if(getClass(name))
         {
            if(data)
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
            this.rslLoader.loader.contentLoaderInfo.addEventListener(Event.COMPLETE,function(param1:Event):void
            {
               param1.currentTarget.removeEventListener(Event.COMPLETE,arguments.callee);
               requestClass(name,callback,url,data);
            });
            this.rslLoader.load([{"url":url}]);
         }
      }
   }
}

