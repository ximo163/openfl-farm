package mc.view.farm.Research
{
   import common.INI;
   import common.LocalData;
   import mc.FBridge.EventRecorder;
   import mc.FBridge.FRequest;
   import mc.control.Command;
   import mc.model.MainData;
   import mc.view.main.WindowControl.WControl;
   
   public class ResearchController
   {
      
      private var _postValue:Object;
      
      public function ResearchController()
      {
         super();
      }
      
      public function verifyQBRequest(param1:int = 358) : void
      {
         var _loc3_:int = 0;
         var _loc2_:String = "";
         _loc2_ = INI.getInstance().data.postUrl.@verifyRequest;
         if(LocalData.reclaimType == 3 || LocalData.reclaimType == 1)
         {
            _loc3_ = 15;
         }
         else if(LocalData.reclaimType == 4 || LocalData.reclaimType == 2)
         {
            _loc3_ = 16;
         }
         this._postValue = {};
         this._postValue["payitem"] = _loc3_ * 10000 + 1 + "-" + 1 + "-租用槽位";
         FRequest.getInstance().postRequest2(_loc2_,this._postValue,this.diyBuyVerifyFn);
      }
      
      public function openFirstWindow() : void
      {
         var _loc1_:ResearchFirstOpen = new ResearchFirstOpen();
         WControl.open(_loc1_);
      }
      
      private function returnFn(param1:Object) : void
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         if(param1["open"] == "1")
         {
            _loc2_ = new Object();
            if(LocalData.reclaimType == 3 || LocalData.reclaimType == 1)
            {
               _loc3_ = 15;
            }
            else if(LocalData.reclaimType == 4 || LocalData.reclaimType == 2)
            {
               _loc3_ = 16;
            }
            _loc2_["payitem"] = _loc3_ * 10000 + 1 + "-" + 1 + "-租用槽位";
            _loc2_["payType"] = 1;
            FRequest.getInstance().postRequest2("cgi_pasture_shop_pay",_loc2_,Command.getInstance().mainCommand.onInGamePreCheckSuccess);
            MainData.inGameBuyType = "UpdateHireSlot";
            MainData.inGameBuyObject["itemType"] = param1["postValue"]["type"];
            return;
         }
         if(param1["errorType"] == "logic" || param1["errorType"] == "system")
         {
            Command.getInstance().mainCommand.alertWindow("error",param1["direction"]);
         }
      }
      
      private function diyBuyVerifyFn(param1:Object) : void
      {
         var _loc2_:Object = {};
         if(param1.hasOwnProperty("code"))
         {
            EventRecorder.recordSueecssEvent("160953",0);
            _loc2_["code"] = 1;
            _loc2_["postValue"] = this._postValue;
            if(param1.hasOwnProperty("open") && param1["open"] == "1")
            {
               _loc2_["open"] = param1["open"];
            }
         }
         else if(param1.hasOwnProperty("errorType"))
         {
            EventRecorder.recordErrorEvent("160953",0,14);
            _loc2_["code"] = 0;
            _loc2_["errorType"] = param1["errorType"];
            _loc2_["direction"] = param1["errorContent"];
         }
         this.returnFn(_loc2_);
      }
      
      public function shouComplete(param1:Array) : void
      {
         ResearchModel.gi().shouComplete(param1);
      }
   }
}

