package com.qzone.allianceActivity.framewrok.service.rpc
{
   public interface IResponder
   {
      
      function resultHandler(param1:*) : void;
      
      function faultHandler(param1:*) : void;
   }
}

