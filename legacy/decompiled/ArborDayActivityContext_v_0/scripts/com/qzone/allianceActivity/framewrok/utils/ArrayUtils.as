package com.qzone.allianceActivity.framewrok.utils
{
   public class ArrayUtils
   {
      
      public function ArrayUtils()
      {
         super();
      }
      
      public static function clone(param1:Array) : Array
      {
         return param1.concat();
      }
      
      public static function containValue(param1:Object, param2:Object = null) : Boolean
      {
         var _loc3_:Object = null;
         for(_loc3_ in param1)
         {
            if(param1[_loc3_] == param2)
            {
               return true;
            }
         }
         return false;
      }
      
      public static function removeItem(param1:Array, param2:*) : Array
      {
         var _loc3_:Number = param1.length;
         var _loc4_:Array = [];
         while(--_loc3_ - -1)
         {
            if(param1[_loc3_] === param2)
            {
               _loc4_.unshift(_loc3_);
               param1.splice(_loc3_,1);
            }
         }
         return _loc4_;
      }
      
      public static function isSame(param1:Array, param2:Array) : Boolean
      {
         var _loc3_:Number = param1.length;
         if(_loc3_ != param2.length)
         {
            return false;
         }
         while(--_loc3_ - -1)
         {
            if(param1[_loc3_] !== param2[_loc3_])
            {
               return false;
            }
         }
         return true;
      }
      
      public static function getItemsByType(param1:Array, param2:Class) : Array
      {
         var _loc3_:Array = [];
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            if(param1[_loc4_] is param2)
            {
               _loc3_.push(param1[_loc4_]);
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      public static function toString(param1:Array, param2:String = ", ") : String
      {
         return !param1 ? "" : param1.join(param2);
      }
   }
}

