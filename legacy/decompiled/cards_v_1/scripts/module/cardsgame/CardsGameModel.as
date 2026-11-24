package module.cardsgame
{
   import com.qzone.qfa.events.CommandEvent;
   import common.Session;
   import common.Settings;
   import common.misc.QzoneJSAPI;
   import events.CommonEvent;
   import flash.events.EventDispatcher;
   import framework.net.CommandDefs;
   import framework.net.NetHelper;
   import framework.net.vo.ServiceResultVOHelper;
   import report.EventRecorder;
   
   public class CardsGameModel extends EventDispatcher
   {
      
      public static const GET_CARDSGAME_DATA:String = "CardsGameInitialized";
      
      public static const CARDSGAME_LOADED:String = "CardsGameRewardLoaded";
      
      public static const CARDSGAME_REFRESHED:String = "CardsGameRefreshed";
      
      public static const CARDSGAME_BONUS:String = "CardsGameBonus";
      
      public static const CARDSGAME_ACTIVITY:String = "CARDSGAME_ACTIVITY";
      
      private static const E_SUCCEED:int = 1;
      
      public var loginDays:String = "";
      
      public var isGetDraw:Array = [0,0,0];
      
      public var remainPlays:int = 0;
      
      public var cardGameBonus:int = 0;
      
      private var _lastRewardID:int = 0;
      
      public function CardsGameModel()
      {
         super();
      }
      
      public function cardsGameQuery() : void
      {
         NetHelper.sendRequest(CommandDefs.CMD_GET_CARDSGAME_DATA,null,this.onCardsGameQueryed,this.onNetError);
      }
      
      public function refreshCardsGameData() : void
      {
         NetHelper.sendRequest(CommandDefs.CMD_REFRESH_CARDSGAME_DATA,null,this.onRefresh,this.onRefresh);
      }
      
      public function getReward() : void
      {
         var _loc1_:* = {};
         _loc1_["flag"] = 2;
         _loc1_["pid"] = this._lastRewardID.toString();
         _loc1_["yellow"] = Session.getInstance().host._yellowstatus == 0 ? 0 : 1;
         NetHelper.sendRequest(CommandDefs.CMD_GET_CARDSGAME_REWARD,_loc1_,this.onReward,this.onReward);
      }
      
      private function onNetError(param1:CommandEvent) : void
      {
         if(param1 == null || param1.body == null)
         {
            return;
         }
         var _loc2_:int = param1.body["cmdID"] as int;
         if(_loc2_ == CommandDefs.CMD_GET_CARDSGAME_DATA)
         {
            QzoneJSAPI.reportError("拉取签到板数据出错。",2);
            EventRecorder.recordErrorEvent("160841",null,4);
         }
      }
      
      public function ActivityClickGet(param1:int) : void
      {
         var _loc2_:* = {};
         _loc2_["t"] = param1;
         NetHelper.sendRequest(CommandDefs.CMD_GET_CARDSGAME_ACTIVITY,_loc2_,this.onCardsGameActivity,this.onCardsGameActivity);
      }
      
      private function onReward(param1:CommandEvent) : void
      {
         var _loc3_:Object = null;
         var _loc4_:Array = null;
         var _loc5_:Object = null;
         var _loc2_:Object = ServiceResultVOHelper.getVOData(param1);
         this._lastRewardID = _loc2_["id"];
         this.remainPlays = int(_loc2_["canNum"]);
         dispatchEvent(new CommonEvent(CARDSGAME_LOADED,_loc2_));
         if(int(_loc2_["code"]) == E_SUCCEED)
         {
            _loc3_ = Settings.getInstance().getCardsGameReward(_loc2_["id"]);
            _loc4_ = new Array();
            _loc5_ = new Object();
            _loc5_["eType"] = _loc3_["type"];
            _loc5_["eNum"] = parseInt(_loc3_["num"]);
            _loc4_.push(_loc5_);
            Session.getInstance().addReward(_loc4_);
            EventRecorder.recordSueecssEvent("160842",null);
         }
         else
         {
            EventRecorder.recordErrorEvent("160842",null,4);
         }
      }
      
      private function onCardsGameQueryed(param1:CommandEvent) : void
      {
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_.hasOwnProperty("code") && _loc2_["code"] == 1)
         {
            this.loginDays = _loc2_["days"];
            this.cardGameBonus = int(_loc2_["bonus"]);
            if(Session.getInstance().host._yellowstatus != 0)
            {
               this.remainPlays = 2 - int(_loc2_["number"]);
            }
            else
            {
               this.remainPlays = 1 - int(_loc2_["number"]);
            }
            dispatchEvent(new CommonEvent(GET_CARDSGAME_DATA,this.remainPlays > 0 || this.cardGameBonus > 0));
            EventRecorder.recordSueecssEvent("160841",null);
         }
      }
      
      private function onCardsGameActivity(param1:CommandEvent) : void
      {
         var _loc2_:Object = ServiceResultVOHelper.getVOData(param1);
         this.dispatchEvent(new CommonEvent(CARDSGAME_ACTIVITY,_loc2_));
      }
      
      private function onBonus(param1:CommandEvent) : void
      {
         var _loc3_:Object = null;
         var _loc4_:Array = null;
         var _loc5_:Object = null;
         var _loc2_:Object = ServiceResultVOHelper.getVOData(param1);
         this.dispatchEvent(new CommonEvent(CARDSGAME_BONUS,_loc2_));
         if(int(_loc2_["code"]) == E_SUCCEED)
         {
            _loc3_ = Settings.getInstance().getCardsGameReward(_loc2_["id"]);
            _loc4_ = new Array();
            _loc5_ = new Object();
            _loc5_["eType"] = _loc3_["type"];
            _loc5_["eNum"] = parseInt(_loc3_["num"]);
            _loc4_.push(_loc5_);
            Session.getInstance().addReward(_loc4_);
            EventRecorder.recordSueecssEvent("160849",null);
         }
         else
         {
            EventRecorder.recordErrorEvent("160849",null,4);
         }
      }
      
      public function getBonusGift() : void
      {
         var _loc1_:* = {};
         _loc1_["flag"] = 1;
         _loc1_["days"] = this.loginDays;
         NetHelper.sendRequest(CommandDefs.CMD_GET_CARDSGAME_REWARD,_loc1_,this.onBonus,this.onBonus);
      }
      
      private function onRefresh(param1:CommandEvent) : void
      {
         var _loc2_:Object = ServiceResultVOHelper.getVOData(param1);
         this.dispatchEvent(new CommonEvent(CARDSGAME_REFRESHED,_loc2_));
      }
   }
}

