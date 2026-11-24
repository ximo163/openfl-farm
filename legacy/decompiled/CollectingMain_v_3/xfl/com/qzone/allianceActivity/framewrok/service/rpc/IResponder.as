package com.qzone.allianceActivity.framewrok.service.rpc
{
   public interface IResponder
   {
      
      function faultHandler(param1:*) : void;
      
      function resultHandler(param1:*) : void;
   }
}

