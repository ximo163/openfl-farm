package plugins.external.fairy
{
   import com.qzone.farm.api.interfaces.IFarmAPI;
   import common.CommonData;
   import common.Settings;
   import common.misc.Cookies;
   import entities.Friend;
   import events.CommonEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import framework.net.CommandDefs;
   
   public class FriendsModel extends EventDispatcher
   {
      
      internal static const CMD_EXCLUDE_LIST:uint = 11010;
      
      internal static const CMD_SEND_TIP:uint = 11011;
      
      internal static const EVENT_FRIEND_DATA:String = "LoadFriendData";
      
      internal static const EVENT_TIP_SENT:String = "InviteSent";
      
      internal static const EVENT_FUSION_CALLBACK:String = "RequestSent";
      
      private var _loading:Boolean;
      
      private var _friendStatus:Object;
      
      private var _noFriends:Boolean;
      
      private var _api:IFarmAPI;
      
      private var _exclude:Array;
      
      public var hostId:uint = 0;
      
      private var _loadExcluded:Boolean;
      
      private var _friendList:Array;
      
      public function FriendsModel(param1:IFarmAPI)
      {
         super(null);
         this._api = param1;
         var _loc2_:Settings = Settings.getInstance();
         var _loc3_:String = _loc2_.mode;
         if(_loc3_ == "qplus")
         {
            _loc3_ = "qzone";
         }
         this._api.registerNetCommand(CMD_EXCLUDE_LIST,"" + _loc3_ + "mod=cgi_farm_sx_request_list",null);
         this._api.registerNetCommand(CMD_SEND_TIP,"" + _loc3_ + "mod=cgi_farm_sx_send_request",null);
         this._noFriends = false;
         this._loading = false;
         this._exclude = [];
         this._loadExcluded = false;
      }
      
      public function pick5Friends() : Array
      {
         if(this._loading == true)
         {
            return null;
         }
         if(this._noFriends == true)
         {
            return null;
         }
         if(this._friendList == null)
         {
            return null;
         }
         var _loc1_:Array = [];
         var _loc2_:int = 0;
         var _loc3_:uint = this._friendList.length;
         var _loc4_:Friend = null;
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_)
         {
            _loc4_ = this._friendList[_loc5_] as Friend;
            if(_loc4_ != null)
            {
               if(this._exclude == null || this._exclude.indexOf(_loc4_._uin) == -1)
               {
                  _loc1_.push(_loc4_);
                  _loc2_++;
               }
               if(_loc2_ >= 5)
               {
                  break;
               }
            }
            _loc5_++;
         }
         return _loc1_;
      }
      
      public function get loaded() : Boolean
      {
         if(this._noFriends == true)
         {
            return true;
         }
         if(this._friendList != null && this._friendList.length > 0 && this._friendStatus != null)
         {
            return true;
         }
         return false;
      }
      
      private function loadFriendStatus(param1:Array) : void
      {
         var _loc5_:Friend = null;
         if(param1 == null || param1.length == 0)
         {
            return;
         }
         var _loc2_:Array = [];
         var _loc3_:Array = [];
         var _loc4_:String = Settings.getInstance().mode;
         for each(_loc5_ in param1)
         {
            if(_loc4_ == "qzone")
            {
               _loc3_.push(_loc5_._uin);
            }
            _loc2_.push(_loc5_._uId || _loc5_._userId);
         }
         this._api.sendRequest(CommandDefs.CMD_GET_FRIENDLIST_STATUS,{
            "cmd":3,
            "friend_uids":_loc2_.join(","),
            "friend_uins":_loc3_.join(",")
         },this.onFriendStatusLoaded,this.onNetError);
      }
      
      public function loadExclude() : void
      {
         var onSuccess:Function = null;
         onSuccess = function(param1:int, param2:*):void
         {
            var _loc3_:Array = param2["request_list"] as Array;
            if(_loc3_ != null && _loc3_.length > 0)
            {
               _exclude = _exclude.concat(_loc3_);
            }
            _loadExcluded = true;
         };
         if(this._loadExcluded == true)
         {
            return;
         }
         this._api.sendRequest(CMD_EXCLUDE_LIST,null,onSuccess,this.onNetError);
      }
      
      public function loadFriends() : void
      {
         if(this.loaded == true)
         {
            return;
         }
         if(this.loadFriendsDataFromCache() == false)
         {
            this._api.sendRequest(CommandDefs.CMD_GET_FRIENDLIST,{
               "refresh":true,
               "user":true
            },this.onFriendsDataLoaded,this.onNetError);
            this._loading = true;
         }
         else
         {
            if(this._friendList == null || this._friendList.length == 0)
            {
               this._noFriends = true;
               dispatchEvent(new CommonEvent(EVENT_FRIEND_DATA,{"noFriends":true}));
               return;
            }
            this.loadFriendStatus(this._friendList);
         }
      }
      
      private function loadFriendsDataFromCache() : Boolean
      {
         var _loc4_:* = undefined;
         var _loc1_:Array = null;
         var _loc2_:String = Settings.getInstance().mode;
         _loc1_ = Cookies.getObject(_loc2_ + this.hostId,CommonData.serverTime) as Array;
         if(_loc1_ != null)
         {
            this._friendList = [];
         }
         var _loc3_:Friend = null;
         for each(_loc4_ in _loc1_)
         {
            _loc3_ = new Friend(null);
            _loc3_.importFromCache(_loc4_);
            if(_loc3_.me != true)
            {
               this._friendList.push(_loc3_);
            }
         }
         return this._friendList != null && this._friendList.length > 0 ? true : false;
      }
      
      private function onFriendsDataLoaded(param1:int, param2:*) : void
      {
         this._loading = false;
         if(param2 != null)
         {
            delete param2["__body"];
         }
         var _loc3_:Array = param2 as Array;
         this.processFriends(_loc3_);
         this.loadFriendStatus(this._friendList);
      }
      
      private function processFriends(param1:Array) : void
      {
         if(param1 == null)
         {
            this._noFriends = true;
            dispatchEvent(new CommonEvent(EVENT_FRIEND_DATA,{"noFriends":true}));
            return;
         }
         var _loc2_:int = int(param1.length);
         var _loc3_:Friend = null;
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_)
         {
            _loc3_ = param1[_loc4_] as Friend;
            if(_loc3_ != null && _loc3_._uId == this.hostId)
            {
               param1.splice(_loc4_,1);
               break;
            }
            _loc4_++;
         }
         this._friendList = param1;
         if(this._friendList.length == 0)
         {
            this._noFriends = true;
            dispatchEvent(new CommonEvent(EVENT_FRIEND_DATA,{"noFriends":true}));
         }
      }
      
      public function sendRequest(param1:String, param2:String) : void
      {
         var _loc4_:String = null;
         if(param1 == null || param1 == "")
         {
            return;
         }
         var _loc3_:Array = param1.split(",");
         for each(_loc4_ in _loc3_)
         {
            this._exclude.push(parseInt(_loc4_));
         }
      }
      
      private function onFriendStatusLoaded(param1:int, param2:*) : void
      {
         this._loading = false;
         if(param2 != null && param2.hasOwnProperty("status") == true)
         {
            this._friendStatus = param2["status"];
            this._friendList.forEach(this.sortRule);
            this._friendList.sortOn("sort",Array.DESCENDING | Array.NUMERIC);
         }
         dispatchEvent(new CommonEvent(EVENT_FRIEND_DATA,{"success":true}));
      }
      
      private function onNetError(param1:int, param2:*) : void
      {
         if(param1 == CommandDefs.CMD_GET_FRIENDLIST)
         {
            this._loading = false;
            dispatchEvent(new CommonEvent(EVENT_FRIEND_DATA,{"success":false}));
         }
         else if(param1 == CommandDefs.CMD_GET_FRIENDLIST_STATUS)
         {
            this._loading = false;
            dispatchEvent(new CommonEvent(EVENT_FRIEND_DATA,{"success":false}));
         }
         else if(param1 == CMD_SEND_TIP)
         {
            dispatchEvent(new CommonEvent(EVENT_TIP_SENT,null));
         }
      }
      
      public function sendTip(param1:Array) : void
      {
         var params:Object;
         var onSuccess:Function = null;
         var uins:Array = param1;
         onSuccess = function(param1:int, param2:*):void
         {
            dispatchEvent(new CommonEvent(EVENT_TIP_SENT,param2["__body"]));
         };
         if(uins == null || uins.length < 0)
         {
            return;
         }
         params = {"uin_list":uins.join(",")};
         this._api.sendRequest(CMD_SEND_TIP,params,onSuccess,this.onNetError);
      }
      
      private function sortRule(param1:*, param2:int, param3:Array) : void
      {
         var _loc9_:Object = null;
         var _loc4_:Friend = param1 as Friend;
         if(_loc4_ == null)
         {
            return;
         }
         var _loc5_:Boolean = Boolean(Settings.isQZoneUinMode);
         var _loc6_:uint = uint(_loc4_._uId);
         if(_loc5_ == true)
         {
            _loc6_ = uint(_loc4_._uin);
         }
         var _loc7_:int = 0;
         if(this._friendStatus != null)
         {
            _loc9_ = this._friendStatus[_loc6_];
            if(_loc9_ != null && _loc9_.hasOwnProperty("5") && (_loc9_["5"] == 1 || _loc9_["5"] == true))
            {
               _loc7_ += 10000;
            }
         }
         var _loc8_:int = this.expToGrade(_loc4_._exp);
         if(_loc8_ >= 10 && _loc8_ <= 30)
         {
            _loc7_ += _loc8_ * 100;
         }
         _loc7_ += _loc8_;
         _loc4_.sort = _loc7_;
      }
      
      private function onFusionAPICallback(param1:Object) : void
      {
         dispatchEvent(new Event(EVENT_FUSION_CALLBACK));
      }
      
      private function expToGrade(param1:uint) : int
      {
         return Math.sqrt((param1 + 25) / 100) - 0.5;
      }
   }
}

