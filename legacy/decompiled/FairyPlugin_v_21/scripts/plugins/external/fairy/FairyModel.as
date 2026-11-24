package plugins.external.fairy
{
   import com.qzone.farm.api.interfaces.IFarmAPI;
   import com.qzone.sns.entities.Payment;
   import common.CommonData;
   import common.Settings;
   import entities.Player;
   import events.CommonEvent;
   import flash.events.EventDispatcher;
   
   public class FairyModel extends EventDispatcher
   {
      
      internal static const CMD_REFRESH:uint = 11000;
      
      internal static const CMD_DONATE:uint = 11001;
      
      internal static const CMD_CHARGE:uint = 11002;
      
      internal static const CMD_INIT:uint = 11003;
      
      internal static const CMD_DONATE_LIST:uint = 11004;
      
      internal static const CMD_AB_TEST:uint = 11005;
      
      internal static const CMD_AUTO_POPUP_CHECK:uint = 11006;
      
      internal static const DATA_FAIRY_CHANGED:String = "FairyChanged";
      
      internal static const DATA_INITIALIZED:String = "Initialized";
      
      internal static const DATA_DONATE_LIST:String = "DonateList";
      
      internal static const DATA_MONEY:String = "GuestMoney";
      
      internal static const MSG_PAIRY_BOUGHT:String = "FairyBought";
      
      internal static const MSG_DONATE_MONEY:String = "DonateMoney";
      
      internal static const MSG_CHARGE_MONEY:String = "ChargeMoney";
      
      internal static const MSG_CHANGE_MY_FAIRY:String = "ChangeMyFariy";
      
      private static const FAIRY_NUM:int = 4;
      
      internal var fairyItem:Object;
      
      private var _myFairyList:Array;
      
      internal var isXianHuangWinOpen:Boolean = false;
      
      private var _requestPending:Boolean;
      
      internal var money:int;
      
      internal var discount:int;
      
      private var _isRenew:Boolean;
      
      private var _donateList:Array;
      
      private var _history:Array;
      
      internal var myName:String;
      
      internal var myExpireTime:int;
      
      private var _api:IFarmAPI;
      
      internal var player:Player;
      
      private var _config:Object;
      
      public function FairyModel(param1:IFarmAPI)
      {
         super(null);
         this.discount = 0;
         this.myName = "";
         this.myExpireTime = 0;
         this.money = 0;
         this._api = param1;
         this._config = null;
         var _loc2_:Settings = Settings.getInstance();
         var _loc3_:String = _loc2_.mode;
         if(_loc3_ == "qplus")
         {
            _loc3_ = "qzone";
         }
         this._api.registerNetCommand(CMD_AUTO_POPUP_CHECK,"" + _loc3_ + "mod=cgi_fetch_strategy_rules",null);
         this._api.registerNetCommand(CMD_REFRESH,"" + _loc3_ + "mod=cgi_farm_sx_ref",null);
         this._api.registerNetCommand(CMD_DONATE,"" + _loc3_ + "mod=cgi_farm_sx_dedicate",null);
         this._api.registerNetCommand(CMD_CHARGE,"" + _loc3_ + "mod=cgi_farm_sx_get_money",null);
         this._api.registerNetCommand(CMD_INIT,"" + _loc3_ + "mod=cgi_farm_sx_list",null);
         this._api.registerNetCommand(CMD_DONATE_LIST,"" + _loc3_ + "mod=cgi_farm_sx_dedicate_list",null);
         this._api.registerNetCommand(CMD_AB_TEST,"mod=cgi_ab_report",null);
         this._requestPending = false;
         this._myFairyList = null;
         this._history = [];
      }
      
      public function set config(param1:Object) : void
      {
         this._config = param1;
      }
      
      public function get fairyName() : String
      {
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         if(this.fairyItem != null)
         {
            _loc1_ = int(this.fairyItem["itemId"]);
            _loc2_ = this.getFairyConfig(_loc1_);
            if(_loc2_ != null)
            {
               return _loc2_["name"];
            }
         }
         return "";
      }
      
      public function getMoney() : void
      {
         var onSuccess:Function = null;
         onSuccess = function(param1:int, param2:*):void
         {
            _requestPending = false;
            money = param2["money"];
            dispatchEvent(new CommonEvent(DATA_MONEY,param2["limit_list"] as Array));
         };
         if(this.player == null)
         {
            return;
         }
         if(this._requestPending)
         {
            return;
         }
         this._requestPending = true;
         this.money = 0;
         this._api.sendRequest(CMD_DONATE_LIST,{
            "f":2,
            "ownerId":this.player._uId
         },onSuccess,this.onNetError);
      }
      
      public function getFairyById(param1:int) : Object
      {
         var _loc2_:Object = null;
         if(this._myFairyList == null)
         {
            return null;
         }
         for each(_loc2_ in this._myFairyList)
         {
            if(_loc2_["id"] == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function sendCheckAutoPopupRequest(param1:Function) : void
      {
         this._api.sendRequest(CMD_AUTO_POPUP_CHECK,{"bitpos":"21"},param1,this.onNetError);
      }
      
      public function get fairyList() : Array
      {
         return this._myFairyList;
      }
      
      public function get canBuySprite4() : Boolean
      {
         if(this.player != null)
         {
            return true;
         }
         return false;
      }
      
      public function getDonateList(param1:uint) : void
      {
         var onSuccess:Function = null;
         var uin:uint = param1;
         onSuccess = function(param1:int, param2:*):void
         {
            _requestPending = false;
            _donateList = param2["list"] as Array;
            dispatchEvent(new CommonEvent(DATA_DONATE_LIST,_donateList));
         };
         if(this._requestPending)
         {
            return;
         }
         this._requestPending = true;
         if(uin == 0)
         {
            this._api.sendRequest(CMD_DONATE_LIST,null,onSuccess,this.onNetError);
         }
         else
         {
            this._api.sendRequest(CMD_DONATE_LIST,{
               "f":1,
               "ownerId":uin
            },onSuccess,this.onNetError);
         }
      }
      
      public function init() : void
      {
         var onSuccess:Function = null;
         onSuccess = function(param1:int, param2:*):void
         {
            var _loc3_:Object = null;
            _requestPending = false;
            param2["rate"] *= 10;
            fairyItem = {
               "itemId":param2["id"],
               "lv":param2["lv"],
               "rate":param2["rate"]
            };
            _myFairyList = param2["item"] as Array;
            for each(_loc3_ in _myFairyList)
            {
               _loc3_["rate"] *= 10;
            }
            if(_myFairyList.length < FAIRY_NUM)
            {
               _myFairyList.push({
                  "id":param2["id"],
                  "lv":param2["lv"],
                  "rate":param2["rate"]
               });
            }
            money = param2["money"] as int;
            myExpireTime = param2["validTime"] as int;
            discount = param2["policy"] as int;
            dispatchEvent(new CommonEvent(DATA_INITIALIZED,_myFairyList));
         };
         if(this._requestPending)
         {
            return;
         }
         if(this._myFairyList != null && this._myFairyList.length == 3)
         {
            return;
         }
         this._requestPending = true;
         this._api.sendRequest(CMD_INIT,null,onSuccess,this.onNetError);
      }
      
      public function get donateList() : Array
      {
         return this._donateList;
      }
      
      public function charge() : void
      {
         var onSuccess:Function = null;
         onSuccess = function(param1:int, param2:*):void
         {
            _requestPending = false;
            if(param2["money"] != undefined && param2["money"] > 0)
            {
               money -= param2["money"];
               money = Math.max(0,money);
            }
            dispatchEvent(new CommonEvent(MSG_CHARGE_MONEY,param2));
         };
         if(this._requestPending)
         {
            return;
         }
         this._requestPending = true;
         this._api.sendRequest(CMD_CHARGE,null,onSuccess,this.onNetError);
      }
      
      public function get tipName() : String
      {
         if(this.fairyItem == null)
         {
            return "无效的小仙";
         }
         var _loc1_:String = "";
         if(this.fairyItem["lv"] == 1)
         {
            _loc1_ = "一级";
         }
         else if(this.fairyItem["lv"] == 2)
         {
            _loc1_ = "二级";
         }
         else if(this.fairyItem["lv"] == 3)
         {
            _loc1_ = "三级";
         }
         return _loc1_ + this.fairyName;
      }
      
      public function getFairyConfig(param1:int) : Object
      {
         var _loc2_:Object = null;
         if(this._config != null && this._config["fairy"] != undefined)
         {
            for each(_loc2_ in this._config["fairy"])
            {
               if(param1 == _loc2_["id"])
               {
                  return _loc2_;
               }
            }
         }
         return null;
      }
      
      public function markDonated(param1:uint) : void
      {
         if(param1 == 0)
         {
            return;
         }
         if(this._history.indexOf(param1) == -1)
         {
            this._history.push(param1);
         }
      }
      
      public function isSameDay(param1:Number) : Boolean
      {
         if(param1 == 0 || isNaN(param1) == true)
         {
            return false;
         }
         var _loc2_:Number = Number(CommonData.serverTime);
         var _loc3_:Date = new Date(param1 * 1000);
         var _loc4_:Date = new Date(_loc2_ * 1000);
         if(_loc3_.getDate() != _loc4_.getDate() || _loc3_.month != _loc4_.month || _loc3_.fullYear != _loc4_.fullYear)
         {
            return false;
         }
         return true;
      }
      
      private function abTest(param1:int) : void
      {
         var _loc2_:String = Settings.getInstance().mode;
         var _loc3_:String = this._isRenew ? "renew" : "buy";
         var _loc4_:Object = {
            "test_id":1,
            "rule_id":this.discount,
            "app_id":353,
            "domain":_loc2_,
            "uin":this.player.uin,
            "to_uin":"",
            "action_id":param1,
            "source":_loc3_,
            "time":CommonData.serverTime
         };
         this._api.sendRequest(CMD_AB_TEST,_loc4_,null,null);
      }
      
      public function queryDonate(param1:uint) : Boolean
      {
         if(param1 == 0)
         {
            return false;
         }
         if(this._history.indexOf(param1) != -1)
         {
            return false;
         }
         return true;
      }
      
      public function updateReward(param1:Object) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Date = null;
         if(param1 == null || this.player == null)
         {
            return;
         }
         if(param1["rate"] != undefined)
         {
            param1["rate"] *= 10;
         }
         if(this.player.me == true)
         {
            if(this.fairyItem != null && this.fairyItem["itemId"] != 0)
            {
               this.myExpireTime += param1["time"];
            }
            else
            {
               this.fairyItem = {
                  "itemId":param1["id"],
                  "lv":param1["lv"],
                  "rate":param1["rate"]
               };
               for each(_loc2_ in this._myFairyList)
               {
                  if(_loc2_["id"] == param1["id"])
                  {
                     _loc2_["lv"] = param1["lv"];
                     _loc2_["rate"] = param1["rate"] * 10;
                     break;
                  }
               }
               dispatchEvent(new CommonEvent(MSG_CHANGE_MY_FAIRY,{
                  "fairy":param1,
                  "update":true
               }));
               _loc3_ = new Date();
               this.myExpireTime = _loc3_.time / 1000 + param1["time"];
            }
         }
         else
         {
            this.myExpireTime += param1["time"];
         }
      }
      
      public function get currentUserIdByUinMode() : uint
      {
         var _loc1_:uint = 0;
         if(this.player == null)
         {
            return _loc1_;
         }
         _loc1_ = uint(this.player._uId);
         var _loc2_:Boolean = Boolean(Settings.isQZoneUinMode);
         if(_loc2_ == true)
         {
            _loc1_ = uint(this.player.uin);
         }
         return _loc1_;
      }
      
      private function onNetError(param1:int, param2:*) : void
      {
         this._requestPending = false;
         var _loc3_:String = "";
         if(param2 == undefined || param2 == null)
         {
            _loc3_ = "请求超时，稍后再试";
         }
         if(param1 == CMD_REFRESH)
         {
            dispatchEvent(new CommonEvent(DATA_FAIRY_CHANGED,{"error":param2["direction"]}));
         }
         else if(param1 == CMD_DONATE)
         {
            dispatchEvent(new CommonEvent(MSG_DONATE_MONEY,{"error":param2["direction"]}));
         }
         else if(param1 == CMD_CHARGE)
         {
            dispatchEvent(new CommonEvent(MSG_CHARGE_MONEY,{"error":param2["direction"]}));
         }
         else if(param1 == CMD_INIT)
         {
            dispatchEvent(new CommonEvent(DATA_INITIALIZED,null));
         }
         else if(param1 == CMD_DONATE_LIST)
         {
            if(param2["__body"]["f"] != 2)
            {
               dispatchEvent(new CommonEvent(DATA_DONATE_LIST,{"error":param2["direction"]}));
            }
         }
      }
      
      public function buySprite(param1:int, param2:int, param3:int = 16, param4:int = 16) : void
      {
         var buyResult:Function = null;
         var id:int = param1;
         var month:int = param2;
         var itemType:int = param3;
         var shopType:int = param4;
         buyResult = function(param1:int, param2:Boolean, param3:Payment, param4:*):void
         {
            var _loc5_:Date = null;
            if(itemType == 26 && shopType == 26)
            {
               param3.id = 92004;
            }
            if(param1 == 1 && param2 == true)
            {
               if(player != null && player.me == true)
               {
                  _loc5_ = new Date();
                  if(fairyItem == null || fairyItem != null && fairyItem["itemId"] == param3.id)
                  {
                     if(myExpireTime == 0)
                     {
                        myExpireTime = _loc5_.time / 1000;
                     }
                     myExpireTime += param3.num * 31 * 24 * 60 * 60;
                  }
                  else
                  {
                     money = 0;
                     _donateList = null;
                     myExpireTime = _loc5_.time / 1000;
                     myExpireTime += param3.num * 31 * 24 * 60 * 60;
                  }
               }
               dispatchEvent(new CommonEvent(MSG_PAIRY_BOUGHT,{
                  "succ":true,
                  "id":param3.id,
                  "month":param3.num
               }));
               if(discount > 0)
               {
                  abTest(1);
               }
            }
         };
         this._api.payByPlatform(id,itemType,month,shopType,buyResult);
         if(this.discount > 0)
         {
            if(this.fairyItem != null && this.fairyItem["itemId"] == id)
            {
               this._isRenew = true;
            }
            else
            {
               this._isRenew = false;
            }
            this.abTest(0);
         }
      }
      
      public function randomXianHuang() : void
      {
         var onSuccess:Function = null;
         onSuccess = function(param1:int, param2:*):void
         {
            var _loc3_:Object = null;
            _requestPending = false;
            param2["rate"] *= 10;
            _myFairyList = param2["item"] as Array;
            for each(_loc3_ in _myFairyList)
            {
               _loc3_["rate"] *= 10;
            }
            if(_myFairyList.length < FAIRY_NUM)
            {
               _myFairyList.push({
                  "id":param2["id"],
                  "lv":param2["lv"],
                  "rate":param2["rate"]
               });
            }
            money = param2["money"];
            myExpireTime = param2["validTime"] as int;
            dispatchEvent(new CommonEvent(DATA_FAIRY_CHANGED,{
               "list":_myFairyList,
               "cost":param2["cost"]
            }));
         };
         if(this._requestPending)
         {
            return;
         }
         this._requestPending = true;
         this._api.sendRequest(CMD_REFRESH,{"v":1},onSuccess,this.onNetError);
      }
      
      public function randomSprite() : void
      {
         var onSuccess:Function = null;
         onSuccess = function(param1:int, param2:*):void
         {
            var _loc3_:Object = null;
            _requestPending = false;
            param2["rate"] *= 10;
            _myFairyList = param2["item"] as Array;
            for each(_loc3_ in _myFairyList)
            {
               _loc3_["rate"] *= 10;
            }
            if(_myFairyList.length < FAIRY_NUM)
            {
               _myFairyList.push({
                  "id":param2["id"],
                  "lv":param2["lv"],
                  "rate":param2["rate"]
               });
            }
            money = param2["money"];
            myExpireTime = param2["validTime"] as int;
            dispatchEvent(new CommonEvent(DATA_FAIRY_CHANGED,{
               "list":_myFairyList,
               "cost":param2["cost"]
            }));
         };
         if(this._requestPending)
         {
            return;
         }
         this._requestPending = true;
         this._api.sendRequest(CMD_REFRESH,null,onSuccess,this.onNetError);
      }
      
      public function donate(param1:uint = 10000) : void
      {
         var uin:String;
         var onSuccess:Function = null;
         var gold:uint = param1;
         onSuccess = function(param1:int, param2:*):void
         {
            var _loc3_:Date = null;
            var _loc4_:Object = null;
            _requestPending = false;
            if(param2 != null)
            {
               if(param2["type"] == 31)
               {
                  _loc3_ = new Date();
                  myExpireTime = _loc3_.time / 1000 + 24 * 60 * 60;
                  for each(_loc4_ in _myFairyList)
                  {
                     if(_loc4_["id"] == param2["item"])
                     {
                        _loc4_["lv"] = 1;
                        _loc4_["rate"] = 50;
                        dispatchEvent(new CommonEvent(MSG_CHANGE_MY_FAIRY,{
                           "fairy":_loc4_,
                           "update":false
                        }));
                        break;
                     }
                  }
               }
               else if(param2["type"] == 4)
               {
                  param2["type"] = 909090;
               }
               else if(param2["type"] == 30)
               {
                  param2["type"] = 7;
               }
            }
            money = param2["money"];
            dispatchEvent(new CommonEvent(MSG_DONATE_MONEY,param2));
         };
         if(this._requestPending)
         {
            return;
         }
         this._requestPending = true;
         uin = this.player._uId.toString();
         this._api.sendRequest(CMD_DONATE,{"ownerId":uin},onSuccess,this.onNetError);
      }
   }
}

