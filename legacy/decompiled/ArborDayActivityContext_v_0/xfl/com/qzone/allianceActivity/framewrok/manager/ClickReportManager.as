package com.qzone.allianceActivity.framewrok.manager
{
   import flash.external.ExternalInterface;
   
   public class ClickReportManager
   {
      
      private static const DOMAIN:String = "sns.activity.qq.com";
      
      private static var PV_REPORTED:Boolean = false;
      
      private static var tp:Number = 20;
      
      private static const PAGE_URL:String = "/allianceActivity";
      
      private static const CLICK_REPORT_DOMAIN:String = "";
      
      private static const PV_REPORT_DOMAIN:String = "";
      
      public function ClickReportManager()
      {
         super();
      }
      
      public static function reportClick(param1:String) : void
      {
         var _loc2_:String = null;
         if(checkRan())
         {
            _loc2_ = CLICK_REPORT_DOMAIN + "?dm=" + DOMAIN + ".hot" + "&url=" + PAGE_URL + "&tt=-" + "&hottag=" + param1 + "&hotx=9999" + "&hoty=9999" + "&rand=" + String(Math.random());
            if(ExternalInterface.available)
            {
               ExternalInterface.call("eval","(function(){window._flash_img = new Image();window._flash_img.src=\"" + _loc2_ + "\"})()");
            }
         }
      }
      
      public static function reportPv() : void
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         var _loc3_:Object = null;
         var _loc4_:Array = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:Array = null;
         var _loc9_:String = null;
         if(!PV_REPORTED && checkRan())
         {
            _loc1_ = DOMAIN || getHostName();
            _loc2_ = PAGE_URL || getPathName();
            _loc3_ = {};
            _loc3_.referURL = "" || getReferrer();
            _loc4_ = _loc3_.referURL.split(/[\?\#]/);
            _loc5_ = _loc4_[0];
            _loc4_ = _loc5_.split("/");
            _loc6_ = _loc4_.length >= 2 ? _loc4_[2] : "-";
            _loc7_ = "/" + _loc4_.slice(3).join("/");
            _loc3_.referDomain = _loc3_.referDomain || _loc6_;
            _loc3_.referPath = _loc3_.referPath || _loc7_;
            _loc6_ = JSAPI.getCookie("pgv_pvid");
            if(!_loc6_)
            {
               _loc6_ = String(Math.round(Math.random() * 2147483647) * new Date().getUTCMilliseconds() % 10000000000);
               JSAPI.setCookie("pgv_pvid",_loc6_,"qq.com","/",10000);
            }
            _loc8_ = [PV_REPORT_DOMAIN,"?cc=-&ct=-&java=1&lang=-&pf=-&scl=-&scr=-&tt=-&tz=-8&vs=3.3&","dm=",_loc1_,"&","url=",_loc2_,"&","rdm=",_loc3_.referDomain,"&","rurl=",_loc3_.referPath,"&","pgv_pvid=",_loc6_,"&","sds=",Math.random()];
            _loc9_ = _loc8_.join("");
            if(ExternalInterface.available)
            {
               ExternalInterface.call("eval","(function(){window._flash_img = new Image();window._flash_img.src=\"" + _loc9_ + "\"})()");
            }
            PV_REPORTED = true;
         }
      }
      
      private static function checkRan() : Boolean
      {
         return int(Math.random() * tp) == 0;
      }
      
      private static function getHostName() : String
      {
         if(ExternalInterface.available)
         {
            return ExternalInterface.call("eval","(function(){location.hostname})()");
         }
         return "";
      }
      
      private static function getPathName() : String
      {
         if(ExternalInterface.available)
         {
            return ExternalInterface.call("eval","(function(){location.pathname})()");
         }
         return "";
      }
      
      private static function getReferrer() : String
      {
         if(ExternalInterface.available)
         {
            return ExternalInterface.call("eval","(function(){document.referrer})()");
         }
         return "";
      }
   }
}

