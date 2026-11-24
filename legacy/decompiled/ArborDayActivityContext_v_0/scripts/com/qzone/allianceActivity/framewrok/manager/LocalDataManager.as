package com.qzone.allianceActivity.framewrok.manager
{
   import com.qzone.allianceActivity.framewrok.utils.ClassUtils;
   import flash.net.SharedObject;
   
   public class LocalDataManager
   {
      
      private static var _ins:LocalDataManager;
      
      public var minDiskSpace:int = 0;
      
      public function LocalDataManager()
      {
         super();
      }
      
      public static function getInstance() : LocalDataManager
      {
         if(_ins == null)
         {
            _ins = new LocalDataManager();
         }
         return _ins;
      }
      
      private function getLocalPath(param1:*, param2:String = "") : String
      {
         return param1 ? ClassUtils.getInstanceClassName(param1) + param2 : param2;
      }
      
      public function save(param1:*, param2:String, param3:*, param4:Boolean = false) : void
      {
         var _loc5_:SharedObject = SharedObject.getLocal(this.getLocalPath(param1,param2));
         _loc5_.data.value = param3;
         _loc5_.data.time = new Date();
         if(param4)
         {
            _loc5_.flush(this.minDiskSpace);
         }
      }
      
      public function load(param1:*, param2:String = "") : *
      {
         var _loc3_:SharedObject = SharedObject.getLocal(this.getLocalPath(param1,param2));
         return _loc3_.data.value;
      }
      
      public function loadToday(param1:*, param2:String = "") : *
      {
         var _loc4_:Date = null;
         var _loc5_:Date = null;
         var _loc3_:SharedObject = SharedObject.getLocal(this.getLocalPath(param1,param2));
         if(Boolean(_loc3_) && Boolean(_loc3_.data.time) && _loc3_.data.time is Date)
         {
            _loc4_ = _loc3_.data.time;
            _loc5_ = new Date();
            if(_loc4_.fullYear == _loc5_.fullYear && _loc4_.month == _loc5_.month && _loc4_.date == _loc5_.date)
            {
               return _loc3_.data.value;
            }
         }
         return null;
      }
   }
}

