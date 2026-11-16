package com.qzone.utils
{
   public final class DateUtil
   {
      
      public function DateUtil()
      {
         super();
      }
      
      public static function getTimeNumber(param1:Date) : Number
      {
         var _loc2_:Number = NaN;
         _loc2_ = param1.getHours() * 10000;
         _loc2_ += param1.getMinutes() * 100;
         _loc2_ += param1.getSeconds();
         return _loc2_ / 10000;
      }
      
      public static function getDateFromString(param1:String, param2:String = "-", param3:String = ":") : Date
      {
         var _loc4_:Array = param1.split(" ");
         var _loc5_:Array = String(_loc4_[0]).split(param2);
         var _loc6_:Array = String(_loc4_[1]).split(param3);
         return new Date(_loc5_[0],_loc5_[1] - 1,_loc5_[2],_loc6_[0],_loc6_[1],_loc6_[2]);
      }
   }
}

