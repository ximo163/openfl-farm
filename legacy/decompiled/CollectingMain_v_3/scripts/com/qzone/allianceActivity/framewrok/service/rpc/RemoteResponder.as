package com.qzone.allianceActivity.framewrok.service.rpc
{
   import flash.net.Responder;
   
   public class RemoteResponder extends Responder implements IResponder
   {
      
      private var _loader:IRemoteLoader;
      
      private var _faultHandler:Function;
      
      private var _resultHandler:Function;
      
      public function RemoteResponder(param1:IRemoteLoader, param2:Function, param3:Function = null)
      {
         this._loader = param1;
         this._resultHandler = param2;
         this._faultHandler = param3;
         super(this._resultHandler,this._faultHandler);
      }
      
      public function faultHandler(param1:*) : void
      {
         var _loc2_:String = null;
         var _loc3_:Array = null;
         this._loader.close();
         if(this._faultHandler != null)
         {
            this._faultHandler(param1);
         }
         else
         {
            _loc2_ = "service error";
            if(param1.message)
            {
               _loc2_ = param1.message;
               _loc3_ = _loc2_.split(":");
               if(_loc3_[1])
               {
                  _loc2_ = _loc3_[1];
               }
               trace(_loc2_);
            }
         }
      }
      
      public function resultHandler(param1:*) : void
      {
         this._loader.close();
         this._resultHandler(param1);
      }
   }
}

