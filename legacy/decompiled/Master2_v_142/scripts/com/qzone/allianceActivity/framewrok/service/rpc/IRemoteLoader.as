package com.qzone.allianceActivity.framewrok.service.rpc
{
   public interface IRemoteLoader
   {
      
      function get method() : String;
      
      function addResponder(param1:Function, param2:Function = null) : void;
      
      function set method(param1:String) : void;
      
      function send(param1:Array = null) : void;
      
      function close() : void;
   }
}

