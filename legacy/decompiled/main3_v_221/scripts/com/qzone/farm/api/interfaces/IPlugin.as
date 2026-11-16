package com.qzone.farm.api.interfaces
{
   import flash.display.Sprite;
   
   public interface IPlugin
   {
      
      function createMainUI(param1:Object) : Sprite;
      
      function executeCommand(param1:int, param2:Object) : Object;
      
      function load(param1:int, param2:IFarmAPI) : Boolean;
      
      function unload() : void;
   }
}

