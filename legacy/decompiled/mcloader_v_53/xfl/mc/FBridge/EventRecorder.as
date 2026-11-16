package mc.FBridge
{
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.HTTPStatusEvent;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.external.ExternalInterface;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   import flash.net.sendToURL;
   import flash.utils.getTimer;
   
   public class EventRecorder
   {
      
      public static var recordUrl:String = "nmc.php?";
      
      public static var successRecordProbability:int = 100;
      
      public static var errorRecordProbability:int = 20;
      
      public static var MC_ENTER:String = "19112";
      
      public static var MC_GET_EXP:String = "19113";
      
      public static var MC_REPERTORY_ANIMAl:String = "19114";
      
      public static var MC_REPERTORY_PCAKAGE:String = "19116";
      
      public static var MC_ANIMAL:String = "19115";
      
      public static var MC_STEAL_PRODUCT:String = "19117";
      
      public static var MC_POST_PRODUCT:String = "19118";
      
      public static var MC_HARVEST_PRODUCT:String = "19119";
      
      public static var MC_CLEAR_FLY:String = "19120";
      
      public static var MC_CLEAR_BB:String = "19121";
      
      public static var MC_SNOW:String = "160029";
      
      public static var MC_STEALFLAG:String = "160058";
      
      public static var MC_GAME_URL:String = "160063";
      
      public static var MC_HOT_URL:String = "160062";
      
      public static var MC_MORE_URL:String = "160061";
      
      public static var MC_2_NC:String = "160092";
      
      public static var CHEAT_NC:String = "160223";
      
      public static var FLOP_NC:String = "160235";
      
      public static var QUICK_SHOOT:String = "160238";
      
      public static var QD_BUYGT:String = "160463";
      
      public static var QD_BUYGZ:String = "160464";
      
      public static var CFT_BUYGT:String = "160462";
      
      public static var CFT_BUYGZ:String = "160465";
      
      public static var QD_BUYZS:String = "160466";
      
      public static var CFT_BUYZS:String = "160467";
      
      public static var SUCCESS_BUYZS:String = "160468";
      
      public static var SUCCESS_BUYDJ:String = "160469";
      
      public static var MONTHEND_SUCCESS_BUY:String = "160506";
      
      public static var MONTHEND_SUCCESS_GETGIFT:String = "160507";
      
      public static var MONTHEND_SUCCESS_REFRESH1:String = "160508";
      
      public static var MONTHEND_SUCCESS_REFRESH2:String = "160509";
      
      public static var DENSHED_SUCCESS_BUYBYGOLD:String = "160527";
      
      public static var DENSHED_SUCCESS_BUYBYQD:String = "160528";
      
      public static var DENSHED_HOUSEGLASS_1:String = "160530";
      
      public static var DENSHED_HOUSEGLASS_2:String = "160529";
      
      public static var DENSHED_HOUSEGLASS_3:String = "160531";
      
      public static var DENSHED_HOUSEGLASS_4:String = "160532";
      
      public static var DENSHED_UPDATEBUTTON:String = "160558";
      
      public static var DENSHED_DOUBLEINPRICE:String = "160559";
      
      public static var DENSHED_DOUBLEINPRICE_SURE:String = "160560";
      
      public static var FEBRUARY_GIFT1_CLICK:String = "160577";
      
      public static var FEBRUARY_GIFT2_CLICK:String = "160578";
      
      public static var FEBRUARY_GIFT1_BUY:String = "160580";
      
      public static var FEBRUARY_GIFT2_BUY:String = "160581";
      
      public static var DENSHED_SUCCESS_HIREDEN:String = "160582";
      
      public static var DENSHED_SUCCESS_HIRESHED:String = "160583";
      
      public static var MAGICAL_BABY_BUY_TOOLS_WO:String = "160688";
      
      public static var MAGICAL_BABY_BUY_TOOLS_PENG:String = "160689";
      
      public static var OPEN_RESEARCH_WIN_WO:String = "160690";
      
      public static var OPEN_RESEARCH_WIN_PENG:String = "160691";
      
      public static var LIMIT_SALES_OPEN_1107:String = "160693";
      
      public static var LIMIT_SALES_OPEN_1108:String = "160694";
      
      public static var LIMIT_SALES_OPEN_1109:String = "160695";
      
      public static var LIMIT_SALES_OPEN_1110:String = "160696";
      
      public static var WEEKEND_ENTRANCE_CLICK:String = "160711";
      
      public static const LOAD_INIT_THINGS:String = "160712";
      
      private static var _list:Array = [];
      
      public static const SUEECSS:int = 1;
      
      public static const FAULT_ERROR:int = 14;
      
      public static const FAULT_SESSION:int = 15;
      
      public static const FAULT_SYSTEM:int = 16;
      
      public static const FAULT_SNOW_ENTER:int = 17;
      
      public static const FAULT_SNOW_STEAL:int = 18;
      
      public static const FAULT_FLAG_STEAL:int = 19;
      
      public static const MC_2_NC_ERR0:int = 70;
      
      public static const MC_2_NC_ERR1:int = 71;
      
      public static const MC_2_NC_ERR2:int = 72;
      
      public static const DATA_ERROR:int = 1;
      
      public static const TIME_OUT:int = 3;
      
      public static const DOMAIN_ERROR:int = 2;
      
      public static const PGVID_UPDATEDENSHED:String = "ISD.SNSAPP.PASTURE.UPDATEDENSHED";
      
      public static const PGVID_DOUBLE_IN_PRICE:String = "ISD.SNSAPP.PASTURE.DOUBLE_IN_PRICE";
      
      public static const PGVID_DOUBLE_IN_PRICE_SURE:String = "ISD.SNSAPP.PASTURE.DOUBLE_IN_PRICE_SURE";
      
      public function EventRecorder()
      {
         super();
      }
      
      private static function __onCompleteHandler(param1:Event) : void
      {
         var _loc3_:URLVariables = null;
         var _loc2_:Object = getObjectBy(param1.target);
         if(!_loc2_)
         {
            return;
         }
         if(int(Math.random() * successRecordProbability) == 0)
         {
            _loc3_ = new URLVariables();
            _loc3_["flag1"] = _loc2_.pid;
            _loc3_["flag2"] = SUEECSS;
            _loc3_["1"] = successRecordProbability;
            _loc3_["2"] = getTimer() - _loc2_.requestTime;
            record(_loc3_);
            remove(param1.target);
         }
      }
      
      public static function recordDataError(param1:*) : void
      {
         var _loc2_:Object = getObjectBy(param1);
         if(!_loc2_)
         {
            return;
         }
         var _loc3_:URLVariables = new URLVariables();
         _loc3_["flag1"] = _loc2_.pid;
         _loc3_["flag2"] = DATA_ERROR;
         _loc3_["1"] = 1;
         _loc3_["2"] = getTimer() - _loc2_.requestTime;
         record(_loc3_);
         remove(param1);
      }
      
      public static function pgvSendClick(param1:String) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = ExternalInterface.call("function getPvid(){var t;t = document.cookie.match((new RegExp(\";?pgv_pvid=([^;]*)\")));if(t && t.length && t.length > 1){return unescape(t[1])}else{return 0};}");
         _loc2_ = "";
         _loc2_ += "dm=appbase.qzone.qq.com.hot";
         _loc2_ += "&url=/qz/358/normal";
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
         var _loc2_:URLRequest = new URLRequest(recordUrl);
         _loc2_.data = param1;
         _loc2_.method = URLRequestMethod.GET;
         sendToURL(_loc2_);
      }
      
      private static function __onOpenHandler(param1:Event) : void
      {
         getObjectBy(param1.target).requestTime = getTimer();
      }
      
      protected static function getObjectBy(param1:*) : Object
      {
         var _loc2_:Object = null;
         for each(_loc2_ in _list)
         {
            if(_loc2_.loader == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      private static function __onHttpStatusHandler(param1:HTTPStatusEvent) : void
      {
      }
      
      protected static function remove(param1:*) : void
      {
         var loader:* = param1;
         try
         {
            loader.removeEventListener(Event.OPEN,__onOpenHandler);
            loader.removeEventListener(Event.COMPLETE,__onCompleteHandler);
            loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,__onSecurityErrorHandler);
            loader.removeEventListener(IOErrorEvent.IO_ERROR,__onIOErrorHandler);
            loader.removeEventListener(IOErrorEvent.DISK_ERROR,__onIOErrorHandler);
            loader.removeEventListener(IOErrorEvent.NETWORK_ERROR,__onIOErrorHandler);
            loader.removeEventListener(IOErrorEvent.VERIFY_ERROR,__onIOErrorHandler);
            loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS,__onHttpStatusHandler);
         }
         catch(e:Error)
         {
         }
         _list.splice(getIndexBy(loader),1);
      }
      
      public static function add(param1:*, param2:int) : void
      {
         var _loc3_:Object = {
            "requestTime":getTimer(),
            "loader":param1,
            "pid":param2
         };
         if(param1 is Loader)
         {
            _loc3_.loader = param1.contentLoaderInfo;
         }
         _loc3_.loader.addEventListener(Event.OPEN,__onOpenHandler);
         _loc3_.loader.addEventListener(Event.COMPLETE,__onCompleteHandler);
         _loc3_.loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,__onSecurityErrorHandler);
         _loc3_.loader.addEventListener(IOErrorEvent.IO_ERROR,__onIOErrorHandler);
         _loc3_.loader.addEventListener(IOErrorEvent.DISK_ERROR,__onIOErrorHandler);
         _loc3_.loader.addEventListener(IOErrorEvent.NETWORK_ERROR,__onIOErrorHandler);
         _loc3_.loader.addEventListener(IOErrorEvent.VERIFY_ERROR,__onIOErrorHandler);
         _loc3_.loader.addEventListener(HTTPStatusEvent.HTTP_STATUS,__onHttpStatusHandler);
         _list.push(_loc3_);
      }
      
      protected static function getIndexBy(param1:*) : int
      {
         var _loc3_:Object = null;
         var _loc2_:int = -1;
         for each(_loc3_ in _list)
         {
            _loc2_++;
            if(_loc3_.loader == param1)
            {
               return _loc2_;
            }
         }
         return _loc2_;
      }
      
      public static function recordErrorEvent(param1:String, param2:Number, param3:int, param4:String = null) : void
      {
         var _loc5_:URLVariables = null;
         if(int(Math.random() * errorRecordProbability) == 0)
         {
            _loc5_ = new URLVariables();
            _loc5_["flag1"] = param1;
            _loc5_["flag2"] = 2;
            _loc5_["flag3"] = param3;
            _loc5_["1"] = errorRecordProbability;
            _loc5_["2"] = param2;
            if(param4)
            {
               _loc5_["flag5"] = param4;
            }
            record(_loc5_);
         }
      }
      
      public static function recordSueecssEvent(param1:String, param2:Number, param3:String = null, param4:int = 0) : void
      {
         var _loc5_:Number = NaN;
         var _loc6_:URLVariables = null;
         if(param4 != 0)
         {
            _loc5_ = param4;
         }
         else
         {
            _loc5_ = successRecordProbability;
         }
         if(int(Math.random() * _loc5_) == 0)
         {
            _loc6_ = new URLVariables();
            _loc6_["flag1"] = param1;
            _loc6_["flag2"] = 1;
            _loc6_["1"] = _loc5_;
            _loc6_["2"] = param2;
            if(param3)
            {
               _loc6_["flag5"] = param3;
            }
            record(_loc6_);
         }
      }
      
      private static function __onSecurityErrorHandler(param1:SecurityErrorEvent) : void
      {
         var _loc2_:Object = getObjectBy(param1.target);
         if(!_loc2_)
         {
            return;
         }
         var _loc3_:URLVariables = new URLVariables();
         _loc3_["flag1"] = _loc2_.pid;
         _loc3_["flag2"] = DOMAIN_ERROR;
         _loc3_["1"] = 1;
         _loc3_["2"] = getTimer() - _loc2_.requestTime;
         record(_loc3_);
         remove(param1.target);
      }
      
      private static function __onIOErrorHandler(param1:IOErrorEvent) : void
      {
         var _loc2_:Object = getObjectBy(param1.target);
         if(!_loc2_)
         {
            return;
         }
         var _loc3_:URLVariables = new URLVariables();
         _loc3_["flag1"] = _loc2_.pid;
         _loc3_["flag2"] = FAULT_ERROR;
         _loc3_["1"] = 1;
         _loc3_["2"] = getTimer() - _loc2_.requestTime;
         record(_loc3_);
         remove(param1.target);
      }
      
      public static function recordMultiValueInCode(param1:String, param2:String) : void
      {
         var _loc3_:URLVariables = null;
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

