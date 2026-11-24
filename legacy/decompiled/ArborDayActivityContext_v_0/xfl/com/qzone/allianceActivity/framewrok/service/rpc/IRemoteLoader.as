package com.qzone.allianceActivity.framewrok.service.rpc
{
   public interface IRemoteLoader
   {
      
      function send(param1:Array = null) : void;
      
      function addResponder(param1:Function, param2:Function = null) : void;
      
      function get method() : String;
      
      function set method(param1:String) : void;
      
      function close() : void;
   }
}

