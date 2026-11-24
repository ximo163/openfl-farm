package com.qzone.allianceActivity.framewrok.service.rpc
{
   public interface IRemoteOperation
   {
      
      function invoke(param1:Array = null) : IRemoteOperation;
      
      function addResponder(param1:Function, param2:Function = null) : void;
      
      function get loader() : IRemoteLoader;
      
      function set loader(param1:IRemoteLoader) : void;
   }
}

