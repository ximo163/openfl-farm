package mc.control
{
   import com.adobe.utils.StringUtil;
   import com.qzone.corelib.js.JSProxy;
   import common.INI;
   import common.LocalData;
   import mc.FBridge.EventRecorder;
   import mc.FBridge.FRequest;
   import mc.events.WindowEvent;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.common.BaseWindow;
   
   public class DiyItemCommand
   {
      
      private var _targetWindow:BaseWindow;
      
      private var mainData:MainData;
      
      private var fr:FRequest;
      
      private var _postValue:Object = {};
      
      private var _preBuyDiyType:int;
      
      private var _pending:Boolean;
      
      public function DiyItemCommand()
      {
         super();
         this.fr = FRequest.getInstance();
         this._pending = false;
         this._preBuyDiyType = 0;
         this._targetWindow = null;
         this.mainData = MData.getInstance().mainData;
      }
      
      public function verifyQBRequest(param1:int, param2:int, param3:Boolean = false, param4:String = "", param5:int = 0, param6:BaseWindow = null, param7:int = 0, param8:int = 1) : void
      {
         var _loc9_:String = "";
         _loc9_ = INI.getInstance().data.postUrl.@verifyRequest;
         this._postValue = null;
         this._postValue = {
            "itemID":param1,
            "type":param2,
            "userFB":param3,
            "diyName":param4,
            "FBPrice":param5,
            "win":param6,
            "exp":param7,
            "number":param8
         };
         var _loc10_:Object = {};
         _loc10_["payitem"] = param2 * 10000 + param1 + "-" + param8 + "-" + param4;
         this.fr.postRequest(_loc9_,_loc10_,this.diyBuyVerifyFn);
      }
      
      private function diyBuyVerifyFn(param1:Object) : void
      {
         if(param1.hasOwnProperty("errorType"))
         {
            EventRecorder.recordErrorEvent("160893",0,14);
         }
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
         EventRecorder.recordSueecssEvent("160893",0);
      }
      
      private function buyDiy(param1:int, param2:int, param3:Boolean = false, param4:String = "", param5:int = 0, param6:BaseWindow = null, param7:int = 0, param8:int = 1) : void
      {
         this._preBuyDiyType = param2;
         var _loc9_:String = "";
         _loc9_ = INI.getInstance().data.postUrl.@fbRequest;
         var _loc10_:Object = {};
         _loc10_["app_key"] = "QQMCZZ";
         _loc10_["payitem"] = param2 * 10000 + param1 + "-" + param8 + "-" + param4;
         _loc10_["payvalue"] = 10 * param5 * param8;
         _loc10_["paytype"] = 0;
         _loc10_["accttype"] = 4;
         _loc10_["dnatime"] = 0;
         _loc10_["payinfo"] = param4;
         _loc10_["dnakey"] = 0;
         _loc10_["format"] = "JSON";
         _loc10_["itemId"] = param1;
         _loc10_["exp"] = param7;
         this.fr.postRequest(_loc9_,_loc10_,this.qqBuyDiyFn);
         this._targetWindow = param6;
      }
      
      private function returnFn(param1:Object) : void
      {
         var _loc2_:Object = null;
         if(param1["open"] == "1")
         {
            _loc2_ = new Object();
            _loc2_["payitem"] = int(param1["postValue"]["type"]) * 10000 + int(param1["postValue"]["itemID"]) + "-" + param1["postValue"]["number"] + "-" + param1["postValue"]["diyName"];
            _loc2_["payType"] = 1;
            this.fr.postRequest("cgi_pasture_shop_pay",_loc2_,Command.getInstance().mainCommand.onInGamePreCheckSuccess);
            MainData.inGameBuyType = "DIY";
            MainData.inGameBuyObject["itemID"] = param1["postValue"]["itemID"];
            MainData.inGameBuyObject["exp"] = param1["postValue"]["exp"];
            return;
         }
         if(param1["code"] == 1)
         {
            this.buyDiy(param1["postValue"]["itemID"],param1["postValue"]["type"],param1["postValue"]["userFB"],param1["postValue"]["diyName"],param1["postValue"]["FBPrice"],param1["postValue"]["win"],param1["postValue"]["exp"],param1["postValue"]["number"]);
         }
         else if(param1["errorType"] == "logic" || param1["errorType"] == "system")
         {
            this.alertWindow("error",param1["direction"]);
         }
      }
      
      public function forDNA(param1:String, param2:String) : void
      {
         var _loc3_:* = LocalData.lastRequestValue;
         if(_loc3_)
         {
            LocalData.lastRequestValue["dnakey"] = param1;
            LocalData.lastRequestValue["dnatime"] = param2;
         }
         else
         {
            LocalData.lastRequestValue = {
               "dnakey":param1,
               "dnatime":param2
            };
         }
         LocalData.lastRequestFn(LocalData.lastRequestUrl,LocalData.lastRequestValue,LocalData.lastRequestHandle);
      }
      
      private function qqBuyDiyFn(param1:Object) : void
      {
         var _loc3_:Object = null;
         if(param1.hasOwnProperty("160900"))
         {
            EventRecorder.recordErrorEvent("160900",0,14);
         }
         EventRecorder.recordSueecssEvent("160900",0);
         var _loc2_:Object = {};
         if(param1["code"] == 0)
         {
            _loc2_["code"] = 1;
            _loc2_["direction"] = "购买成功";
            _loc2_["type"] = this._preBuyDiyType;
            this.addExp({"addExp":param1["post_data"]["exp"]});
            if(this.mainData.me)
            {
               _loc3_ = this.mainData.items;
               _loc3_["1"]["id"] = param1.post_data["itemId"];
               this.mainData.items = _loc3_;
               this.mainData.reloadUserItems = true;
            }
         }
         else
         {
            _loc2_["code"] = param1["code"];
            _loc2_["direction"] = param1["msg"];
            _loc2_["dnaurl"] = param1["dnaurl"];
         }
         this.buyDiyFn(_loc2_);
      }
      
      private function alertWindow(param1:String, param2:String, param3:String = null) : void
      {
         var _loc4_:WindowEvent = null;
         var _loc5_:Object = null;
         if(StringUtil.trim(param2) != "")
         {
            _loc4_ = new WindowEvent(WindowEvent.OPEN);
            _loc4_.windowName = "AlertWindow";
            _loc5_ = null;
            if(param3 != null && param3.length > 0)
            {
               _loc5_ = {
                  "type":param1,
                  "text":param2,
                  "url":param3
               };
            }
            else
            {
               _loc5_ = {
                  "type":param1,
                  "text":param2
               };
            }
            _loc4_.windowArgument = _loc5_;
            ViewControl.getInstance().dispatchEvent(_loc4_);
         }
      }
      
      public function addExp(param1:Object) : void
      {
         if(param1.hasOwnProperty("addExp") && param1["addExp"] != 0)
         {
            this.mainData.host["exp"] = int(this.mainData.host["exp"]) + int(param1["addExp"]);
            this.mainData.addExp = param1["addExp"];
         }
      }
      
      public function buyDiyFn(param1:Object) : void
      {
         var _loc4_:String = null;
         var _loc2_:String = null;
         var _loc3_:Boolean = false;
         if(param1["code"] == 1)
         {
            MData.getInstance().farmData.reloadUserSeed = true;
            param1.money = -param1.money;
            Command.getInstance().mainCommand.addMoney(param1);
            if(param1.hasOwnProperty("direction") && StringUtil.trim(param1["direction"]) != "")
            {
               _loc2_ = param1["direction"];
            }
            else
            {
               _loc2_ = "购买成功";
            }
            if(LocalData.parameters["tinBuySuccessText"] != undefined)
            {
               _loc3_ = LocalData.parameters["tinBuySuccessUrl"] != undefined;
               _loc2_ += "<br>";
               if(_loc3_)
               {
                  _loc2_ += "<a href=\'event:success\'><u>";
               }
               _loc2_ += LocalData.parameters["tinBuySuccessText"];
               if(_loc3_)
               {
                  _loc2_ += "</u></a>";
               }
            }
            this.alertWindow("success",_loc2_,LocalData.parameters["tinBuySuccessUrl"]);
            this.closeBuyWindow();
            EventRecorder.recordSueecssEvent("160933",0);
         }
         else
         {
            if(param1["code"] == 100)
            {
               JSProxy.showDNA(param1["dnaurl"],this.forDNA);
               return;
            }
            if(param1["code"] == 50)
            {
               _loc2_ = "余额不足";
               if(LocalData.parameters["tinBuyQDText"] != undefined)
               {
                  _loc3_ = LocalData.parameters["tinBuyQDUrl"] != undefined;
                  _loc2_ += "<br>";
                  if(_loc3_)
                  {
                     _loc2_ += "<a href=\'event:addMoney\'><u>";
                  }
                  _loc2_ += LocalData.parameters["tinBuyQDText"];
                  if(_loc3_)
                  {
                     _loc2_ += "</u></a>";
                  }
               }
               this.alertWindow("error",_loc2_,LocalData.parameters["tinBuyQDUrl"]);
               EventRecorder.recordErrorEvent("160933",0,14);
               return;
            }
            if(param1["direction"] != undefined && StringUtil.trim(param1["direction"]) != "")
            {
               this.alertWindow("error",param1["direction"]);
               EventRecorder.recordErrorEvent("160933",0,14);
               return;
            }
         }
         if(param1.hasOwnProperty("errorType"))
         {
            _loc4_ = param1["errorType"];
            if(_loc4_ == "IOError" || _loc4_ == "httpStatus" || _loc4_ == "timeOut")
            {
               this.alertWindow("error","请求超时，稍后再试");
               EventRecorder.recordErrorEvent("160933",0,14);
            }
         }
      }
      
      private function closeBuyWindow() : void
      {
         if(this._targetWindow == null)
         {
            return;
         }
         var _loc1_:WindowEvent = new WindowEvent(WindowEvent.CLOSE);
         _loc1_.window = this._targetWindow;
         ViewControl.getInstance().dispatchEvent(_loc1_);
         this._targetWindow = null;
      }
   }
}

