package com.qzone.sns
{
   import com.qzone.farm.api.interfaces.IFarmAPI;
   import com.qzone.sns.entities.Payment;
   import common.misc.QzoneJSAPI;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   import framework.net.CommandDefs;
   
   public final class QQPay
   {
      
      private static var _instance:QQPay;
      
      public static const PAY_STEP_PRECHECK:uint = 0;
      
      public static const PAY_STEP_PAY:uint = 1;
      
      private var _bills:Dictionary;
      
      private var _api:IFarmAPI;
      
      public function QQPay()
      {
         super();
         this._bills = new Dictionary();
      }
      
      public static function getInstance() : QQPay
      {
         if(_instance != null)
         {
            return _instance;
         }
         _instance = new QQPay();
         return _instance;
      }
      
      public function set app(param1:IFarmAPI) : void
      {
         this._api = param1;
      }
      
      private function conflictProtect(param1:int, param2:int) : Boolean
      {
         var _loc5_:String = null;
         var _loc3_:Payment = null;
         var _loc4_:int = getTimer();
         for(_loc5_ in this._bills)
         {
            _loc3_ = this._bills[_loc5_] as Payment;
            if(_loc3_.id == param1 && _loc3_.type == param2 && _loc3_.bill > 0)
            {
               if(_loc4_ - _loc3_._stamp < 3000)
               {
                  return false;
               }
            }
         }
         return true;
      }
      
      private function onPreCheckedError(param1:int, param2:*) : void
      {
         this._api.alert(2,"支付失败",param2["direction"],0,0,null);
         var _loc3_:Payment = this.getPayment(param2);
         _loc3_.notify(PAY_STEP_PRECHECK,false,param2);
         this.cleanPayment(_loc3_);
      }
      
      private function onPayFailed(param1:int, param2:*) : void
      {
         var _loc3_:Payment = this.getPayment(param2);
         if(param2["direction"] != undefined && param2["direction"] != "")
         {
            this._api.alert(2,"支付失败",param2["direction"],0,0,null);
         }
         if(_loc3_ != null)
         {
            _loc3_.notify(PAY_STEP_PAY,false,param2);
            this.cleanPayment(_loc3_);
         }
      }
      
      private function getPayment(param1:*) : Payment
      {
         if(param1 == null || param1["__body"] == undefined)
         {
            return null;
         }
         var _loc2_:int = param1["__body"]["clientBill"] as int;
         if(_loc2_ == 0 || this._bills[_loc2_] == null || this._bills[_loc2_] == undefined)
         {
            trace("Error> Payment bill dose not exist.");
            return null;
         }
         var _loc3_:Payment = this._bills[_loc2_] as Payment;
         if(_loc3_.bill == 0)
         {
            return null;
         }
         return _loc3_;
      }
      
      public function payByPlatform(param1:int, param2:int, param3:int, param4:int, param5:Function) : Boolean
      {
         if(this.conflictProtect(param1,param2) == false)
         {
            return false;
         }
         var _loc6_:Payment = new Payment(param1,param2,param3,param4);
         _loc6_.callback = param5;
         this._bills[_loc6_.bill] = _loc6_;
         this._api.sendRequest(CommandDefs.CMD_BUY_PRECHECK,_loc6_.buildCheckParams(),this.onPreCheckSuccess,this.onPreCheckedError);
         return true;
      }
      
      private function onPaySuccess(param1:int, param2:*) : void
      {
         var pay:Payment = null;
         var onPaySuccessCallback:Function = null;
         var cmd:int = param1;
         var data:* = param2;
         onPaySuccessCallback = function(param1:Object):void
         {
            if(pay != null)
            {
               pay.notify(PAY_STEP_PAY,true,data);
               cleanPayment(pay);
            }
         };
         pay = this.getPayment(data);
         if(data["code"] == 1)
         {
            QzoneJSAPI.getInGamePay(data["url_params"],onPaySuccessCallback);
         }
         else
         {
            this.onPayFailed(cmd,data);
         }
      }
      
      private function cleanPayment(param1:Payment) : void
      {
         if(param1 == null)
         {
            return;
         }
         delete this._bills[param1.bill];
         param1.bill = 0;
         param1 = null;
      }
      
      private function onPreCheckSuccess(param1:int, param2:*) : void
      {
         var _loc3_:Payment = null;
         var _loc4_:Object = null;
         if(param2["code"] == 1)
         {
            _loc3_ = this.getPayment(param2);
            _loc4_ = _loc3_.buildCheckParams();
            _loc4_["payType"] = 1;
            this._api.sendRequest(CommandDefs.CMD_BUY_INGAME_BUY,_loc4_,this.onPaySuccess,this.onPayFailed);
            _loc3_.notify(PAY_STEP_PRECHECK,true,param2);
            _loc3_.misc = param2;
         }
         else
         {
            this.onPreCheckedError(param1,param2);
         }
      }
   }
}

