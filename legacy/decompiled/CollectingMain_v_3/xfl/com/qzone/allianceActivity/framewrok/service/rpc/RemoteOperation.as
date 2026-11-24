package com.qzone.allianceActivity.framewrok.service.rpc
{
   public class RemoteOperation implements IRemoteOperation
   {
      
      private var _loader:IRemoteLoader;
      
      private var _args:Array;
      
      public function RemoteOperation()
      {
         super();
      }
      
      public function set loader(param1:IRemoteLoader) : void
      {
         this._loader = param1;
      }
      
      public function addResponder(param1:Function, param2:Function = null) : void
      {
         this._loader.addResponder(param1,param2);
      }
      
      public function get loader() : IRemoteLoader
      {
         return this._loader;
      }
      
      public function invoke(param1:Array = null) : IRemoteOperation
      {
         this.loader.send(param1);
         return this;
      }
   }
}

