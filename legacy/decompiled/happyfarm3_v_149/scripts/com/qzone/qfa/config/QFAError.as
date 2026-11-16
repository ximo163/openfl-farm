package com.qzone.qfa.config
{
   import flash.utils.Dictionary;
   
   public class QFAError extends Error
   {
      
      public static const ERR_IO:int = -100001;
      
      public static const ERR_SECURITY:int = -100002;
      
      public static const ERR_TIMEOUT:int = -100003;
      
      public static const ERR_HTTP_STATUS:int = -100004;
      
      public static const ERR_INVALID_ARGUMENTS:int = -100010;
      
      public static const ERR_FETAL:int = -100011;
      
      public static const ERR_TIMEOUT_CONNECT:int = -100012;
      
      public static const ERR_TIMEOUT_SEND:int = -100013;
      
      public static const ERR_TIMEOUT_RECEIVE:int = -100014;
      
      private static var _err_map:Dictionary = new Dictionary();
      
      public function QFAError(param1:* = 0)
      {
         var _loc2_:String = "";
         if(_err_map[param1])
         {
            _loc2_ = _err_map[param1];
         }
         super(_loc2_,param1);
      }
      
      public function importConfig(param1:Object) : void
      {
         var _loc2_:String = null;
         for(_loc2_ in param1)
         {
            _err_map[_loc2_] = param1[_loc2_];
         }
      }
   }
}

