package com.qzone.corelib.js
{
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.external.ExternalInterface;
   
   public class JSProxy extends EventDispatcher
   {
      
      private static var DEFAULT_DEBUG_QQ:Number;
      
      public static var addCallBackProxy:Function;
      
      private static const GET_NICKNAME:String = "SwfAppLib.method.getNickName";
      
      private static const SHOW_LOGIN_WINDOW:String = "SwfAppLib.method.showLoginBox";
      
      private static const GET_COOKIES_METHOD:String = "SwfAppLib.method.getCookie";
      
      private static const SET_COOKIES_METHOD:String = "SwfAppLib.method.setCookie";
      
      private static const CHECKLOGIN_METHOD:String = "SwfAppLib.method.getLoginUin";
      
      private static const GET_SERVER_TIME:String = "SwfAppLib.method.getServerTime";
      
      private static const APP_INVITE:String = "SwfAppLib.method.inviteFriend";
      
      private static const GET_SEX:String = "SwfAppLib.method.getSex";
      
      private static const GET_PARAMETER:String = "getParameter";
      
      private static const GET_HASH:String = "SwfAppLib.method.getHash";
      
      private static const SWITCH_TO_FARM:String = "switchToFarm";
      
      private static const GET_HEAD:String = "SwfAppLib.method.getHead";
      
      private static const GET_HEADLIST:String = "SwfAppLib.method.getHeadList";
      
      private static const SHOW_DNA:String = "SwfAppLib.pay.showDna";
      
      private static const GET_UPURL:String = "SwfAppLib.method.getUploadUrl";
      
      private static const TO_APP:String = "C.util.toApp";
      
      private static const GET_APP_PARAMS:String = "C.util.getAppParams";
      
      private static const IS_APP_INSTALL:String = "SwfAppLib.method.isAppInstalled";
      
      private static const SELECT_FRIENDS:String = "SwfAppLib.method.selectFriend";
      
      private static const SHOW_YELLOW_PACKAGE:String = "C.canvas.showYellowPackage";
      
      private static const SIZE_30:int = 30;
      
      private static const SIZE_50:int = 50;
      
      private static const SIZE_100:int = 100;
      
      private static const APP_ID:int = 372;
      
      private static var TIME_OFFSET:Number = 0;
      
      private static var _serverTime:Number = 0;
      
      public function JSProxy(param1:IEventDispatcher = null)
      {
         super(param1);
      }
      
      public static function showLoginWindow() : Boolean
      {
         if(ExternalInterface.available)
         {
            return ExternalInterface.call(SHOW_LOGIN_WINDOW);
         }
         return false;
      }
      
      public static function isAppInstall(param1:int, param2:Function) : void
      {
         if(ExternalInterface.available)
         {
            addCallBack("setAppInstalled",param2);
            ExternalInterface.call(IS_APP_INSTALL,param1);
         }
         else
         {
            param2(param1,false);
         }
      }
      
      public static function openWindow(param1:String) : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call("window.open",param1);
         }
      }
      
      public static function get isQzone() : Boolean
      {
         if(ExternalInterface.available)
         {
            return ExternalInterface.call("eval","SwfAppLib.platform.isQzone") as Boolean;
         }
         return false;
      }
      
      public static function getHeadList(param1:Array, param2:int, param3:Function) : void
      {
         if(ExternalInterface.available)
         {
            addCallBack("setHeadList",param3);
            ExternalInterface.call(GET_HEADLIST,param1,param2);
         }
      }
      
      public static function inviteFriend() : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call(APP_INVITE,APP_ID,520,520,"邀请好友开通QQ餐厅");
         }
      }
      
      public static function getUpUrl(param1:Function) : *
      {
         var _loc2_:* = undefined;
         if(ExternalInterface.available)
         {
            addCallBack("setUploadUrl",param1);
            _loc2_ = ExternalInterface.call(GET_UPURL);
         }
         return _loc2_;
      }
      
      private static function addCallBack(param1:String, param2:Function) : void
      {
         if(addCallBackProxy is Function)
         {
            addCallBackProxy(param1,param2);
            return;
         }
         throw new Error("请先绑定addCallBackProxy方法。");
      }
      
      public static function flashInit() : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call("SwfAppLib.method.flashInit");
         }
      }
      
      public static function getSevTime() : Number
      {
         return Math.floor(new Date().getTime() / 1000 + TIME_OFFSET);
      }
      
      public static function switchToFarm() : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call(SWITCH_TO_FARM);
         }
      }
      
      public static function getSex() : int
      {
         if(!ExternalInterface.available)
         {
            return 1;
         }
         ExternalInterface.marshallExceptions = true;
         try
         {
            return ExternalInterface.call(GET_SEX) as int;
         }
         catch(e:Error)
         {
            return 0;
         }
      }
      
      public static function setSevTime(param1:Number) : void
      {
         _serverTime = param1;
         if(!TIME_OFFSET)
         {
            TIME_OFFSET = Math.floor(param1 - new Date().getTime() / 1000);
         }
      }
      
      public static function toApp(param1:int, param2:String = "") : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call(TO_APP,param1,param2);
         }
      }
      
      public static function getLoginUin() : String
      {
         return checkLogin().toString();
      }
      
      public static function checkLogin() : int
      {
         var _loc1_:* = 0;
         if(ExternalInterface.available)
         {
            _loc1_ = int(ExternalInterface.call(CHECKLOGIN_METHOD));
            if(_loc1_)
            {
               return _loc1_;
            }
         }
         return int(_loc1_) || int(DEFAULT_DEBUG_QQ);
      }
      
      public static function getCookie(param1:String) : String
      {
         if(ExternalInterface.available)
         {
            return ExternalInterface.call(GET_COOKIES_METHOD,param1);
         }
         return "";
      }
      
      public static function getAppParams() : String
      {
         if(ExternalInterface.available)
         {
            return ExternalInterface.call(GET_APP_PARAMS);
         }
         return "";
      }
      
      public static function selectFriend(param1:Function) : void
      {
         if(ExternalInterface.available)
         {
            addCallBack("friendSelected",param1);
            ExternalInterface.call(SELECT_FRIENDS);
         }
      }
      
      public static function getUserPortraitUrl(param1:String, param2:int = 30) : String
      {
         var _loc3_:int = 0;
         var _loc4_:String = null;
         if(!isNaN(Number(param1)) && param1 != getLoginUin() || param1 == getLoginUin() && isQzone)
         {
            _loc3_ = parseInt(param1,10) % 4 + 1;
            return "" + _loc3_ + ".store.qq.com/qzone/" + param1 + "/" + param1 + "/" + param2;
         }
         if(param1 == getLoginUin())
         {
            if(ExternalInterface.available)
            {
               return getUserPortraitOnCampus(ExternalInterface.call(GET_HASH),param2);
            }
            return "";
         }
         return getUserPortraitOnCampus(param1,param2);
      }
      
      public static function getHead(param1:String, param2:int) : String
      {
         if(ExternalInterface.available)
         {
            return ExternalInterface.call(GET_HEAD,param1,param2);
         }
         return "";
      }
      
      public static function isFull() : Boolean
      {
         trace(ExternalInterface.call("C.isFull"));
         return Boolean(ExternalInterface.call("C.isFull"));
      }
      
      private static function getUserPortraitOnCampus(param1:String, param2:int = 30) : String
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         if(param1)
         {
            _loc3_ = int(param1.charCodeAt(0) % 10);
            _loc4_ = 0;
            switch(param2)
            {
               case SIZE_30:
                  _loc4_ = 2;
                  break;
               case SIZE_50:
                  _loc4_ = 2;
                  break;
               case SIZE_100:
                  _loc4_ = 0;
                  break;
               default:
                  _loc4_ = 0;
            }
            return "" + param1 + _loc4_;
         }
         return "";
      }
      
      public static function getSKey() : String
      {
         return getCookie("skey");
      }
      
      public static function getOnLineTime() : int
      {
         if(ExternalInterface.available)
         {
            return ExternalInterface.call("SwfAppLib.method.getAppDuration");
         }
         return 0;
      }
      
      public static function showDNA(param1:String, param2:Function) : void
      {
         if(ExternalInterface.available)
         {
            addCallBack("forDNA",param2);
            ExternalInterface.call(SHOW_DNA,param1);
         }
      }
      
      public static function getNickname() : String
      {
         if(ExternalInterface.available)
         {
            return ExternalInterface.call(GET_NICKNAME);
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
      
      public static function getParameter(param1:String) : String
      {
         if(ExternalInterface.available)
         {
            return ExternalInterface.call(GET_PARAMETER,param1);
         }
         return "";
      }
      
      public static function addGToken(param1:String) : String
      {
         return ExternalInterface.call("SwfAppLib.method.attachDefParam",param1) as String;
      }
      
      public static function goBack() : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call("C.util.goBack");
         }
      }
      
      public static function getParams() : String
      {
         if(ExternalInterface.available)
         {
            return ExternalInterface.call("C.util.getAppParams");
         }
         return null;
      }
   }
}

