package mc.FBridge
{
   import com.minutes.net.HTTPRequest;
   import common.CommonData;
   import common.LocalData;
   import mc.control.Command;
   import mc.model.MData;
   import mc.model.MainData;
   
   public class FRequest
   {
      
      private static var instance:FRequest;
      
      public function FRequest()
      {
         super();
         if(instance != null)
         {
            throw new Error("实例化单例类出错-FRequest");
         }
      }
      
      public static function getInstance() : FRequest
      {
         if(instance == null)
         {
            instance = new FRequest();
         }
         return instance;
      }
      
      public function postRequest2(param1:String, param2:Object, param3:Function, param4:String = null) : void
      {
         this.request(param1,param2,param3,12000,false,"text",param4);
      }
      
      public function postRequest(param1:String, param2:Object, param3:Function, param4:String = null) : void
      {
         this.request(param1,param2,param3,60000,false,"text",param4);
      }
      
      public function get httpUrl() : String
      {
         return HTTPRequest.getInstance().httpUrl;
      }
      
      public function getRequest(param1:String, param2:Object, param3:Function, param4:int = 60000, param5:Boolean = false, param6:String = "text") : void
      {
         var url:String = param1;
         var value:Object = param2;
         var handlerFun:Function = param3;
         var timeout:int = param4;
         var reload:Boolean = param5;
         var dataFormat:String = param6;
         LocalData.lastRequestValue = value;
         LocalData.lastRequestUrl = url;
         LocalData.lastRequestHandle = handlerFun;
         LocalData.lastRequestFn = this.getRequest;
         if(Boolean(value) && Boolean(url.indexOf("?") != -1) && url.indexOf("?") != url.length - 1)
         {
            url += "&";
         }
         HTTPRequest.getInstance().getRequest(url,value,function(param1:Object):void
         {
            var _loc2_:Object = param1;
            if(_loc2_)
            {
               if(_loc2_.hasOwnProperty("errorType"))
               {
                  if(_loc2_["errorType"] == "validateCode")
                  {
                     Command.getInstance().mainCommand.showWin("validateCode");
                  }
                  else if(_loc2_["errorType"] == "session")
                  {
                     MData.getInstance().mainData.sessionTimeout = _loc2_["errorContent"];
                  }
               }
               handlerFun(_loc2_);
            }
            else
            {
               trace("数据为空!");
            }
         },timeout,reload,dataFormat);
      }
      
      public function set httpUrl(param1:String) : void
      {
         HTTPRequest.getInstance().httpUrl = param1;
      }
      
      private function request(param1:String, param2:Object, param3:Function, param4:int = 60000, param5:Boolean = false, param6:String = "text", param7:String = null) : void
      {
         var mainData:MainData;
         var farmKey:String;
         var farmTime:String;
         var _timeValue:int;
         var pastureKey:String;
         var rqManager:RequestManager = null;
         var errStr:String = null;
         var errData:Object = null;
         var url:String = param1;
         var value:Object = param2;
         var handlerFun:Function = param3;
         var timeout:int = param4;
         var reload:Boolean = param5;
         var dataFormat:String = param6;
         var act:String = param7;
         try
         {
            rqManager = RequestManager.getInstance();
            if(act)
            {
               if(act == RequestManager.ENTER)
               {
                  errStr = rqManager.checkAction(act,value["uId"]);
               }
               else
               {
                  errStr = rqManager.checkAction(act);
               }
               if(errStr)
               {
                  errData = {
                     "errorType":"system",
                     "errorContent":errStr,
                     "post_data":value
                  };
                  handlerFun(errData);
                  return;
               }
            }
         }
         catch(e:Error)
         {
         }
         LocalData.lastRequestValue = value;
         LocalData.lastRequestUrl = url;
         LocalData.lastRequestHandle = handlerFun;
         LocalData.lastRequestFn = this.postRequest;
         _timeValue = int(CommonData.serverTime);
         mainData = MData.getInstance().mainData;
         farmKey = CommonData.getKey();
         farmTime = String(_timeValue);
         pastureKey = MainData.getKey2();
         if(value)
         {
            value["farmTime"] = farmTime;
            value["farmKey"] = farmKey;
            value["pastureKey"] = pastureKey;
         }
         else
         {
            value = {
               "farmKey":farmKey,
               "farmTime":farmTime,
               "pastureKey":pastureKey
            };
         }
         value["uIdx"] = mainData.getHostId;
         HTTPRequest.getInstance().postRequest(url,value,function(param1:Object):void
         {
            var _loc2_:Object = param1;
            if(_loc2_)
            {
               if(_loc2_.hasOwnProperty("errorType"))
               {
                  if(_loc2_["errorType"] == "validateCode")
                  {
                     Command.getInstance().mainCommand.showWin("validateCode");
                  }
                  else if(_loc2_.hasOwnProperty("errorType") && _loc2_["errorType"] == "session")
                  {
                     MData.getInstance().mainData.sessionTimeout = _loc2_["errorContent"];
                  }
               }
               handlerFun(_loc2_);
            }
            else
            {
               trace("数据为空!");
            }
         },timeout,reload,dataFormat);
      }
   }
}

