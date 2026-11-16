package com.qzone.farm.api.interfaces
{
   public interface IPluginProxy
   {
      
      function initialize(param1:Object) : Boolean;
      
      function get config() : Object;
      
      function executeCommand(param1:int, param2:Object) : Object;
   }
}

