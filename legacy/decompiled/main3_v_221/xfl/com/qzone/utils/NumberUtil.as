package com.qzone.utils
{
   public class NumberUtil
   {
      
      private static var __TWO_PI:Number = 2 * Math.PI;
      
      private static var __PI:Number = Math.PI;
      
      private static var __HALF_PI:Number = 0.5 * Math.PI;
      
      private static var __TO_DREGREE:Number = 180 / Math.PI;
      
      private static var __TO_RADIAN:Number = Math.PI / 180;
      
      public static var TOL:Number = 0.00001;
      
      private static var _fABS:Function = Math.abs;
      
      public function NumberUtil()
      {
         super();
      }
      
      public static function areEqual(param1:Number, param2:Number) : Boolean
      {
         return _fABS(param1 - param2) < TOL;
      }
      
      public static function get TO_DEGREE() : Number
      {
         return __TO_DREGREE;
      }
      
      public static function get HALF_PI() : Number
      {
         return __HALF_PI;
      }
      
      public static function toDegree(param1:Number) : Number
      {
         return param1 * TO_DEGREE;
      }
      
      public static function roundTo(param1:Number, param2:Number = 0) : Number
      {
         if(param2 == 0)
         {
            param2 = 1;
         }
         return Math.round(param1 / param2) * param2;
      }
      
      public static function get TWO_PI() : Number
      {
         return __TWO_PI;
      }
      
      public static function isZero(param1:Number) : Boolean
      {
         return _fABS(param1) < TOL;
      }
      
      public static function get TO_RADIAN() : Number
      {
         return __TO_RADIAN;
      }
      
      public static function constrain(param1:Number, param2:Number, param3:Number) : Number
      {
         return Math.max(Math.min(param1,param3),param2);
      }
      
      public static function get PI() : Number
      {
         return __PI;
      }
      
      public static function toRadian(param1:Number) : Number
      {
         return param1 * TO_RADIAN;
      }
   }
}

