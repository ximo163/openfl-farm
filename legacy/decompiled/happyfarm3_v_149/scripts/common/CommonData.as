package common
{
   import com.qzone.corelib.net.RSLLoader;
   import com.qzone.corelib.net.RSLManager;
   import common.misc.Cookies;
   import flash.system.ApplicationDomain;
   import flash.utils.getTimer;
   
   public class CommonData
   {
      
      public static var _root:*;
      
      public static var freeGift:Object;
      
      public static var APP_DOMAIN:ApplicationDomain;
      
      public static var swfUrl:String;
      
      public static var speed_indexer:Object;
      
      public static var useExpressUser:Boolean;
      
      public static var expressUser:*;
      
      public static var getRequestData:Object;
      
      public static var addCallBackProxy:Function;
      
      public static var rslManager:RSLManager;
      
      public static var getKey:Function;
      
      public static var applicationDomain:ApplicationDomain;
      
      public static var rslLoader:RSLLoader;
      
      private static var _serverTime:Number = 0;
      
      private static var _clientTime:Number = 0;
      
      public function CommonData()
      {
         trace("construct CommonData");
         super();
      }
      
      public static function beBackTimeIsToday() : Boolean
      {
         var _loc1_:Boolean = false;
         if(Cookies.getObject("getZhaohui") == null)
         {
            return false;
         }
         var _loc2_:Date = new Date(CommonData.serverTime * 1000);
         var _loc3_:Date = new Date(Cookies.getObject("getZhaohui")["time"] * 1000);
         if(_loc2_.getFullYear() == _loc3_.getFullYear())
         {
            if(_loc2_.getMonth() == _loc3_.getMonth())
            {
               if(_loc2_.getDate() == _loc3_.getDate())
               {
                  _loc1_ = true;
               }
            }
         }
         return _loc1_;
      }
      
      public static function set root(param1:*) : void
      {
         _root = param1;
      }
      
      public static function isCardsGameActivityToday(param1:uint) : Boolean
      {
         var _loc2_:Boolean = true;
         var _loc3_:uint = param1;
         if(Cookies.getObject("cardsgame_" + _loc3_) == null)
         {
            return _loc2_;
         }
         var _loc4_:Date = new Date(CommonData.serverTime * 1000);
         var _loc5_:Date = new Date(int(Cookies.getObject("cardsgame_" + _loc3_)) * 1000);
         if(_loc4_.getFullYear() == _loc5_.getFullYear())
         {
            if(_loc4_.getMonth() == _loc5_.getMonth())
            {
               if(_loc4_.getDate() == _loc5_.getDate())
               {
                  _loc2_ = false;
               }
            }
         }
         return _loc2_;
      }
      
      public static function getFormatNumber(param1:Number) : String
      {
         var _loc4_:String = null;
         var _loc2_:String = param1.toString();
         var _loc3_:String = "";
         while(_loc2_.length != 0)
         {
            if(_loc2_.length < 3)
            {
               _loc4_ = _loc2_.substr(0,_loc2_.length);
            }
            else
            {
               _loc4_ = _loc2_.substr(_loc2_.length - 3,_loc2_.length);
            }
            if(_loc3_ != "")
            {
               _loc3_ = _loc4_ + "," + _loc3_;
            }
            else
            {
               _loc3_ += _loc4_;
            }
            _loc2_ = _loc2_.replace(_loc4_,"");
         }
         return _loc3_;
      }
      
      public static function set serverTime(param1:Number) : void
      {
         if(Math.abs(_serverTime - param1) <= 1)
         {
            return;
         }
         _serverTime = param1;
         _clientTime = int(getTimer() / 1000);
      }
      
      public static function get root() : *
      {
         return _root;
      }
      
      public static function get serverTime() : Number
      {
         if(_serverTime == 0)
         {
            return 0;
         }
         return _serverTime + (Math.floor(getTimer() / 1000) - _clientTime);
      }
      
      public static function BackHandTimeIsToday(param1:int) : Boolean
      {
         var _loc2_:Boolean = false;
         if(Cookies.getObject("z_" + param1) == null)
         {
            return false;
         }
         var _loc3_:Date = new Date(CommonData.serverTime * 1000);
         var _loc4_:Date = new Date(Cookies.getObject("z_" + param1)["time"] * 1000);
         if(_loc3_.getFullYear() == _loc4_.getFullYear())
         {
            if(_loc3_.getMonth() == _loc4_.getMonth())
            {
               if(_loc3_.getDate() == _loc4_.getDate())
               {
                  _loc2_ = true;
               }
            }
         }
         return _loc2_;
      }
      
      public static function isMonthEndToday(param1:uint) : Boolean
      {
         var _loc2_:Boolean = true;
         var _loc3_:uint = param1;
         if(Cookies.getObject("monthend_" + _loc3_) == null)
         {
            return _loc2_;
         }
         var _loc4_:Date = new Date(CommonData.serverTime * 1000);
         var _loc5_:Date = new Date(int(Cookies.getObject("monthend_" + _loc3_)) * 1000);
         if(_loc4_.getFullYear() == _loc5_.getFullYear())
         {
            if(_loc4_.getMonth() == _loc5_.getMonth())
            {
               if(_loc4_.getDate() == _loc5_.getDate())
               {
                  _loc2_ = false;
               }
            }
         }
         return _loc2_;
      }
   }
}

