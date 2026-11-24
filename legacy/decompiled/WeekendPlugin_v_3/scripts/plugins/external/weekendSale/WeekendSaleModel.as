package plugins.external.weekendSale
{
   import com.qzone.farm.api.interfaces.IFarmAPI;
   import common.CommonData;
   import common.Settings;
   import events.CommonEvent;
   import flash.events.EventDispatcher;
   
   public class WeekendSaleModel extends EventDispatcher
   {
      
      internal static const CMD_REFRESH:uint = 12000;
      
      internal static const CMD_INIT:uint = 12001;
      
      internal static const DATA_INITIALIZED:String = "DataLoaded";
      
      internal static const DATA_CARD_LOADED:String = "CardsLoaded";
      
      internal static const DATA_TIMES:String = "TimesRefreshed";
      
      private var _api:IFarmAPI;
      
      private var _config:Object;
      
      private var _seeds:Array;
      
      private var _cards:int;
      
      private var _requestPending:Boolean;
      
      private const week:Array = ["周日","周一","周二","周三","周四","周五","周六"];
      
      private var _freeCard:Boolean;
      
      public function WeekendSaleModel(param1:IFarmAPI, param2:Object)
      {
         super(null);
         this._api = param1;
         this._config = param2;
         this._requestPending = false;
         this._seeds = null;
         this._freeCard = false;
         this._cards = 0;
         var _loc3_:Settings = Settings.getInstance();
         var _loc4_:String = _loc3_.mode;
         if(_loc4_ == "qplus")
         {
            _loc4_ = "qzone";
         }
         this._api.registerNetCommand(CMD_REFRESH,"" + _loc4_ + "mod=cgi_farm_refresh_multiple",null);
         this._api.registerNetCommand(CMD_INIT,"" + _loc4_ + "mod=cgi_farm_happyweekend_getcrops",null);
      }
      
      public function get desc1() : String
      {
         if(this._config == null)
         {
            return "";
         }
         var _loc1_:Date = new Date(this._config["start2"]);
         var _loc2_:Date = new Date(this._config["end1"]);
         var _loc3_:Date = new Date(this._config["end2"]);
         return "说明：" + this.week[_loc1_.day] + _loc1_.hours + "时后可在此购买活动种子、刷倍数，" + this.week[_loc2_.day] + "-" + this.week[_loc3_.day] + "翻倍卖产物";
      }
      
      public function get desc2() : String
      {
         if(this._config == null)
         {
            return "";
         }
         var _loc1_:Date = new Date(this._config["end1"]);
         var _loc2_:Date = new Date(this._config["end2"]);
         return this.week[_loc1_.day] + "-" + this.week[_loc2_.day] + "翻倍卖产物";
      }
      
      public function get durationFull() : String
      {
         if(this._config == null)
         {
            return "";
         }
         var _loc1_:Date = new Date(this._config["end1"]);
         var _loc2_:Date = new Date(this._config["end2"]);
         return _loc1_.getFullYear() + "年" + (_loc1_.getMonth() + 1) + "月" + _loc1_.date + "日至" + _loc2_.getFullYear() + "年" + (_loc2_.getMonth() + 1) + "月" + _loc2_.date + "日";
      }
      
      public function get canSell() : Boolean
      {
         if(this._config == null)
         {
            return false;
         }
         var _loc1_:Date = new Date(CommonData.serverTime * 1000);
         var _loc2_:Date = new Date(this._config["end1"]);
         var _loc3_:Date = new Date(this._config["end2"]);
         if(_loc1_.time >= _loc2_.time && _loc1_.time <= _loc3_.time)
         {
            return true;
         }
         return false;
      }
      
      public function refreshFactor(param1:int) : void
      {
         var onSuccess:Function = null;
         var index:int = param1;
         onSuccess = function(param1:int, param2:*):void
         {
            _requestPending = false;
            var _loc3_:int = param2["cid"] as int;
            var _loc4_:int = 0;
            if(_seeds[1]["cId"] == _loc3_)
            {
               _loc4_ = 1;
            }
            _seeds[_loc4_]["times"] = param2["times"] as int;
            dispatchEvent(new CommonEvent(DATA_TIMES,{
               "index":_loc4_,
               "times":param2["times"],
               "price":_seeds[_loc4_]["price"],
               "cId":_loc3_
            }));
            --_cards;
            _cards = Math.max(0,_cards);
         };
         if(this._requestPending)
         {
            return;
         }
         if(this._seeds == null || this._seeds.length < 2)
         {
            return;
         }
         this._requestPending = true;
         this._api.sendRequest(CMD_REFRESH,{"cid":this._seeds[index]["cId"]},onSuccess,this.onNetError);
      }
      
      public function init() : Boolean
      {
         var onSuccess:Function = null;
         onSuccess = function(param1:int, param2:*):void
         {
            _requestPending = false;
            _seeds = param2 as Array;
            delete _seeds["__body"];
            dispatchEvent(new CommonEvent(DATA_INITIALIZED,_seeds));
         };
         if(this._requestPending)
         {
            return false;
         }
         this._requestPending = true;
         this._api.sendRequest(CMD_INIT,null,onSuccess,this.onNetError);
         return false;
      }
      
      public function get duration() : String
      {
         if(this._config == null)
         {
            return "";
         }
         var _loc1_:Date = new Date(this._config["end1"]);
         var _loc2_:Date = new Date(this._config["end2"]);
         return _loc1_.date + "日-" + _loc2_.date + "日";
      }
      
      public function get startDay() : String
      {
         if(this._config == null)
         {
            return "";
         }
         var _loc1_:Date = new Date(this._config["start2"]);
         var _loc2_:Date = new Date(this._config["end2"]);
         return _loc1_.date + "日-" + _loc2_.date + "日";
      }
      
      public function loadCards() : void
      {
         var onSuccess:Function = null;
         onSuccess = function(param1:int, param2:*):void
         {
            var _loc4_:* = undefined;
            _requestPending = false;
            _cards = 0;
            _freeCard = false;
            var _loc3_:Array = param2 as Array;
            if(_loc3_ == null || _loc3_.length == 0)
            {
               dispatchEvent(new CommonEvent(DATA_CARD_LOADED,{
                  "cards":0,
                  "free":false
               }));
               return;
            }
            for each(_loc4_ in _loc3_)
            {
               if(_loc4_._type == 3 && _loc4_._cId == 35 && _loc4_._amount > 0)
               {
                  _freeCard = true;
                  _cards += _loc4_._amount;
               }
               if(_loc4_._type == 3 && _loc4_._cId == 34)
               {
                  _cards += _loc4_._amount;
               }
            }
            dispatchEvent(new CommonEvent(DATA_CARD_LOADED,{
               "cards":_cards,
               "free":_freeCard
            }));
         };
         if(this._requestPending)
         {
            return;
         }
         this._requestPending = true;
         this._api.sendRequest(32,{"hw":1},onSuccess,this.onNetError);
      }
      
      public function get share() : Object
      {
         return this._config["share"];
      }
      
      public function get seeds() : Array
      {
         return this._seeds;
      }
      
      private function onNetError(param1:int, param2:*) : void
      {
         this._requestPending = false;
         var _loc3_:String = "周末乐翻天";
         if(param1 == CMD_INIT)
         {
            this._api.alert(2,_loc3_,"加载活动数据失败，请稍后再试。",0,0,null);
         }
         else if(param1 == CMD_REFRESH)
         {
            this._api.alert(2,_loc3_,"刷新倍数失败，请稍后再试。",0,0,null);
            dispatchEvent(new CommonEvent(DATA_TIMES,null));
         }
         else if(param1 == 32)
         {
            this._api.alert(2,_loc3_,"获取道具卡数据失败，请稍后再试。",0,0,null);
         }
      }
      
      public function get canRefresh() : Boolean
      {
         if(this._config == null)
         {
            return false;
         }
         var _loc1_:Date = new Date(CommonData.serverTime * 1000);
         var _loc2_:Date = new Date(this._config["start2"]);
         var _loc3_:Date = new Date(this._config["end2"]);
         if(_loc1_.time >= _loc2_.time && _loc1_.time <= _loc3_.time)
         {
            return true;
         }
         return false;
      }
      
      public function get isWeekend() : Boolean
      {
         if(this._config == null)
         {
            return false;
         }
         var _loc1_:Date = new Date(CommonData.serverTime * 1000);
         var _loc2_:Date = new Date(this._config["start2"]);
         var _loc3_:Date = new Date(this._config["end2"]);
         if(_loc1_.time >= _loc2_.time && _loc1_.time <= _loc3_.time)
         {
            return true;
         }
         return false;
      }
      
      public function get startDayWeek() : String
      {
         if(this._config == null)
         {
            return "";
         }
         var _loc1_:Date = new Date(this._config["start2"]);
         var _loc2_:Date = new Date(this._config["end2"]);
         var _loc3_:Array = ["周日","周一","周二","周三","周四","周五","周六"];
         return _loc3_[_loc1_.day] + _loc1_.hours + "点-" + _loc3_[_loc2_.day];
      }
      
      public function get durationWeek() : String
      {
         if(this._config == null)
         {
            return "";
         }
         var _loc1_:Date = new Date(this._config["end1"]);
         var _loc2_:Date = new Date(this._config["end2"]);
         return this.week[_loc1_.day] + "-" + this.week[_loc2_.day];
      }
      
      public function get isShowNotice() : Boolean
      {
         if(this._config == null)
         {
            return false;
         }
         var _loc1_:Date = new Date(CommonData.serverTime * 1000);
         var _loc2_:Date = new Date(this._config["start"]);
         var _loc3_:Date = new Date(this._config["start2"]);
         if(_loc1_.time >= _loc2_.time && _loc1_.time <= _loc3_.time)
         {
            return true;
         }
         return false;
      }
   }
}

