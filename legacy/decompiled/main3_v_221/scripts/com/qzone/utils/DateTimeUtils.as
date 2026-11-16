package com.qzone.utils
{
   public class DateTimeUtils
   {
      
      public function DateTimeUtils()
      {
         super();
      }
      
      public static function getDateTime() : String
      {
         return getDate() + " " + getTime();
      }
      
      public static function getTime() : String
      {
         var _loc1_:Date = new Date();
         var _loc2_:String = _loc1_.getHours() > 9 ? String(_loc1_.getHours()) : "0" + _loc1_.getHours();
         var _loc3_:String = _loc1_.getMinutes() > 9 ? String(_loc1_.getMinutes()) : "0" + _loc1_.getMinutes();
         var _loc4_:String = _loc1_.getSeconds() > 9 ? String(_loc1_.getSeconds()) : "0" + _loc1_.getSeconds();
         return _loc2_ + ":" + _loc3_ + ":" + _loc4_;
      }
      
      public static function getDate() : String
      {
         var _loc1_:Date = new Date();
         var _loc2_:String = String(_loc1_.getFullYear());
         var _loc3_:String = _loc1_.getMonth() + 1 > 9 ? String(_loc1_.getMonth() + 1) : "0" + (_loc1_.getMonth() + 1);
         var _loc4_:String = _loc1_.getDate() > 9 ? String(_loc1_.getDate()) : "0" + _loc1_.getDate();
         return _loc2_ + "-" + _loc3_ + "-" + _loc4_;
      }
      
      public static function formatSecondCount(param1:int, param2:Boolean) : String
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc3_:String = "";
         if(param1 > 0)
         {
            _loc4_ = param1 / 3600;
            _loc5_ = (param1 - _loc4_ * 3600) / 60;
            _loc6_ = param1 - _loc4_ * 3600 - _loc5_ * 60;
            if(param2 == true)
            {
               if(_loc4_ > 0)
               {
                  _loc3_ = _loc4_ + "小时";
               }
               if(_loc5_ > 0)
               {
                  _loc3_ += _loc5_ + "分";
               }
               if(_loc4_ == 0 && _loc6_ > 0)
               {
                  _loc3_ += _loc6_ + "秒";
               }
            }
            else
            {
               _loc3_ += _loc4_ + "小时" + _loc5_ + "分" + _loc6_ + "秒";
            }
         }
         return _loc3_;
      }
      
      public static function parseDate(param1:String) : Date
      {
         var _loc2_:Array = param1.split("-");
         return new Date(parseInt(_loc2_[0],10),parseInt(_loc2_[1],10) - 1,parseInt(_loc2_[2],10));
      }
      
      public static function formatMillisecond(param1:Number) : String
      {
         var _loc2_:int = Math.floor(param1 / 60000);
         var _loc3_:int = Math.floor(Math.floor(param1 / 1000) % 60);
         var _loc4_:String = String(_loc2_);
         var _loc5_:String = String(_loc3_);
         if(_loc2_ < 10)
         {
            _loc4_ = "0" + String(_loc2_);
         }
         if(_loc3_ < 10)
         {
            _loc5_ = "0" + String(_loc3_);
         }
         return _loc4_ + ":" + _loc5_;
      }
      
      public static function formatSecond(param1:Number) : String
      {
         var _loc2_:Number = Math.floor(param1 / 60);
         var _loc3_:Number = Math.floor(Math.floor(param1) % 60);
         var _loc4_:String = String(_loc2_);
         var _loc5_:String = String(_loc3_);
         if(_loc2_ < 10)
         {
            _loc4_ = "0" + String(_loc2_);
         }
         if(_loc3_ < 10)
         {
            _loc5_ = "0" + String(_loc3_);
         }
         return _loc4_ + ":" + _loc5_;
      }
      
      public static function getTimeString() : String
      {
         var _loc1_:Date = new Date();
         return String(_loc1_.getFullYear()) + String(_loc1_.getMonth() + 1) + String(_loc1_.getDate()) + String(_loc1_.getHours()) + String(_loc1_.getMinutes()) + String(_loc1_.getMilliseconds());
      }
      
      public static function isSameDay(param1:Number, param2:Number) : Boolean
      {
         if(param1 == 0)
         {
            return false;
         }
         var _loc3_:Date = new Date(param1 * 1000);
         var _loc4_:Date = new Date(param2 * 1000);
         if(_loc3_.getDate() != _loc4_.getDate())
         {
            return false;
         }
         return true;
      }
      
      public static function isLeapYear(param1:Number) : Boolean
      {
         if(param1 % 100 == 0)
         {
            if(param1 % 400 == 0)
            {
               return true;
            }
            return false;
         }
         if(param1 % 4 == 0)
         {
            return true;
         }
         return false;
      }
   }
}

