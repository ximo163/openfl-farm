package com.qzone.utils
{
   import flash.display.DisplayObject;
   
   public final class AlignUtil
   {
      
      public function AlignUtil()
      {
         super();
      }
      
      public static function moveToCenter(param1:DisplayObject, param2:Number, param3:Number) : void
      {
         param1.x = int(middle(param2,param1.width));
         param1.y = int(middle(param3,param1.height));
      }
      
      public static function moveToBR(param1:DisplayObject, param2:Number, param3:Number) : void
      {
         var _loc4_:Number = 0;
         var _loc5_:Number = 0;
         _loc4_ = right(param2,param1.width);
         _loc5_ = right(param3,param1.height);
         param1.x = _loc4_;
         param1.y = _loc5_;
      }
      
      public static function right(param1:Number, param2:Number) : Number
      {
         var _loc3_:Number = 0;
         return param1 - param2;
      }
      
      public static function middle(param1:Number, param2:Number) : Number
      {
         var _loc3_:Number = 0;
         return param1 / 2 - param2 / 2;
      }
   }
}

