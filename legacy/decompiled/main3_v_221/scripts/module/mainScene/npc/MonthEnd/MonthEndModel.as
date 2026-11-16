package module.mainScene.npc.MonthEnd
{
   import com.qzone.qfa.events.CommandEvent;
   import common.misc.QzoneJSAPI;
   import events.CommonEvent;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.external.ExternalInterface;
   import framework.net.CommandDefs;
   import framework.net.NetHelper;
   import report.EventRecorder;
   
   public class MonthEndModel extends EventDispatcher
   {
      
      public static const MONTHEND_LIST:String = "monthend_list";
      
      public static const MONTHEND_GETGIFT:String = "monthend_getgift";
      
      public static const MONTHEND_PRICE:String = "monthend_price";
      
      public static const MONTHEND_LASTBUYTIME:String = "monthend_lastbuytime";
      
      public static const MONTHEND_REFRESHTOTALMONEY:String = "MONTHEND_REFRESHTOTALMONEY";
      
      public static const EVENT_BUY_GIFT_SUCCESS:String = "eventbuygiftsuccess";
      
      public static const EVENT_BUY_MONTHEND_FAIL:String = "eventbuygiftfail";
      
      private var _totalPrice:int;
      
      private var _refreshTotalMoney:int;
      
      private var _itemAry:Array;
      
      public const MaxListNum:int = 18;
      
      private var _gainFlag:int;
      
      private var _lastbuytime:int;
      
      public function MonthEndModel(param1:IEventDispatcher = null)
      {
         super(param1);
      }
      
      public function payCheck(param1:Function, param2:Function) : void
      {
         var _loc3_:int = 1;
         var _loc4_:int = 1;
         var _loc5_:int = 15;
         var _loc6_:int = 15;
         NetHelper.sendRequest(CommandDefs.CMD_BUY_PRECHECK,{
            "shopType":_loc5_,
            "itemType":_loc6_,
            "itemId":_loc3_,
            "itemNum":_loc4_
         },param1,param2);
      }
      
      private function onInGameBuySuccess(param1:Object) : void
      {
         var _loc2_:Object = new Object();
         dispatchEvent(new CommonEvent(EVENT_BUY_GIFT_SUCCESS,null));
      }
      
      public function get TotalPrice() : int
      {
         return this._totalPrice;
      }
      
      private function onTransactionError(param1:CommandEvent) : void
      {
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:int = int(param1.body["cmdID"]);
         var _loc4_:Object = {};
         EventRecorder.recordErrorEvent("160890",null,4);
      }
      
      public function set TotalPrice(param1:int) : void
      {
         this._totalPrice = param1;
         dispatchEvent(new CommonEvent(MONTHEND_PRICE,param1));
      }
      
      public function get gainFlag() : int
      {
         return this._gainFlag;
      }
      
      public function getMonthEndGetGift(param1:Function, param2:Function) : void
      {
         NetHelper.sendRequest(CommandDefs.CMD_MONTHEND_GET_GIFT,null,param1,param2);
      }
      
      public function set gainFlag(param1:int) : void
      {
         this._gainFlag = param1;
         dispatchEvent(new CommonEvent(MONTHEND_GETGIFT,param1));
      }
      
      private function onInGamePreCheckSuccess(param1:CommandEvent) : void
      {
         var _loc3_:Object = null;
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_["code"] == 1)
         {
            QzoneJSAPI.getInGamePay(_loc2_["url_params"],this.onInGameBuySuccess);
         }
         else
         {
            _loc3_ = new Object();
            _loc3_["direction"] = _loc2_["direction"];
            dispatchEvent(new CommonEvent(EVENT_BUY_MONTHEND_FAIL,_loc3_));
         }
         EventRecorder.recordSueecssEvent("160890",null);
      }
      
      public function buyInGame(param1:Object, param2:int) : void
      {
         var _loc3_:int = 1;
         var _loc4_:int = 1;
         var _loc5_:int = 15;
         var _loc6_:int = 15;
         param1 = {
            "shopType":_loc5_,
            "itemType":_loc6_,
            "itemId":_loc3_,
            "itemNum":_loc4_
         };
         param1["payType"] = param2;
         NetHelper.sendRequest(CommandDefs.CMD_BUY_INGAME_BUY,param1,this.onInGamePreCheckSuccess,this.onTransactionError);
      }
      
      public function set ItemAry(param1:Array) : void
      {
         this._itemAry = param1;
         dispatchEvent(new CommonEvent(MONTHEND_LIST,this._itemAry));
      }
      
      public function shareHandler(param1:String, param2:String, param3:String, param4:String, param5:String) : void
      {
         var _loc6_:String = "mod=cgi_qzshare_onekey";
         _loc6_ = _loc6_ + ("url=" + encodeURIComponent(param1));
         _loc6_ = _loc6_ + ("&desc=" + encodeURIComponent(""));
         _loc6_ = _loc6_ + ("&summary=" + encodeURIComponent(param2));
         _loc6_ = _loc6_ + ("&title=" + encodeURIComponent(param3));
         _loc6_ = _loc6_ + ("&site=" + encodeURIComponent(param4));
         _loc6_ = _loc6_ + ("&pics=" + encodeURIComponent(param5));
         ExternalInterface.call("window.open",_loc6_);
      }
      
      public function set RefreshTotalMoney(param1:int) : void
      {
         this._refreshTotalMoney = param1;
         dispatchEvent(new CommonEvent(MONTHEND_REFRESHTOTALMONEY,param1));
      }
      
      public function getMonthEndList(param1:Function, param2:Function) : void
      {
         NetHelper.sendRequest(CommandDefs.CMD_MONTHEND_LIST,null,param1,param2);
      }
      
      public function get ItemAry() : Array
      {
         return this._itemAry;
      }
      
      public function get RefreshTotalMoney() : int
      {
         return this._refreshTotalMoney;
      }
      
      public function getMonthEndRefresh(param1:int, param2:Function, param3:Function) : void
      {
         NetHelper.sendRequest(CommandDefs.CMD_MONTHEND_REFRESH,{"op":param1},param2,param3);
      }
      
      public function set LastBuyTime(param1:int) : void
      {
         this._lastbuytime = param1;
         dispatchEvent(new CommonEvent(MONTHEND_LASTBUYTIME,param1));
      }
      
      public function get LastBuyTime() : int
      {
         return this._lastbuytime;
      }
   }
}

