package module.weekendSale
{
   import common.CommonData;
   import flash.events.EventDispatcher;
   import mc.FBridge.FRequest;
   import mc.api.IAPIHelper;
   import mc.control.Version;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.model.ModelEvent;
   
   public class WeekendSaleModel extends EventDispatcher
   {
      
      public static const CMD_REFRESH:uint = 12000;
      
      public static const CMD_INIT:uint = 12001;
      
      public static const DATA_INITIALIZED:String = "DataLoaded";
      
      public static const DATA_CARD_LOADED:String = "CardsLoaded";
      
      public static const DATA_TIMES:String = "TimesRefreshed";
      
      public var mainData:MainData;
      
      private var _api:IAPIHelper;
      
      private var _config:Object;
      
      private var _requestPending:Boolean;
      
      private var _fr:FRequest = FRequest.getInstance();
      
      private const week:Array = ["周日","周一","周二","周三","周四","周五","周六"];
      
      public function WeekendSaleModel(param1:IAPIHelper, param2:Object)
      {
         super(null);
         this.mainData = MData.getInstance().mainData;
         this._api = param1;
         this._config = param2;
         this._requestPending = false;
         WeekendSaleHelper.products = null;
         WeekendSaleHelper.freeCard = false;
         WeekendSaleHelper.cards = 0;
         WeekendSaleHelper.model = this;
         var _loc3_:String = Version.value;
         this._api.registerNetCommand(CMD_REFRESH,"" + _loc3_ + "cgi_pasture_refresh_multiple");
         this._api.registerNetCommand(CMD_INIT,"" + _loc3_ + "cgi_pasture_happyweekend_getanimals");
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
         return this.week[_loc1_.day] + _loc1_.hours + "时后可在此购买活动幼仔、刷倍数," + this.week[_loc2_.day] + "-" + this.week[_loc3_.day] + "翻倍卖产物";
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
      
      public function set seeds(param1:Array) : void
      {
         WeekendSaleHelper.products = param1;
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
      
      public function init() : Boolean
      {
         var onSuccess:Function = null;
         onSuccess = function(param1:*):void
         {
            var _loc2_:Object = null;
            var _loc3_:ModelEvent = null;
            if(!param1.hasOwnProperty("errorType"))
            {
               _requestPending = false;
               seeds = param1 as Array;
               for each(_loc2_ in seeds)
               {
                  _loc2_.cId = _loc2_.aId;
               }
               delete seeds["__body"];
               _loc3_ = new ModelEvent(DATA_INITIALIZED);
               _loc3_.data = seeds;
               dispatchEvent(_loc3_);
            }
         };
         if(this._requestPending)
         {
            return false;
         }
         this._requestPending = true;
         this._api.sendRequest(CMD_INIT,null,onSuccess);
         return false;
      }
      
      public function refreshFactor(param1:int) : void
      {
         var params:Object;
         var onSuccess:Function = null;
         var index:int = param1;
         onSuccess = function(param1:*):void
         {
            var _loc2_:int = 0;
            var _loc3_:int = 0;
            var _loc4_:ModelEvent = null;
            _requestPending = false;
            if(!param1.hasOwnProperty("errorType"))
            {
               _loc2_ = param1["cid"] as int;
               _loc3_ = 0;
               if(seeds[1]["cId"] == _loc2_)
               {
                  _loc3_ = 1;
               }
               seeds[_loc3_]["times"] = param1["times"] as int;
               _loc4_ = new ModelEvent(DATA_TIMES);
               _loc4_.data = {
                  "index":_loc3_,
                  "times":param1["times"],
                  "price":seeds[_loc3_]["price"],
                  "cId":_loc2_
               };
               dispatchEvent(_loc4_);
               --WeekendSaleHelper.cards;
               WeekendSaleHelper.cards = Math.max(0,WeekendSaleHelper.cards);
            }
         };
         if(this._requestPending)
         {
            return;
         }
         if(this.seeds == null || this.seeds.length < 2)
         {
            return;
         }
         this._requestPending = true;
         params = new Object();
         params.aid = this.seeds[index]["cId"];
         this._api.sendRequest(CMD_REFRESH,params,onSuccess);
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
         onSuccess = function(param1:*):void
         {
            var _loc3_:* = undefined;
            var _loc4_:ModelEvent = null;
            _requestPending = false;
            var _loc2_:Array = param1 as Array;
            if(_loc2_ == null)
            {
               return;
            }
            WeekendSaleHelper.cards = 0;
            for each(_loc3_ in _loc2_)
            {
               if(_loc3_.type == WeekendSaleHelper.cardType && _loc3_.tId == WeekendSaleHelper.freeDardId && _loc3_.amount > 0)
               {
                  WeekendSaleHelper.freeCard = true;
                  WeekendSaleHelper.cards += _loc3_.amount;
               }
               if(_loc3_.type == WeekendSaleHelper.cardType && _loc3_.tId == WeekendSaleHelper.cardId)
               {
                  WeekendSaleHelper.cards += _loc3_.amount;
               }
            }
            _loc4_ = new ModelEvent(DATA_CARD_LOADED);
            _loc4_.data = {
               "cards":WeekendSaleHelper.cards,
               "free":WeekendSaleHelper.freeCard
            };
            dispatchEvent(_loc4_);
         };
         if(this._requestPending)
         {
            return;
         }
         this._requestPending = true;
         this._fr.postRequest2("cgi_get_package",{"hw":1},onSuccess);
      }
      
      public function get share() : Object
      {
         return this._config["share"];
      }
      
      public function get seeds() : Array
      {
         return WeekendSaleHelper.products;
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

