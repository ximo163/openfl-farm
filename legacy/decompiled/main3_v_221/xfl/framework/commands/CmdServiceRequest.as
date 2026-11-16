package framework.commands
{
   import com.qzone.qfa.core.Command;
   import com.qzone.qfa.debug.Debugger;
   import com.qzone.qfa.managers.events.RequestEvent;
   import common.Consts;
   import events.CommonEvent;
   import framework.net.CommandDefs;
   import framework.net.NetHelper;
   import framework.net.ServerServices;
   import framework.net.core.HttpConnectionPool;
   import framework.net.core.HttpOperationEx;
   import framework.net.core.RequestChecker;
   import framework.net.protocol.Protocol;
   import framework.net.vo.ServiceResultVO;
   import interfaces.IMsgCenter;
   
   public class CmdServiceRequest extends Command
   {
      
      private static var CLASS_NAME:String = Consts.CMD_NAME_REQUESTSERVICE;
      
      private var m_protocol:Protocol;
      
      private var m_request:HttpOperationEx;
      
      public function CmdServiceRequest()
      {
         super();
         this.m_protocol = null;
         this.m_request = null;
      }
      
      private function onRequestSuccess(param1:RequestEvent) : void
      {
         var _loc3_:IMsgCenter = null;
         if(param1.data == null)
         {
            Debugger.log("INFO: server return null");
            return;
         }
         RequestChecker.clean(this.m_request.url);
         var _loc2_:ServiceResultVO = null;
         if(this.m_protocol != null)
         {
            this.m_protocol.importResponseObject(param1.data);
            _loc2_ = ServerServices.getInstance().decodeResult(this.m_protocol);
            if(_loc2_ != null)
            {
               _loc3_ = NetHelper.theApp as IMsgCenter;
               if(_loc2_.m_result == "validateCode")
               {
                  _loc3_.dispatchEvent(new CommonEvent(Consts.MSG_NEED_VALIDATE_CODE,_loc2_.m_message));
               }
               else if(_loc2_.m_result == "session")
               {
                  _loc3_.dispatchEvent(new CommonEvent(Consts.MSG_SESSION_TIMEOUT,_loc2_.m_message));
               }
               else if(_loc2_.m_result != "")
               {
                  error(_loc2_);
               }
               else
               {
                  finish(_loc2_);
               }
            }
         }
         else
         {
            Debugger.log("ERROR: can not decode reponse with an empty protocol.");
         }
         this.destroy();
      }
      
      override public function execute(param1:* = null) : void
      {
         if(this.prepare() == false)
         {
            Debugger.log("ERROR: init request [" + super.body["cmdID"] + "] failed.");
            return;
         }
         if(this.m_request == null)
         {
            Debugger.log("ERROR: request [" + super.body["cmdID"] + "] is null.");
            return;
         }
         if(super.body != null && super.body["cmdID"] != undefined)
         {
            this.m_protocol = ServerServices.getInstance().encodeRequest(super.body["cmdID"],super.body["__body"]);
            if(this.m_protocol == null)
            {
               Debugger.log("ERROR: create protocol object [" + super.body["cmdID"] + "] failed.");
               return;
            }
            this.m_request.send(this.m_protocol.encodeForHttp(this.m_request.method));
         }
      }
      
      private function prepare() : Boolean
      {
         if(this.m_request != null)
         {
            return true;
         }
         if(super.body == null || super.body["cmdID"] == undefined)
         {
            return false;
         }
         var _loc1_:String = ServerServices.getInstance().getRequestUrl(super.body["cmdID"]);
         if(this.checkRequest(_loc1_) == false)
         {
            return false;
         }
         var _loc2_:String = Consts.NET_HTTP_METHOD_POST;
         if(super.body["__method"] != undefined)
         {
            _loc2_ = super.body["__method"];
         }
         this.m_request = HttpConnectionPool.getInstance().borrow();
         if(this.m_request != null)
         {
            this.m_request.method = _loc2_;
            this.m_request.url = _loc1_;
            this.m_request.addEventListener(RequestEvent.RESULT,this.onRequestSuccess,false,0,true);
            this.m_request.addEventListener(RequestEvent.FAULT,this.onRequestFailed,false,0,true);
            this.m_request.open();
            return true;
         }
         return false;
      }
      
      override public function destroy() : void
      {
         if(this.m_request != null)
         {
            this.m_request.removeEventListener(RequestEvent.RESULT,this.onRequestSuccess);
            this.m_request.removeEventListener(RequestEvent.FAULT,this.onRequestFailed);
            HttpConnectionPool.getInstance().free(this.m_request);
            this.m_request = null;
         }
         super.destroy();
      }
      
      private function checkRequest(param1:String) : Boolean
      {
         var _loc3_:Object = null;
         var _loc4_:IMsgCenter = null;
         if(param1 == null || param1.length == 0)
         {
            return false;
         }
         var _loc2_:String = param1;
         if(param1.indexOf("cgi_farm_index") != -1)
         {
            _loc3_ = null;
            if(super.body != null && super.body["__body"] != undefined)
            {
               _loc3_ = super.body["__body"];
            }
            if(_loc3_ != null && _loc3_["ownerId"] != undefined)
            {
               _loc2_ = _loc2_ + "&" + _loc3_["ownerId"];
            }
         }
         if(RequestChecker.checkRequest(_loc2_) == false)
         {
            _loc4_ = NetHelper.theApp as IMsgCenter;
            if(_loc4_ != null)
            {
               _loc4_.dispatchEvent(new CommonEvent(Consts.MSG_REQUEST_CHECK_ERROR,{
                  "cmdID":super.body["cmdID"],
                  "url":_loc2_
               }));
            }
            return false;
         }
         return true;
      }
      
      private function onRequestFailed(param1:RequestEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:ServiceResultVO = null;
         if(param1 == null)
         {
            return;
         }
         if(param1.data["errorType"] != undefined)
         {
            _loc2_ = param1.data["errorType"] as int;
            if(_loc2_ == CommandDefs.HTTP_ERR_IOERROR || _loc2_ == CommandDefs.HTTP_ERR_HTTPSTATUS || _loc2_ == CommandDefs.HTTP_ERR_TIMEOUT)
            {
               RequestChecker.addErrorRequest(this.m_request.url);
               _loc3_ = new ServiceResultVO();
               _loc3_.m_result = _loc2_.toString();
               _loc3_.m_extra = {"errorType":Consts.MSG_REQUEST_NET_CLIENT_ERROR};
               error(_loc3_);
            }
         }
         this.destroy();
      }
   }
}

