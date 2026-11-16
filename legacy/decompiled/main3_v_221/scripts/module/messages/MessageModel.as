package module.messages
{
   import com.qzone.qfa.events.CommandEvent;
   import common.Language;
   import common.Session;
   import common.Settings;
   import entities.Player;
   import events.CommonEvent;
   import flash.events.EventDispatcher;
   import framework.net.CommandDefs;
   import framework.net.NetHelper;
   import report.EventRecorder;
   
   public class MessageModel extends EventDispatcher
   {
      
      public static const EVENT_DATA_CHANGED:String = "DataChanged";
      
      public static const EVENT_DATA_LOADING:String = "DataLoading";
      
      public static const EVENT_DATA_FAILED:String = "DataFailed";
      
      public static const EVENT_LOG_CLEARED:String = "LogCleared";
      
      private var m_flags:Array = [2,4,8];
      
      private var m_costNM:Boolean;
      
      private var m_me:Boolean;
      
      private var m_costWS:Boolean;
      
      private var m_data:Object;
      
      public function MessageModel()
      {
         super();
         this.m_data = {};
         this.m_me = true;
         this.m_costNM = false;
         this.m_costWS = false;
      }
      
      public function sendChat(param1:String, param2:String, param3:int, param4:String, param5:String = "") : void
      {
         var _loc6_:String = Session.getInstance().host._userName;
         var _loc7_:* = {
            "toId":param1,
            "msg":param4,
            "showId":param2,
            "isReply":param3,
            "tName":param5,
            "fName":_loc6_
         };
         NetHelper.sendRequest(CommandDefs.CMD_SEND_CHAT,_loc7_,this.onChatMsgSent,this.onChatMsgSentFail);
      }
      
      public function clearChat() : void
      {
         NetHelper.sendRequest(CommandDefs.CMD_CLEAR_ALL_CHAT,null,this.onChatCleared,this.onChatClearedFail);
      }
      
      private function onLogCleared(param1:CommandEvent) : void
      {
         this.m_data["log"] = [];
         dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED,{
            "index":"log",
            "data":this.m_data
         }));
         EventRecorder.recordSueecssEvent("160875",null);
      }
      
      public function reloadAll() : void
      {
         var _loc1_:Object = {"uId":Session.getInstance().hostId};
         _loc1_["ownerId"] = _loc1_["uId"];
         _loc1_["flag"] = 16;
         dispatchEvent(new CommonEvent(EVENT_DATA_LOADING,true));
         NetHelper.sendRequest(CommandDefs.CMD_GET_PROFILE_ALL_INFO,_loc1_,this.onDataLoaded,this.onNetError);
      }
      
      private function onLogClearedFail(param1:CommandEvent) : void
      {
         EventRecorder.recordErrorEvent("160875",null,4);
      }
      
      private function onDataLoaded(param1:CommandEvent) : void
      {
         var _loc4_:* = undefined;
         var _loc5_:* = undefined;
         var _loc6_:* = undefined;
         var _loc7_:* = undefined;
         var _loc8_:* = undefined;
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:int = int(param1.body["cmdID"]);
         if(_loc3_ == CommandDefs.CMD_GET_BILL_DATA)
         {
            this.m_costNM = true;
            _loc4_ = {"uin":Session.getInstance().host._uinLogin};
            NetHelper.sendRequest(CommandDefs.CMD_GET_BILL_WS_DATA,_loc4_,this.onDataLoaded,this.onNetError);
            this.m_data["cost"] = _loc2_["cost"];
            EventRecorder.recordSueecssEvent(EventRecorder.HF_GET_BILL_DATA,null,"cgi_farm_exchange");
         }
         else if(_loc3_ == CommandDefs.CMD_GET_BILL_WS_DATA)
         {
            this.m_costWS = true;
            if(this.m_data["cost"] == undefined || this.m_data["cost"] == null)
            {
               this.m_data["cost"] = _loc2_["cost"];
            }
            else if(_loc2_["cost"] is Array)
            {
               this.m_data["cost"] = this.m_data["cost"].concat(_loc2_["cost"]);
            }
            if(this.m_costNM == true && this.m_costWS == true)
            {
               if(this.m_data["cost"] is Array)
               {
                  this.m_data["cost"].sortOn("time",Array.DESCENDING);
               }
               dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED,{
                  "index":"cost",
                  "data":this.m_data
               }));
            }
            EventRecorder.recordSueecssEvent("160878",null);
         }
         else if(_loc3_ == CommandDefs.CMD_GET_SYSTEM_MSG)
         {
            if(_loc2_["ret"] == 0)
            {
               this.m_data["systemMsg"] = _loc2_["data"];
            }
            dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED,{
               "index":"systemMsg",
               "data":this.m_data
            }));
            EventRecorder.recordSueecssEvent(EventRecorder.HF_GET_SYSTEM_MSG,null,"sysmsg_select");
         }
         else if(_loc3_ == CommandDefs.CMD_GET_PROFILE_ALL_INFO && param1.body["__body"]["flag"] == 3)
         {
            for(_loc5_ in _loc2_)
            {
               if(_loc5_ != "log")
               {
                  this.m_data[_loc5_] = _loc2_[_loc5_];
                  if(Boolean(_loc5_ == "user") && Boolean(_loc2_[_loc5_].hasOwnProperty("xystr")) && Settings.getInstance().mode == "")
                  {
                     Session.getInstance().currentUser.xystr = _loc2_["user"]["xystr"];
                  }
               }
            }
            this.loadFeeds();
         }
         else if(_loc3_ == CommandDefs.CMD_GET_PROFILE_ALL_INFO && param1.body["__body"]["flag"] == 1)
         {
            for(_loc6_ in _loc2_)
            {
               this.m_data[_loc6_] = _loc2_[_loc6_];
               dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED,{
                  "index":_loc6_,
                  "data":this.m_data
               }));
            }
            if(this.m_data["systemMsg"] != undefined)
            {
               return;
            }
            dispatchEvent(new CommonEvent(EVENT_DATA_LOADING,true));
            _loc7_ = {
               "uin":Session.getInstance().hostUin,
               "opuin":Session.getInstance().hostUin
            };
            _loc7_["appid"] = "353";
            _loc7_["msgnum"] = "300";
            NetHelper.sendRequest(CommandDefs.CMD_GET_SYSTEM_MSG,_loc7_,this.onDataLoaded,this.onNetError);
         }
         else if(_loc3_ == CommandDefs.CMD_GET_FISH_ALL)
         {
            if(_loc2_["repertory"] is Array)
            {
               this.m_data["fish"] = _loc2_["repertory"];
            }
            dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED,{
               "index":"fish",
               "data":this.m_data
            }));
            EventRecorder.recordSueecssEvent("160874",null);
         }
         else
         {
            for(_loc8_ in _loc2_)
            {
               this.m_data[_loc8_] = _loc2_[_loc8_];
               if(Boolean(_loc8_ == "user") && Boolean(_loc2_[_loc8_].hasOwnProperty("xystr")) && Settings.getInstance().mode == "")
               {
                  Session.getInstance().currentUser.xystr = _loc2_["user"]["xystr"];
               }
               dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED,{
                  "index":_loc8_,
                  "data":this.m_data
               }));
            }
         }
      }
      
      public function loadFeeds() : void
      {
         var _loc1_:* = null;
         if(this.m_me == true)
         {
            _loc1_ = Session.getInstance().host._uinLogin;
         }
         else
         {
            _loc1_ = Session.getInstance().currentUser.uin || Session.getInstance().currentUser.xystr;
         }
         var _loc2_:* = {
            "appid":353,
            "feedsnum":50,
            "isfeeds":1,
            "uin":_loc1_,
            "opuin":Session.getInstance().host._uinLogin
         };
         NetHelper.sendRequest(CommandDefs.CMD_GET_FEEDS,_loc2_,this.onLoadFeeds,this.onNetError);
      }
      
      public function clearAllLog() : void
      {
         var _loc1_:* = {
            "appid":353,
            "isfeeds":1,
            "uin":Session.getInstance().host._uinLogin
         };
         NetHelper.sendRequest(CommandDefs.CMD_CLEAR_ALL_FEEDS,_loc1_,this.onLogCleared,this.onLogClearedFail);
      }
      
      private function onChatClearedFail(param1:CommandEvent) : void
      {
         EventRecorder.recordErrorEvent("160876",null,4);
      }
      
      private function onChatCleared(param1:CommandEvent) : void
      {
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ != null && _loc2_["code"] == 1)
         {
            this.m_data["chat"] = [];
            dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED,{
               "index":"chat",
               "data":this.m_data
            }));
            EventRecorder.recordSueecssEvent("160876",null);
         }
      }
      
      public function reset() : void
      {
         this.m_data = {};
         this.m_costNM = false;
         this.m_costWS = false;
      }
      
      public function get me() : Boolean
      {
         return this.m_me;
      }
      
      private function onChatMsgSentFail(param1:CommandEvent) : void
      {
         EventRecorder.recordErrorEvent("160877",null,4);
      }
      
      private function onChatMsgSent(param1:CommandEvent) : void
      {
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         this.m_data["chat"] = _loc2_["chat"];
         dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED,{
            "index":"chat",
            "data":this.m_data
         }));
         EventRecorder.recordSueecssEvent("160877",null);
      }
      
      public function loadData(param1:int) : void
      {
         var _loc2_:Object = null;
         if(param1 >= 0 && param1 < 3)
         {
            if(param1 == 0 && this.m_data["log"] != undefined)
            {
               return;
            }
            if(param1 == 1 && this.m_data["chat"] != undefined)
            {
               return;
            }
            if(param1 == 2 && this.m_data["repertory"] != undefined)
            {
               return;
            }
            if(this.m_me == true)
            {
               _loc2_ = {"uId":Session.getInstance().hostId};
            }
            else
            {
               _loc2_ = {"uId":Session.getInstance().currentUser._uId};
            }
            _loc2_["ownerId"] = _loc2_["uId"];
            if(this.m_data["user"] != undefined)
            {
               _loc2_["flag"] = this.m_flags[param1];
            }
            else
            {
               _loc2_["flag"] = this.m_flags[param1] + 1;
            }
            dispatchEvent(new CommonEvent(EVENT_DATA_LOADING,true));
            if(_loc2_["flag"] == 2)
            {
               this.loadFeeds();
            }
            else
            {
               NetHelper.sendRequest(CommandDefs.CMD_GET_PROFILE_ALL_INFO,_loc2_,this.onDataLoaded,this.onNetError);
            }
         }
         else if(param1 == 3)
         {
            if(this.m_data["fish"] != undefined)
            {
               return;
            }
            if(this.m_me == true)
            {
               _loc2_ = {"uId":Session.getInstance().hostId};
            }
            else
            {
               _loc2_ = {"uId":Session.getInstance().currentUser._uId};
            }
            _loc2_["ownerId"] = _loc2_["uId"];
            dispatchEvent(new CommonEvent(EVENT_DATA_LOADING,true));
            NetHelper.sendRequest(CommandDefs.CMD_GET_FISH_ALL,_loc2_,this.onDataLoaded,this.onNetError);
         }
         else if(param1 == 4)
         {
            if(this.m_data["cost"] != undefined)
            {
               return;
            }
            dispatchEvent(new CommonEvent(EVENT_DATA_LOADING,true));
            this.m_costNM = false;
            this.m_costWS = false;
            NetHelper.sendRequest(CommandDefs.CMD_GET_BILL_DATA,_loc2_,this.onDataLoaded,this.onNetError);
         }
         else if(param1 == 5)
         {
            if(this.m_data["user"] == undefined)
            {
               if(this.m_me == true)
               {
                  _loc2_ = {"uId":Session.getInstance().hostId};
               }
               else
               {
                  _loc2_ = {"uId":Session.getInstance().currentUser._uId};
               }
               _loc2_["ownerId"] = _loc2_["uId"];
               _loc2_["flag"] = 1;
               NetHelper.sendRequest(CommandDefs.CMD_GET_PROFILE_ALL_INFO,_loc2_,this.onDataLoaded,this.onNetError);
            }
            else
            {
               if(this.m_data["systemMsg"] != undefined)
               {
                  return;
               }
               dispatchEvent(new CommonEvent(EVENT_DATA_LOADING,true));
               _loc2_ = {
                  "uin":Session.getInstance().hostUin,
                  "opuin":Session.getInstance().hostUin
               };
               _loc2_["appid"] = "353";
               _loc2_["msgnum"] = "300";
               NetHelper.sendRequest(CommandDefs.CMD_GET_SYSTEM_MSG,_loc2_,this.onDataLoaded,this.onNetError);
            }
         }
      }
      
      public function set currentPlayer(param1:Player) : void
      {
         if(param1 == null || param1.me == true)
         {
            this.m_me = true;
         }
         else
         {
            this.m_me = false;
         }
      }
      
      private function onBillDataLoaded(param1:CommandEvent) : void
      {
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ != null && _loc2_["cost"] != undefined)
         {
            this.m_data["cost"] = _loc2_["cost"];
            dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED,{
               "index":"cost",
               "data":this.m_data
            }));
         }
      }
      
      private function onLoadFeeds(param1:CommandEvent) : void
      {
         var _loc3_:* = undefined;
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_["ecode"] == 0)
         {
            this.m_data["log"] = _loc2_["data"];
            for(_loc3_ in this.m_data)
            {
               dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED,{
                  "index":_loc3_,
                  "data":this.m_data
               }));
            }
            EventRecorder.recordSueecssEvent(EventRecorder.HF_GET_FEEDS,null,"feeds_select");
         }
         else if(_loc2_["errmsg"] != undefined)
         {
            dispatchEvent(new CommonEvent(EVENT_DATA_FAILED,{"error":_loc2_["errmsg"]}));
         }
      }
      
      private function onNetError(param1:CommandEvent) : void
      {
         var _loc2_:String = Language.L["请求超时，"] + "<a href=\'event:reload\'><u><font color=\'#ff6600\'>" + Language.L["点击重试"] + "</font></u></a>";
         dispatchEvent(new CommonEvent(EVENT_DATA_FAILED,{"error":_loc2_}));
         if(param1.body != null && param1.body["cmdID"] != undefined)
         {
            if(param1.body["cmdID"] as int == CommandDefs.CMD_GET_SYSTEM_MSG)
            {
               EventRecorder.recordErrorEvent(EventRecorder.HF_GET_SYSTEM_MSG,null,EventRecorder.FAULT_ERROR,"sysmsg_select");
            }
            else if(param1.body["cmdID"] as int == CommandDefs.CMD_GET_FEEDS)
            {
               EventRecorder.recordErrorEvent(EventRecorder.HF_GET_FEEDS,null,EventRecorder.FAULT_ERROR,"feeds_select");
            }
            else if(param1.body["cmdID"] as int == CommandDefs.CMD_GET_BILL_DATA)
            {
               EventRecorder.recordErrorEvent(EventRecorder.HF_GET_BILL_DATA,null,EventRecorder.FAULT_ERROR,"cgi_farm_exchange");
            }
            else if(param1.body["cmdID"] as int == CommandDefs.CMD_GET_FISH_ALL)
            {
               EventRecorder.recordErrorEvent("160874",null,4);
            }
            else if(param1.body["cmdID"] as int == CommandDefs.CMD_GET_BILL_WS_DATA)
            {
               EventRecorder.recordErrorEvent("160878",null,4);
            }
         }
      }
   }
}

