package framework.net.core
{
   import common.CommonData;
   import common.Settings;
   import common.misc.Cookies;
   
   public final class RequestChecker
   {
      
      private static var _data:Object = null;
      
      private static var _errorLimit:int = 10;
      
      private static var _instance:RequestChecker = null;
      
      public function RequestChecker()
      {
         super();
      }
      
      public static function getInofByUrl(param1:String) : Object
      {
         if(_data == null)
         {
            return null;
         }
         return _data[param1];
      }
      
      public static function checkRequest(param1:String) : Boolean
      {
         var _loc3_:Object = null;
         var _loc4_:int = 0;
         if(param1 == null || param1.length == 0)
         {
            return false;
         }
         if(_data == null)
         {
            return true;
         }
         var _loc2_:Boolean = false;
         if(param1.indexOf("harvest") == -1 && param1.indexOf("scrounge") == -1 && param1.indexOf("planting") == -1 && param1.indexOf("scarify") == -1)
         {
            if(param1.indexOf("cgi_farm_index") != -1 && param1.indexOf("flag=1") != -1)
            {
               _loc2_ = true;
            }
         }
         if(_loc2_)
         {
            return true;
         }
         _loc2_ = true;
         if(_data.hasOwnProperty(param1))
         {
            _loc3_ = _data[param1];
            if(_loc3_ != null && int(_loc3_.limitMinute) > 0)
            {
               _loc2_ = false;
               _loc4_ = CommonData.serverTime / 60 - int(_loc3_.time) / 60;
               if(_loc4_ >= int(_loc3_.limitMinute))
               {
                  delete _data[param1];
                  save();
                  _loc2_ = true;
               }
            }
         }
         return _loc2_;
      }
      
      public static function clean(param1:String) : void
      {
         if(param1 == null || param1.length == 0)
         {
            return;
         }
         if(_data == null)
         {
            return;
         }
         if(_data.hasOwnProperty(param1))
         {
            delete _data[param1];
            save();
         }
      }
      
      public static function addErrorRequest(param1:String) : void
      {
         if(param1 == null || param1.length == 0)
         {
            return;
         }
         if(_data == null)
         {
            return;
         }
         var _loc2_:Object = null;
         if(_data.hasOwnProperty(param1))
         {
            _loc2_ = _data[param1];
            _loc2_["errorCount"] = int(_loc2_.errorCount) + 1;
            _loc2_["time"] = CommonData.serverTime;
            if(int(_loc2_["errorCount"]) >= _errorLimit)
            {
               _loc2_["limitMinute"] = int(Math.random() * 9 + 1);
            }
         }
         else
         {
            _loc2_ = {
               "errorCount":1,
               "time":CommonData.serverTime,
               "limitMinute":0,
               "showed":false
            };
         }
         _data[param1] = _loc2_;
         save();
      }
      
      public static function initialize() : void
      {
         if(_instance == null)
         {
            _errorLimit = int(parseInt(Settings.getInstance().getStringAttribute("snowslide"))) || _errorLimit;
            _instance = new RequestChecker();
            _data = Cookies.getObject("requestManager2") || {};
         }
      }
      
      protected static function save() : void
      {
         Cookies.setObject("requestManager2",_data,0,false);
      }
   }
}

