package com.qzone.allianceActivity.framewrok.service.rpc
{
   public interface IServiceLocator
   {
      
      function removeService(param1:String) : void;
      
      function getService(param1:String) : IRemoteService;
   }
}

