package com.qzone.allianceActivity.framewrok.service.rpc
{
   import flash.net.URLRequestMethod;
   
   public class TextService implements IRemoteService
   {
      
      private var _operationParamNames:Object = {};
      
      private var _operationMethods:Object = {};
      
      private var _operationURLs:Object = {};
      
      public function TextService()
      {
         super();
      }
      
      public function getOperation(param1:String) : IRemoteOperation
      {
         var _loc2_:IRemoteOperation = new RemoteOperation();
         var _loc3_:TextLoader = this.getLoaderInstance() as TextLoader;
         var _loc4_:String = this._operationURLs[param1];
         var _loc5_:Array = this._operationParamNames[param1];
         var _loc6_:String = this._operationMethods[param1];
         _loc3_.method = _loc4_;
         _loc3_.paramNames = _loc5_;
         _loc3_.requestMethond = _loc6_;
         _loc2_.loader = _loc3_;
         return _loc2_;
      }
      
      public function addOperation(param1:String, param2:String, param3:Array = null, param4:String = "get") : void
      {
         this._operationURLs[param1] = param2;
         this._operationParamNames[param1] = param3;
         if(param4 == "post")
         {
            this._operationMethods[param1] = URLRequestMethod.POST;
         }
         else
         {
            this._operationMethods[param1] = URLRequestMethod.GET;
         }
      }
      
      public function getLoaderInstance() : IRemoteLoader
      {
         return new TextLoader();
      }
   }
}

