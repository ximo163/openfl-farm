package mc.control
{
   import common.INI;
   import mc.FBridge.EventRecorder;
   import mc.FBridge.FRequest;
   import mc.model.MainData;
   import mc.view.common.ConfirmWindow;
   
   public class LimitSaleCommand
   {
      
      private static var cmd:LimitSaleCommand;
      
      private var postValue:Object;
      
      private var confirmWin:ConfirmWindow;
      
      public function LimitSaleCommand()
      {
         super();
      }
      
      public static function getCommand() : LimitSaleCommand
      {
         if(!cmd)
         {
            cmd = new LimitSaleCommand();
         }
         return cmd;
      }
      
      public function verifyPrice(param1:String, param2:String) : void
      {
         this.postValue = {
            "payitem":param1,
            "payType":param2
         };
         this.verify();
      }
      
      private function verify() : void
      {
         var _loc1_:String = "";
         _loc1_ = INI.getInstance().data.postUrl.@verifyRequest;
         FRequest.getInstance().postRequest(_loc1_,this.postValue,this.diyBuyVerifyFn);
      }
      
      private function diyBuyVerifyFn(param1:Object) : void
      {
         var _loc2_:Object = {};
         if(param1.hasOwnProperty("code"))
         {
            EventRecorder.recordSueecssEvent("160941",0);
            _loc2_["code"] = 1;
            _loc2_["postValue"] = this.postValue;
            if(param1.hasOwnProperty("open") && param1["open"] == "1")
            {
               _loc2_["open"] = param1["open"];
            }
         }
         else if(param1.hasOwnProperty("errorType"))
         {
            EventRecorder.recordErrorEvent("160941",0,14);
            _loc2_["code"] = 0;
            _loc2_["errorType"] = param1["errorType"];
            _loc2_["direction"] = param1["errorContent"];
         }
         this.returnFn(_loc2_);
      }
      
      private function returnFn(param1:Object) : void
      {
         if(param1["open"] == "1")
         {
            FRequest.getInstance().postRequest2("cgi_pasture_shop_pay",this.postValue,Command.getInstance().mainCommand.onInGamePreCheckSuccess);
            MainData.inGameBuyType = "LimitSales";
            return;
         }
         if(param1["errorType"] == "logic" || param1["errorType"] == "system")
         {
            Command.getInstance().mainCommand.alertWindow("error",param1["direction"]);
         }
      }
   }
}

