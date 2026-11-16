package mc.api
{
   import flash.display.DisplayObjectContainer;
   import flash.events.IEventDispatcher;
   
   public interface IAPIHelper
   {
      
      function reportReturnCode(param1:String, param2:String) : void;
      
      function registerNetCommand(param1:uint, param2:String) : void;
      
      function get messageCenter() : IEventDispatcher;
      
      function popMouseTip(param1:String) : void;
      
      function hideMouseTip() : void;
      
      function getDisableFilter() : Array;
      
      function hidePopUp(param1:DisplayObjectContainer) : void;
      
      function alert(param1:String, param2:String) : void;
      
      function sendRequest(param1:uint, param2:Object, param3:Function) : Boolean;
      
      function showPopUp(param1:DisplayObjectContainer) : void;
   }
}

