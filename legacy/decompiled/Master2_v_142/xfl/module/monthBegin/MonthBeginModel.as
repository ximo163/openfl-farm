package module.monthBegin
{
   import common.CommonData;
   import common.INI;
   import common.LocalData;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.external.ExternalInterface;
   import mc.control.Command;
   import mc.model.MainData;
   import mc.view.proxy.GameProxy;
   
   public class MonthBeginModel extends EventDispatcher
   {
      
      private static var intence:MonthBeginModel;
      
      private var _totalPrice:int;
      
      private var _giftList:Array;
      
      private var _itemAry:Array;
      
      public const MaxListNum:int = 18;
      
      private var _gainFlag:int;
      
      private var _postValue:Object;
      
      private var _lastbuytime:int;
      
      public function MonthBeginModel(param1:IEventDispatcher = null)
      {
         super(param1);
      }
      
      public static function gi() : MonthBeginModel
      {
         if(intence == null)
         {
            intence = new MonthBeginModel();
         }
         return intence;
      }
      
      public function get TotalPrice() : int
      {
         return this._totalPrice;
      }
      
      public function set TotalPrice(param1:int) : void
      {
         this._totalPrice = param1;
         var _loc2_:MonthBeginEvent = new MonthBeginEvent(MonthBeginEvent.MONTHBEGIN_PRICE);
         _loc2_.data = param1;
         dispatchEvent(_loc2_);
      }
      
      public function get gainFlag() : int
      {
         return this._gainFlag;
      }
      
      public function isMonthBeginToday(param1:uint) : Boolean
      {
         var _loc2_:Boolean = true;
         var _loc3_:LocalData = LocalData.getInstance();
         var _loc4_:uint = param1;
         if(_loc3_.getObject("monthbegin_" + _loc4_) == null)
         {
            return _loc2_;
         }
         var _loc5_:Date = new Date(CommonData.serverTime * 1000);
         var _loc6_:Date = new Date(int(_loc3_.getObject("monthbegin_" + _loc4_)) * 1000);
         if(_loc5_.getFullYear() == _loc6_.getFullYear())
         {
            if(_loc5_.getMonth() == _loc6_.getMonth())
            {
               if(_loc5_.getDate() == _loc6_.getDate())
               {
                  _loc2_ = false;
               }
            }
         }
         return _loc2_;
      }
      
      private function diyBuyVerifyFn(param1:Object) : void
      {
         var _loc2_:Object = {};
         if(param1.hasOwnProperty("code"))
         {
            _loc2_["code"] = 1;
            _loc2_["postValue"] = this._postValue;
            if(param1.hasOwnProperty("open") && param1["open"] == "1")
            {
               _loc2_["open"] = param1["open"];
            }
         }
         else if(param1.hasOwnProperty("errorType"))
         {
            _loc2_["code"] = 0;
            _loc2_["errorType"] = param1["errorType"];
            _loc2_["direction"] = param1["errorContent"];
         }
         this.returnFn(_loc2_);
      }
      
      public function set gainFlag(param1:int) : void
      {
         this._gainFlag = param1;
         var _loc2_:MonthBeginEvent = new MonthBeginEvent(MonthBeginEvent.MONTHBEGIN_GETGIFT);
         _loc2_.data = param1;
         dispatchEvent(_loc2_);
      }
      
      private function returnFn(param1:Object) : void
      {
         var _loc2_:Object = null;
         if(param1["open"] == "1")
         {
            _loc2_ = new Object();
            _loc2_["payitem"] = 110001 + "-" + 1 + "-购买礼包";
            _loc2_["payType"] = 1;
            MonthBeginServer.gi().sendRequest("cgi_pasture_shop_pay",_loc2_,Command.getInstance().mainCommand.onInGamePreCheckSuccess);
            MainData.inGameBuyType = "MonthBegin";
            MainData.inGameBuyObject["itemType"] = param1["postValue"]["type"];
            return;
         }
         if(param1["errorType"] == "logic" || param1["errorType"] == "system")
         {
            Command.getInstance().mainCommand.alertWindow("error",param1["direction"]);
         }
      }
      
      public function set giftList(param1:Array) : void
      {
         this._giftList = param1;
      }
      
      public function getMonthBeginRefresh(param1:int, param2:Function) : void
      {
         MonthBeginServer.gi().sendRequest("cgi_pasture_month_refresh_1209",{"op":param1},param2);
      }
      
      public function verifyQBRequest() : void
      {
         var _loc1_:String = "";
         _loc1_ = INI.getInstance().data.postUrl.@verifyRequest;
         var _loc2_:int = 1;
         var _loc3_:int = 1;
         var _loc4_:int = 11;
         this._postValue = {};
         this._postValue["payitem"] = _loc4_ * 10000 + _loc2_ + "-" + _loc3_ + "-购买礼包";
         MonthBeginServer.gi().sendRequest(_loc1_,this._postValue,this.diyBuyVerifyFn);
      }
      
      public function isGiftTime() : Boolean
      {
         var _iniData:Object = null;
         var t1:String = null;
         var t2:String = null;
         var startTime:Number = NaN;
         var endTime:Number = NaN;
         var now:Number = NaN;
         _iniData = GameProxy.iniData;
         t1 = _iniData.submodule.module.(@name == "monthbegin").@start;
         t2 = _iniData.submodule.module.(@name == "monthbegin").@end;
         startTime = new Date(t1).time;
         endTime = new Date(t2).time;
         now = CommonData.serverTime * 1000;
         if(startTime < now && now < endTime)
         {
            return true;
         }
         return false;
      }
      
      public function shareHandler(param1:String, param2:String, param3:String, param4:String, param5:String) : void
      {
         var _loc6_:String = "cgi_qzshare_onekey";
         _loc6_ = _loc6_ + ("url=" + encodeURIComponent(param1));
         _loc6_ = _loc6_ + ("&desc=" + encodeURIComponent(""));
         _loc6_ = _loc6_ + ("&summary=" + encodeURIComponent(param2));
         _loc6_ = _loc6_ + ("&title=" + encodeURIComponent(param3));
         _loc6_ = _loc6_ + ("&site=" + encodeURIComponent(param4));
         _loc6_ = _loc6_ + ("&pics=" + encodeURIComponent(param5));
         ExternalInterface.call("window.open",_loc6_);
      }
      
      public function get giftList() : Array
      {
         return this._giftList;
      }
      
      public function set ItemAry(param1:Array) : void
      {
         this._itemAry = param1;
         var _loc2_:MonthBeginEvent = new MonthBeginEvent(MonthBeginEvent.MONTHBEGIN_LIST);
         _loc2_.data = this._itemAry;
         dispatchEvent(_loc2_);
      }
      
      public function get ItemAry() : Array
      {
         return this._itemAry;
      }
      
      public function getMonthBeginGetGift(param1:Function) : void
      {
         MonthBeginServer.gi().sendRequest("cgi_pasture_month_get",null,param1);
      }
      
      public function set LastBuyTime(param1:int) : void
      {
         this._lastbuytime = param1;
         var _loc2_:MonthBeginEvent = new MonthBeginEvent(MonthBeginEvent.MONTHBEGIN_LASTBUYTIME);
         _loc2_.data = param1;
         dispatchEvent(_loc2_);
      }
      
      public function getMonthBeginList(param1:Function) : void
      {
         MonthBeginServer.gi().sendRequest("cgi_pasture_month_list_1209",null,param1);
      }
      
      public function get LastBuyTime() : int
      {
         return this._lastbuytime;
      }
   }
}

