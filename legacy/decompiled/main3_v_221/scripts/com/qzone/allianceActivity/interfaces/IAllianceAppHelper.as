package com.qzone.allianceActivity.interfaces
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   
   public interface IAllianceAppHelper
   {
      
      function payActivityByPlatform(param1:int, param2:int, param3:int, param4:int, param5:Function) : void;
      
      function getItemIcon(param1:int, param2:int) : DisplayObject;
      
      function popupWindow(param1:DisplayObject) : Boolean;
      
      function execute(param1:String, param2:Object = null) : Object;
      
      function removePopup(param1:DisplayObject) : Boolean;
      
      function acceptRewards(param1:Array) : void;
      
      function addIconEntrance(param1:DisplayObject) : void;
      
      function get loginUin() : String;
      
      function showLoadingState() : void;
      
      function showTips(param1:DisplayObject, param2:String) : void;
      
      function addNpcEntrance(param1:String, param2:String, param3:int, param4:int, param5:String, param6:String) : Sprite;
      
      function hideLoadingState() : void;
      
      function debugLog(param1:String) : void;
      
      function hideTips(param1:DisplayObject) : void;
      
      function alert(param1:String) : void;
      
      function showBubbleMessage(param1:String) : void;
   }
}

