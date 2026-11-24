package com.qzone.allianceActivity.framewrok.service.rpc
{
   public interface IRemoteService
   {
      
      function getOperation(param1:String) : IRemoteOperation;
      
      function getLoaderInstance() : IRemoteLoader;
   }
}

