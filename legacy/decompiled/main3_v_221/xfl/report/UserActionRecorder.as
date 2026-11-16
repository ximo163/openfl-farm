package report
{
   import common.CommonData;
   import common.Session;
   import common.Settings;
   import flash.events.TimerEvent;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   import flash.net.sendToURL;
   import flash.utils.Timer;
   
   public class UserActionRecorder
   {
      
      public static var recordUrl:String = "mync.php?mod=cgi_ua_stat";
      
      private static var timer:Timer = new Timer(60000);
      
      private static var _timerStart:Boolean = true;
      
      private static var _sendID:int = 0;
      
      private static var _actionArray:Array = [];
      
      public static const HF_GAME_INIT:String = "1";
      
      public static const HF_TOOL_HOE_CLICKED:String = "7";
      
      public static const HF_TOOL_PACK_CLICKED:String = "8";
      
      public static const HF_TOOL_TOOLBOX_CLICKED:String = "9";
      
      public static const HF_TOOL_HOOK_CLICKED:String = "10";
      
      public static const HF_TOOL_PESTICIDE_CLICKED:String = "11";
      
      public static const HF_TOOL_WILD_CLICKED:String = "14";
      
      public static const HF_TOOL_HAND_CLICKED:String = "18";
      
      public static const HF_TOOL_ONECLICK_CLICKED:String = "19";
      
      public static const HF_FRIENDLIST_OPEN:String = "20";
      
      public static const HF_FRIENDLIST_CLOSE:String = "21";
      
      public static const HF_FRIENDLIST_SORT_EXP:String = "22";
      
      public static const HF_FRIENDLIST_SORT_GOLD:String = "23";
      
      public static const HF_FRIENDLIST_SEARCH:String = "26";
      
      public static const HF_FRIENDLIST_REFRESH_STATUS:String = "27";
      
      public static const HF_FRIENDLIST_BACK:String = "28";
      
      public static const HF_FRIENDLIST_NEXT:String = "29";
      
      public static const HF_PERSONINFO_OPEN:String = "30";
      
      public static const HF_HOMELINK_CLICKED:String = "41";
      
      public static const HF_MYFARM_CLICKED:String = "42";
      
      public static const HF_MYPASTURE_CLICKED:String = "43";
      
      public static const HF_MYRESTAURANT_CLICKED:String = "44";
      
      public static const HF_MYMILL_CLICKED:String = "45";
      
      public static const HF_WAREHOUSE_CLICKED:String = "46";
      
      public static const HF_SHOP_CLICKED:String = "47";
      
      public static const HF_DECORATE_CLICKED:String = "48";
      
      public static const HF_SHORTCUTBAR_INFO_CLICKED:String = "50";
      
      public static const HF_SHORTCUTBAR_MSG_CLICKED:String = "51";
      
      public static const HF_SHORTCUTBAR_POST_CLICKED:String = "54";
      
      public static const HF_SHORTCUTBAR_CARDS_CLICKED:String = "55";
      
      public static const HF_SHORTCUTBAR_CARDSITEM_CLICKED:String = "56";
      
      public static const HF_BAG_NORAML_CLICKED:String = "57";
      
      public static const HF_BAG_TOOL_CLICKED:String = "58";
      
      public static const HF_TO_PASTURE_CLICKED:String = "10300";
      
      public static const HF_BILLBOARD_CLICKED:String = "10301";
      
      public static const HF_DOGBOWL_CLICKED:String = "10302";
      
      public static const HF_DOGFOODWINDOW_BUY_CLICKED:String = "10303";
      
      public function UserActionRecorder()
      {
         super();
      }
      
      private static function _timerHandler(param1:TimerEvent) : void
      {
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:URLVariables = null;
         var _loc6_:URLRequest = null;
         var _loc2_:int = int(_actionArray.length);
         if(_loc2_ > 0)
         {
            _loc3_ = (++_sendID).toString() + "#" + CommonData.serverTime.toString();
            _loc4_ = 0;
            while(_loc4_ < _loc2_)
            {
               _loc3_ += "+" + _actionArray[_loc4_]["action"] + "#" + _actionArray[_loc4_]["time"];
               _loc4_++;
            }
            _loc3_ += "+" + "353" + "+" + (Settings.getInstance().mode == "qzone" ? "1" : "2");
            _actionArray = [];
            _loc5_ = new URLVariables();
            _loc5_["detail"] = _loc3_;
            _loc6_ = new URLRequest(recordUrl);
            _loc6_.data = _loc5_;
            _loc6_.method = URLRequestMethod.POST;
            sendToURL(_loc6_);
         }
      }
      
      public static function recordAction(param1:String) : void
      {
         var _loc2_:uint = Session.getInstance().host._uinLogin % 10000;
         var _loc3_:String = Settings.getInstance().getStringAttribute("userActionOpenUin");
         var _loc4_:Array = [];
         _loc4_ = _loc3_.split(",");
         if(_loc2_ < _loc4_[0] || _loc2_ > _loc4_[1])
         {
            return;
         }
         var _loc5_:Object = new Object();
         _loc5_["action"] = param1;
         _loc5_["time"] = CommonData.serverTime.toString();
         _actionArray.push(_loc5_);
         if(_timerStart)
         {
            timer.addEventListener("timer",_timerHandler);
            timer.start();
            _timerStart = false;
         }
         if(param1 == HF_MYPASTURE_CLICKED || param1 == HF_MYMILL_CLICKED || param1 == HF_MYRESTAURANT_CLICKED || param1 == HF_TO_PASTURE_CLICKED)
         {
            _timerHandler(null);
         }
      }
   }
}

