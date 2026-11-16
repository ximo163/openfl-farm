package module.uitools
{
   import com.qzone.qfa.events.CommandEvent;
   import common.CommonData;
   import common.Consts;
   import common.Language;
   import common.Session;
   import common.Settings;
   import entities.Player;
   import events.CommonEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.net.URLVariables;
   import framework.net.CommandDefs;
   import framework.net.NetHelper;
   import framework.net.vo.ServiceResultVO;
   import module.uitools.vo.OfflineData;
   import module.uitools.vo.ProfileData;
   import report.EventRecorder;
   
   public class UIToolsModel extends EventDispatcher
   {
      
      public static const EVENT_PLAYER_BASEINFO_CHANGED:String = "PlayerBaseInfoChanged";
      
      public static const EVENT_PLAYER_ACCOUNT_CHANGED:String = "PlayerAccountChanged";
      
      public static const EVENT_OFFLINE_DATA_CHANGED:String = "OfflineDataChanged";
      
      public static const EVENT_SYSTEM_POST_LOADED:String = "SystemPostMsgLoaded";
      
      public static const EVENT_EVERYDAY_GIFT_LOADED:String = "EverydayGiftLoaded";
      
      public static const EVENT_EVERYDAY_GIFT_ACCEPTED:String = "EverydayGiftAccepted";
      
      public static const EVENT_OFFLINE_DATA_MSG:String = "OfflineDataMessage";
      
      public static const EVENT_LEVELUP_CHANGED:String = "LevelupDataChanged";
      
      public static const EVENT_LEVELUP_GIFTS:String = "LevelUpGiftLoaded";
      
      public static const GET_VIPRETURN_GIFT:String = "getVipReturnGift";
      
      public static const GET_FREE_GIFT:String = "getFreeGift";
      
      public static const EVENT_SHOW_WARNMSG:String = "showWarnMsg";
      
      private var m_host:Player;
      
      private var m_freeData:Object;
      
      private var m_myProfile:ProfileData;
      
      private var m_giftData:Object;
      
      private var m_postMsgLoading:Boolean;
      
      private var m_giftDataLoading:Boolean;
      
      private var m_freeDataLoading:Boolean;
      
      private var m_offlineData:OfflineData;
      
      private var m_controller:UIController;
      
      private var m_postMsg:Object;
      
      private var m_levelupGifts:Array;
      
      private var m_levelupGiftPending:Boolean;
      
      public function UIToolsModel(param1:UIController)
      {
         super();
         this.m_myProfile = new ProfileData();
         this.m_offlineData = new OfflineData();
         this.m_postMsg = null;
         this.m_postMsgLoading = false;
         this.m_giftData = null;
         this.m_giftDataLoading = false;
         this.m_freeData = null;
         this.m_freeDataLoading = false;
         this.m_levelupGifts = null;
         this.m_levelupGiftPending = false;
         this.m_host = Session.getInstance().host;
         this.m_controller = param1;
      }
      
      public function get freeGift() : Object
      {
         return this.m_freeData;
      }
      
      public function updateOfflineStatus(param1:Object) : void
      {
         var _loc2_:Boolean = false;
         if(param1 != null)
         {
            if(this.m_offlineData.m_postNum != param1["b"])
            {
               this.m_offlineData.m_postNum = param1["b"] as int;
               _loc2_ = true;
            }
            if(this.m_offlineData.m_msgNum != param1["c"])
            {
               this.m_offlineData.m_msgNum = param1["c"] as int;
               _loc2_ = true;
            }
            if(this.m_offlineData.m_giftNum != param1["d"])
            {
               this.m_offlineData.m_giftNum = param1["d"] as int;
               _loc2_ = true;
            }
            if(this.m_offlineData.m_flowerNum != param1["e"])
            {
               this.m_offlineData.m_flowerNum = param1["e"] as int;
               _loc2_ = true;
            }
         }
         if(_loc2_ == true)
         {
            dispatchEvent(new CommonEvent(EVENT_OFFLINE_DATA_CHANGED,this.m_offlineData));
         }
      }
      
      private function onEverydayGiftAccepted(param1:CommandEvent) : void
      {
         var _loc2_:* = NetHelper.getVOData(param1);
         if(Session.getInstance().isVipReturn)
         {
            _loc2_ = this.loadVipReturnGift();
            dispatchEvent(new CommonEvent(EVENT_EVERYDAY_GIFT_ACCEPTED,_loc2_));
         }
         else
         {
            dispatchEvent(new CommonEvent(EVENT_EVERYDAY_GIFT_ACCEPTED,_loc2_));
         }
         this.m_offlineData.m_giftNum = 0;
         Session.getInstance().isVipReturn = false;
         EventRecorder.recordSueecssEvent("160860",null);
      }
      
      private function onPostMsgLoaded(param1:CommandEvent) : void
      {
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         this.m_postMsgLoading = false;
         this.m_postMsg = _loc2_;
         dispatchEvent(new CommonEvent(EVENT_SYSTEM_POST_LOADED,_loc2_));
         if(_loc2_["have_new_feeds"] == true)
         {
            this.m_offlineData.m_infoNum = 1;
            dispatchEvent(new CommonEvent(EVENT_OFFLINE_DATA_CHANGED,this.m_offlineData));
            this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_FEEDS_NPC_NEW_FEEDS_FLAG,null));
         }
         if(_loc2_["have_new_sysmsg"] == true)
         {
            this.m_offlineData.m_msgNum = 1;
            dispatchEvent(new CommonEvent(EVENT_OFFLINE_DATA_CHANGED,this.m_offlineData));
            dispatchEvent(new CommonEvent(EVENT_OFFLINE_DATA_MSG,4));
         }
         if(_loc2_["have_new_warnmsg"] == true)
         {
            dispatchEvent(new CommonEvent(EVENT_SHOW_WARNMSG,_loc2_));
         }
         EventRecorder.recordSueecssEvent("160861",null);
      }
      
      private function onLevelUpGiftData(param1:CommandEvent) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:* = undefined;
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         this.m_levelupGiftPending = false;
         if(_loc2_["lv"] != undefined)
         {
            _loc3_ = _loc2_["lv"] as int;
            if(this.m_levelupGifts != null)
            {
               _loc4_ = this.m_levelupGifts.indexOf(_loc3_);
               while(_loc4_ != -1)
               {
                  this.m_levelupGifts.splice(_loc4_,1);
                  _loc4_ = this.m_levelupGifts.indexOf(_loc3_);
               }
               dispatchEvent(new CommonEvent(EVENT_LEVELUP_CHANGED,this.m_levelupGifts));
            }
         }
         if(_loc2_["direction"] == undefined)
         {
            _loc2_["direction"] = "恭喜您升到" + _loc3_ + "级，赠送您 ";
            for each(_loc5_ in _loc2_["item"])
            {
               if(_loc5_["num"] > 0 && _loc5_["name"] != undefined && _loc5_["name"] != "")
               {
                  _loc2_["direction"] += _loc5_["num"] + "个" + _loc5_["name"] + "，";
               }
            }
            _loc2_["direction"] = _loc2_["direction"].slice(0,_loc2_["direction"].length - 1);
         }
         if(_loc2_["vipItem"] != undefined && _loc2_["vipText"] == undefined)
         {
            _loc2_["vipText"] = "您是尊贵的VIP，还可额外获得以下奖励：";
         }
         _loc2_["levelup"] = true;
         _loc2_["big"] = true;
         _loc2_["title"] = "查看礼包";
         dispatchEvent(new CommonEvent(EVENT_LEVELUP_GIFTS,_loc2_));
         EventRecorder.recordSueecssEvent("160864",null);
      }
      
      private function onEverydayGiftLoaded(param1:CommandEvent) : void
      {
         this.m_giftDataLoading = false;
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         this.m_giftData = _loc2_;
         _loc2_["everyDayGift"] = true;
         dispatchEvent(new CommonEvent(EVENT_EVERYDAY_GIFT_LOADED,_loc2_));
         EventRecorder.recordSueecssEvent("160863",null);
      }
      
      private function onLevelUpResponse(param1:CommandEvent) : void
      {
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_["hasgift"] == undefined || _loc2_["hasgift"] == false)
         {
            return;
         }
         this.addLevelUp(_loc2_);
      }
      
      public function get myProfile() : ProfileData
      {
         return this.m_myProfile;
      }
      
      public function updateHostInfo() : void
      {
         var _loc1_:Player = Session.getInstance().host;
         if(_loc1_ == null)
         {
            return;
         }
         var _loc2_:Boolean = false;
         if(this.m_myProfile.m_userName != _loc1_._userName)
         {
            this.m_myProfile.m_userName = _loc1_._userName;
            _loc2_ = true;
         }
         if(this.m_myProfile.m_photoUrl != _loc1_._headPic)
         {
            this.m_myProfile.m_photoUrl = _loc1_._headPic;
            _loc2_ = true;
         }
         if(_loc2_ == true)
         {
            dispatchEvent(new Event(EVENT_PLAYER_BASEINFO_CHANGED));
         }
         _loc2_ = false;
         if(this.m_myProfile.m_gold != _loc1_._money)
         {
            this.m_myProfile.m_gold = _loc1_._money;
            _loc2_ = true;
         }
         if(this.m_myProfile.m_exp != _loc1_._exp)
         {
            this.m_myProfile.m_exp = _loc1_._exp;
            _loc2_ = true;
         }
         if(this.m_myProfile.m_fb != _loc1_._fb)
         {
            this.m_myProfile.m_fb = _loc1_._fb;
            _loc2_ = true;
         }
         if(this.m_myProfile.m_moral != _loc1_._moralExp)
         {
            this.m_myProfile.m_moral = _loc1_._moralExp;
            _loc2_ = true;
         }
         if(_loc2_ == true)
         {
            dispatchEvent(new Event(EVENT_PLAYER_ACCOUNT_CHANGED));
         }
      }
      
      public function resetLoadingFlags() : void
      {
         if(this.m_postMsgLoading == true)
         {
            this.m_postMsgLoading = false;
            this.m_postMsg = null;
         }
         if(this.m_giftDataLoading == true)
         {
            this.m_giftDataLoading = false;
            this.m_giftData = null;
         }
         if(this.m_freeDataLoading == true)
         {
            this.m_freeDataLoading = false;
            this.m_freeData = null;
         }
      }
      
      public function acceptGifts(param1:Boolean) : void
      {
         var _loc2_:Object = null;
         if(param1)
         {
            _loc2_ = new Object();
            _loc2_["opt"] = 1;
            _loc2_["isfarm"] = 1;
            NetHelper.sendRequest(CommandDefs.CMD_GET_VIPRETURN_GIFT,_loc2_,this.onEverydayGiftAccepted,this.onNetError);
         }
         else
         {
            NetHelper.sendRequest(CommandDefs.CMD_ACCEPT_EVERYDAY_GIFT,null,this.onEverydayGiftAccepted,this.onNetError);
         }
      }
      
      public function get postMsg() : Object
      {
         return this.m_postMsg;
      }
      
      public function addLevelUp(param1:Object) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         if(param1 == null)
         {
            return;
         }
         if(param1.hasOwnProperty("hasgift") == true && param1["hasgift"] as Boolean == true)
         {
            _loc2_ = param1["lvup"] as Array;
            if(_loc2_ == null)
            {
               return;
            }
            if(this.m_levelupGifts == null)
            {
               this.m_levelupGifts = _loc2_;
            }
            else
            {
               for each(_loc3_ in _loc2_)
               {
                  if(this.m_levelupGifts.indexOf(_loc3_) == -1)
                  {
                     this.m_levelupGifts.push(_loc3_);
                  }
               }
            }
         }
         if(param1 is Array && param1.length > 0)
         {
            this.m_levelupGifts = param1 as Array;
         }
         dispatchEvent(new CommonEvent(EVENT_LEVELUP_CHANGED,this.m_levelupGifts));
      }
      
      public function loadEveryDayGift() : Object
      {
         if(this.m_giftData != null)
         {
            return this.m_giftData;
         }
         if(this.m_giftDataLoading == true)
         {
            return null;
         }
         this.m_giftDataLoading = true;
         NetHelper.sendRequest(CommandDefs.CMD_GET_EVERYDAY_GIFT,null,this.onEverydayGiftLoaded,this.onNetError);
         return null;
      }
      
      private function onFreeGiftLoaded(param1:CommandEvent) : void
      {
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         this.m_freeDataLoading = false;
         this.m_freeData = _loc2_;
         CommonData.freeGift = this.m_freeData;
         dispatchEvent(new CommonEvent(GET_FREE_GIFT,this.m_freeData));
         EventRecorder.recordSueecssEvent("160862",null);
      }
      
      private function onNetError(param1:CommandEvent) : void
      {
         if(param1 == null || param1.body == null)
         {
            return;
         }
         var _loc2_:int = param1.body["cmdID"] as int;
         var _loc3_:ServiceResultVO = param1.result as ServiceResultVO;
         var _loc4_:String = "";
         if(_loc3_ == null || _loc3_.m_message == "")
         {
            _loc4_ = Language.L["请求超时，稍后再试"];
         }
         else
         {
            _loc4_ = _loc3_.m_message;
         }
         if(_loc2_ == CommandDefs.CMD_GET_SYSTEM_POST_MSG)
         {
            this.m_postMsgLoading = false;
            EventRecorder.recordErrorEvent("160861",null,4);
         }
         else if(_loc2_ == CommandDefs.CMD_GET_EVERYDAY_GIFT)
         {
            this.m_giftDataLoading = false;
            EventRecorder.recordErrorEvent("160863",null,4);
         }
         else if(_loc2_ == CommandDefs.CMD_FREE_COUNT)
         {
            this.m_freeDataLoading = false;
            EventRecorder.recordErrorEvent("160862",null,4);
         }
         else if(_loc2_ == CommandDefs.CMD_LEVEL_UP)
         {
            if(param1.body["__body"]["op"] == 1)
            {
               this.m_levelupGiftPending = false;
            }
            EventRecorder.recordErrorEvent("160864",null,4);
         }
         else if(_loc2_ == CommandDefs.CMD_GET_VIPRETURN_GIFT || _loc2_ == CommandDefs.CMD_ACCEPT_EVERYDAY_GIFT)
         {
            EventRecorder.recordErrorEvent("160860",null,4);
         }
      }
      
      public function drawLevelUpGift() : Boolean
      {
         if(this.m_levelupGiftPending == true)
         {
            return false;
         }
         if(this.m_levelupGifts == null && this.m_levelupGifts.length == 0)
         {
            return false;
         }
         this.m_levelupGiftPending = true;
         NetHelper.sendRequest(CommandDefs.CMD_LEVEL_UP,{
            "lv":this.m_levelupGifts[0],
            "op":1
         },this.onLevelUpGiftData,this.onNetError);
         return true;
      }
      
      public function initializeMyProfile() : void
      {
         var _loc1_:Player = Session.getInstance().host;
         if(_loc1_ == null)
         {
            return;
         }
         this.m_myProfile.m_userName = _loc1_._userName;
         this.m_myProfile.m_photoUrl = _loc1_._headPic;
         dispatchEvent(new Event(EVENT_PLAYER_BASEINFO_CHANGED));
         this.m_myProfile.m_exp = _loc1_._exp;
         this.m_myProfile.m_gold = _loc1_._money;
         this.m_myProfile.m_moral = _loc1_._moralExp;
         dispatchEvent(new Event(EVENT_PLAYER_ACCOUNT_CHANGED));
      }
      
      public function loadPostData() : Object
      {
         if(this.m_postMsg != null)
         {
            return this.m_postMsg;
         }
         if(this.m_postMsgLoading == true)
         {
            return null;
         }
         this.m_postMsgLoading = true;
         var _loc1_:URLVariables = new URLVariables();
         _loc1_["appId"] = 353;
         _loc1_["serviceId"] = Settings.getInstance().mode == "" ? 2 : 1;
         _loc1_["uin"] = Session.getInstance().host._uinLogin;
         NetHelper.getRequest(CommandDefs.CMD_GET_SYSTEM_POST_MSG,_loc1_,this.onPostMsgLoaded,this.onNetError);
         return null;
      }
      
      public function clearUnReadMsgFlag() : void
      {
         this.m_offlineData.m_infoNum = 0;
         this.m_offlineData.m_msgNum = 0;
         dispatchEvent(new CommonEvent(EVENT_OFFLINE_DATA_CHANGED,this.m_offlineData));
      }
      
      public function loadVipReturnGift() : Object
      {
         if(this.m_giftData != null)
         {
            return this.m_giftData;
         }
         return null;
      }
      
      public function get everydayGift() : Object
      {
         return this.m_giftData;
      }
      
      public function loadFreeData() : Object
      {
         if(this.m_freeData != null)
         {
            return this.m_freeData;
         }
         if(this.m_freeDataLoading == true)
         {
            return null;
         }
         this.m_freeDataLoading = true;
         NetHelper.sendRequest(CommandDefs.CMD_FREE_COUNT,null,this.onFreeGiftLoaded,this.onNetError);
         return null;
      }
      
      public function checkLevelup(param1:int) : void
      {
         if(param1 <= 0)
         {
            return;
         }
         var _loc2_:int = Session.getInstance().host._exp;
         var _loc3_:int = Math.sqrt((_loc2_ + 25) / 100) - 0.5;
         var _loc4_:int = Math.sqrt((_loc2_ + param1 + 25) / 100) - 0.5;
         if(_loc4_ > _loc3_)
         {
            NetHelper.sendRequest(CommandDefs.CMD_LEVEL_UP,{
               "level":_loc4_,
               "op":0
            },this.onLevelUpResponse,this.onLevelUpResponse);
         }
      }
   }
}

