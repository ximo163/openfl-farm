package com.minutes.net
{
   import cn.snowkit.utils.ObjectCopy;
   import com.adobe.serialization.json.JSON;
   import com.qzone.corelib.js.JSProxy;
   import flash.events.Event;
   import flash.events.HTTPStatusEvent;
   import flash.events.IOErrorEvent;
   import flash.events.TimerEvent;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   import flash.utils.ByteArray;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import mc.FBridge.DataURLLoader;
   
   public class HTTPRequest
   {
      
      private static var instance:HTTPRequest;
      
      public static var REQUEST_ERROR:String = "requestError";
      
      public static var OVER_TIME:String = "overTime";
      
      public static const IOERROR:String = "IOError";
      
      public static const HTTPSTATUS:String = "httpStatus";
      
      public static const TIMEOUT:String = "timeOut";
      
      private var _timer:Timer;
      
      private var _httpUrl:String = "";
      
      public function HTTPRequest()
      {
         super();
         if(instance != null)
         {
            throw new Error("实例化单例类出错-HTTPRequest");
         }
         this._timer = new Timer(1000);
         this._timer.start();
      }
      
      public static function getInstance() : HTTPRequest
      {
         if(instance == null)
         {
            instance = new HTTPRequest();
         }
         return instance;
      }
      
      public function set httpUrl(param1:String) : void
      {
         this._httpUrl = param1;
      }
      
      public function get httpUrl() : String
      {
         return this._httpUrl;
      }
      
      public function getRequest(param1:String, param2:Object, param3:Function, param4:uint = 60000, param5:Boolean = false, param6:String = "text") : void
      {
         this.request(URLRequestMethod.GET,param1,param2,param3,param4,param5,param6);
      }
      
      private function dataToString(param1:Object) : String
      {
         var _loc2_:ByteArray = null;
         var _loc3_:String = null;
         if(param1 is ByteArray)
         {
            _loc2_ = param1 as ByteArray;
            _loc2_.position = 0;
            return _loc2_.readUTFBytes(_loc2_.length);
         }
         return param1.toString();
      }
      
      private function decode(param1:Object) : Object
      {
         var _data:Object = null;
         var loadStr:String = null;
         var data:Object = param1;
         try
         {
            loadStr = this.dataToString(data);
            if(/^[\{\[].*/.test(loadStr) == false)
            {
               loadStr = "{\"errorType\":\"PHPError\",\"errorContent\":\"" + loadStr + "\"}";
            }
            _data = com.adobe.serialization.json.JSON.decode(loadStr);
            return _data;
         }
         catch(e:Error)
         {
            trace("JSON解码错误:" + e + "\n" + loadStr);
         }
         return null;
      }
      
      public function postRequest(param1:String, param2:Object, param3:Function, param4:uint = 60000, param5:Boolean = false, param6:String = "text") : void
      {
         this.request(URLRequestMethod.POST,param1,param2,param3,param4,param5,param6);
      }
      
      private function request(param1:String, param2:String, param3:Object, param4:Function, param5:uint = 60000, param6:Boolean = false, param7:String = "text") : void
      {
         var tk:String;
         var _postData:Object = null;
         var isHandler:Boolean = false;
         var aURLRequest:URLRequest = null;
         var aURLLoader:DataURLLoader = null;
         var ioerrorHandler:Function = null;
         var httpStatusHandler:Function = null;
         var loadCompHandler:Function = null;
         var timerFn:Function = null;
         var timerValue:int = 0;
         var requestNum:int = 0;
         var _uv:URLVariables = null;
         var _name:String = null;
         var tmp:String = null;
         var k:String = null;
         var method:String = param1;
         var url:String = param2;
         var value:Object = param3;
         var handlerFun:Function = param4;
         var timeout:uint = param5;
         var reload:Boolean = param6;
         var dataFormat:String = param7;
         var clearAll:Function = function():void
         {
            aURLLoader.close();
            aURLLoader.postData = null;
            _timer.removeEventListener(TimerEvent.TIMER,timerFn);
            aURLLoader.removeEventListener(IOErrorEvent.IO_ERROR,ioerrorHandler);
            aURLLoader.removeEventListener(HTTPStatusEvent.HTTP_STATUS,httpStatusHandler);
            aURLLoader.removeEventListener(Event.COMPLETE,loadCompHandler);
         };
         ioerrorHandler = function(param1:IOErrorEvent):void
         {
            var _loc2_:Object = null;
            if(!isHandler)
            {
               _loc2_ = {
                  "errorType":"IOError",
                  "errorContent":""
               };
               _loc2_["post_data"] = ObjectCopy.copy((param1.target as DataURLLoader).postData);
               handlerFun(_loc2_);
               isHandler = true;
            }
            clearAll();
         };
         httpStatusHandler = function(param1:HTTPStatusEvent):void
         {
            var _loc2_:Object = null;
            if(param1.status != 0 && param1.status != 200)
            {
               if(!isHandler)
               {
                  _loc2_ = {
                     "errorType":"httpStatus",
                     "errorContent":param1.status
                  };
                  _loc2_["post_data"] = ObjectCopy.copy((param1.target as DataURLLoader).postData);
                  handlerFun(_loc2_);
                  isHandler = true;
               }
            }
         };
         loadCompHandler = function(param1:Event):void
         {
            var _loc2_:Object = null;
            if(!isHandler)
            {
               _loc2_ = decode(param1.currentTarget.data);
               if(_loc2_)
               {
                  _loc2_["post_data"] = ObjectCopy.copy((param1.target as DataURLLoader).postData);
               }
               handlerFun(_loc2_);
               isHandler = true;
            }
            clearAll();
         };
         timerFn = function(param1:TimerEvent):void
         {
            var _loc2_:Object = null;
            if(reload)
            {
               _loc2_ = null;
               if(getTimer() - timerValue > timeout && requestNum == 0)
               {
                  aURLLoader.load(aURLRequest);
                  timerValue = getTimer();
                  requestNum = 1;
               }
               else if(getTimer() - timerValue > timeout && requestNum == 1)
               {
                  if(!isHandler)
                  {
                     _loc2_ = {
                        "errorType":"timeOut",
                        "content":""
                     };
                     _loc2_["post_data"] = ObjectCopy.copy(aURLLoader.postData);
                     handlerFun(_loc2_);
                     isHandler = true;
                  }
                  clearAll();
               }
            }
            else if(getTimer() - timerValue > timeout)
            {
               if(!isHandler)
               {
                  _loc2_ = {
                     "errorType":"timeOut",
                     "content":""
                  };
                  _loc2_["post_data"] = ObjectCopy.copy(aURLLoader.postData);
                  handlerFun(_loc2_);
                  isHandler = true;
               }
               clearAll();
            }
         };
         var completeUrl:String = "";
         if(/^http.*/.test(url))
         {
            completeUrl = url;
         }
         else
         {
            completeUrl = this.httpUrl + url;
         }
         tk = JSProxy.addGToken(completeUrl);
         if(tk != null && tk != "")
         {
            completeUrl = tk;
         }
         if(value is String)
         {
            _postData = value;
         }
         else if(value is URLVariables)
         {
            _postData = value;
         }
         else
         {
            _uv = new URLVariables();
            for(_name in value)
            {
               _uv[_name] = value[_name];
            }
            _postData = _uv;
         }
         isHandler = false;
         aURLRequest = new URLRequest(completeUrl);
         aURLRequest.method = method;
         aURLRequest.data = _postData;
         aURLLoader = new DataURLLoader();
         aURLLoader.dataFormat = dataFormat;
         aURLLoader.postData = _postData;
         if(method.toLowerCase() == "get" && completeUrl != null)
         {
            tmp = completeUrl;
            if(tmp.charAt(tmp.length - 1) != "&")
            {
               tmp += "&";
            }
            for(k in _postData)
            {
               if(k != "" && k != null)
               {
                  tmp += k + "=" + _postData[k] + "&";
               }
            }
            aURLRequest.url = tmp;
            aURLRequest.data = null;
         }
         aURLLoader.addEventListener(IOErrorEvent.IO_ERROR,ioerrorHandler);
         aURLLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS,httpStatusHandler);
         aURLLoader.addEventListener(Event.COMPLETE,loadCompHandler);
         aURLLoader.load(aURLRequest);
         timerValue = getTimer();
         requestNum = 0;
         this._timer.addEventListener(TimerEvent.TIMER,timerFn);
      }
   }
}

