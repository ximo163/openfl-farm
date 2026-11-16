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
   import mc.model.TinItemsData;
   import mc.view.common.BaseWindow;
   
   public final class TinItemCommand
   {
      
      private var m_pending:Boolean;
      
      private var m_preBuyToolType:int;
      
      private var fr:FRequest;
      
      private var m_mainData:MainData;
      
      private var m_tinsData:TinItemsData;
      
      private var m_targetWinddow:BaseWindow;
      
      private var _postValue:Object = {};
      
      public function TinItemCommand()
      {
         super();
         this.fr = FRequest.getInstance();
         this.m_tinsData = MData.getInstance().tinData;
         this.m_mainData = MData.getInstance().mainData;
         this.m_pending = false;
         this.m_preBuyToolType = 0;
         this.m_targetWinddow = null;
      }
      
      public function getTinsInfo() : void
      {
         if(this.m_pending == true)
         {
            return;
         }
         var _loc1_:MainData = MData.getInstance().mainData;
         this.fr.postRequest2("cgi_get_toollist",{
            "ystatus":_loc1_.host["yellowstatus"],
            "ylv":_loc1_.host["yellowlevel"],
            "plv":_loc1_.expToGrade(_loc1_.host["exp"])
         },this.getTinsInfoFn);
         this.m_pending = true;
         this.m_tinsData.loadingData = true;
      }
      
      private function diyBuyVerifyFn(param1:Object) : void
      {
         var _loc2_:Object = {};
         if(param1.hasOwnProperty("code"))
         {
            EventRecorder.recordSueecssEvent("160944",0);
            _loc2_["code"] = 1;
            _loc2_["postValue"] = this._postValue;
            if(param1.hasOwnProperty("open") && param1["open"] == "1")
            {
               _loc2_["open"] = param1["open"];
            }
         }
         else if(param1.hasOwnProperty("errorType"))
         {
            EventRecorder.recordErrorEvent("160944",0,14);
            _loc2_["code"] = 0;
            _loc2_["errorType"] = param1["errorType"];
            _loc2_["direction"] = param1["errorContent"];
         }
         this.returnFn(_loc2_);
      }
      
      public function buyToolFn2(param1:Object) : void
      {
         var _loc2_:Object = null;
         if(Command.getInstance().mainCommand.checkErrorReturn(param1))
         {
            return;
         }
         if(param1["ecode"] == 0)
         {
            EventRecorder.recordSueecssEvent("160945",0);
            this.alertWindow("success","购买成功！");
            Command.getInstance().mainCommand.addMoney(param1);
            _loc2_ = param1["post_data"];
            if(Boolean(_loc2_["type"]) && _loc2_["type"] == 106)
            {
               MData.getInstance().mainData.hunter = {
                  "id":param1["id"],
                  "name":param1["name"],
                  "t":param1["striketime"],
                  "used":1
               };
            }
            MData.getInstance().farmData.reloadUserSeed = true;
            MData.getInstance().mainData.reloadUserMaterial = true;
            this.getTinsInfo();
         }
         else
         {
            EventRecorder.recordErrorEvent("160945",0,14);
            Command.getInstance().mainCommand.floatWindow(param1["direction"],"Exclamation");
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
      
      private function returnFn(param1:Object) : void
      {
         var _loc2_:Object = null;
         if(param1["open"] == "1")
         {
            _loc2_ = new Object();
            if(int(param1["postValue"]["appid"]) != 353)
            {
               _loc2_["payitem"] = int(param1["postValue"]["type"]) * 10000 + int(param1["postValue"]["itemID"]) + "-" + param1["postValue"]["number"] + "-" + param1["postValue"]["itemName"];
               _loc2_["payType"] = 1;
               this.fr.postRequest("cgi_pasture_shop_pay",_loc2_,Command.getInstance().mainCommand.onInGamePreCheckSuccess);
            }
            else
            {
               _loc2_["shopType"] = 10;
               _loc2_["itemType"] = param1["postValue"]["type"];
               _loc2_["itemId"] = param1["postValue"]["itemID"];
               _loc2_["itemNum"] = param1["postValue"]["number"];
               _loc2_["payType"] = 1;
               this.fr.postRequest("cgi_farm_shop_pay",_loc2_,Command.getInstance().mainCommand.onInGamePreCheckSuccess);
            }
            MainData.inGameBuyType = "Item";
            MainData.inGameBuyObject["itemType"] = param1["postValue"]["type"];
            return;
         }
         if(param1["code"] == 1)
         {
            this.buyTool(param1["postValue"]["itemID"],param1["postValue"]["number"],param1["postValue"]["type"],param1["postValue"]["userFB"],param1["postValue"]["itemName"],param1["postValue"]["FBPrice"],param1["postValue"]["win"]);
         }
         else if(param1["errorType"] == "logic" || param1["errorType"] == "system")
         {
            this.alertWindow("error",param1["direction"]);
         }
      }
      
      private function closeBuyWindow() : void
      {
         if(this.m_targetWinddow == null)
         {
            return;
         }
         var _loc1_:WindowEvent = new WindowEvent(WindowEvent.CLOSE);
         _loc1_.window = this.m_targetWinddow;
         ViewControl.getInstance().dispatchEvent(_loc1_);
         this.m_targetWinddow = null;
      }
      
      public function verifyQBRequest(param1:int, param2:int, param3:Boolean = false, param4:String = "", param5:int = 0, param6:BaseWindow = null, param7:int = 1, param8:int = 358) : void
      {
         var _loc9_:String = "";
         _loc9_ = INI.getInstance().data.postUrl.@verifyRequest;
         this._postValue = null;
         this._postValue = {
            "itemID":param1,
            "type":param2,
            "userFB":param3,
            "itemName":param4,
            "FBPrice":param5,
            "win":param6,
            "number":param7,
            "appid":param8
         };
         var _loc10_:Object = {};
         if(param8 != 353)
         {
            _loc10_["payitem"] = param2 * 10000 + param1 + "-" + param7 + "-" + param4;
            this.fr.postRequest(_loc9_,_loc10_,this.diyBuyVerifyFn);
         }
         else
         {
            _loc10_["shopType"] = 10;
            _loc10_["itemType"] = param2;
            _loc10_["itemId"] = param1;
            _loc10_["itemNum"] = param7;
            this.fr.postRequest("cgi_farm_shop_verify",_loc10_,this.diyBuyVerifyFn);
         }
      }
      
      public function buyToolFn(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:Boolean = false;
         if(param1["code"] == 1)
         {
            MData.getInstance().farmData.reloadUserSeed = true;
            MData.getInstance().mainData.reloadUserMaterial = true;
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
               return;
            }
            if(param1["direction"] != undefined && StringUtil.trim(param1["direction"]) != "")
            {
               this.alertWindow("error",param1["direction"]);
               return;
            }
         }
      }
      
      private function qqBuyToolFn(param1:Object) : void
      {
         var _loc3_:String = null;
         var _loc2_:Object = {};
         if(param1["code"] == 0)
         {
            _loc2_["code"] = 1;
            _loc2_["direction"] = "购买成功";
            _loc2_["type"] = this.m_preBuyToolType;
            _loc2_["post_data"] = param1["post_data"];
            MData.getInstance().farmData.reloadUserSeed = true;
            if(param1["post_data"]["checkUpdateType"] == 5)
            {
               Command.getInstance().mainCommand.getCropStatus("0",false);
            }
            if(param1["post_data"]["type"] == 10 && param1["post_data"]["appid"] == "353")
            {
               _loc2_["direction"] = "购买成功+<br>驱赶武器放在扩展场景->武器背包中，<a href=\'event:gotoWild\'><font color=\'#ff6600\'>去查看。</font></a>";
            }
            EventRecorder.recordSueecssEvent("160946",0);
         }
         else
         {
            if(param1.hasOwnProperty("errorType"))
            {
               _loc3_ = param1["errorType"];
               if(_loc3_ == "IOError" || _loc3_ == "httpStatus" || _loc3_ == "timeOut")
               {
                  this.alertWindow("error","请求超时，稍后再试");
               }
            }
            else
            {
               _loc2_["code"] = param1["code"];
               _loc2_["direction"] = param1["msg"];
               _loc2_["dnaurl"] = param1["dnaurl"];
            }
            EventRecorder.recordErrorEvent("160946",0,14);
         }
         this.buyToolFn(_loc2_);
      }
      
      private function getTinsInfoFn(param1:Object) : void
      {
         var _loc3_:String = null;
         this.m_pending = false;
         if(param1.hasOwnProperty("errorType"))
         {
            EventRecorder.recordErrorEvent("160943",0,14);
            _loc3_ = param1["errorType"];
            if(_loc3_ == "IOError" || _loc3_ == "httpStatus" || _loc3_ == "timeOut")
            {
               this.m_tinsData.shopTinInfoErr = "请求超时，" + "<a href=\'event:reload\'><u><font color=\'#ff6600\'>点击重试</font></u></a>";
               return;
            }
         }
         EventRecorder.recordSueecssEvent("160943",0);
         var _loc2_:Array = param1 as Array;
         this.m_tinsData.addTinItems(_loc2_);
         this.m_tinsData.loadingData = false;
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
      
      public function buyTool(param1:int, param2:int, param3:int, param4:Boolean = false, param5:String = "", param6:int = 0, param7:BaseWindow = null) : void
      {
         var _loc8_:Object = null;
         var _loc9_:String = null;
         var _loc10_:Object = null;
         if(!param4)
         {
            if(param3 == 106)
            {
               _loc8_ = {
                  "id":param1,
                  "type":param3,
                  "number":param2
               };
               this.fr.postRequest("cgi_buy_guard",_loc8_,this.buyToolFn2);
            }
            if(param3 == 10 && param7.data["appid"] == "353")
            {
               this.fr.postRequest(INI.getInstance().getPostUrl() + "cgi_farm_buyweapon",{
                  "tId":param1,
                  "type":param3,
                  "number":param2
               },this.buyToolFn2);
            }
         }
         else
         {
            this.m_preBuyToolType = param3;
            _loc9_ = "";
            _loc9_ = INI.getInstance().data.postUrl.@fbRequest;
            _loc10_ = {};
            if(param7.data["appid"] == "353")
            {
               _loc10_["app_key"] = "happyfarm";
            }
            else
            {
               _loc10_["app_key"] = "QQMCZZ";
            }
            _loc10_["payitem"] = param3 * 10000 + param1 + "-" + param2 + "-" + param5;
            _loc10_["payvalue"] = 10 * param6 * param2;
            _loc10_["paytype"] = 0;
            _loc10_["accttype"] = 4;
            _loc10_["dnatime"] = 0;
            _loc10_["payinfo"] = param5;
            _loc10_["dnakey"] = 0;
            _loc10_["format"] = "JSON";
            _loc10_["appid"] = param7.data["appid"];
            _loc10_["checkUpdateType"] = param3;
            this.fr.postRequest(_loc9_,_loc10_,this.qqBuyToolFn);
         }
         this.m_targetWinddow = param7;
      }
   }
}

