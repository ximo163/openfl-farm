package framework.net
{
   import com.qzone.qfa.control.Application;
   import com.qzone.qfa.events.CommandEvent;
   import common.Consts;
   import common.misc.Utils;
   import flash.net.URLVariables;
   import framework.commands.CommandList;
   import framework.net.vo.ServiceResultVO;
   
   public final class NetHelper
   {
      
      public static var theApp:Application;
      
      private static var STATE:Object;
      
      public function NetHelper()
      {
         super();
      }
      
      public static function reSendRequest(param1:Object) : void
      {
         var _loc3_:* = undefined;
         if(STATE == null)
         {
            return;
         }
         var _loc2_:* = STATE["arg"];
         if(_loc2_ != undefined && _loc2_ != null)
         {
            for(_loc3_ in param1)
            {
               _loc2_[_loc3_] = param1[_loc3_];
            }
         }
         else
         {
            _loc2_ = param1;
         }
         sendRequest(STATE["cmd"],STATE["arg"],STATE["success"],STATE["fail"]);
      }
      
      public static function sendRequest(param1:int, param2:Object, param3:Function, param4:Function = null) : void
      {
         if(theApp == null)
         {
            return;
         }
         STATE = {
            "cmd":param1,
            "arg":param2,
            "success":param3,
            "fail":param4
         };
         var _loc5_:Object = Utils.buildRequest(param1,param2);
         theApp.run(CommandList.SERVICE_REQUEST,_loc5_,"",null,param3,param4);
      }
      
      public static function getRequest(param1:int, param2:URLVariables, param3:Function, param4:Function = null) : void
      {
         if(theApp == null)
         {
            return;
         }
         STATE = {
            "cmd":param1,
            "arg":param2,
            "success":param3,
            "fail":param4
         };
         var _loc5_:Object = Utils.buildRequest(param1,param2,Consts.NET_HTTP_METHOD_GET);
         theApp.run(CommandList.SERVICE_REQUEST,_loc5_,"",null,param3,param4);
      }
      
      public static function getVOData(param1:CommandEvent) : Object
      {
         if(param1 == null || param1.result == null)
         {
            return null;
         }
         var _loc2_:ServiceResultVO = param1.result as ServiceResultVO;
         if(_loc2_ == null)
         {
            if(param1.result is Array)
            {
               return param1.result;
            }
            return null;
         }
         return _loc2_.m_extra;
      }
   }
}

