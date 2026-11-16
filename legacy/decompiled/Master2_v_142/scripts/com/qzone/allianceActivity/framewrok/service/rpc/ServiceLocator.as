package com.qzone.allianceActivity.framewrok.service.rpc
{
   public class ServiceLocator implements IServiceLocator
   {
      
      protected var _services:Object = {};
      
      public function ServiceLocator()
      {
         super();
      }
      
      public function addTextService(param1:String, param2:TextService) : void
      {
         this._services[param1] = param2;
      }
      
      public function removeService(param1:String) : void
      {
         this._services[param1] = null;
         delete this._services[param1];
      }
      
      public function getService(param1:String) : IRemoteService
      {
         return this._services[param1];
      }
   }
}

