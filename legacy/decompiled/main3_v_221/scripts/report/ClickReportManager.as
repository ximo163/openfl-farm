package report
{
   import common.misc.QzoneJSAPI;
   import flash.external.ExternalInterface;
   
   public class ClickReportManager
   {
      
      private static const CT_DOMAIN:String = "happyfarm.qzone.qq.com";
      
      private static const CT_PAGE_URL:String = "/app/happyfarm";
      
      private static const CLICK_REPORT_DOMAIN:String = "";
      
      private static const PV_REPORT_DOMAIN:String = "";
      
      private static var PV_REPORTED:Boolean = false;
      
      public function ClickReportManager()
      {
         super();
      }
      
      public static function reportPv(param1:int = 20) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:Object = null;
         var _loc5_:Array = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:Array = null;
         var _loc10_:String = null;
         if(!PV_REPORTED && checkRan(param1))
         {
            _loc2_ = CT_DOMAIN || "-";
            _loc3_ = CT_PAGE_URL;
            _loc4_ ||= {};
            _loc4_.referURL = "http://ct0.xiaoyou.qq.com";
            _loc5_ = _loc4_.referURL.split(/[\?\#]/);
            _loc6_ = _loc5_[0];
            _loc5_ = _loc6_.split("/");
            _loc7_ = _loc5_.length >= 2 ? _loc5_[2] : "-";
            _loc8_ = "/" + _loc5_.slice(3).join("/");
            _loc4_.referDomain = _loc4_.referDomain || _loc7_;
            _loc4_.referPath = _loc4_.referPath || _loc8_;
            _loc7_ = QzoneJSAPI.getCookie("pgv_pvid");
            if(!_loc7_)
            {
               _loc7_ = String(Math.round(Math.random() * 2147483647) * new Date().getUTCMilliseconds() % 10000000000);
               QzoneJSAPI.setCookie("pgv_pvid",_loc7_,"qq.com","/",10000);
            }
            _loc9_ = [PV_REPORT_DOMAIN,"?cc=-&ct=-&java=1&lang=-&pf=-&scl=-&scr=-&tt=-&tz=-8&vs=3.3&","dm=",_loc2_,"&","url=",_loc3_,"&","rdm=",_loc4_.referDomain,"&","rurl=",_loc4_.referPath,"&","pgv_pvid=",_loc7_,"&","sds=",Math.random()];
            _loc10_ = _loc9_.join("");
            if(ExternalInterface.available)
            {
               ExternalInterface.call("eval","(function(){window._flash_img = new Image();window._flash_img.src=\"" + _loc10_ + "\"})()");
            }
            PV_REPORTED = true;
         }
      }
      
      public static function reportClick(param1:String, param2:int = 20) : void
      {
         var _loc3_:String = null;
         if(checkRan(param2))
         {
            _loc3_ = CLICK_REPORT_DOMAIN + "?dm=" + CT_DOMAIN + ".hot" + "&url=" + CT_PAGE_URL + "&tt=-" + "&hottag=" + param1 + "&hotx=9999" + "&hoty=9999" + "&rand=" + String(Math.random());
            if(ExternalInterface.available)
            {
               ExternalInterface.call("eval","(function(){window._flash_img = new Image();window._flash_img.src=\"" + _loc3_ + "\"})()");
            }
         }
      }
      
      private static function checkRan(param1:int = 20) : Boolean
      {
         return int(Math.random() * param1) == 0;
      }
   }
}

