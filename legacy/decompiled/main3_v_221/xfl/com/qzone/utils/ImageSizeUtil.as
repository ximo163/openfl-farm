package com.qzone.utils
{
   public class ImageSizeUtil
   {
      
      private static var __style:Number;
      
      public static const NO_SCALE_CENTER:int = 0;
      
      public static const SCALE_WITH_BIG_CENTER:int = 1;
      
      public static const SCALE_WITH_SMALL:int = 3;
      
      public static const SCALE_WITH_SMALL_TOP:int = 5;
      
      public static const SCALE_WITH_SMALL_BUTTOM:int = 6;
      
      public static const NO_HANDEL:int = -1;
      
      public static const NO_SCALE_CENTER_AND_KEEP_IN_RECT:int = 4;
      
      public function ImageSizeUtil()
      {
         super();
      }
      
      public static function setSize1(param1:Object, param2:Object, param3:Number) : void
      {
         setSize2(param1,param2.x,param2.y,param2.width,param2.height,param3);
      }
      
      public static function setSize2(param1:Object, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number) : void
      {
         if(param6 == -1)
         {
            return;
         }
         param1.scaleX = param1.scaleY = 1;
         if(param6 == 0)
         {
            param1.scaleX = param1.scaleY = 1;
         }
         else if(param6 == 1)
         {
            if(param1.width / param4 > param1.height / param5)
            {
               param1.height = param1.height / param1.width * param4;
               param1.width = param4;
            }
            else
            {
               param1.width = param1.width / param1.height * param5;
               param1.height = param5;
            }
         }
         else if(param6 == 3)
         {
            if(param1.width / param4 < param1.height / param5)
            {
               param1.height = param1.height / param1.width * param4;
               param1.width = param4;
            }
            else
            {
               param1.width = param1.width / param1.height * param5;
               param1.height = param4;
            }
         }
         else if(param6 == 2)
         {
            param1.width = param4;
            param1.height = param5;
         }
         else if(param6 == 4)
         {
            if(param1.width > param4 || param1.height > param5)
            {
               if(param1.width / param4 > param1.height / param5)
               {
                  param1.height = param1.height / param1.width * param4;
                  param1.width = param4;
               }
               else
               {
                  param1.width = param1.width / param1.height * param5;
                  param1.height = param5;
               }
            }
            else
            {
               param1.scaleX = param1.scaleY = 1;
            }
         }
         else
         {
            if(param6 == 5)
            {
               if(param1.width / param4 < param1.height / param5)
               {
                  param1.height = param1.height / param1.width * param4;
                  param1.width = param4;
               }
               else
               {
                  param1.width = param1.width / param1.height * param5;
                  param1.height = param4;
               }
               param1.x = param2 + param4 / 2 - param1.width / 2;
               param1.y = param3;
               return;
            }
            if(param6 == 6)
            {
               if(param1.width / param4 < param1.height / param5)
               {
                  param1.height = param1.height / param1.width * param4;
                  param1.width = param4;
               }
               else
               {
                  param1.width = param1.width / param1.height * param5;
                  param1.height = param4;
               }
               param1.x = param2 + param4 / 2 - param1.width / 2;
               param1.y = param5 - param1.height;
               return;
            }
         }
         param1.x = param2 + param4 / 2 - param1.width / 2;
         param1.y = param3 + param5 / 2 - param1.height / 2;
      }
   }
}

