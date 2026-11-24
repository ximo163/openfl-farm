package com.qzone.allianceActivity.framewrok.manager
{
   import flash.external.ExternalInterface;
   
   public class JSAPI
   {
      
      public static const ATTACH_DEF_PARAM:String = "SwfAppLib.method.attachDefParam";
      
      public static const GET_COOKIES_METHOD:String = "SwfAppLib.method.getCookie";
      
      public static const SET_COOKIES_METHOD:String = "SwfAppLib.method.setCookie";
      
      public static const GET_TOKEN:String = "C.util.getToken";
      
      public function JSAPI()
      {
         super();
      }
      
      public static function attachDefParam(param1:String) : String
      {
         if(ExternalInterface.available)
         {
            param1 = String(ExternalInterface.call(ATTACH_DEF_PARAM,param1));
         }
         return param1;
      }
      
      public static function getCookie(param1:String) : String
      {
         if(ExternalInterface.available)
         {
            return ExternalInterface.call(GET_COOKIES_METHOD,param1);
         }
         return "";
      }
      
      public static function setCookie(param1:String, param2:String, param3:String, param4:String, param5:int) : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call(SET_COOKIES_METHOD,param1,param2);
         }
      }
      
      public static function getToken() : String
      {
         if(ExternalInterface.available)
         {
            return ExternalInterface.call(GET_TOKEN);
         }
         return "";
      }
      
      public static function get isQzone() : Boolean
      {
         if(ExternalInterface.available)
         {
            return ExternalInterface.call("eval","SwfAppLib.platform.isQzone") as Boolean;
         }
         return false;
      }
   }
}

