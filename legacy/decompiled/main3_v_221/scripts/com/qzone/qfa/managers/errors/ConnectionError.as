package com.qzone.qfa.managers.errors
{
   public class ConnectionError extends Error
   {
      
      public static const ERR_IO:String = "io_err";
      
      public static const ERR_SECURITY:String = "security_err";
      
      public static const ERR_TIMEOUT:String = "timeout_err";
      
      public static const ERR_FETAL:String = "fetal_err";
      
      public static const ERR_TIMEOUT_CONNECT:String = "timeout_connect";
      
      public static const ERR_TIMEOUT_SEND:String = "timeout_send";
      
      public static const ERR_TIMEOUT_RECEIVE:String = "timeout_receive";
      
      public function ConnectionError(param1:* = "", param2:int = 0)
      {
         super(param1,param2);
      }
   }
}

