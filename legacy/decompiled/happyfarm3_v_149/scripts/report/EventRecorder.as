package report
{
   import flash.external.ExternalInterface;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   import flash.net.sendToURL;
   import flash.utils.getTimer;
   
   public class EventRecorder
   {
      
      public static var recordUrl:String = "nmc.php?";
      
      public static var successRecordProbability:int = 500;
      
      public static var errorRecordProbability:int = 1;
      
      public static var MC_ENTER:String = "19112";
      
      public static var MC_GET_EXP:String = "19113";
      
      public static var MC_REPERTORY_ANIMAl:String = "19114";
      
      public static var MC_REPERTORY_PCAKAGE:String = "19116";
      
      public static var MC_ANIMAL:String = "19115";
      
      public static var MC_STEAL_PRODUCT:String = "19117";
      
      public static var MC_POST_PRODUCT:String = "19118";
      
      public static var MC_HARVEST_PRODUCT:String = "19119";
      
      public static const HF_SCROUNGE:String = "160190";
      
      public static const HF_HARVEST:String = "160191";
      
      public static const HF_CLEARWEED:String = "160015";
      
      public static const HF_SPRAYING:String = "160016";
      
      public static const HF_SHOP:String = "160017";
      
      public static const HF_LIB:String = "160018";
      
      public static const HF_DIY:String = "160019";
      
      public static const HF_PEST:String = "160020";
      
      public static const HF_SCATTERSEED:String = "160021";
      
      public static const HF_WATER:String = "160022";
      
      public static const HF_SCARIFY:String = "160023";
      
      public static const HF_PLANTING:String = "160024";
      
      public static const HF_FERTILIZE:String = "160025";
      
      public static const HF_SNOW:String = "160026";
      
      public static const HF_POSTCLICK:String = "160027";
      
      public static const HF_POSTVIEW:String = "160028";
      
      public static const HF_SWFLOAD:String = "160187";
      
      public static const HF_ONLINETIME:String = "160090";
      
      public static const HF_ENTERMUCHANG:String = "160091";
      
      public static const HF_CGI_ENTER:String = "160200";
      
      public static const HF_GET_BAG_DATA:String = "160201";
      
      public static const HF_GET_SHOP_SEED:String = "160202";
      
      public static const HF_GET_SHOP_DIY:String = "160203";
      
      public static const HF_GET_SHOP_ITEM:String = "160204";
      
      public static const HF_GET_SNS_AD:String = "160205";
      
      public static const HF_GET_WAREHOUSE_CROPS:String = "160206";
      
      public static const HF_GET_WAREHOUSE_SEEDS:String = "160207";
      
      public static const HF_GET_WAREHOUSE_CRYSTAL:String = "160208";
      
      public static const HF_SELL_ALL_PLANTS:String = "160209";
      
      public static const HF_SELL_PLANT:String = "160210";
      
      public static const HF_GET_DIY_ITEMS:String = "160211";
      
      public static const HF_GET_FRIENDLIST:String = "160212";
      
      public static const HF_GET_FRIENDLIST_STATUS:String = "160213";
      
      public static const HF_GET_SYSTEM_MSG:String = "160214";
      
      public static const HF_GET_FEEDS:String = "160215";
      
      public static const HF_GET_BILL_DATA:String = "160216";
      
      public static const HF_BUY_SEEDS:String = "160217";
      
      public static const HF_BUY_DIY:String = "160218";
      
      public static const CHEAT_FARM:String = "160224";
      
      public static const HF_ZOOMIN:String = "160245";
      
      public static const HF_ZOOMOUT:String = "160246";
      
      public static const HF_PHOTO_BIG:String = "160364";
      
      public static const HF_PHOTO_SMALL:String = "160365";
      
      public static const HF_THANKS_GG:String = "160456";
      
      public static const HF_THANKS_BD:String = "160457";
      
      public static const HF_THANKS_SF:String = "160458";
      
      public static const HF_THANKS_DJ:String = "160459";
      
      public static const HF_THANKS_ZS:String = "160460";
      
      public static const HF_THANKS_CX:String = "160461";
      
      public static const MONTHEND_CLICKBUY:String = "160499";
      
      public static const MONTHEND_BUYSUCCESS:String = "160500";
      
      public static const MONTHEND_GETGIFT:String = "160501";
      
      public static const MONTHEND_REFRESHTYPE:String = "160502";
      
      public static const MONTHEND_REFRESHNUMBER:String = "160503";
      
      public static const QDSEED_BUYCLICK:String = "160587";
      
      public static const QDSEED_BUYSUCCESS:String = "160588";
      
      public static const PGVID_TOSUPERMARKET:String = "ISD.SNSAPP.HAPPYFARM.TOSUPERMARKET";
      
      public static const SUEECSS:int = 1;
      
      public static const FAULT_ERROR:int = 4;
      
      public static const FAULT_SESSION:int = 5;
      
      public static const DATA_ERROR:int = 1;
      
      public static const TIME_OUT:int = 3;
      
      public static const DOMAIN_ERROR:int = 2;
      
      public static var STARTUP_SPEED_INFO:Object = null;
      
      public static var DISABLED:Boolean = false;
      
      private static var _list:Array = [];
      
      private static var _startTime:Object = {};
      
      public function EventRecorder()
      {
         super();
      }
      
      public static function initStartupSpeed() : void
      {
         var _loc1_:URLVariables = new URLVariables();
         _loc1_["flag1"] = 7721;
         _loc1_["flag2"] = 1;
         _loc1_["flag3"] = 1;
         STARTUP_SPEED_INFO = _loc1_;
      }
      
      public static function pgvSendClick(param1:String) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = ExternalInterface.call("function getPvid(){var t;t = document.cookie.match((new RegExp(\";?pgv_pvid=([^;]*)\")));if(t && t.length && t.length > 1){return unescape(t[1])}else{return 0};}");
         _loc2_ = "";
         _loc2_ += "dm=appbase.qzone.qq.com.hot";
         _loc2_ += "&url=/qz/353/normal";
         _loc2_ += "&tt=-";
         _loc2_ += "&hottag=" + param1;
         _loc2_ += "&hotx=9999";
         _loc2_ += "&hoty=9999";
         _loc2_ += "&rand=" + Math.random().toString();
         _loc2_ += "&pvid=" + _loc3_;
         sendToURL(new URLRequest(_loc2_));
      }
      
      public static function record(param1:URLVariables) : void
      {
         if(DISABLED)
         {
            return;
         }
         var _loc2_:URLRequest = new URLRequest(recordUrl);
         _loc2_.data = param1;
         _loc2_.method = URLRequestMethod.GET;
         sendToURL(_loc2_);
      }
      
      public static function startARequest(param1:String) : void
      {
         _startTime[param1] = getTimer();
      }
      
      public static function recordSueecssEvent(param1:String, param2:*, param3:String = null) : void
      {
         var _loc4_:URLVariables = null;
         if(DISABLED)
         {
            return;
         }
         if(int(Math.random() * successRecordProbability) == 0)
         {
            _loc4_ = new URLVariables();
            _loc4_["flag1"] = param1;
            _loc4_["flag2"] = 1;
            _loc4_["1"] = successRecordProbability;
            _loc4_["2"] = param2 || getTimer() - _startTime[param1];
            if(param3)
            {
               _loc4_["flag5"] = param3;
            }
            record(_loc4_);
         }
      }
      
      public static function recordErrorEvent(param1:String, param2:*, param3:int, param4:String = null) : void
      {
         var _loc5_:URLVariables = null;
         if(DISABLED)
         {
            return;
         }
         if(int(Math.random() * errorRecordProbability) == 0)
         {
            _loc5_ = new URLVariables();
            _loc5_["flag1"] = param1;
            _loc5_["flag2"] = 2;
            _loc5_["flag3"] = param3;
            _loc5_["1"] = errorRecordProbability;
            _loc5_["2"] = param2 || getTimer() - _startTime[param1];
            if(param4)
            {
               _loc5_["flag5"] = param4;
            }
            record(_loc5_);
         }
      }
      
      public static function recordMultiValueInCode(param1:String, param2:String) : void
      {
         var _loc3_:URLVariables = null;
         if(DISABLED)
         {
            return;
         }
         if(int(Math.random() * successRecordProbability) == 0)
         {
            _loc3_ = new URLVariables();
            _loc3_["flag1"] = param1;
            _loc3_["flag2"] = 1;
            _loc3_["flag3"] = param2;
            _loc3_["1"] = successRecordProbability;
            record(_loc3_);
         }
      }
   }
}

