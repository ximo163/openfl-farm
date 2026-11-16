package mc.view.main.leftInfo.FebruaryGift
{
   import common.INI;
   import mc.FBridge.EventRecorder;
   import mc.FBridge.FRequest;
   import mc.control.Command;
   import mc.model.MainData;
   import mc.view.main.WindowControl.WControl;
   
   public class FebruaryGiftControl
   {
      
      private var _postValue:Object;
      
      public function FebruaryGiftControl()
      {
         super();
      }
      
      public function verifyQBRequest(param1:int = 358) : void
      {
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc2_:String = "";
         _loc2_ = INI.getInstance().data.postUrl.@verifyRequest;
         if(FebruaryGiftModel.gi().isBuy9)
         {
            _loc3_ = 19;
            _loc4_ = "龙之九子礼包";
         }
         else
         {
            _loc3_ = 20;
            _loc4_ = "飞行动物礼包";
         }
         this._postValue = {};
         this._postValue["payitem"] = 10 * 10000 + _loc3_ + "-" + 1 + "-" + _loc4_;
         FRequest.getInstance().postRequest2(_loc2_,this._postValue,this.diyBuyVerifyFn);
      }
      
      public function openWindow1() : void
      {
         var _loc1_:FebruaryGiftWindow1 = new FebruaryGiftWindow1();
         WControl.open(_loc1_);
      }
      
      public function openWindow2() : void
      {
         var _loc1_:FebruaryGiftWindow2 = new FebruaryGiftWindow2();
         WControl.open(_loc1_);
      }
      
      private function diyBuyVerifyFn(param1:Object) : void
      {
         var _loc2_:Object = {};
         if(param1.hasOwnProperty("code"))
         {
            EventRecorder.recordSueecssEvent("160957",0);
            _loc2_["code"] = 1;
            _loc2_["postValue"] = this._postValue;
            if(param1.hasOwnProperty("open") && param1["open"] == "1")
            {
               _loc2_["open"] = param1["open"];
            }
         }
         else if(param1.hasOwnProperty("errorType"))
         {
            EventRecorder.recordErrorEvent("160957",0,14);
            _loc2_["code"] = 0;
            _loc2_["errorType"] = param1["errorType"];
            _loc2_["direction"] = param1["errorContent"];
         }
         this.returnFn(_loc2_);
      }
      
      private function returnFn(param1:Object) : void
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         var _loc4_:String = null;
         if(param1["open"] == "1")
         {
            _loc2_ = new Object();
            if(FebruaryGiftModel.gi().isBuy9)
            {
               _loc3_ = 19;
               _loc4_ = "龙之九子礼包";
            }
            else
            {
               _loc3_ = 20;
               _loc4_ = "飞行动物礼包";
            }
            _loc2_["payitem"] = 10 * 10000 + _loc3_ + "-" + 1 + "-" + _loc4_;
            _loc2_["payType"] = 1;
            FRequest.getInstance().postRequest2("cgi_pasture_shop_pay",_loc2_,Command.getInstance().mainCommand.onInGamePreCheckSuccess);
            MainData.inGameBuyType = "buyFebruaryGift";
            MainData.inGameBuyObject["itemType"] = param1["postValue"]["type"];
            return;
         }
         if(param1["errorType"] == "logic" || param1["errorType"] == "system")
         {
            Command.getInstance().mainCommand.alertWindow("error",param1["direction"]);
         }
      }
   }
}

