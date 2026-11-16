package common.misc
{
   import common.CommonData;
   import common.Settings;
   import flash.external.ExternalInterface;
   
   public class QzoneJSAPI
   {
      
      public static var DEFAULT_DEBUG_QQ:Number;
      
      public static var WB:Boolean;
      
      public static var QPLUS:Boolean;
      
      public static const APP_ID:int = 372;
      
      private static const APP_INVITE:String = "SwfAppLib.method.inviteFriend";
      
      private static const GET_NICKNAME:String = "SwfAppLib.method.getNickName";
      
      private static const GET_SEX:String = "SwfAppLib.method.getSex";
      
      private static const GET_VIP_INFO:String = "SwfAppLib.method.getVipInfo";
      
      private static const SET_COOKIES_METHOD:String = "SwfAppLib.method.setCookie";
      
      private static const GET_COOKIES_METHOD:String = "SwfAppLib.method.getCookie";
      
      private static const SHOW_LOGIN_BOX:String = "SwfAppLib.method.showLoginBox";
      
      private static const SELECT_FRIENDS:String = "SwfAppLib.method.selectFriend";
      
      private static const GET_HEAD:String = "SwfAppLib.method.getHead";
      
      private static const GET_HEADLIST:String = "SwfAppLib.method.getHeadList";
      
      private static const GET_UPURL:String = "SwfAppLib.method.getUploadUrl";
      
      private static const IS_APP_INSTALL:String = "SwfAppLib.method.isAppInstalled";
      
      private static const QQ_PLATFORM_PAY:String = "SwfAppLib.pay.showBuy";
      
      private static const ADD_GTK:String = "SwfAppLib.method.attachDefParam";
      
      private static const SEND_REQUEST:String = "fusion2.api.sendRequest";
      
      private static const TO_APP:String = "C.util.toApp";
      
      private static const GET_APP_PARAMS:String = "C.util.getAppParams";
      
      private static const SHOW_VIP_PACKAGE:String = "C.canvas.showYellowPackage";
      
      private static const REPORT_PROBLEM:String = "Clinic.log.report";
      
      public function QzoneJSAPI()
      {
         super();
      }
      
      public static function isAppInstall(param1:int, param2:Function) : void
      {
         if(ExternalInterface.available)
         {
            CommonData.addCallBackProxy("setAppInstalled",param2);
            ExternalInterface.call(IS_APP_INSTALL,param1);
         }
      }
      
      public static function sendGameRequest(param1:Number, param2:String, param3:String, param4:Function, param5:Function, param6:String = "", param7:String = "喊你回来种菜") : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call("fusion2.api.sendRequest({appid:353,type:\'request\',stat:\'action_id\',receiver:" + [param1.toString()] + ",title:\'" + param6 + "\',desc:\'免费礼物\',msg:\'" + param7 + "\',img:\'" + param2 + "\',button:\'" + param3 + "\',callback:\'http://app353.qzoneapp.com/receive_request?id=353\',context:\'1315885819:3375731104e6ed2fb9d23e\'})");
         }
      }
      
      public static function getHeadList(param1:Array, param2:int, param3:Function) : void
      {
         if(ExternalInterface.available)
         {
            CommonData.addCallBackProxy("setHeadList",param3);
            ExternalInterface.call(GET_HEADLIST,param1,param2);
         }
      }
      
      public static function getUpUrl(param1:Function) : *
      {
         var _loc2_:* = undefined;
         if(ExternalInterface.available)
         {
            CommonData.addCallBackProxy("setUploadUrl",param1);
            return ExternalInterface.call(GET_UPURL);
         }
         return null;
      }
      
      public static function inviteFriend() : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call(APP_INVITE,APP_ID,520,520,"邀请好友开通QQ餐厅");
         }
      }
      
      public static function toApp(param1:int, param2:String) : void
      {
         var _loc3_:RegExp = null;
         if(ExternalInterface.available)
         {
            _loc3_ = new RegExp("\\\\","g");
            param2 = param2.replace(_loc3_,"\\\\");
            ExternalInterface.call(TO_APP,param1,param2);
         }
      }
      
      public static function flashInit() : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call("SwfAppLib.method.flashInit");
         }
      }
      
      public static function getVipInfo(param1:Boolean, param2:int, param3:Boolean, param4:Function) : void
      {
         if(ExternalInterface.available)
         {
            CommonData.addCallBackProxy("setYellowInfo",param4);
            ExternalInterface.call(GET_VIP_INFO,param1,param2,param3);
         }
      }
      
      public static function getOnlineTime(param1:String) : int
      {
         var _loc2_:int = 0;
         if(ExternalInterface.available == true)
         {
            if(param1 == "qzone")
            {
               _loc2_ = ExternalInterface.call("QZONE.FP.getAppDuration");
            }
            else
            {
               _loc2_ = ExternalInterface.call("parent.XY_APP.getAppDuration");
            }
         }
         return _loc2_;
      }
      
      public static function selectFriend(param1:Function) : void
      {
         if(ExternalInterface.available)
         {
            CommonData.addCallBackProxy("friendSelected",param1);
            ExternalInterface.call(SELECT_FRIENDS);
         }
      }
      
      public static function reportError(param1:String, param2:Number) : void
      {
         if(QPLUS == true || WB == true)
         {
            return;
         }
         var _loc3_:String = "";
         _loc3_ += param1;
         if(ExternalInterface.available)
         {
            ExternalInterface.call(REPORT_PROBLEM,param2,_loc3_);
         }
      }
      
      public static function showLoginBox() : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call(SHOW_LOGIN_BOX);
         }
      }
      
      public static function getInGamePay(param1:String, param2:Function) : void
      {
         var _loc3_:Boolean = false;
         if(QPLUS == true)
         {
            return;
         }
         if(ExternalInterface.available)
         {
            CommonData.addCallBackProxy("setBoughtRes",param2);
            _loc3_ = Settings.getInstance().getStringAttribute("sandbox") == "1";
            ExternalInterface.call(QQ_PLATFORM_PAY,param1,_loc3_);
         }
      }
      
      public static function showVIPPackage(param1:int, param2:Boolean, param3:String, param4:int, param5:int) : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call(SHOW_VIP_PACKAGE,param1,param2,param3,param4,param5);
         }
      }
      
      public static function getAppParams() : String
      {
         if(ExternalInterface.available)
         {
            return ExternalInterface.call(GET_APP_PARAMS);
         }
         return "";
      }
      
      public static function addGToken(param1:String) : String
      {
         if(ExternalInterface.available)
         {
            return ExternalInterface.call(ADD_GTK,param1) as String;
         }
         return param1;
      }
      
      public static function sendRequestOpen(param1:String, param2:String, param3:Function, param4:Function, param5:Function, param6:String = "", param7:String = "喊你回来种菜") : void
      {
         CommonData.addCallBackProxy("onSuccess",param3);
         CommonData.addCallBackProxy("onCancel",param4);
         CommonData.addCallBackProxy("onClose",param5);
         if(ExternalInterface.available)
         {
            ExternalInterface.call("fusion2.dialog.sendRequest({appid:353,type:\'freegift\',stat:\'action_id\',title:\'" + param6 + "\',desc:\'免费礼物\',msg:\'" + param7 + "\',img:\'" + param1 + "\',button:\'" + param2 + "\',context:\'1315885819:86933d85682a0bbc318616d90fa641bb\'," + "callback:\'http://app24341.qzoneapp.com/receive_gift?id=12345\'," + "onSuccess:function (opt){swfAppObject.onSuccess(opt);}," + "onCancel:function (opt){swfAppObject.onCancel(opt);}," + "onClose:function (opt){swfAppObject.onClose(opt);}})");
         }
      }
      
      public static function getHead(param1:String, param2:int) : String
      {
         if(ExternalInterface.available)
         {
            return ExternalInterface.call(GET_HEAD,param1,param2);
         }
         return "";
      }
      
      public static function share(param1:String, param2:String, param3:String, param4:String = "", param5:String = "进入应用", param6:String = "") : void
      {
         ExternalInterface.call("fusion2.dialog.sendStory",{
            "title":param1,
            "summary":param2,
            "img":param3,
            "msg":param4,
            "button":param5,
            "source":param6
         });
      }
      
      public static function getNickname() : String
      {
         if(ExternalInterface.available)
         {
            return ExternalInterface.call(GET_NICKNAME);
         }
         return "";
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
      
      public static function openWindow(param1:String) : void
      {
         if(param1 == "" || param1 == null)
         {
            return;
         }
         if(ExternalInterface.available)
         {
            ExternalInterface.call("window.open",param1);
         }
      }
      
      public static function sendRequestOne(param1:Number, param2:String, param3:String, param4:Function, param5:Function, param6:String = "", param7:String = "喊你回来种菜", param8:String = "常来看看，别错过收礼唷！") : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call("fusion2.api.sendRequest({appid:353,type:\'freegift\',stat:\'action_id\',receiver:" + [param1.toString()] + ",title:\'" + param6 + "\',desc:\'" + param8 + "\',msg:\'" + param7 + "\',img:\'" + param2 + "\',button:\'" + param3 + "\',callback:\'http://app353.qzoneapp.com/receive_request?id=353\'," + "context:\'1315885819:3375731104e6ed2fb9d23e\'})");
         }
      }
   }
}

