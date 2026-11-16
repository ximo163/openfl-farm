package com.qzone.farm.api.interfaces
{
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import interfaces.ILogicParser;
   import interfaces.IMsgCenter;
   
   public interface IFarmAPI
   {
      
      function confirm(param1:String, param2:String, param3:String, param4:int, param5:int, param6:Boolean, param7:Boolean, param8:Function) : void;
      
      function requestClass(param1:String, param2:Function, param3:String = null, param4:Object = null) : void;
      
      function get messageCenter() : IMsgCenter;
      
      function sendRequest(param1:uint, param2:Object, param3:Function, param4:Function) : Boolean;
      
      function showStrongGuide(param1:Sprite, param2:int, param3:int, param4:String, param5:int = 5, param6:Boolean = false) : void;
      
      function reportReturnCode(param1:String, param2:String) : void;
      
      function hidePopUp(param1:DisplayObjectContainer) : void;
      
      function createWindow(param1:String, param2:DisplayObjectContainer, param3:Function, param4:Object) : Boolean;
      
      function showWindow(param1:String, param2:Boolean) : void;
      
      function popMouseTip(param1:String) : void;
      
      function showPopUp(param1:DisplayObjectContainer, param2:Boolean) : void;
      
      function popFloatTip(param1:int, param2:String, param3:DisplayObjectContainer = null) : void;
      
      function registerNetCommand(param1:uint, param2:String, param3:ILogicParser) : void;
      
      function payByPlatform(param1:int, param2:int, param3:int, param4:int, param5:Function) : Boolean;
      
      function useSystemCursor(param1:Boolean) : void;
      
      function executeCommand(param1:int, param2:int, param3:Object) : Object;
      
      function hideMouseTip() : void;
      
      function reportSuccessError(param1:String, param2:*, param3:int = -1, param4:String = null) : void;
      
      function alert(param1:int, param2:String, param3:String, param4:int, param5:int, param6:Function) : void;
   }
}

